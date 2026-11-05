package com.example.translation_poc_app.translate

/**
 * [primary]가 실패하면(오류 · 오프라인 · 키 없음) [fallback]으로 다시 번역한다 (NA-13).
 * 결과의 engine은 실제로 번역한 엔진이라 화면 배지가 맞게 나온다. 언어 모델 관리는 [fallback](ML Kit)이 맡는다.
 */
class FallbackTranslationEngine(
    private val primary: TranslationEngine,
    private val fallback: TranslationEngine,
    /** 대체할 때 [primary]의 실패 이유를 알린다 (안내 표시용). */
    private val onFallback: (TranslationError) -> Unit = {},
) : TranslationEngine {

    override val id = primary.id

    override fun supports(language: String) = primary.supports(language) || fallback.supports(language)

    override suspend fun translate(request: TranslationRequest): EngineResult<TranslationResult> {
        val first = primary.translate(request)
        if (first is EngineResult.Ok) return first
        onFallback((first as EngineResult.Err).error)
        return fallback.translate(request)
    }

    override val prefersBatch get() = primary.prefersBatch

    /** primary가 묶음으로 보내고, 실패한 항목만 fallback이 따로 번역한다. */
    override suspend fun translateBatch(requests: List<TranslationRequest>): List<EngineResult<TranslationResult>> {
        val firsts = primary.translateBatch(requests)
        val failed = firsts.withIndex().filter { it.value is EngineResult.Err }
        if (failed.isEmpty()) return firsts
        onFallback((failed.first().value as EngineResult.Err).error)
        val retried = fallback.translateBatch(failed.map { requests[it.index] })
        val out = firsts.toMutableList()
        failed.forEachIndexed { n, f -> out[f.index] = retried[n] }
        return out
    }

    override suspend fun isLanguageAvailable(language: String) = fallback.isLanguageAvailable(language)

    override suspend fun downloadLanguage(language: String, policy: ModelDownloadPolicy) =
        fallback.downloadLanguage(language, policy)

    override suspend fun deleteLanguage(language: String) = fallback.deleteLanguage(language)

    override fun close() {
        primary.close()
        fallback.close()
    }
}
