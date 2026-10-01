package com.example.translation_poc_app.translate

import kotlinx.coroutines.CancellationException

/**
 * ML Kit 온디바이스 번역 엔진 (NA-12). 기기 안에서만 처리하고, 언어 모델은 처음 쓸 때 내려받는다.
 *
 * - 원문이 [AUTO_LANGUAGE]면 Language ID로 감지한다 (못 알아내면 [TranslationError.LanguageUndetermined]).
 * - ML Kit은 영어를 중간 언어로 쓴다: 영어가 아닌 두 언어 사이는 영어 모델도 필요하다.
 * - 모델이 없을 때: [autoDownload]면 내려받고 번역, 아니면 [TranslationError.ModelNotDownloaded].
 */
class MlKitTranslationEngine(
    private val backend: OnDeviceBackend = MlKitOnDeviceBackend(),
    private val autoDownload: Boolean = true,
    private val downloadPolicy: ModelDownloadPolicy = ModelDownloadPolicy(),
) : TranslationEngine {

    override val id = EngineId.ML_KIT

    /** 같은 글자 · 언어 쌍의 최근 번역 결과. 같은 화면을 다시 번역하거나 반복되는 UI 글자를 건너뛴다 (#19). */
    private val cache = object : LinkedHashMap<Triple<String, String, String>, String>(16, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<Triple<String, String, String>, String>?) =
            size > CACHE_SIZE
    }

    override fun supports(language: String): Boolean =
        LanguagePlan.normalize(language) in backend.supportedLanguages()

    override suspend fun translate(request: TranslationRequest): EngineResult<TranslationResult> = guard {
        val target = LanguagePlan.normalize(request.target)
        if (!supports(target)) return@guard unsupported(request.target)

        val source = if (request.source == AUTO_LANGUAGE) {
            val detected = backend.identify(request.text)?.let(LanguagePlan::normalize)
            if (detected == null || detected == LanguagePlan.UNDETERMINED) {
                return@guard EngineResult.Err(TranslationError.LanguageUndetermined)
            }
            detected
        } else {
            LanguagePlan.normalize(request.source)
        }
        if (!supports(source)) return@guard unsupported(source)

        if (request.text.isBlank() || source == target) {
            return@guard EngineResult.Ok(TranslationResult(request.text, source, target, id))
        }

        val missing = requiredModels(source, target).filterNot { backend.isDownloaded(it) }
        if (missing.isNotEmpty()) {
            if (!autoDownload) return@guard EngineResult.Err(TranslationError.ModelNotDownloaded(missing))
            missing.forEach { backend.download(it, downloadPolicy.wifiOnly) }
        }
        val key = Triple(request.text, source, target)
        val translated = synchronized(cache) { cache[key] }
            ?: backend.translate(request.text, source, target).also { synchronized(cache) { cache[key] = it } }
        EngineResult.Ok(TranslationResult(translated, source, target, id))
    }

    override suspend fun isLanguageAvailable(language: String): EngineResult<Boolean> = guard {
        val code = LanguagePlan.normalize(language)
        if (!supports(code)) return@guard unsupported(language)
        EngineResult.Ok(backend.isDownloaded(code))
    }

    override suspend fun downloadLanguage(language: String, policy: ModelDownloadPolicy): EngineResult<Unit> = guard {
        val code = LanguagePlan.normalize(language)
        if (!supports(code)) return@guard unsupported(language)
        if (!backend.isDownloaded(code)) backend.download(code, policy.wifiOnly)
        EngineResult.Ok(Unit)
    }

    override suspend fun deleteLanguage(language: String): EngineResult<Unit> = guard {
        val code = LanguagePlan.normalize(language)
        if (!supports(code)) return@guard unsupported(language)
        backend.delete(code)
        EngineResult.Ok(Unit)
    }

    override fun close() = backend.close()

    private fun unsupported(language: String) =
        EngineResult.Err(TranslationError.UnsupportedLanguage(language))

    private suspend fun <T> guard(block: suspend () -> EngineResult<T>): EngineResult<T> =
        try {
            block()
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            EngineResult.Err(TranslationErrorMapper.map(e))
        }

    companion object {
        private const val PIVOT = "en"
        private const val CACHE_SIZE = 128

        /** 번역에 필요한 모델. 영어가 끼지 않은 쌍은 영어 모델이 중간에 필요하다. 순수 함수. */
        fun requiredModels(source: String, target: String): List<String> =
            if (source == PIVOT || target == PIVOT) listOf(source, target).distinct()
            else listOf(source, target, PIVOT).distinct()
    }
}
