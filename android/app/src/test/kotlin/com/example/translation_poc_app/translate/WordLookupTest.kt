package com.example.translation_poc_app.translate

import kotlinx.coroutines.runBlocking
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

private class FakeTranslator(private val reply: (TranslationRequest) -> EngineResult<TranslationResult>) : TranslationEngine {
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

class WordLookupTest {
    private fun ok(text: String, source: String = "en") =
        EngineResult.Ok(TranslationResult(text, source, "ko", EngineId.ML_KIT))

    private val definition = WordDefinition("사과", "/ˈæp.əl/", "명사", "(과일) 사과")

    private fun lookup(
        translator: FakeTranslator,
        dictionary: WordDictionary? = null,
        word: String = " apple ",
        sentence: String? = "An apple a day.",
    ) = runBlocking { WordLookup(translator, dictionary).lookup(word, sentence, "en", "ko") }

    @Test
    fun `AI가 없으면 번역만 보여 준다`() {
        val translator = FakeTranslator { ok("사과") }
        val found = lookup(translator) as WordLookupOutcome.Found
        assertEquals("사과", found.entry.translation)
        assertNull(found.entry.definition)
        assertNull(found.entry.aiError)
        assertEquals("apple", found.entry.word)
        assertEquals("사과", found.entry.savedMeaning)
        assertEquals(TranslationRequest("apple", "en", "ko"), translator.requests.single())
    }

    @Test
    fun `AI가 있으면 뜻 · 발음 · 품사 · 문맥 뜻이 붙고 저장할 뜻은 AI 뜻이다`() {
        val translator = FakeTranslator { ok("애플") }
        val found = lookup(translator, { _, _, _, _ -> EngineResult.Ok(definition) }) as WordLookupOutcome.Found
        assertEquals(definition, found.entry.definition)
        assertEquals("애플", found.entry.translation)
        assertEquals("사과", found.entry.savedMeaning)
    }

    @Test
    fun `AI가 실패해도 번역은 보여 주고 이유를 남긴다`() {
        val translator = FakeTranslator { ok("사과") }
        val found = lookup(translator, { _, _, _, _ -> EngineResult.Err(TranslationError.ServiceBusy) }) as WordLookupOutcome.Found
        assertNull(found.entry.definition)
        assertEquals(TranslationError.ServiceBusy, found.entry.aiError)
        assertEquals("사과", found.entry.savedMeaning)
    }

    @Test
    fun `번역이 실패해도 AI 뜻이 있으면 카드를 만든다`() {
        val translator = FakeTranslator { EngineResult.Err(TranslationError.Network) }
        val found = lookup(translator, { _, _, _, _ -> EngineResult.Ok(definition) }) as WordLookupOutcome.Found
        assertEquals("사과", found.entry.translation)
    }

    @Test
    fun `둘 다 실패하면 번역 엔진이 알려 준 이유로 실패한다`() {
        val translator = FakeTranslator { EngineResult.Err(TranslationError.Network) }
        val failed = lookup(translator, { _, _, _, _ -> EngineResult.Err(TranslationError.NoApiKey) })
        assertEquals(WordLookupOutcome.Failed(TranslationError.Network), failed)
    }

    @Test
    fun `빈 단어는 엔진을 부르지 않는다`() {
        val translator = FakeTranslator { ok("x") }
        assertEquals(WordLookupOutcome.Failed(null), lookup(translator, word = "  "))
        assertTrue(translator.requests.isEmpty())
    }

    @Test
    fun `문장이 비면 문맥 없이 조회한다`() {
        val translator = FakeTranslator { ok("사과") }
        var seen: String? = "unset"
        lookup(translator, { _, sentence, _, _ -> seen = sentence; EngineResult.Ok(definition) }, sentence = "  ")
        assertNull(seen)
    }
}

class GeminiDictionaryTest {
    private fun response(text: String) = JSONObject()
        .put(
            "candidates",
            org.json.JSONArray().put(
                JSONObject().put(
                    "content",
                    JSONObject().put("parts", org.json.JSONArray().put(JSONObject().put("text", text))),
                ),
            ),
        )
        .toString()

    @Test
    fun `응답 JSON을 풀이로 읽는다`() {
        val parsed = GeminiDictionary.parse(
            response("""{"meaning":"사과","pronunciation":"/ˈæp.əl/","partOfSpeech":"명사","contextMeaning":"과일 사과"}"""),
        )
        assertEquals(WordDefinition("사과", "/ˈæp.əl/", "명사", "과일 사과"), parsed)
    }

    @Test
    fun `코드 펜스가 붙어도 읽고 빈 항목은 null이다`() {
        val parsed = GeminiDictionary.parse(
            response("```json\n{\"meaning\":\"달리다\",\"pronunciation\":\"\",\"partOfSpeech\":\" \"}\n```"),
        )
        assertEquals(WordDefinition("달리다", null, null, null), parsed)
    }

    @Test
    fun `뜻이 하나도 없거나 JSON이 아니면 null이다`() {
        assertNull(GeminiDictionary.parse(response("""{"meaning":"","contextMeaning":""}""")))
        assertNull(GeminiDictionary.parse(response("모르겠어요")))
    }

    @Test
    fun `요청에는 단어 · 문장 · 대상 언어 · JSON 응답 지시가 들어간다`() {
        val body = JSONObject(GeminiDictionary.buildBody("apple", "An apple a day.", "en", "ko"))
        val system = body.getJSONObject("systemInstruction").getJSONArray("parts").getJSONObject(0).getString("text")
        val user = body.getJSONArray("contents").getJSONObject(0).getJSONArray("parts").getJSONObject(0).getString("text")
        assertTrue(system.contains("ko"))
        assertTrue(system.contains("JSON"))
        assertEquals("Word: apple\nSentence: An apple a day.", user)
        assertEquals("application/json", body.getJSONObject("generationConfig").getString("responseMimeType"))
    }

    @Test
    fun `문장이 없으면 요청에도 넣지 않는다`() {
        val body = JSONObject(GeminiDictionary.buildBody("apple", null, "auto", "ko"))
        val user = body.getJSONArray("contents").getJSONObject(0).getJSONArray("parts").getJSONObject(0).getString("text")
        assertEquals("Word: apple", user)
    }

    @Test
    fun `키가 없으면 키 없음 오류다`() {
        val result = runBlocking { GeminiDictionary({ null }).define("apple", null, "en", "ko") }
        assertEquals(EngineResult.Err(TranslationError.NoApiKey), result)
    }

    @Test
    fun `서버 한도 초과는 서비스 혼잡으로 돌려준다`() {
        val dictionary = GeminiDictionary(
            keys = { "key" },
            transport = { _, _, _ -> throw GeminiHttpException(429, "quota") },
        )
        val result = runBlocking { dictionary.define("apple", null, "en", "ko") }
        assertEquals(EngineResult.Err(TranslationError.ServiceBusy), result)
    }
}
