package com.example.translation_poc_app.translate

import com.example.translation_poc_app.data.settings.AiTone
import com.example.translation_poc_app.data.settings.GlossaryEntry
import java.io.IOException
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

private fun reply(text: String) = """{"candidates":[{"content":{"parts":[{"text":"$text"}]}}]}"""

private class FakeEngine(override val id: EngineId, val result: EngineResult<TranslationResult>) : TranslationEngine {
    var calls = 0
    override fun supports(language: String) = true
    override suspend fun translate(request: TranslationRequest): EngineResult<TranslationResult> { calls++; return result }
    override suspend fun isLanguageAvailable(language: String) = EngineResult.Ok(true)
    override suspend fun downloadLanguage(language: String, policy: ModelDownloadPolicy) = EngineResult.Ok(Unit)
    override suspend fun deleteLanguage(language: String) = EngineResult.Ok(Unit)
    override fun close() {}
}

class GeminiTranslationEngineTest {
    private val request = TranslationRequest("hello", "en", "ko")

    private fun run(keys: ApiKeyProvider, transport: GeminiTransport) =
        runBlocking { GeminiTranslationEngine(keys, transport).translate(request) }

    @Test
    fun `응답에서 번역문을 꺼낸다`() {
        val r = run({ "k" }, { _, _, _ -> reply("안녕") })
        assertEquals("안녕", ((r as EngineResult.Ok).value).text)
        assertEquals(EngineId.GEMINI, r.value.engine)
    }

    @Test
    fun `키가 없으면 호출하지 않고 Unavailable`() {
        var called = false
        val r = run({ null }, { _, _, _ -> called = true; "" })
        assertEquals(TranslationError.NoApiKey, (r as EngineResult.Err).error)
        assertTrue(!called)
    }

    @Test
    fun `오프라인 Network, 한도 ServiceBusy, 키 거부 InvalidApiKey, 접근 거부 AccessDenied, 그 외 Unknown`() {
        assertEquals(TranslationError.Network, (run({ "k" }, { _, _, _ -> throw IOException() }) as EngineResult.Err).error)
        assertEquals(TranslationError.ServiceBusy, (run({ "k" }, { _, _, _ -> throw GeminiHttpException(503, "") }) as EngineResult.Err).error)
        assertEquals(TranslationError.InvalidApiKey, (run({ "k" }, { _, _, _ -> throw GeminiHttpException(400, "API_KEY_INVALID") }) as EngineResult.Err).error)
        assertEquals(TranslationError.AccessDenied, (run({ "k" }, { _, _, _ -> throw GeminiHttpException(403, "PERMISSION_DENIED") }) as EngineResult.Err).error)
        assertTrue((run({ "k" }, { _, _, _ -> throw GeminiHttpException(404, "not found") }) as EngineResult.Err).error is TranslationError.Unknown)
    }

    @Test
    fun `빈 응답은 실패`() {
        assertTrue(run({ "k" }, { _, _, _ -> """{"candidates":[]}""" }) is EngineResult.Err)
    }

    @Test
    fun `AI가 실패하면 대체 엔진 결과를 쓴다`() = runBlocking {
        val ok = EngineResult.Ok(TranslationResult("x", "en", "ko", EngineId.ML_KIT))
        val ai = FakeEngine(EngineId.GEMINI, EngineResult.Err(TranslationError.Network))
        val ml = FakeEngine(EngineId.ML_KIT, ok)
        var reason: TranslationError? = null
        val r = FallbackTranslationEngine(ai, ml) { reason = it }.translate(request)
        assertEquals(TranslationError.Network, reason)
        assertEquals(EngineId.ML_KIT, (r as EngineResult.Ok).value.engine)
        assertEquals(1, ml.calls)
    }

    @Test
    fun `AI가 성공하면 대체 엔진을 부르지 않는다`() = runBlocking {
        val ai = FakeEngine(EngineId.GEMINI, EngineResult.Ok(TranslationResult("x", "en", "ko", EngineId.GEMINI)))
        val ml = FakeEngine(EngineId.ML_KIT, EngineResult.Err(TranslationError.Network))
        FallbackTranslationEngine(ai, ml).translate(request)
        assertEquals(0, ml.calls)
    }
}

class AiEngineOrderChainTest {
    private val request = TranslationRequest("hello", "en", "ko")
    private fun ok(id: EngineId) = EngineResult.Ok(TranslationResult("x", "en", "ko", id))
    private val busy = EngineResult.Err(TranslationError.ServiceBusy)

    @Test
    fun `1순위가 한도 초과면 2순위 AI가 번역하고 ML Kit은 부르지 않는다`() = runBlocking {
        val first = FakeEngine(EngineId.GEMINI, busy)
        val second = FakeEngine(EngineId.GROQ, ok(EngineId.GROQ))
        val ml = FakeEngine(EngineId.ML_KIT, ok(EngineId.ML_KIT))
        val chain = FallbackTranslationEngine(FallbackTranslationEngine(first, second), ml)
        val r = chain.translate(request)
        assertEquals(EngineId.GROQ, (r as EngineResult.Ok).value.engine)
        assertEquals(0, ml.calls)
    }

    @Test
    fun `AI 둘 다 실패하면 ML Kit으로 대체하고 안내한다`() = runBlocking {
        val first = FakeEngine(EngineId.GEMINI, busy)
        val second = FakeEngine(EngineId.GROQ, EngineResult.Err(TranslationError.Network))
        val ml = FakeEngine(EngineId.ML_KIT, ok(EngineId.ML_KIT))
        var noticed: TranslationError? = null
        val chain = FallbackTranslationEngine(FallbackTranslationEngine(first, second), ml) { noticed = it }
        val r = chain.translate(request)
        assertEquals(EngineId.ML_KIT, (r as EngineResult.Ok).value.engine)
        assertEquals(TranslationError.Network, noticed)
    }
}

class GeminiPromptTest {
    private fun prompt(style: AiStyle, text: String = "Open the Quest log") =
        GeminiTranslationEngine.systemPrompt(TranslationRequest(text, "en", "ko", style), "en")

    @Test
    fun `옵션이 없으면 기본 지시문만`() {
        val p = prompt(AiStyle.NONE)
        assertTrue(!p.contains("speech level"))
        assertTrue(!p.contains("exactly as given"))
    }

    @Test
    fun `말투를 지시문에 넣는다`() {
        assertTrue(prompt(AiStyle(AiTone.FORMAL)).contains("formal speech level"))
        assertTrue(prompt(AiStyle(AiTone.INFORMAL)).contains("informal speech level"))
    }

    @Test
    fun `용어집은 이 글에 나오는 항목만 대소문자 무시로 넣는다`() {
        val style = AiStyle(glossary = listOf(GlossaryEntry("quest", "퀘스트"), GlossaryEntry("Mana", "마나")))
        val p = prompt(style)
        assertTrue(p.contains("quest => 퀘스트"))
        assertTrue(!p.contains("Mana"))
    }

    @Test
    fun `옵션이 다르면 캐시 키도 다르다`() {
        val a = TranslationKey(EngineId.GEMINI, "hi", "en", "ko", AiStyle(AiTone.FORMAL))
        val b = TranslationKey(EngineId.GEMINI, "hi", "en", "ko", AiStyle(AiTone.INFORMAL))
        assertTrue(a != b)
        assertEquals(a, TranslationKey(EngineId.GEMINI, "hi", "en", "ko", AiStyle(AiTone.FORMAL)))
    }
}
