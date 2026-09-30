package com.example.translation_poc_app.translate

import com.google.mlkit.common.MlKitException
import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.common.model.RemoteModelManager
import com.google.mlkit.nl.languageid.LanguageIdentification
import com.google.mlkit.nl.languageid.LanguageIdentificationOptions
import com.google.mlkit.nl.languageid.LanguageIdentifier
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.TranslateRemoteModel
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.Translator
import com.google.mlkit.nl.translate.TranslatorOptions
import java.io.Closeable

/**
 * ML Kit 호출만 감싼 얇은 층 (NA-12). [MlKitTranslationEngine]의 규칙(언어 검사 · 모델 정책 ·
 * 오류 변환)을 ML Kit 없이 테스트할 수 있게 분리했다. 실패는 예외로 던진다.
 */
interface OnDeviceBackend : Closeable {
    fun supportedLanguages(): Set<String>
    suspend fun isDownloaded(language: String): Boolean
    suspend fun download(language: String, wifiOnly: Boolean)
    suspend fun delete(language: String)

    /** 원문 언어 코드. 모르면 null. */
    suspend fun identify(text: String): String?
    suspend fun translate(text: String, source: String, target: String): String
}

class MlKitOnDeviceBackend : OnDeviceBackend {

    private val modelManager = RemoteModelManager.getInstance()
    private val translators = HashMap<String, Translator>()
    private var languageId: LanguageIdentifier? = null

    override fun supportedLanguages(): Set<String> = TranslateLanguage.getAllLanguages().toSet()

    override suspend fun isDownloaded(language: String): Boolean =
        modelManager.isModelDownloaded(model(language)).await()

    override suspend fun download(language: String, wifiOnly: Boolean) {
        val conditions = DownloadConditions.Builder().apply { if (wifiOnly) requireWifi() }.build()
        modelManager.download(model(language), conditions).await()
    }

    override suspend fun delete(language: String) {
        modelManager.deleteDownloadedModel(model(language)).await()
    }

    override suspend fun identify(text: String): String? =
        languageIdClient().identifyLanguage(text).await().takeIf { it != LanguagePlan.UNDETERMINED }

    override suspend fun translate(text: String, source: String, target: String): String =
        translator(source, target).translate(text).await()

    @Synchronized
    private fun translator(source: String, target: String): Translator =
        translators.getOrPut("$source>$target") {
            Translation.getClient(
                TranslatorOptions.Builder().setSourceLanguage(source).setTargetLanguage(target).build(),
            )
        }

    @Synchronized
    private fun languageIdClient(): LanguageIdentifier = languageId ?: LanguageIdentification.getClient(
        LanguageIdentificationOptions.Builder().setConfidenceThreshold(CONFIDENCE_THRESHOLD).build(),
    ).also { languageId = it }

    @Synchronized
    override fun close() {
        translators.values.forEach { it.close() }
        translators.clear()
        languageId?.close()
        languageId = null
    }

    private fun model(language: String) = TranslateRemoteModel.Builder(language).build()

    private companion object {
        const val CONFIDENCE_THRESHOLD = 0.5f
    }
}

/** ML Kit 오류 코드 → 번역 오류 (순수 함수, NA-12). */
object TranslationErrorMapper {
    fun map(error: Throwable): TranslationError = when (error) {
        is MlKitException -> when (error.errorCode) {
            MlKitException.NETWORK_ISSUE -> TranslationError.Network
            MlKitException.NOT_ENOUGH_SPACE -> TranslationError.NotEnoughSpace
            else -> TranslationError.Unknown(error.message)
        }
        else -> TranslationError.Unknown(error.message)
    }
}
