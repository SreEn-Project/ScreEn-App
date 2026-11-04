package com.example.translation_poc_app.bridge

import android.content.Context
import com.example.translation_poc_app.data.history.HistoryRepository
import com.example.translation_poc_app.data.settings.ApiKeyStore
import com.example.translation_poc_app.data.settings.Engine
import com.example.translation_poc_app.data.settings.GlossaryEntry as NativeGlossaryEntry
import com.example.translation_poc_app.data.settings.SettingsRepository
import com.example.translation_poc_app.data.vocabulary.VocabularyRepository
import com.example.translation_poc_app.data.vocabulary.WordDraft
import com.example.translation_poc_app.data.vocabulary.WordSort
import com.example.translation_poc_app.translate.GeminiKeyTester
import com.example.translation_poc_app.translate.GroqKeyTester
import com.example.translation_poc_app.service.CaptureConsentActivity
import com.example.translation_poc_app.service.RunState
import com.example.translation_poc_app.service.TranslatorService
import com.example.translation_poc_app.service.TranslatorServiceState
import com.example.translation_poc_app.translate.GemmaFailure
import com.example.translation_poc_app.translate.GemmaModelManager
import com.example.translation_poc_app.translate.GemmaModelState
import com.example.translation_poc_app.translate.GemmaRuntime
import com.example.translation_poc_app.translate.LanguageModelManager

/** Flutter → 네이티브 설정 호출 (NA-01, NA-16). */
class SettingsHostApiImpl(
    private val repository: SettingsRepository,
    private val apiKeys: ApiKeyStore,
) : SettingsHostApi {
    override suspend fun getSettings(): AppSettings = repository.current().toPigeon()

    override suspend fun setTargetLanguage(languageCode: String) =
        repository.setTargetLanguage(languageCode)

    override suspend fun setEngine(engine: EngineType) = repository.setEngine(engine.toNative())

    override suspend fun setCaptureMode(mode: CaptureMode) = repository.setCaptureRange(mode.toNative())

    override suspend fun setDisplayMode(mode: DisplayMode) = repository.setResultDisplay(mode.toNative())

    override suspend fun setQuickLanguages(languageCodes: List<String>) =
        repository.setQuickLanguages(languageCodes)

    override suspend fun setAutoTranslate(enabled: Boolean) = repository.setAutoTranslate(enabled)

    override suspend fun setAutoShowDelayMs(ms: Long) = repository.setAutoShowDelayMs(ms)

    override suspend fun setHideAfterInteractionMs(ms: Long) = repository.setHideAfterInteractionMs(ms)

    override suspend fun setWifiOnlyModelDownload(enabled: Boolean) =
        repository.setWifiOnlyModelDownload(enabled)

    override suspend fun setButtonSizeDp(dp: Long) = repository.setButtonSizeDp(dp.toInt())

    override suspend fun setButtonOpacityPercent(percent: Long) = repository.setButtonOpacityPercent(percent.toInt())

    override suspend fun resetFixedRegion() = repository.clearFixedRegion()

    override suspend fun setOnboardingCompleted(completed: Boolean) =
        repository.setOnboardingCompleted(completed)

    override suspend fun setAgeConfirmed(confirmed: Boolean) = repository.setAgeConfirmed(confirmed)

    override suspend fun setAiTone(tone: com.example.translation_poc_app.bridge.AiTone) =
        repository.setAiTone(tone.toNative())

    override suspend fun setGlossary(entries: List<GlossaryEntry>) =
        repository.setGlossary(entries.map { NativeGlossaryEntry(it.source, it.target) })

    override suspend fun getApiKey(engine: EngineType): String? = apiKeys.get(engine.toNative())

    override suspend fun setApiKey(engine: EngineType, apiKey: String) = apiKeys.set(engine.toNative(), apiKey)

    override suspend fun clearApiKey(engine: EngineType) = apiKeys.clear(engine.toNative())

    override suspend fun testApiKey(engine: EngineType, apiKey: String): String? = when (engine.toNative()) {
        Engine.GROQ -> GroqKeyTester.test(apiKey)
        else -> GeminiKeyTester.test(apiKey)
    }

    override suspend fun isApiKeyPinEnabled(): Boolean = apiKeys.isPinEnabled()

    override suspend fun verifyApiKeyPin(pin: String): Boolean = apiKeys.verifyPin(pin)

    override suspend fun setApiKeyPin(newPin: String, currentPin: String?): Boolean =
        apiKeys.setPin(newPin, currentPin)

    override suspend fun clearApiKeyPin(currentPin: String): Boolean = apiKeys.clearPin(currentPin)

    override suspend fun resetApiKeyProtection() = apiKeys.reset()
}

/** 언어 모델 조회 · 받기 · 삭제 (FL-05). 실패는 예외로 던져 Flutter에 오류로 전해진다. */
class ModelHostApiImpl(private val models: LanguageModelManager = LanguageModelManager()) : ModelHostApi {
    override suspend fun getDownloadedLanguages(): List<String> = models.downloaded().sorted()

    override suspend fun downloadLanguage(languageCode: String, wifiOnly: Boolean) =
        models.download(languageCode, wifiOnly)

    override suspend fun deleteLanguage(languageCode: String) = models.delete(languageCode)
}

/** Gemma 온디바이스 모델 상태 · 받기 · 삭제와 Hugging Face 토큰 (#174). */
class GemmaHostApiImpl(
    private val models: GemmaModelManager,
    private val runtime: GemmaRuntime,
    private val apiKeys: ApiKeyStore,
) : GemmaHostApi {
    override suspend fun getStatus(): GemmaStatus {
        val s = models.snapshot()
        return GemmaStatus(
            state = when (s.state) {
                GemmaModelState.NOT_DOWNLOADED -> GemmaState.NOT_DOWNLOADED
                GemmaModelState.DOWNLOADING -> GemmaState.DOWNLOADING
                GemmaModelState.READY -> GemmaState.READY
            },
            downloadedBytes = s.downloadedBytes,
            totalBytes = s.totalBytes,
            error = when (s.failure) {
                GemmaFailure.NONE -> GemmaError.NONE
                GemmaFailure.TOKEN_REQUIRED -> GemmaError.TOKEN_REQUIRED
                GemmaFailure.LICENSE_NOT_ACCEPTED -> GemmaError.LICENSE_NOT_ACCEPTED
                GemmaFailure.NETWORK -> GemmaError.NETWORK
                GemmaFailure.NOT_ENOUGH_SPACE -> GemmaError.NOT_ENOUGH_SPACE
                GemmaFailure.UNKNOWN -> GemmaError.UNKNOWN
            },
            hasToken = apiKeys.huggingFaceToken() != null,
            deviceRamMb = models.deviceRamMb().toLong(),
            minRamMb = models.minRamMb.toLong(),
        )
    }

    override suspend fun startDownload(wifiOnly: Boolean) = models.startDownload(wifiOnly)

    override suspend fun cancelDownload() = models.cancelDownload()

    override suspend fun deleteModel() {
        runtime.unload() // 파일을 지우기 전에 메모리에서 내린다.
        models.delete()
    }

    override suspend fun setHuggingFaceToken(token: String) = apiKeys.setHuggingFaceToken(token)

    override suspend fun clearHuggingFaceToken() = apiKeys.clearHuggingFaceToken()
}

/** 번역 기록 조회 · 삭제 (FL-13). */
class HistoryHostApiImpl(private val repository: HistoryRepository) : HistoryHostApi {
    override suspend fun getHistory(query: String, sinceMs: Long, limit: Long): List<TranslationRecord> =
        repository.search(query, sinceMs, limit.toInt()).map { it.toPigeon() }

    override suspend fun deleteHistory(id: Long) = repository.delete(id)

    override suspend fun clearHistory() = repository.clear()
}

/** 단어장 · 단어 관리 (AD-04 ~ AD-06)와 앱에서 단어 저장. 오버레이는 저장소를 직접 부른다. */
class VocabularyHostApiImpl(private val repository: VocabularyRepository) : VocabularyHostApi {
    override suspend fun getWordbooks(): List<Wordbook> = repository.wordbooks().map { it.toPigeon() }

    override suspend fun createWordbook(name: String): Wordbook? =
        repository.createWordbook(name)?.let { created ->
            repository.wordbooks().first { it.id == created.id }.toPigeon()
        }

    override suspend fun renameWordbook(id: Long, name: String): Boolean = repository.renameWordbook(id, name)

    override suspend fun deleteWordbook(id: Long) = repository.deleteWordbook(id)

    override suspend fun getWords(wordbookId: Long, query: String, sort: VocabSort): List<VocabWord> =
        repository.words(wordbookId, query, sort.toNative()).map { it.toPigeon() }

    override suspend fun getWord(id: Long): VocabWord? = repository.word(id)?.toPigeon()

    override suspend fun moveWord(id: Long, wordbookId: Long) = repository.moveWord(id, wordbookId)

    override suspend fun deleteWord(id: Long) = repository.deleteWord(id)

    override suspend fun setMemorized(id: Long, memorized: Boolean) = repository.setMemorized(id, memorized)

    override suspend fun recordAnswers(answers: List<WordAnswer>) =
        repository.recordAnswers(answers.map { it.wordId to it.correct })

    override suspend fun saveWord(wordbookId: Long, input: VocabWordInput): Long? =
        repository.saveWord(
            wordbookId,
            WordDraft(
                word = input.word,
                meaning = input.meaning,
                pronunciation = input.pronunciation,
                partOfSpeech = input.partOfSpeech,
                contextMeaning = input.contextMeaning,
                sentence = input.sentence,
                sourceLanguage = input.sourceLanguage,
                targetLanguage = input.targetLanguage,
            ),
        )

    override suspend fun updateWord(id: Long, input: VocabWordInput): Boolean =
        repository.updateWord(
            id,
            WordDraft(
                word = input.word,
                meaning = input.meaning,
                pronunciation = input.pronunciation,
                partOfSpeech = input.partOfSpeech,
                contextMeaning = input.contextMeaning,
                sentence = input.sentence,
                sourceLanguage = input.sourceLanguage,
                targetLanguage = input.targetLanguage,
            ),
        )
}

/** 서비스 상태 조회 · 시작 · 중지 (NA-01, NA-02). */
class ServiceHostApiImpl(private val context: Context) : ServiceHostApi {
    override fun getServiceState(): ServiceState = TranslatorServiceState.state.value.toPigeon()

    override fun startService() {
        if (TranslatorServiceState.state.value == RunState.RUNNING) return
        // STARTING이어도 다시 띄운다: 동의 창을 두고 다른 앱으로 간 경우 되찾는 길.
        CaptureConsentActivity.launch(context)
    }

    override fun stopService() {
        TranslatorService.stop(context)
    }
}
