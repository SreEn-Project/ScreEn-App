package com.example.translation_poc_app.translate

/**
 * [primary]가 실패하면(오류 · 오프라인 · 키 없음) [fallback]으로 다시 번역한다 (NA-13).
 * 결과의 engine은 실제로 번역한 엔진이라 화면 배지가 맞게 나온다. 언어 모델 관리는 [fallback](ML Kit)이 맡는다.
 */
class FallbackTranslationEngine(
    private val primary: TranslationEngine,
    private val fallback: TranslationEngine,
) : TranslationEngine {

    override val id = primary.id

    override fun supports(language: String) = primary.supports(language) || fallback.supports(language)

    override suspend fun translate(request: TranslationRequest): EngineResult<TranslationResult> {
        val first = primary.translate(request)
        if (first is EngineResult.Ok) return first
        return fallback.translate(request)
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
