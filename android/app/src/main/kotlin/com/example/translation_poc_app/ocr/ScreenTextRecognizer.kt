package com.example.translation_poc_app.ocr

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint
import android.graphics.Rect
import android.util.Log
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

    /**
     * [sourceLanguage]에 맞는 인식기로 읽는다 (null = 자동, [OcrSelection.scriptsFor]).
     * 자동 모드는 직전에 잘 읽은 인식기 하나로 먼저 읽고, 결과가 미덥지 않을 때만 나머지를 병렬로
     * 돌려 가장 잘 읽은 걸 고른다. 신뢰도 낮은 줄은 뺀다.
     */
    suspend fun recognize(bitmap: Bitmap, sourceLanguage: String? = null): OcrResult {
        // 글자 인식 시간은 픽셀 수에 거의 비례한다. 긴 변을 줄여 읽고, 좌표는 원래 크기로 되돌린다 (#11).
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
            var result = read(InputImage.fromBitmap(input, 0), sourceLanguage, 1f / scale)
            // 거의 못 읽은 화면은 어두운 배경의 밝은 글자일 수 있다. 이 경우에만 색을 뒤집어 한 번 더 읽는다 (#21).
            if (OcrSelection.charCount(result.blocks) < OcrSelection.MIN_TRUSTED_CHARS) {
                val inverted = inverted(input)
                try {
                    val second = read(InputImage.fromBitmap(inverted, 0), sourceLanguage, 1f / scale)
                    if (OcrSelection.score(second) > OcrSelection.score(result)) {
                        Log.i(TAG, "색을 뒤집어 읽은 결과가 더 낫다")
                        result = second
                    }
                } finally {
                    inverted.recycle()
                }
            }
            synchronized(this) { cache = key to result }
            return result
        } finally {
            if (input !== bitmap) input.recycle()
        }
    }

    private suspend fun read(image: InputImage, sourceLanguage: String?, factor: Float): OcrResult {
        val auto = OcrSelection.scriptsFor(sourceLanguage).size > 1
        val first = if (auto) setOf(lastWinner) else OcrSelection.scriptsFor(sourceLanguage)
        var results = readWith(image, first, factor)
        if (auto && !OcrSelection.isTrusted(results.flatMap { it.raw })) {
            Log.i(TAG, "첫 인식기(${lastWinner}) 결과가 미덥지 않아 나머지도 읽는다")
            results = results + readWith(image, OcrSelection.remainingAuto(lastWinner), factor)
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

    private suspend fun readWith(image: InputImage, scripts: Set<Script>, factor: Float): List<Read> = coroutineScope {
        scripts.map { script ->
            async {
                val raw = recognizerFor(script).process(image).await().toBlocks(factor)
                Read(raw, OcrResult(script, OcrSelection.filterLowConfidence(raw)))
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
        const val MAX_SIDE = 1600
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
