package com.example.translation_poc_app.translate

import com.example.translation_poc_app.ocr.OcrBlock
import com.google.android.gms.tasks.Task
import com.google.mlkit.nl.languageid.LanguageIdentification
import com.google.mlkit.nl.languageid.LanguageIdentificationOptions
import com.google.mlkit.nl.translate.TranslateLanguage
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.suspendCancellableCoroutine
import java.io.Closeable
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

/** 블록과 그 블록에 대한 결정. */
data class DetectedBlock(val block: OcrBlock, val decision: BlockDecision)

/**
 * 블록별 원문 언어 감지 (NA-10). ML Kit Language ID, 기기 안에서만 처리.
 * 대상 언어와 같으면 번역을 건너뛰고, 엔진이 지원하지 않는 언어면 표시해 안내할 수 있게 한다.
 */
class LanguageDetector(
    /** 번역 엔진이 원문으로 받는 언어. 기본은 ML Kit 번역(NA-12)이 지원하는 59개. */
    private val supportedSources: Set<String> = TranslateLanguage.getAllLanguages().toSet(),
) : Closeable {

    // 신뢰도 0.5 미만이면 "und". 짧은 글자에서 엉뚱한 언어로 번역하는 것을 막는다.
    private val client = LanguageIdentification.getClient(
        LanguageIdentificationOptions.Builder().setConfidenceThreshold(CONFIDENCE_THRESHOLD).build(),
    )

    suspend fun detect(blocks: List<OcrBlock>, targetLanguage: String): List<DetectedBlock> =
        coroutineScope {
            blocks.map { block ->
                async {
                    val detected = runCatching { client.identifyLanguage(block.text).await() }.getOrNull()
                    DetectedBlock(
                        block,
                        LanguagePlan.decide(detected, block.language, targetLanguage, supportedSources),
                    )
                }
            }.awaitAll()
        }

    override fun close() = client.close()

    private companion object {
        const val CONFIDENCE_THRESHOLD = 0.5f
    }
}

private suspend fun <T> Task<T>.await(): T = suspendCancellableCoroutine { cont ->
    addOnSuccessListener { cont.resume(it) }
    addOnFailureListener { cont.resumeWithException(it) }
    addOnCanceledListener { cont.cancel() }
}
