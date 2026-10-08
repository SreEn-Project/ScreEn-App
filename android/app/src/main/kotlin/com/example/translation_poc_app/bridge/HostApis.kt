package com.example.translation_poc_app.bridge

import android.content.Context
import com.example.translation_poc_app.data.history.HistoryRepository
import com.example.translation_poc_app.data.settings.ApiKeyStore
import com.example.translation_poc_app.data.settings.GlossaryEntry as NativeGlossaryEntry
import com.example.translation_poc_app.data.settings.SettingsRepository
import com.example.translation_poc_app.data.vocabulary.VocabularyRepository
import com.example.translation_poc_app.data.vocabulary.WordDraft
import com.example.translation_poc_app.data.vocabulary.WordSort
import com.example.translation_poc_app.translate.GeminiKeyTester
import com.example.translation_poc_app.service.CaptureConsentActivity
import com.example.translation_poc_app.service.RunState
import com.example.translation_poc_app.service.TranslatorService
import com.example.translation_poc_app.service.TranslatorServiceState
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

    override suspend fun getApiKey(): String? = apiKeys.get()

    override suspend fun setApiKey(apiKey: String) = apiKeys.set(apiKey)

    override suspend fun clearApiKey() = apiKeys.clear()

    override suspend fun testApiKey(apiKey: String): String? = GeminiKeyTester.test(apiKey)

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
