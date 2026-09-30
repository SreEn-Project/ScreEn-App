package com.example.translation_poc_app.ocr

import android.graphics.Bitmap
import android.graphics.Rect
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

    /**
     * [sourceLanguage]에 맞는 인식기로 읽는다 (null = 자동, [OcrSelection.scriptsFor]).
     * 여러 인식기를 돌리면 병렬로 돌리고 가장 잘 읽은 결과를 고른다. 신뢰도 낮은 줄은 뺀다.
     */
    suspend fun recognize(bitmap: Bitmap, sourceLanguage: String? = null): OcrResult {
        // 글자 인식 시간은 픽셀 수에 거의 비례한다. 긴 변을 줄여 읽고, 좌표는 원래 크기로 되돌린다 (#11).
        val scale = minOf(1f, MAX_SIDE.toFloat() / maxOf(bitmap.width, bitmap.height))
        val input = if (scale < 1f) {
            Bitmap.createScaledBitmap(bitmap, (bitmap.width * scale).toInt(), (bitmap.height * scale).toInt(), true)
        } else {
            bitmap
        }
        val image = InputImage.fromBitmap(input, 0)
        val results = coroutineScope {
            OcrSelection.scriptsFor(sourceLanguage).map { script ->
                async {
                    val text = recognizerFor(script).process(image).await()
                    OcrResult(script, OcrSelection.filterLowConfidence(text.toBlocks(1f / scale)))
                }
            }.awaitAll()
        }.also { if (input !== bitmap) input.recycle() }
        return OcrSelection.pickBest(results) ?: OcrResult(Script.LATIN, emptyList())
    }

    private companion object {
        /** 인식에 넣는 이미지의 긴 변 상한(px). 휴대폰 글자 크기는 이 정도로 줄여도 읽힌다. */
        const val MAX_SIDE = 1280
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
