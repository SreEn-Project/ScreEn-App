package com.example.translation_poc_app.selection

import com.example.translation_poc_app.translate.EngineId
import com.example.translation_poc_app.translate.EngineResult
import com.example.translation_poc_app.translate.ModelDownloadPolicy
import com.example.translation_poc_app.translate.TranslationEngine
import com.example.translation_poc_app.translate.TranslationError
import com.example.translation_poc_app.translate.TranslationRequest
import com.example.translation_poc_app.translate.TranslationResult
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

private class FakeEngine(private val reply: (TranslationRequest) -> EngineResult<TranslationResult>) : TranslationEngine {
    val requests = mutableListOf<TranslationRequest>()
    override val id = EngineId.ML_KIT
    override fun supports(language: String) = true
    override suspend fun translate(request: TranslationRequest): EngineResult<TranslationResult> {
        requests += request
        return reply(request)
    }
    override suspend fun isLanguageAvailable(language: String) = EngineResult.Ok(true)
    override suspend fun downloadLanguage(language: String, policy: ModelDownloadPolicy) = EngineResult.Ok(Unit)
    override suspend fun deleteLanguage(language: String) = EngineResult.Ok(Unit)
    override fun close() {}
}

class SelectionTranslatorTest {

    private fun ok(text: String, source: String, target: String) =
        EngineResult.Ok(TranslationResult(text, source, target, EngineId.ML_KIT))

    private fun run(engine: FakeEngine, text: String, target: String = "ko") =
        runBlocking { SelectionTranslator(engine).translate(text, target) }

    @Test
    fun `원문 언어는 자동 감지로 요청하고 앞뒤 공백은 뗀다`() {
        val engine = FakeEngine { ok("안녕", "en", "ko") }
        val outcome = run(engine, "  Hello \n")
        assertEquals(TranslationRequest("Hello", "auto", "ko"), engine.requests.single())
        assertEquals(SelectionOutcome.Translated("Hello", "안녕", "en", "ko", EngineId.ML_KIT), outcome)
    }

    @Test
    fun `빈 글은 엔진을 부르지 않는다`() {
        val engine = FakeEngine { ok("", "en", "ko") }
        assertEquals(SelectionOutcome.Empty, run(engine, "   "))
        assertTrue(engine.requests.isEmpty())
    }

    @Test
    fun `이미 대상 언어면 번역하지 않았다고 알린다`() {
        val engine = FakeEngine { ok(it.text, "ko", "ko") }
        assertEquals(SelectionOutcome.AlreadyInTarget("ko"), run(engine, "안녕"))
    }

    @Test
    fun `엔진 실패 이유를 그대로 돌려준다`() {
        val engine = FakeEngine { EngineResult.Err(TranslationError.Network) }
        assertEquals(SelectionOutcome.Failed(TranslationError.Network), run(engine, "Hello"))
    }

    @Test
    fun `기록용 결과는 글 하나짜리 번역 결과다`() {
        val translated = SelectionOutcome.Translated("Hello", "안녕", "en", "ko", EngineId.ML_KIT)
        val history = translated.toHistoryOutcome()
        assertEquals("ko", history.targetLanguage)
        assertEquals(listOf("Hello" to "안녕"), history.items.map { it.original to it.translated })
    }
}
