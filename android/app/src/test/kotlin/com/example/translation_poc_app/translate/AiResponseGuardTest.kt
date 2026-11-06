package com.example.translation_poc_app.translate

import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class AiResponseGuardTest {

    @Test
    fun `정상 번역은 통과한다`() {
        assertTrue(AiResponseGuard.isPlausible("Hello, how are you today?", "안녕하세요, 오늘 어떠세요?", "ko"))
        assertTrue(AiResponseGuard.isPlausible("OK", "확인", "ko"))
    }

    @Test
    fun `대답 문장과 프롬프트 지시문은 거른다`() {
        assertFalse(AiResponseGuard.isPlausible("Settings", "네, 번역해 드릴게요.", "ko"))
        assertFalse(AiResponseGuard.isPlausible("Settings and more things", "설정\nDo not repeat the original text.", "ko"))
        assertFalse(AiResponseGuard.isPlausible("Hello there my friend", "Sure, here is the translation: 안녕", "ko"))
    }

    @Test
    fun `대상 언어 글자가 없거나 길이가 어긋나면 거른다`() {
        assertFalse(AiResponseGuard.isPlausible("Hello there my friend, welcome", "Hello there my friend, welcome", "ko"))
        assertFalse(AiResponseGuard.isPlausible("Hi", "안녕하세요 ".repeat(30), "ko"))
        assertFalse(AiResponseGuard.isPlausible("a".repeat(100), "가", "ko"))
        assertFalse(AiResponseGuard.isPlausible("hello", "  ", "ko"))
    }

    @Test
    fun `원문을 다시 보여 준 줄은 지운다`() {
        assertEquals("안녕하세요", AiResponseGuard.stripEchoedSource("Hello there", "Hello there\n안녕하세요"))
        assertEquals("안녕하세요", AiResponseGuard.stripEchoedSource("Hello there", "Hello there - 안녕하세요"))
        assertEquals("안녕", AiResponseGuard.stripEchoedSource("Hello there", "안녕"))
    }

    @Test
    fun `가드 엔진은 이상한 응답을 오류로 바꿔 다음 엔진이 맡게 한다`() = runBlocking {
        val inner = object : TranslationEngine by NoopEngine {
            override val id = EngineId.GEMINI
            override suspend fun translate(request: TranslationRequest) = EngineResult.Ok(
                TranslationResult(if (request.text == "bad") "번역해 드릴게요" else "Hello there\n안녕하세요", "en", "ko", id),
            )
        }
        val guarded = GuardedTranslationEngine(inner)
        val bad = guarded.translate(TranslationRequest("bad", "en", "ko"))
        assertTrue((bad as EngineResult.Err).error is TranslationError.Unavailable)
        val ok = guarded.translate(TranslationRequest("Hello there", "en", "ko"))
        assertEquals("안녕하세요", (ok as EngineResult.Ok).value.text)
    }

    @Test
    fun `묶음 응답은 개수가 맞을 때만 꺼낸다`() {
        assertEquals(listOf("가", "나"), BatchTranslation.parse("""{"translations":["가","나"]}""", 2))
        assertEquals(listOf("가", "나"), BatchTranslation.parse("```json\n[\"가\",\"나\"]\n```", 2))
        assertNull(BatchTranslation.parse("""{"translations":["가"]}""", 2))
        assertNull(BatchTranslation.parse("번역해 드릴게요", 2))
        assertNull(BatchTranslation.parse("""{"translations":["가",""]}""", 2))
    }

    @Test
    fun `Gemini와 Groq는 블록을 한 번의 호출로 보낸다`() = runBlocking {
        var calls = 0
        val gemini = GeminiTranslationEngine({ "k" }, { _, _, _ ->
            calls++
            """{"candidates":[{"content":{"parts":[{"text":"{\"translations\":[\"하나\",\"둘\"]}"}]}}]}"""
        })
        val reqs = listOf(TranslationRequest("one", "en", "ko"), TranslationRequest("two", "en", "ko"))
        val out = gemini.translateBatch(reqs)
        assertEquals(1, calls)
        assertEquals(listOf("하나", "둘"), out.map { (it as EngineResult.Ok).value.text })

        calls = 0
        val groq = GroqTranslationEngine({ "k" }, { _, _ ->
            calls++
            """{"choices":[{"message":{"content":"{\"translations\":[\"하나\",\"둘\"]}"}}]}"""
        })
        assertEquals(listOf("하나", "둘"), groq.translateBatch(reqs).map { (it as EngineResult.Ok).value.text })
        assertEquals(1, calls)
    }

    private object NoopEngine : TranslationEngine {
        override val id = EngineId.ML_KIT
        override fun supports(language: String) = true
        override suspend fun translate(request: TranslationRequest): EngineResult<TranslationResult> = error("unused")
        override suspend fun isLanguageAvailable(language: String) = EngineResult.Ok(true)
        override suspend fun downloadLanguage(language: String, policy: ModelDownloadPolicy) = EngineResult.Ok(Unit)
        override suspend fun deleteLanguage(language: String) = EngineResult.Ok(Unit)
        override fun close() = Unit
    }
}
