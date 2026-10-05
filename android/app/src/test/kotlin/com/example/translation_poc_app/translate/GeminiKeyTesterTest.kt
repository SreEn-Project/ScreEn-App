package com.example.translation_poc_app.translate

import java.io.IOException
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class GeminiKeyTesterTest {
    private fun test(key: String = "k", transport: GeminiTransport) = runBlocking { GeminiKeyTester.test(key, transport) }

    @Test
    fun `성공이면 null`() = assertNull(test { _, _, _ -> """{"candidates":[]}""" })

    @Test
    fun `구글이 알려 준 이유를 그대로 돌려준다`() {
        val body = """{"error":{"code":400,"message":"API key not valid. Please pass a valid API key."}}"""
        assertEquals(
            "(400) API key not valid. Please pass a valid API key.",
            test { _, _, _ -> throw GeminiHttpException(400, body) },
        )
    }

    @Test
    fun `본문이 JSON이 아니면 코드와 본문 일부`() {
        assertEquals("(503) busy", test { _, _, _ -> throw GeminiHttpException(503, "busy") })
    }

    @Test
    fun `오프라인은 안내 문장`() {
        assertEquals("네트워크에 연결하지 못했어요", test { _, _, _ -> throw IOException() })
    }

    @Test
    fun `키의 공백은 걷어 내고 보낸다`() {
        var sent = ""
        test(" a b\n") { key, _, _ -> sent = key; "{}" }
        assertEquals("ab", sent)
    }
}

class GeminiModelFallbackTest {
    @Test
    fun `404면 다음 모델로 시도한다`() = runBlocking {
        val tried = mutableListOf<String>()
        val result = generateWithFallback({ _, model, _ ->
            tried += model
            if (model == "a") throw GeminiHttpException(404, "nf") else "ok"
        }, "k", listOf("a", "b"), "{}")
        assertEquals("ok", result)
        assertEquals(listOf("a", "b"), tried)
    }

    @Test(expected = GeminiHttpException::class)
    fun `404가 아닌 오류는 바로 던진다`() {
        runBlocking { generateWithFallback({ _, _, _ -> throw GeminiHttpException(403, "x") }, "k", listOf("a", "b"), "{}") }
    }
}
