package com.example.translation_poc_app.service

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.ServiceInfo
import android.content.res.Configuration
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.ServiceCompat
import androidx.core.content.IntentCompat
import androidx.lifecycle.LifecycleService
import androidx.lifecycle.lifecycleScope
import com.example.translation_poc_app.capture.CaptureResult
import com.example.translation_poc_app.capture.ScreenCapturer
import com.example.translation_poc_app.ocr.OcrResult
import com.example.translation_poc_app.ocr.ScreenTextRecognizer
import com.example.translation_poc_app.AppGraph
import com.example.translation_poc_app.overlay.OverlayController
import com.example.translation_poc_app.translate.DetectedBlock
import com.example.translation_poc_app.translate.LanguageDetector
import com.example.translation_poc_app.translate.MlKitTranslationEngine
import com.example.translation_poc_app.translate.TranslationEngine
import com.example.translation_poc_app.translate.TranslationPipeline
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

/**
 * 번역 포그라운드 서비스 (NA-02). Flutter 엔진 없이 독립적으로 돈다.
 * 화면 캡처 동의 결과로만 시작하며([CaptureConsentActivity]), MediaProjection 세션을 가진다.
 * 캡처(NA-05) · 오버레이(NA-18, NA-19)는 이 서비스 안에 붙인다.
 */
class TranslatorService : LifecycleService() {

    private var projection: MediaProjection? = null
    private var capturer: ScreenCapturer? = null
    private val textRecognizer by lazy { ScreenTextRecognizer() }
    private val languageDetector by lazy { LanguageDetector() }
    private var overlay: OverlayController? = null
    private var mlKitEngine: MlKitTranslationEngine? = null

    /** 플로팅 버튼 한 번 = 캡처 → 문자 인식 → 언어 감지 → 번역 (NA-18 → NA-19). */
    private val pipeline by lazy {
        TranslationPipeline(
            capture = {
                // 버튼을 숨긴 뒤의 화면을 찍는다.
                capturer?.awaitFreshFrame()
                captureFrame()
            },
            recognize = { frame -> recognizeText(frame) },
            detect = { ocr, target -> languageDetector.detect(ocr.blocks, target) },
            engineFor = { translationEngine() },
            settings = { AppGraph.settingsRepository(this).current() },
            onTimings = { Log.i(TAG, "번역 시간 $it total=${it.total}ms") },
        )
    }

    private val projectionCallback = object : MediaProjection.Callback() {
        // 사용자가 시스템 UI(상태 표시줄 칩 등)에서 공유를 끄면 서비스도 멈춘다 (NA-04).
        override fun onStop() {
            stopSelf()
        }

        // 캡처 대상 크기가 바뀌면(회전 등, Android 14+) 캡처 크기도 맞춘다.
        override fun onCapturedContentResize(width: Int, height: Int) {
            capturer?.resize(width, height)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        when (intent?.action) {
            ACTION_START -> handleStart(intent)
            ACTION_STOP -> stopSelf()
            ACTION_DEBUG_CAPTURE -> debugCapture()
            // 시스템이 다시 살린 경우(동의 토큰 없음)는 이어갈 수 없으니 멈춘다.
            else -> stopSelf()
        }
        // 동의 토큰은 한 번만 쓸 수 있어 재시작해도 이어갈 수 없다.
        return START_NOT_STICKY
    }

    private fun handleStart(intent: Intent) {
        val resultCode = intent.getIntExtra(EXTRA_RESULT_CODE, Activity.RESULT_CANCELED)
        val data = IntentCompat.getParcelableExtra(intent, EXTRA_DATA, Intent::class.java)
        if (data == null) {
            fail("캡처 동의 데이터 없음")
            return
        }

        ServiceNotification.ensureChannel(this)
        // mediaProjection 유형으로 먼저 포그라운드가 된 뒤에 MediaProjection을 얻어야 한다 (Android 14+).
        try {
            ServiceCompat.startForeground(
                this,
                ServiceNotification.ID,
                ServiceNotification.build(this),
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
                } else {
                    0
                },
            )
        } catch (e: Exception) {
            fail("포그라운드 시작 실패", e)
            return
        }

        val manager = getSystemService(MediaProjectionManager::class.java)
        projection?.unregisterCallback(projectionCallback)
        projection?.stop()
        projection = manager.getMediaProjection(resultCode, data)?.also {
            it.registerCallback(projectionCallback, Handler(Looper.getMainLooper()))
        }
        if (projection == null) {
            fail("MediaProjection을 얻지 못함")
            return
        }

        // 토큰 하나로 VirtualDisplay는 한 번만 만들 수 있어 세션 동안 유지한다 (NA-05).
        capturer?.release()
        capturer = try {
            ScreenCapturer(this, projection!!).also { it.start() }
        } catch (e: Exception) {
            fail("캡처 시작 실패", e)
            return
        }

        TranslatorServiceState.update(RunState.RUNNING)
        showOverlay()
        warmUp()
    }

    /**
     * 번역 엔진 (NA-11). 지금은 ML Kit(NA-12)뿐이라 설정의 엔진과 상관없이 ML Kit을 쓴다.
     * AI 엔진(NA-13 · NA-14)이 생기면 설정으로 고르고, 실패하면 ML Kit으로 대체한다.
     */
    private fun translationEngine(): TranslationEngine =
        mlKitEngine ?: MlKitTranslationEngine().also { mlKitEngine = it }

    /** 첫 번역이 느리지 않도록 문자 인식기를 미리 불러 둔다 (#11). 실패해도 번역 때 다시 시도한다. */
    private fun warmUp() {
        lifecycleScope.launch(Dispatchers.Default) {
            try {
                textRecognizer.warmUp()
            } catch (e: Exception) {
                Log.w(TAG, "인식기 예열 실패", e)
            }
        }
    }

    /** 플로팅 버튼을 띄운다 (NA-18). 권한이 없으면 띄우지 않고 서비스만 돈다. */
    private fun showOverlay() {
        overlay?.destroy()
        overlay = OverlayController(
            context = this,
            scope = lifecycleScope,
            settingsRepository = AppGraph.settingsRepository(this),
            pipeline = pipeline,
            sampleSignature = { region -> capturer?.captureSignature(region) },
            onStopRequested = { stopSelf() },
        ).takeIf { it.show() }
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        capturer?.onDisplayChanged()
        overlay?.onConfigurationChanged()
    }

    /**
     * 화면 한 장을 찍는다 (NA-05). 플로팅 버튼(NA-18)은 [pipeline]으로 부르며,
     * 찍기 전에 버튼을 숨기고 찍은 뒤 다시 보여 번역 대상에 섞이지 않게 한다.
     */
    suspend fun captureFrame(): CaptureResult =
        capturer?.capture() ?: CaptureResult.Failed("서비스가 실행 중이 아님")

    /** 캡처한 화면에서 글자를 읽는다 (NA-09). [sourceLanguage] null = 자동. */
    suspend fun recognizeText(frame: CaptureResult.Frame, sourceLanguage: String? = null): OcrResult =
        textRecognizer.recognize(frame.bitmap, sourceLanguage)

    /** 블록별 원문 언어를 감지해 번역할지 정한다 (NA-10). 대상 언어는 저장된 설정(NA-16)을 쓴다. */
    suspend fun detectLanguages(ocr: OcrResult): List<DetectedBlock> {
        val target = AppGraph.settingsRepository(this).current().targetLanguage
        return languageDetector.detect(ocr.blocks, target)
    }

    /** 디버그 빌드 전용: 알림의 "캡처 테스트"로 한 장 찍어 앱 캐시에 저장하고 결과를 로그로 남긴다. */
    private fun debugCapture() {
        if (!isDebuggable()) return
        lifecycleScope.launch {
            // 알림 창이 닫히는 애니메이션이 찍히지 않도록 잠시 기다린다.
            delay(1_000)
            when (val result = captureFrame()) {
                is CaptureResult.Frame -> {
                    val file = File(cacheDir, "debug_capture.png")
                    withContext(Dispatchers.IO) {
                        file.outputStream().use {
                            result.bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, it)
                        }
                    }
                    Log.i(TAG, "캡처 성공 ${result.bitmap.width}x${result.bitmap.height} → ${file.absolutePath}")
                    val started = System.currentTimeMillis()
                    val ocr = recognizeText(result)
                    Log.i(
                        TAG,
                        "문자 인식 ${ocr.script} 블록 ${ocr.blocks.size}개, ${System.currentTimeMillis() - started}ms: " +
                            ocr.blocks.take(5).joinToString(" | ") { "${it.language}:${it.text.replace('\n', ' ')}" },
                    )
                    val detected = detectLanguages(ocr)
                    Log.i(
                        TAG,
                        "언어 감지: " + detected.groupBy { it.decision.action }
                            .map { (action, blocks) -> "$action ${blocks.size}개(${blocks.map { it.decision.language }.distinct().joinToString(",")})" }
                            .joinToString(" / "),
                    )
                    result.bitmap.recycle()
                }
                CaptureResult.Blank -> Log.i(TAG, "캡처 결과: 검은 화면 (보안 화면일 수 있음)")
                is CaptureResult.Failed -> Log.w(TAG, "캡처 실패: ${result.reason}")
            }
        }
    }

    private fun fail(reason: String, error: Throwable? = null) {
        Log.e(TAG, reason, error)
        TranslatorServiceState.update(RunState.ERROR)
        stopForegroundCompat()
        stopSelf()
    }

    private fun stopForegroundCompat() {
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
    }

    override fun onDestroy() {
        overlay?.destroy()
        overlay = null
        mlKitEngine?.close()
        mlKitEngine = null
        textRecognizer.close()
        languageDetector.close()
        capturer?.release()
        capturer = null
        projection?.unregisterCallback(projectionCallback)
        projection?.stop()
        projection = null
        if (TranslatorServiceState.state.value != RunState.ERROR) {
            TranslatorServiceState.update(RunState.STOPPED)
        }
        super.onDestroy()
    }

    companion object {
        private const val TAG = "TranslatorService"
        private const val ACTION_START = "com.example.translation_poc_app.action.START"
        const val ACTION_STOP = "com.example.translation_poc_app.action.STOP"
        private const val ACTION_DEBUG_CAPTURE = "com.example.translation_poc_app.action.DEBUG_CAPTURE"
        private const val EXTRA_RESULT_CODE = "result_code"
        private const val EXTRA_DATA = "data"

        /** 캡처 동의 결과로 서비스를 시작한다. [CaptureConsentActivity]에서만 부른다. */
        fun start(context: Context, resultCode: Int, data: Intent) {
            val intent = Intent(context, TranslatorService::class.java)
                .setAction(ACTION_START)
                .putExtra(EXTRA_RESULT_CODE, resultCode)
                .putExtra(EXTRA_DATA, data)
            context.startForegroundService(intent)
        }

        fun stop(context: Context) {
            // 실행 중이 아니면 startService가 서비스를 새로 만들지 않도록 stopService를 쓴다.
            context.stopService(Intent(context, TranslatorService::class.java))
        }

        fun stopIntent(context: Context): Intent =
            Intent(context, TranslatorService::class.java).setAction(ACTION_STOP)

        fun debugCaptureIntent(context: Context): Intent =
            Intent(context, TranslatorService::class.java).setAction(ACTION_DEBUG_CAPTURE)

        fun Context.isDebuggable(): Boolean =
            applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0
    }
}
