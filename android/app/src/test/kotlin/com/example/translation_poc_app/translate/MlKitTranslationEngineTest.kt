package com.example.translation_poc_app.translate

import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

private class FakeBackend(
    val downloaded: MutableSet<String> = mutableSetOf(),
    var identified: String? = "ja",
    val failure: Exception? = null,
) : OnDeviceBackend {
    val downloads = mutableListOf<Pair<String, Boolean>>()
    override fun supportedLanguages() = setOf("en", "ko", "ja", "he")
    override suspend fun isDownloaded(language: String) = language in downloaded
    override suspend fun download(language: String, wifiOnly: Boolean) {
        failure?.let { throw it }
        downloads += language to wifiOnly
        downloaded += language
    }
    override suspend fun delete(language: String) { downloaded -= language }
    override suspend fun identify(text: String) = identified
    override suspend fun translate(text: String, source: String, target: String) = "[$source>$target]$text"
    override fun close() {}
}

class MlKitTranslationEngineTest {

    private fun run(engine: MlKitTranslationEngine, source: String, target: String = "ko", text: String = "hello") =
        runBlocking { engine.translate(TranslationRequest(text, source, target)) }

    @Test
    fun `영어가 끼지 않은 쌍은 영어 모델도 필요하다`() {
        assertEquals(listOf("ja", "ko", "en"), MlKitTranslationEngine.requiredModels("ja", "ko"))
        assertEquals(listOf("en", "ko"), MlKitTranslationEngine.requiredModels("en", "ko"))
    }

    @Test
    fun `모델이 있으면 바로 번역한다`() {
        val engine = MlKitTranslationEngine(FakeBackend(mutableSetOf("ja", "ko", "en")))
        val r = run(engine, "ja") as EngineResult.Ok
        assertEquals(TranslationResult("[ja>ko]hello", "ja", "ko", EngineId.ML_KIT), r.value)
    }

    @Test
    fun `모델이 없으면 Wi-Fi 조건으로 내려받고 번역한다`() {
        val backend = FakeBackend()
        val engine = MlKitTranslationEngine(backend, downloadPolicy = ModelDownloadPolicy(wifiOnly = true))
        assertTrue(run(engine, "ja") is EngineResult.Ok)
        assertEquals(listOf("ja" to true, "ko" to true, "en" to true), backend.downloads)
    }

    @Test
    fun `자동 내려받기를 끄면 없는 모델을 알려 준다`() {
        val engine = MlKitTranslationEngine(FakeBackend(mutableSetOf("ko")), autoDownload = false)
        val r = run(engine, "ja") as EngineResult.Err
        assertEquals(TranslationError.ModelNotDownloaded(listOf("ja", "en")), r.error)
    }

    @Test
    fun `auto면 감지한 언어로 번역하고 못 알아내면 실패한다`() {
        val backend = FakeBackend(mutableSetOf("ja", "ko", "en"))
        val engine = MlKitTranslationEngine(backend)
        assertEquals("ja", (run(engine, AUTO_LANGUAGE) as EngineResult.Ok).value.sourceLanguage)
        backend.identified = null
        assertEquals(TranslationError.LanguageUndetermined, (run(engine, AUTO_LANGUAGE) as EngineResult.Err).error)
    }

    @Test
    fun `같은 언어 · 빈 글자는 번역하지 않는다`() {
        val backend = FakeBackend()
        val engine = MlKitTranslationEngine(backend)
        assertEquals("hello", (run(engine, "ko") as EngineResult.Ok).value.text)
        assertEquals("", (run(engine, "ja", text = "") as EngineResult.Ok).value.text)
        assertTrue(backend.downloads.isEmpty())
    }

    @Test
    fun `지원하지 않는 언어는 실패한다`() {
        val engine = MlKitTranslationEngine(FakeBackend())
        assertEquals(TranslationError.UnsupportedLanguage("xx"), (run(engine, "xx") as EngineResult.Err).error)
        assertEquals(TranslationError.UnsupportedLanguage("xx"), (run(engine, "ja", target = "xx") as EngineResult.Err).error)
    }

    @Test
    fun `내려받기 실패는 오류 종류로 바꿔 돌려준다`() {
        val engine = MlKitTranslationEngine(FakeBackend(failure = IllegalStateException("boom")))
        assertEquals(TranslationError.Unknown("boom"), (run(engine, "ja") as EngineResult.Err).error)
    }

    @Test
    fun `모델 확인 · 내려받기 · 삭제`() = runBlocking {
        val engine = MlKitTranslationEngine(FakeBackend())
        assertEquals(EngineResult.Ok(false), engine.isLanguageAvailable("he"))
        assertEquals(EngineResult.Ok(Unit), engine.downloadLanguage("iw", ModelDownloadPolicy()))
        assertEquals(EngineResult.Ok(true), engine.isLanguageAvailable("he"))
        engine.deleteLanguage("he")
        assertEquals(EngineResult.Ok(false), engine.isLanguageAvailable("he"))
    }
}
