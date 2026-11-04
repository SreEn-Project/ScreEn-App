package com.example.translation_poc_app.translate

import com.example.translation_poc_app.data.settings.AiTone
import com.example.translation_poc_app.data.settings.GlossaryEntry
import java.io.File
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

private class AssistRunner(val reply: (String) -> String) : LlmRunner {
    val prompts = mutableListOf<String>()
    override fun generate(prompt: String): String {
        prompts += prompt
        return reply(prompt)
    }
    override fun close() = Unit
}

private class StubEngine(private val out: String, override val id: EngineId = EngineId.ML_KIT) : TranslationEngine {
    val requests = mutableListOf<TranslationRequest>()
    override fun supports(language: String) = true
    override suspend fun translate(request: TranslationRequest): EngineResult<TranslationResult> {
        requests += request
        return EngineResult.Ok(TranslationResult(out, request.source, request.target, id))
    }
    override suspend fun isLanguageAvailable(language: String) = EngineResult.Ok(true)
    override suspend fun downloadLanguage(language: String, policy: ModelDownloadPolicy) = EngineResult.Ok(Unit)
    override suspend fun deleteLanguage(language: String) = EngineResult.Ok(Unit)
    override fun close() = Unit
}

class GemmaAssistTest {
    private fun assist(ready: Boolean, runner: AssistRunner, timeoutMs: Long = 5_000) = GemmaAssist(
        GemmaRuntime(modelFile = { File("model.task") }, isReady = { ready }, createRunner = { runner }),
        timeoutMs,
    )

    @Test
    fun `로그 - 호출 시간 · 입력 · 답 · 채택 여부를 남긴다`() {
        val lines = mutableListOf<String>()
        val runner = AssistRunner { "Hello World" }
        val a = GemmaAssist(
            GemmaRuntime(modelFile = { File("model.task") }, isReady = { true }, createRunner = { runner }),
            log = { lines += it },
        )
        runBlocking { a.fixOcr("He1lo W0rld", "en") }
        assertTrue(lines.any { it.contains("모델 응답") && it.contains("ms") })
        assertTrue(lines.any { it.contains("채택") && it.contains("He1lo W0rld") && it.contains("Hello World") })
    }

    @Test
    fun `로그 - 모델이 없으면 건너뜀을 남긴다`() {
        val lines = mutableListOf<String>()
        val runner = AssistRunner { "x" }
        val a = GemmaAssist(
            GemmaRuntime(modelFile = { File("model.task") }, isReady = { false }, createRunner = { runner }),
            log = { lines += it },
        )
        runBlocking { a.fixOcr("abc", "en") }
        assertTrue(lines.single().contains("건너뜀"))
    }

    @Test
    fun `OCR 보정 - 고친 글을 돌려준다`() {
        val runner = AssistRunner { "Hello World" }
        val r = runBlocking { assist(true, runner).fixOcr("He1lo W0rld", "en") }
        assertEquals("Hello World", r)
        assertTrue(runner.prompts.single().contains("He1lo W0rld"))
    }

    @Test
    fun `OK 답은 고칠 것 없음 - 원문 · 초벌 그대로`() {
        assertEquals("abc", GemmaAssist.acceptFix("abc", "OK"))
        assertEquals("abc", GemmaAssist.acceptFix("abc", "ok."))
        assertEquals("안녕", GemmaAssist.applyCorrections("안녕", "\"OK\"", emptyList()))
    }

    @Test
    fun `예열 - 모델이 있으면 실행기를 미리 만든다`() {
        var created = 0
        val rt = GemmaRuntime(modelFile = { File("m.task") }, isReady = { true }, createRunner = { created++; AssistRunner { "x" } })
        runBlocking { rt.warmUp(); rt.warmUp() }
        assertEquals(1, created)
    }

    @Test
    fun `예열 - 모델이 없으면 아무것도 안 한다`() {
        var created = 0
        val rt = GemmaRuntime(modelFile = { File("m.task") }, isReady = { false }, createRunner = { created++; AssistRunner { "x" } })
        runBlocking { rt.warmUp() }
        assertEquals(0, created)
    }

    @Test
    fun `OCR 보정 - 모델이 없으면 모델을 부르지 않고 원문`() {
        val runner = AssistRunner { "x" }
        assertEquals("abc", runBlocking { assist(false, runner).fixOcr("abc", "en") })
        assertTrue(runner.prompts.isEmpty())
    }

    @Test
    fun `OCR 보정 - 번역하거나 요약해 길이가 달라지면 원문`() {
        val original = "Press the button to continue"
        assertEquals(original, GemmaAssist.acceptFix(original, "계속하려면 버튼을 누르세요"))
        assertEquals(original, GemmaAssist.acceptFix(original, "Press"))
        assertEquals(original, GemmaAssist.acceptFix(original, "  "))
    }

    @Test
    fun `OCR 보정 - 실행기가 실패하면 원문`() {
        val runner = AssistRunner { error("boom") }
        assertEquals("abc", runBlocking { assist(true, runner).fixOcr("abc", "en") })
    }

    @Test
    fun `OCR 보정 - 제한 시간을 넘기면 원문`() {
        val runner = AssistRunner { Thread.sleep(300); "fixed" }
        assertEquals("abc", runBlocking { assist(true, runner, timeoutMs = 50).fixOcr("abc", "en") })
    }

    @Test
    fun `OCR 보정 - 너무 긴 글은 건너뛴다`() {
        val runner = AssistRunner { "x" }
        val long = "a".repeat(GemmaAssist.MAX_CHARS + 1)
        assertEquals(long, runBlocking { assist(true, runner).fixOcr(long, "en") })
        assertTrue(runner.prompts.isEmpty())
    }

    @Test
    fun `다듬기 - 말투도 용어집도 없어도 단어를 검토한다`() {
        val runner = AssistRunner { "안녕하세 => 안녕하세요" }
        val r = runBlocking { assist(true, runner).polish("hello", "안녕하세", "ko", AiTone.STANDARD, emptyList()) }
        assertEquals("안녕하세요", r)
        assertTrue(runner.prompts.single().contains("word by word"))
    }

    @Test
    fun `다듬기 - 모델이 없으면 초벌 그대로`() {
        val runner = AssistRunner { "x" }
        val r = runBlocking { assist(false, runner).polish("hello", "안녕", "ko", AiTone.STANDARD, emptyList()) }
        assertEquals("안녕", r)
        assertTrue(runner.prompts.isEmpty())
    }

    @Test
    fun `다듬기 - 말투와 이 글에 나오는 용어만 프롬프트에 넣는다`() {
        val runner = AssistRunner { "안녕." }
        val glossary = listOf(GlossaryEntry("Hello", "안녕"), GlossaryEntry("Other", "다른"))
        runBlocking { assist(true, runner).polish("Hello", "안녕하세요.", "ko", AiTone.INFORMAL, glossary) }
        val prompt = runner.prompts.single()
        assertTrue(prompt.contains("casual"))
        assertTrue(prompt.contains("Hello => 안녕"))
        assertTrue(!prompt.contains("Other"))
        assertTrue(prompt.contains("Draft:\n안녕하세요."))
    }

    @Test
    fun `다듬기 - 틀린 단어 쌍을 초벌에 직접 적용한다`() {
        val raw = "- 고양이를 => 고양이가\n\"야옹\" => \"미야옹\""
        assertEquals("고양이가 미야옹 운다", GemmaAssist.applyCorrections("고양이를 야옹 운다", raw, emptyList()))
    }

    @Test
    fun `다듬기 - 초벌에 없는 단어 · 같은 값 · 지나치게 긴 바꿈은 무시한다`() {
        val draft = "고양이가 있다"
        assertEquals(draft, GemmaAssist.applyCorrections(draft, "강아지 => 개", emptyList()))
        assertEquals(draft, GemmaAssist.applyCorrections(draft, "고양이 => 고양이", emptyList()))
        assertEquals(draft, GemmaAssist.applyCorrections(draft, "있다 => " + "아".repeat(40), emptyList()))
        assertEquals(draft, GemmaAssist.applyCorrections(draft, "고양이가 있다.", emptyList()))
    }

    @Test
    fun `다듬기 - 용어집 번역어를 없애는 바꿈은 무시한다`() {
        val terms = listOf(GlossaryEntry("cat", "고양이"))
        assertEquals("고양이가 있다", GemmaAssist.applyCorrections("고양이가 있다", "고양이 => 야옹이", terms))
        assertEquals("고양이가 있어", GemmaAssist.applyCorrections("고양이가 있다", "있다 => 있어", terms))
    }

    @Test
    fun `다듬기 - 한 번에 적용하는 쌍은 최대 개수까지`() {
        val raw = (1..20).joinToString("\n") { "w$it => x$it" }
        val draft = (1..20).joinToString(" ") { "w$it" }
        val out = GemmaAssist.applyCorrections(draft, raw, emptyList())
        assertTrue(out.contains("x${GemmaAssist.MAX_CORRECTIONS}"))
        assertTrue(!out.contains("x${GemmaAssist.MAX_CORRECTIONS + 1}"))
    }

    @Test
    fun `엔진 - 도우미가 꺼져 있으면 그대로 넘긴다`() {
        val inner = StubEngine("번역")
        val runner = AssistRunner { "x" }
        val r = runBlocking { GemmaAssistedEngine(inner, assist(true, runner)).translate(TranslationRequest("hi", "en", "ko")) }
        assertEquals("번역", (r as EngineResult.Ok).value.text)
        assertTrue(runner.prompts.isEmpty())
    }

    @Test
    fun `엔진 - OCR 보정한 글을 번역하고 번역을 다듬는다`() {
        val inner = StubEngine("안녕하세요")
        val runner = AssistRunner { prompt -> if (prompt.contains("OCR")) "Hello" else "안녕하세요 => 안녕" }
        val request = TranslationRequest("He1lo", "en", "ko", assist = AssistOptions(fixOcr = true, polish = true, tone = AiTone.INFORMAL))
        val r = runBlocking { GemmaAssistedEngine(inner, assist(true, runner)).translate(request) }
        assertEquals("Hello", inner.requests.single().text)
        assertEquals("안녕", (r as EngineResult.Ok).value.text)
    }

    @Test
    fun `엔진 - AI 엔진이 번역했으면 다듬지 않는다`() {
        val inner = StubEngine("안녕하세요", id = EngineId.GEMINI)
        val runner = AssistRunner { "x" }
        val request = TranslationRequest("hi", "en", "ko", assist = AssistOptions(polish = true, tone = AiTone.INFORMAL))
        val r = runBlocking { GemmaAssistedEngine(inner, assist(true, runner)).translate(request) }
        assertEquals("안녕하세요", (r as EngineResult.Ok).value.text)
        assertTrue(runner.prompts.isEmpty())
    }
}
