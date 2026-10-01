package com.example.translation_poc_app.capture

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.Image
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.SystemClock
import android.util.Log
import android.view.WindowManager
import com.example.translation_poc_app.autotranslate.FrameSignature
import com.example.translation_poc_app.data.settings.NormalizedRegion
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.withTimeoutOrNull

/** 캡처 결과 (NA-05). */
sealed interface CaptureResult {
    /** 화면 한 장. 다 쓴 뒤 [Bitmap.recycle]은 받은 쪽이 한다. */
    data class Frame(val bitmap: Bitmap) : CaptureResult

    /** 전부 검은 화면. 보안 화면(FLAG_SECURE, 은행 · OTT 등)일 가능성이 높다. */
    data object Blank : CaptureResult

    data class Failed(val reason: String) : CaptureResult
}

/**
 * MediaProjection 세션 하나에서 화면을 한 장씩 찍는다 (NA-05, D-019).
 *
 * - 미러링 VirtualDisplay는 화면이 바뀔 때만 프레임을 보낸다. 그래서 들어오는 프레임 중 **가장 최근 것 하나를
 *   계속 들고 있다가**, 요청이 오면 그것을 Bitmap으로 바꾼다. 화면이 멈춰 있어도 바로 찍힌다.
 * - 회전 · 해상도 변경:
 *   - Android 14+: 토큰 하나로 VirtualDisplay를 한 번만 만들 수 있다. 시스템이 알려 주는
 *     `onCapturedContentResize`에서만 [resize]로 크기를 바꾼다.
 *   - Android 13 이하: 미러링 화면의 resize는 이전 비율이 남아 어긋난다. 설정이 바뀌면 [onDisplayChanged]가
 *     VirtualDisplay를 새 크기로 다시 만든다.
 */
class ScreenCapturer(
    private val context: Context,
    private val projection: MediaProjection,
) {
    private val thread = HandlerThread("ScreenCapturer").apply { start() }
    private val handler = Handler(thread.looper)
    private val lock = Any()

    private var width = 0
    private var height = 0
    private var densityDpi = 0
    private var reader: ImageReader? = null
    private var display: VirtualDisplay? = null

    /** 가장 최근 프레임. [lock]으로 보호한다. 새 프레임이 오면 이전 것은 닫는다. */
    private var latest: Image? = null

    /** [latest]가 들어온 시각 (진단 로그용, #25). [lock]으로 보호한다. */
    private var latestAt = 0L
    private var firstFrame = CompletableDeferred<Unit>()

    /** [awaitFreshFrame]가 기다리는 다음 프레임. [lock]으로 보호한다. */
    private var nextFrame: CompletableDeferred<Unit>? = null

    /** 세션 시작 때 한 번 부른다. */
    fun start() {
        readScreenSize()
        reader = newReader()
        display = createDisplay() ?: error("VirtualDisplay를 만들지 못함")
    }

    /** Android 14+: 시스템이 알려 준 캡처 대상 크기로 바꾼다 (VirtualDisplay는 유지). */
    fun resize(newWidth: Int, newHeight: Int) {
        if (newWidth <= 0 || newHeight <= 0) return
        if (newWidth == width && newHeight == height) return
        width = newWidth
        height = newHeight
        swapReader()
        display?.resize(width, height, densityDpi)
        display?.surface = reader!!.surface
    }

    /** 설정(회전 등)이 바뀌었을 때. Android 13 이하에서만 VirtualDisplay를 새 크기로 다시 만든다. */
    fun onDisplayChanged() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return
        val oldWidth = width
        val oldHeight = height
        readScreenSize()
        if (width == oldWidth && height == oldHeight) return
        display?.release()
        swapReader()
        display = createDisplay()
    }

    /** 가장 최근 화면 한 장. 세션을 막 시작해 아직 프레임이 없으면 [timeoutMs]까지 기다린다. */
    suspend fun capture(timeoutMs: Long = 1_000): CaptureResult {
        if (reader == null) return CaptureResult.Failed("캡처가 시작되지 않음")
        withTimeoutOrNull(timeoutMs) { firstFrame.await() }
            ?: return CaptureResult.Failed("프레임을 받지 못함")

        var frameAgeMs = 0L
        val bitmap = try {
            synchronized(lock) {
                frameAgeMs = SystemClock.elapsedRealtime() - latestAt
                latest?.toBitmap()
            }
        } catch (e: Exception) {
            Log.e(TAG, "프레임 변환 실패", e)
            return CaptureResult.Failed(e.message ?: "변환 실패")
        } ?: return CaptureResult.Failed("프레임을 받지 못함")

        // 진단: 오래된 프레임이면(화면이 안 바뀌어 새 프레임이 없었던 것) 나이가 크게 나온다.
        Log.i(TAG, "프레임 ${bitmap.width}x${bitmap.height} 나이=${frameAgeMs}ms ${FrameStats.of(bitmap)}")
        if (bitmap.isBlank()) {
            bitmap.recycle()
            return CaptureResult.Blank
        }
        return CaptureResult.Frame(bitmap)
    }

    /**
     * 가장 최근 프레임의 격자 밝기 표본 ([FrameSignature.COLS]×[FrameSignature.ROWS]). 자동 번역(#23)이 화면이 바뀌었는지
     * 볼 때 쓴다. 비트맵으로 바꾸지 않고 버퍼에서 칸마다 한 픽셀만 읽어 가볍다. [region]이 있으면 그 영역만.
     * 프레임이 아직 없으면 null.
     */
    fun captureSignature(region: NormalizedRegion? = null): IntArray? = synchronized(lock) {
        val image = latest ?: return null
        val plane = image.planes[0]
        val buffer = plane.buffer
        val rect = (region ?: FULL).toPixels(image.width, image.height)
        val out = IntArray(FrameSignature.COLS * FrameSignature.ROWS)
        for (row in 0 until FrameSignature.ROWS) {
            val y = rect.top + (rect.height * (2 * row + 1)) / (2 * FrameSignature.ROWS)
            val rowStart = y * plane.rowStride
            for (col in 0 until FrameSignature.COLS) {
                val x = rect.left + (rect.width * (2 * col + 1)) / (2 * FrameSignature.COLS)
                val i = rowStart + x * plane.pixelStride
                out[row * FrameSignature.COLS + col] = FrameSignature.luma(
                    buffer.get(i).toInt() and 0xFF,
                    buffer.get(i + 1).toInt() and 0xFF,
                    buffer.get(i + 2).toInt() and 0xFF,
                )
            }
        }
        out
    }

    /**
     * 화면이 바뀐 뒤(오버레이를 숨긴 뒤 등)의 프레임이 들어올 때까지 기다린다 (NA-18).
     * 멈춘 화면은 숨긴 변화로 프레임이 하나만 오고, 움직이는 화면은 이미 그리고 있던 프레임이 먼저 올 수 있어
     * 하나를 받은 뒤 [settleMs] 안에 오는 프레임을 하나 더 받는다. 오지 않으면 그대로 넘어간다.
     */
    suspend fun awaitFreshFrame(timeoutMs: Long = 200, settleMs: Long = 50) {
        if (awaitNextFrame(timeoutMs)) awaitNextFrame(settleMs)
    }

    private suspend fun awaitNextFrame(timeoutMs: Long): Boolean {
        val deferred = CompletableDeferred<Unit>()
        synchronized(lock) { nextFrame = deferred }
        return withTimeoutOrNull(timeoutMs) { deferred.await() } != null
    }

    fun release() {
        display?.release()
        display = null
        synchronized(lock) {
            latest?.close()
            latest = null
        }
        reader?.close()
        reader = null
        thread.quitSafely()
    }

    private fun createDisplay(): VirtualDisplay? = projection.createVirtualDisplay(
        "translator-capture",
        width,
        height,
        densityDpi,
        DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
        reader!!.surface,
        null,
        handler,
    )

    /** 받는 곳을 새 크기로 바꾼다. 이전 크기의 프레임은 버리고 새 첫 프레임을 기다린다. */
    private fun swapReader() {
        val old = reader
        synchronized(lock) {
            latest?.close()
            latest = null
            firstFrame = CompletableDeferred()
        }
        reader = newReader()
        old?.setOnImageAvailableListener(null, null)
        old?.close()
    }

    // 하나는 우리가 들고(latest), 하나는 시스템이 채운다. 새 프레임이 오면 바꿔 든다.
    @SuppressLint("WrongConstant")
    private fun newReader(): ImageReader =
        ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2).apply {
            setOnImageAvailableListener({ r ->
                val image = try {
                    r.acquireLatestImage()
                } catch (e: IllegalStateException) {
                    // 들고 있는 프레임 때문에 버퍼가 없으면, 들고 있던 것을 놓고 다시 받는다.
                    synchronized(lock) {
                        latest?.close()
                        latest = null
                    }
                    r.acquireLatestImage()
                } ?: return@setOnImageAvailableListener
                synchronized(lock) {
                    latest?.close()
                    latest = image
                    latestAt = SystemClock.elapsedRealtime()
                    nextFrame?.complete(Unit)
                    nextFrame = null
                }
                firstFrame.complete(Unit)
            }, handler)
        }

    private fun readScreenSize() {
        val bounds = context.getSystemService(WindowManager::class.java).maximumWindowMetrics.bounds
        width = bounds.width()
        height = bounds.height()
        densityDpi = context.resources.displayMetrics.densityDpi
    }

    companion object {
        private const val TAG = "ScreenCapturer"
        private val FULL = NormalizedRegion(0f, 0f, 1f, 1f)
    }
}

/** RGBA_8888 Image → Bitmap. 줄 끝 여백(rowStride 패딩)을 잘라낸다. */
internal fun Image.toBitmap(): Bitmap {
    val plane = planes[0]
    val pixelStride = plane.pixelStride
    val rowPadding = plane.rowStride - pixelStride * width
    val padded = Bitmap.createBitmap(
        width + rowPadding / pixelStride,
        height,
        Bitmap.Config.ARGB_8888,
    )
    plane.buffer.rewind()
    padded.copyPixelsFromBuffer(plane.buffer)
    if (rowPadding == 0) return padded
    return Bitmap.createBitmap(padded, 0, 0, width, height).also { padded.recycle() }
}

/**
 * 격자 표본으로 "전부 검은 화면"인지 본다. 보안 화면은 캡처가 검게 나온다.
 * 어두운 앱 화면과 헷갈리지 않도록 거의 완전한 검정(밝기 ≤ 8)만 검은 것으로 본다.
 */
internal fun Bitmap.isBlank(samples: Int = 24): Boolean {
    for (i in 0 until samples) {
        for (j in 0 until samples) {
            val x = (width - 1) * i / (samples - 1)
            val y = (height - 1) * j / (samples - 1)
            val p = getPixel(x, y)
            val r = (p shr 16) and 0xFF
            val g = (p shr 8) and 0xFF
            val b = p and 0xFF
            if (r > 8 || g > 8 || b > 8) return false
        }
    }
    return true
}
