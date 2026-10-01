package com.example.translation_poc_app.translate

import com.example.translation_poc_app.capture.CaptureResult
import com.example.translation_poc_app.data.settings.Settings
import com.example.translation_poc_app.ocr.OcrBlock
import com.example.translation_poc_app.ocr.OcrLine
import com.example.translation_poc_app.ocr.OcrResult
import com.example.translation_poc_app.ocr.Script
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class BlockCacheTest {

    @Test
    fun `가장 오래 안 쓴 항목부터 밀려난다`() {
        val cache = BlockCache<String, Int>(capacity = 2)
        cache["a"] = 1
        cache["b"] = 2
        cache["a"] // a를 최근에 씀
        cache["c"] = 3
        assertEquals(1, cache["a"])
        assertNull(cache["b"])
        assertEquals(3, cache["c"])
        assertEquals(2, cache.size)
    }

    // ── 파이프라인: 안 바뀐 블록은 감지 · 번역을 건너뛴다 ─────────────────────

    private class CountingEngine : TranslationEngine {
        override val id = EngineId.ML_KIT
        val requests = mutableListOf<String>()
        var fail = false
        override fun supports(language: String) = true
        override suspend fun translate(request: TranslationRequest): EngineResult<TranslationResult> {
            requests += request.text
            return if (fail) {
                EngineResult.Err(TranslationError.Network)
            } else {
                EngineResult.Ok(TranslationResult("번역:" + request.text, request.source, request.target, id))
            }
        }
        override suspend fun isLanguageAvailable(language: String) = EngineResult.Ok(true)
        override suspend fun downloadLanguage(language: String, policy: ModelDownloadPolicy) = EngineResult.Ok(Unit)
        override suspend fun deleteLanguage(language: String) = EngineResult.Ok(Unit)
        override fun close() = Unit
    }

    private fun block(text: String) = OcrBlock(text, null, listOf(OcrLine(text, null, 1f)), "und")

    private val detected = mutableListOf<String>()

    private val pipeline = TranslationPipeline(
        capture = { CaptureResult.Failed("unused") },
        recognize = { error("unused") },
        detect = { ocr, _ ->
            ocr.blocks.map {
                detected += it.text
                DetectedBlock(it, BlockDecision("en", BlockAction.TRANSLATE))
            }
        },
        engineFor = { error("unused") },
        settings = { Settings() },
    )

    private fun ocr(vararg texts: String) = OcrResult(Script.LATIN, texts.map(::block))

    @Test
    fun `같은 글자는 두 번째부터 언어 감지를 건너뛴다`() = runTest {
        val first = ocr("Hello", "World")
        pipeline.detectCached(first, first.blocks, "ko")
        assertEquals(listOf("Hello", "World"), detected)

        // 스크롤해서 Hello는 남고 Again이 새로 나타났다.
        val second = ocr("Hello", "Again")
        val result = pipeline.detectCached(second, second.blocks, "ko")
        assertEquals(listOf("Hello", "World", "Again"), detected) // Again만 새로 감지
        assertEquals(listOf("Hello", "Again"), result.map { it.block.text }) // 순서 유지
    }

    @Test
    fun `대상 언어가 바뀌면 감지 캐시가 맞지 않는다`() = runTest {
        val o = ocr("Hello")
        pipeline.detectCached(o, o.blocks, "ko")
        pipeline.detectCached(o, o.blocks, "ja")
        assertEquals(listOf("Hello", "Hello"), detected)
    }

    @Test
    fun `같은 번역은 엔진을 다시 부르지 않고 실패는 캐시하지 않는다`() = runTest {
        val engine = CountingEngine()
        val hits = mutableListOf<Int>()
        val requests = listOf(
            TranslationRequest("Hello", "en", "ko"),
            TranslationRequest("World", "en", "ko"),
        )
        val first = pipeline.translateAll(engine, requests) { hits += 1 }
        assertEquals(listOf("Hello", "World"), engine.requests)
        assertEquals(0, hits.size)

        // 두 번째: 전부 캐시에서. 결과 순서도 그대로.
        val second = pipeline.translateAll(engine, requests) { hits += 1 }
        assertEquals(2, engine.requests.size)
        assertEquals(2, hits.size)
        assertEquals(first, second)

        // 실패한 번역은 다음에 다시 시도한다.
        engine.fail = true
        val failed = pipeline.translateAll(engine, listOf(TranslationRequest("New", "en", "ko"))) {}
        assertEquals(EngineResult.Err(TranslationError.Network), failed.single())
        engine.fail = false
        val retried = pipeline.translateAll(engine, listOf(TranslationRequest("New", "en", "ko"))) {}
        assertEquals("번역:New", (retried.single() as EngineResult.Ok).value.text)
    }
}
