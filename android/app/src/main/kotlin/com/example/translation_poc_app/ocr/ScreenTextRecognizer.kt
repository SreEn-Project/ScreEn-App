package com.example.translation_poc_app.ocr

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint
import android.graphics.Rect
import android.util.Log
import com.example.translation_poc_app.autotranslate.FrameSignature
import com.google.android.gms.tasks.Task
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.Text
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
import com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
import com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
import com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.suspendCancellableCoroutine
import java.io.Closeable
import kotlin.coroutines.resume
import kotlin.math.ceil
import kotlin.math.floor
import kotlin.math.roundToInt
import kotlin.coroutines.resumeWithException

/**
 * 화면 캡처에서 글자를 읽는다 (NA-09). ML Kit Text Recognition v2, 기기 안에서만 처리.
 * 인식기는 처음 쓸 때 만들고 서비스가 끝날 때 [close]로 닫는다.
 */
class ScreenTextRecognizer : Closeable {

    private val recognizers = mutableMapOf<Script, TextRecognizer>()

    /** 자동 모드에서 직전에 가장 잘 읽은 인식기. 다음에도 먼저 시도한다 (#19). */
    @Volatile
    private var lastWinner: Script = OcrSelection.DEFAULT_FIRST

    /** 직전 입력과 같은 화면이면 다시 읽지 않는다 (#19). 키는 입력 이미지 해시 + 원문 언어. */
    private var cache: Pair<Long, OcrResult>? = null

    /** 직전에 읽은 화면의 밝기 격자와 결과. 자동 번역이 바뀐 영역만 다시 읽을 때 기준으로 쓴다 (#43). */
    private class Baseline(
        val grid: IntArray,
        val width: Int,
        val height: Int,
        val sourceLanguage: String?,
        val result: OcrResult,
    )

    private var baseline: Baseline? = null

    /**
     * [sourceLanguage]에 맞는 인식기로 읽는다 (null = 자동, [OcrSelection.scriptsFor]).
     * 자동 모드는 직전에 잘 읽은 인식기 하나로 먼저 읽고, 결과가 미덥지 않을 때만 나머지를 병렬로
     * 돌려 가장 잘 읽은 걸 고른다. 신뢰도 낮은 줄은 뺀다.
     *
     * [incremental]이면(자동 번역) 직전에 읽은 화면과 견줘 바뀐 영역만 다시 읽고 나머지 블록은 이전 결과를 쓴다 (#43).
     * 비교할 수 없거나 너무 많이 바뀌었으면 통째로 읽는다.
     */
    suspend fun recognize(bitmap: Bitmap, sourceLanguage: String? = null, incremental: Boolean = false): OcrResult {
        // 글자 인식 시간은 픽셀 수에 거의 비례한다. 긴 변을 줄여 읽고, 좌표는 원래 크기로 되돌린다 (#11). 너무 줄이면 작은 글자가 뭉개져 누락되므로 상한을 2000px로 둔다 (#178).
        val scale = minOf(1f, MAX_SIDE.toFloat() / maxOf(bitmap.width, bitmap.height))
        val input = if (scale < 1f) {
            Bitmap.createScaledBitmap(bitmap, (bitmap.width * scale).toInt(), (bitmap.height * scale).toInt(), true)
        } else {
            bitmap
        }
        try {
            val key = fingerprint(input) * 31 + (sourceLanguage?.hashCode() ?: 0)
            synchronized(this) { cache }?.takeIf { it.first == key }?.let {
                Log.i(TAG, "같은 화면 — 인식 결과 재사용")
                return it.second
            }
            val grid = lumaGrid(input)
            if (incremental) {
                readChanged(input, grid, sourceLanguage, scale)?.let {
                    synchronized(this) {
                        cache = key to it
                        baseline = Baseline(grid, input.width, input.height, sourceLanguage, it)
                    }
                    return it
                }
            }
            var result = read(InputImage.fromBitmap(input, 0), sourceLanguage, 1f / scale, input.height / scale)
            var wasInverted = false
            // 거의 못 읽은 화면은 어두운 배경의 밝은 글자일 수 있다. 이 경우에만 색을 뒤집어 한 번 더 읽는다 (#21).
            if (OcrSelection.charCount(result.blocks) < OcrSelection.MIN_TRUSTED_CHARS) {
                val inverted = inverted(input)
                try {
                    val second = read(InputImage.fromBitmap(inverted, 0), sourceLanguage, 1f / scale, input.height / scale)
                    if (OcrSelection.score(second) > OcrSelection.score(result)) {
                        Log.i(TAG, "색을 뒤집어 읽은 결과가 더 낫다")
                        result = second
                        wasInverted = true
                    }
                } finally {
                    inverted.recycle()
                }
            }
            synchronized(this) {
                cache = key to result
                // 색을 뒤집어 읽은 화면은 잘라 읽을 때도 뒤집어야 해서 기준으로 삼지 않는다.
                baseline = if (wasInverted) null else Baseline(grid, input.width, input.height, sourceLanguage, result)
            }
            return result
        } finally {
            if (input !== bitmap) input.recycle()
        }
    }

    /**
     * 직전 화면과 견줘 바뀐 영역만 다시 읽은 결과. 통째로 읽어야 하면 null.
     * 바뀐 칸이 없으면 이전 결과 그대로 — 기준 격자는 그대로 둔다 (서서히 바뀌는 것도 언젠가 잡힌다).
     */
    private suspend fun readChanged(input: Bitmap, grid: IntArray, sourceLanguage: String?, scale: Float): OcrResult? {
        val base = synchronized(this) { baseline } ?: return null
        if (base.sourceLanguage != sourceLanguage || base.width != input.width || base.height != input.height) return null
        // 이전 결과 좌표는 원래 크기다 → 입력 크기로 줄여 견준다.
        val oldBoxes = base.result.blocks.map { b ->
            b.bounds?.let { Box(floor(it.left * scale).toInt(), floor(it.top * scale).toInt(), ceil(it.right * scale).toInt(), ceil(it.bottom * scale).toInt()) }
        }
        return when (val plan = ChangedRegions.plan(base.grid, grid, input.width, input.height, oldBoxes)) {
            ChangedRegions.Plan.Reuse -> {
                Log.i(TAG, "바뀐 칸 없음 — 이전 결과 재사용")
                base.result
            }
            ChangedRegions.Plan.Full -> null
            is ChangedRegions.Plan.Partial -> {
                val fresh = plan.regions.flatMap { box ->
                    val crop = Bitmap.createBitmap(input, box.left, box.top, box.width, box.height)
                    try {
                        read(InputImage.fromBitmap(crop, 0), sourceLanguage, 1f, input.height.toFloat()).blocks
                            .map { it.shifted(box.left, box.top).scaledBy(1f / scale) }
                    } finally {
                        crop.recycle()
                    }
                }
                val kept = plan.keep.map { base.result.blocks[it] }
                Log.i(TAG, "바뀐 ${plan.regions.size}곳만 다시 읽음 — 블록 ${kept.size}개 재사용, ${fresh.size}개 새로")
                OcrResult(
                    base.result.script,
                    (kept + fresh).sortedWith(compareBy({ it.bounds?.top ?: 0 }, { it.bounds?.left ?: 0 })),
                )
            }
        }
    }

    /** [bitmap]을 격자 [ChangedRegions.COLS]×[ChangedRegions.ROWS]칸의 밝기로 줄인다 (칸마다 3×3 표본의 평균). */
    private fun lumaGrid(bitmap: Bitmap): IntArray {
        val w = bitmap.width
        val h = bitmap.height
        val cols = ChangedRegions.COLS
        val rows = ChangedRegions.ROWS
        val out = IntArray(cols * rows)
        val row = IntArray(w)
        val sums = IntArray(cols)
        for (r in 0 until rows) {
            sums.fill(0)
            for (sy in 0 until 3) {
                val y = ((r + (sy + 0.5f) / 3f) * h / rows).toInt().coerceIn(0, h - 1)
                bitmap.getPixels(row, 0, w, 0, y, w, 1)
                for (c in 0 until cols) {
                    for (sx in 0 until 3) {
                        val x = ((c + (sx + 0.5f) / 3f) * w / cols).toInt().coerceIn(0, w - 1)
                        val p = row[x]
                        sums[c] += FrameSignature.luma((p shr 16) and 0xFF, (p shr 8) and 0xFF, p and 0xFF)
                    }
                }
            }
            for (c in 0 until cols) out[r * cols + c] = sums[c] / 9
        }
        return out
    }

    /** [referenceHeight]는 결과 좌표계에서의 화면 전체 높이 — 작은 글자 거르기의 기준 (#178). */
    private suspend fun read(image: InputImage, sourceLanguage: String?, factor: Float, referenceHeight: Float): OcrResult {
        val auto = OcrSelection.scriptsFor(sourceLanguage).size > 1
        val first = if (auto) setOf(lastWinner) else OcrSelection.scriptsFor(sourceLanguage)
        var results = readWith(image, first, factor, referenceHeight)
        if (auto && !OcrSelection.isTrusted(results.flatMap { it.raw })) {
            Log.i(TAG, "첫 인식기(${lastWinner}) 결과가 미덥지 않아 나머지도 읽는다")
            results = results + readWith(image, OcrSelection.remainingAuto(lastWinner), factor, referenceHeight)
        }
        val best = OcrSelection.pickBest(results.map { it.filtered }) ?: OcrResult(Script.LATIN, emptyList())
        // 진단 (#25): 인식기별 글자 수 · 평균 신뢰도, 거르고 남은 글자 수.
        Log.i(TAG, "인식 ${image.width}x${image.height}: " + results.joinToString(" / ") {
            "${it.filtered.script} ${OcrSelection.describe(it.raw)} → 남음 ${OcrSelection.charCount(it.filtered.blocks)}자"
        } + " → 선택 ${best.script}")
        if (auto && best.blocks.isNotEmpty()) lastWinner = best.script
        return best
    }

    private class Read(val raw: List<OcrBlock>, val filtered: OcrResult)

    private suspend fun readWith(image: InputImage, scripts: Set<Script>, factor: Float, referenceHeight: Float): List<Read> = coroutineScope {
        scripts.map { script ->
            async {
                val raw = recognizerFor(script).process(image).await().toBlocks(factor)
                Read(raw, OcrResult(script, OcrTinyTextFilter.filter(OcrSelection.filterLowConfidence(raw), referenceHeight)))
            }
        }.awaitAll()
    }

    private fun inverted(src: Bitmap): Bitmap {
        val out = Bitmap.createBitmap(src.width, src.height, Bitmap.Config.ARGB_8888)
        val paint = Paint().apply {
            colorFilter = ColorMatrixColorFilter(
                ColorMatrix(
                    floatArrayOf(
                        -1f, 0f, 0f, 0f, 255f,
                        0f, -1f, 0f, 0f, 255f,
                        0f, 0f, -1f, 0f, 255f,
                        0f, 0f, 0f, 1f, 0f,
                    ),
                ),
            )
        }
        Canvas(out).drawBitmap(src, 0f, 0f, paint)
        return out
    }

    /** 이미지 전체를 가볍게 훑은 해시. 같은 화면이면 같고, 시계 · 애니메이션만 달라도 달라진다. */
    private fun fingerprint(bitmap: Bitmap): Long {
        val w = bitmap.width
        val h = bitmap.height
        val row = IntArray(w)
        var hash = 1125899906842597L
        var y = 0
        while (y < h) {
            bitmap.getPixels(row, 0, w, 0, y, w, 1)
            var x = 0
            while (x < w) {
                hash = 31 * hash + row[x]
                x += 2
            }
            y += 2
        }
        return hash * 31 + w * 7919 + h
    }

    private companion object {
        /** 인식에 넣는 이미지의 긴 변 상한(px). 휴대폰 글자 크기는 이 정도로 줄여도 읽힌다. */
        const val MAX_SIDE = 2000
        const val TAG = "ScreenTextRecognizer"
    }

    /** 첫 번역이 모델 불러오는 시간을 떠안지 않도록, 빈 이미지 한 장을 읽혀 인식기를 미리 깨운다 (#11). */
    suspend fun warmUp() {
        val blank = Bitmap.createBitmap(64, 64, Bitmap.Config.ARGB_8888)
        try {
            recognize(blank)
        } finally {
            blank.recycle()
        }
    }

    override fun close() {
        synchronized(recognizers) {
            recognizers.values.forEach { it.close() }
            recognizers.clear()
        }
    }

    private fun recognizerFor(script: Script): TextRecognizer = synchronized(recognizers) {
        recognizers.getOrPut(script) {
            TextRecognition.getClient(
                when (script) {
                    Script.LATIN -> TextRecognizerOptions.DEFAULT_OPTIONS
                    Script.KOREAN -> KoreanTextRecognizerOptions.Builder().build()
                    Script.JAPANESE -> JapaneseTextRecognizerOptions.Builder().build()
                    Script.CHINESE -> ChineseTextRecognizerOptions.Builder().build()
                    Script.DEVANAGARI -> DevanagariTextRecognizerOptions.Builder().build()
                },
            )
        }
    }
}

private fun Rect?.scaled(factor: Float): Rect? = this?.takeIf { factor != 1f }?.let {
    Rect((it.left * factor).roundToInt(), (it.top * factor).roundToInt(), (it.right * factor).roundToInt(), (it.bottom * factor).roundToInt())
} ?: this

private fun Rect.moved(dx: Int, dy: Int) = Rect(left + dx, top + dy, right + dx, bottom + dy)

/** 잘라낸 이미지 기준 좌표를 (dx, dy)만큼 옮겨 이미지 전체 기준으로 바꾼다. */
private fun OcrBlock.shifted(dx: Int, dy: Int) = copy(
    bounds = bounds?.moved(dx, dy),
    lines = lines.map { it.copy(bounds = it.bounds?.moved(dx, dy)) },
)

private fun OcrBlock.scaledBy(factor: Float) = if (factor == 1f) this else copy(
    bounds = bounds.scaled(factor),
    lines = lines.map { it.copy(bounds = it.bounds.scaled(factor)) },
)

private fun Text.toBlocks(factor: Float): List<OcrBlock> = textBlocks.map { block ->
    OcrBlock(
        text = block.text,
        bounds = block.boundingBox.scaled(factor),
        lines = block.lines.map { line ->
            OcrLine(
                text = line.text,
                bounds = line.boundingBox.scaled(factor),
                // ML Kit이 신뢰도를 못 주면(0 또는 NaN) 버리지 않도록 1로 본다.
                confidence = line.confidence.takeIf { it > 0f && !it.isNaN() } ?: 1f,
            )
        },
        language = block.recognizedLanguage.ifBlank { "und" },
    )
}

private suspend fun <T> Task<T>.await(): T = suspendCancellableCoroutine { cont ->
    addOnSuccessListener { cont.resume(it) }
    addOnFailureListener { cont.resumeWithException(it) }
    addOnCanceledListener { cont.cancel() }
}
