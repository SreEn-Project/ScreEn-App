package com.example.translation_poc_app.translate

import java.io.File
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

private class FakeRunner(val reply: (String) -> String) : LlmRunner {
    val prompts = mutableListOf<String>()
    var closed = false
    override fun generate(prompt: String): String {
        prompts += prompt
        return reply(prompt)
    }
    override fun close() {
        closed = true
    }
}

class GemmaTranslationEngineTest {
    private val request = TranslationRequest("hello", "en", "ko")

    private fun runtime(ready: Boolean, runner: FakeRunner) =
        GemmaRuntime(modelFile = { File("model.task") }, isReady = { ready }, createRunner = { runner })

    @Test
    fun `모델이 없으면 실행하지 않고 ModelNotDownloaded`() {
        val runner = FakeRunner { "x" }
        val r = runBlocking { GemmaTranslationEngine(runtime(false, runner)).translate(request) }
        assertTrue((r as EngineResult.Err).error is TranslationError.ModelNotDownloaded)
        assertTrue(runner.prompts.isEmpty())
    }

    @Test
    fun `모델 답에서 종료 표식과 머리말을 걷어낸다`() {
        val runner = FakeRunner { "Translation: \"안녕\"<end_of_turn>" }
        val r = runBlocking { GemmaTranslationEngine(runtime(true, runner)).translate(request) }
        val ok = r as EngineResult.Ok
        assertEquals("안녕", ok.value.text)
        assertEquals(EngineId.GEMMA, ok.value.engine)
    }

    @Test
    fun `프롬프트는 Gemma 대화 형식이고 원문이 들어간다`() {
        val runner = FakeRunner { "안녕" }
        runBlocking { GemmaTranslationEngine(runtime(true, runner)).translate(request) }
        val prompt = runner.prompts.single()
        assertTrue(prompt.startsWith("<start_of_turn>user\n"))
        assertTrue(prompt.endsWith("<end_of_turn>\n<start_of_turn>model\n"))
        assertTrue(prompt.contains("hello"))
        // 코드(ko)가 아니라 언어 이름으로 도착 언어를 지시한다.
        assertTrue(prompt.contains("to Korean"))
        assertTrue(prompt.contains("only the Korean translation"))
    }

    @Test
    fun `실행기가 실패하면 Unavailable`() {
        val runner = FakeRunner { error("boom") }
        val r = runBlocking { GemmaTranslationEngine(runtime(true, runner)).translate(request) }
        assertTrue((r as EngineResult.Err).error is TranslationError.Unavailable)
    }

    @Test
    fun `같은 언어이거나 빈 글은 그대로 돌려준다`() {
        val runner = FakeRunner { "x" }
        val engine = GemmaTranslationEngine(runtime(true, runner))
        val same = runBlocking { engine.translate(TranslationRequest("hi", "ko", "ko")) }
        assertEquals("hi", (same as EngineResult.Ok).value.text)
        assertTrue(runner.prompts.isEmpty())
    }

    @Test
    fun `긴 글은 줄 단위로 잘라 차례로 번역해 줄바꿈으로 잇는다`() {
        val line = "a".repeat(300)
        val text = listOf(line, line, line).joinToString("\n")
        val runner = FakeRunner { "T" }
        val r = runBlocking { GemmaTranslationEngine(runtime(true, runner)).translate(TranslationRequest(text, "en", "ko")) }
        assertEquals(3, runner.prompts.size)
        assertEquals("T\nT\nT", (r as EngineResult.Ok).value.text)
    }

    @Test
    fun `languageName은 코드를 영어 이름으로 바꾼다`() {
        assertEquals("Korean", GemmaTranslationEngine.languageName("ko"))
        assertEquals("English", GemmaTranslationEngine.languageName("en"))
        assertEquals("Japanese", GemmaTranslationEngine.languageName("ja"))
    }

    @Test
    fun `chunk는 한도를 넘지 않는다`() {
        val long = "문장입니다. ".repeat(200)
        val chunks = GemmaTranslationEngine.chunk(long, 100)
        assertTrue(chunks.size > 1)
        assertTrue(chunks.all { it.length <= 100 })
    }

    @Test
    fun `runtime unload는 실행기를 닫는다`() {
        val runner = FakeRunner { "x" }
        val rt = runtime(true, runner)
        runBlocking {
            rt.generate("p")
            rt.unload()
        }
        assertTrue(runner.closed)
    }
}
