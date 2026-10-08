package com.example.translation_poc_app.translate

import com.example.translation_poc_app.data.settings.AiTone
import java.io.IOException
import kotlinx.coroutines.runBlocking
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

private fun groqReply(text: String) = """{"choices":[{"message":{"role":"assistant","content":"$text"}}]}"""

class GroqTranslationEngineTest {
    private val request = TranslationRequest("hello", "en", "ko")

    private fun run(keys: ApiKeyProvider, transport: GroqTransport) =
        runBlocking { GroqTranslationEngine(keys, transport).translate(request) }

    @Test
    fun `응답에서 번역문을 꺼낸다`() {
        val r = run({ "k" }, { _, _ -> groqReply("안녕") })
        assertEquals("안녕", (r as EngineResult.Ok).value.text)
        assertEquals(EngineId.GROQ, r.value.engine)
    }

    @Test
    fun `키가 없으면 호출하지 않고 NoApiKey`() {
        var called = false
        val r = run({ null }, { _, _ -> called = true; "" })
        assertEquals(TranslationError.NoApiKey, (r as EngineResult.Err).error)
        assertTrue(!called)
    }

    @Test
    fun `오류를 종류별로 나눈다`() {
        fun err(t: GroqTransport) = (run({ "k" }, t) as EngineResult.Err).error
        assertEquals(TranslationError.Network, err { _, _ -> throw IOException() })
        assertEquals(TranslationError.ServiceBusy, err { _, _ -> throw GroqHttpException(429, "") })
        assertEquals(TranslationError.ServiceBusy, err { _, _ -> throw GroqHttpException(503, "") })
        assertEquals(TranslationError.InvalidApiKey, err { _, _ -> throw GroqHttpException(401, "invalid_api_key") })
        assertEquals(TranslationError.AccessDenied, err { _, _ -> throw GroqHttpException(403, "") })
        assertTrue(err { _, _ -> throw GroqHttpException(400, "bad") } is TranslationError.Unknown)
    }

    @Test
    fun `빈 응답은 Unknown`() {
        assertTrue((run({ "k" }, { _, _ -> """{"choices":[]}""" }) as EngineResult.Err).error is TranslationError.Unknown)
    }

    @Test
    fun `원문과 대상이 같으면 호출하지 않는다`() {
        var called = false
        val same = TranslationRequest("hi", "ko", "ko")
        runBlocking { GroqTranslationEngine({ "k" }, { _, _ -> called = true; "" }).translate(same) }
        assertTrue(!called)
    }

    @Test
    fun `본문은 모델과 system user 메시지, 온도 0`() {
        val styled = TranslationRequest("hello", "en", "ko", AiStyle(AiTone.FORMAL, emptyList()))
        val body = JSONObject(GroqTranslationEngine.buildBody(styled, "m1"))
        assertEquals("m1", body.getString("model"))
        assertEquals(0, body.getInt("temperature"))
        val messages = body.getJSONArray("messages")
        assertEquals("system", messages.getJSONObject(0).getString("role"))
        assertTrue(messages.getJSONObject(0).getString("content").contains("polite"))
        assertEquals("user", messages.getJSONObject(1).getString("role"))
        assertEquals("hello", messages.getJSONObject(1).getString("content"))
    }

    @Test
    fun `404나 내려진 모델이면 다음 모델로, 그 외 오류는 바로 던진다`() = runBlocking {
        val tried = mutableListOf<String>()
        val ok = chatWithFallback({ _, body ->
            val model = JSONObject(body).getString("model")
            tried += model
            if (model == "a") throw GroqHttpException(400, """{"error":{"code":"model_decommissioned"}}""") else "ok"
        }, "k", listOf("a", "b")) { m -> """{"model":"$m"}""" }
        assertEquals("ok", ok)
        assertEquals(listOf("a", "b"), tried)

        var thrown: GroqHttpException? = null
        try {
            chatWithFallback({ _, _ -> throw GroqHttpException(401, "x") }, "k", listOf("a", "b")) { "{}" }
        } catch (e: GroqHttpException) {
            thrown = e
        }
        assertEquals(401, thrown?.code)
    }
}

class GroqKeyTesterTest {
    private fun test(key: String = "k", transport: GroqTransport) = runBlocking { GroqKeyTester.test(key, transport) }

    @Test
    fun `성공이면 null`() = assertNull(test { _, _ -> groqReply("안녕") })

    @Test
    fun `Groq가 알려 준 이유를 그대로 돌려준다`() {
        val body = """{"error":{"message":"Invalid API Key","type":"invalid_request_error","code":"invalid_api_key"}}"""
        assertEquals("(401) Invalid API Key", test { _, _ -> throw GroqHttpException(401, body) })
    }

    @Test
    fun `오프라인은 안내 문장`() {
        assertEquals("네트워크에 연결하지 못했어요", test { _, _ -> throw IOException() })
    }

    @Test
    fun `키의 공백은 걷어 내고 보낸다`() {
        var sent = ""
        test(" a b\n") { key, _ -> sent = key; "{}" }
        assertEquals("ab", sent)
    }
}

class GroqDictionaryTest {
    private fun define(transport: GroqTransport) =
        runBlocking { GroqDictionary({ "k" }, transport).define("run", "I run fast", "en", "ko") }

    @Test
    fun `JSON 풀이를 읽는다`() {
        val content = """{\"meaning\":\"달리다\",\"pronunciation\":\"rʌn\",\"partOfSpeech\":\"동사\",\"contextMeaning\":\"빠르게 달리다\"}"""
        val r = define { _, _ -> groqReply(content) } as EngineResult.Ok
        assertEquals("달리다", r.value.meaning)
        assertEquals("빠르게 달리다", r.value.contextMeaning)
    }

    @Test
    fun `JSON 모드로 요청한다`() {
        var body = ""
        define { _, b -> body = b; groqReply("{}") }
        assertEquals("json_object", JSONObject(body).getJSONObject("response_format").getString("type"))
    }

    @Test
    fun `한도 초과는 ServiceBusy`() {
        assertEquals(TranslationError.ServiceBusy, (define { _, _ -> throw GroqHttpException(429, "") } as EngineResult.Err).error)
    }
}
