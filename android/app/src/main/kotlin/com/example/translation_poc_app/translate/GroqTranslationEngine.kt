package com.example.translation_poc_app.translate

import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject

/** Groq 호출 한 번. 실패는 [GroqHttpException] · [IOException]으로 던진다. 테스트에서 바꿔 끼운다. */
fun interface GroqTransport {
    suspend fun chat(apiKey: String, body: String): String
}

class GroqHttpException(val code: Int, val body: String) : IOException("HTTP $code: $body")

/** [HttpURLConnection]으로 Groq REST(OpenAI 호환)를 부른다 (새 의존성 없음). 키는 헤더로만 보낸다. */
class GroqHttpTransport(private val timeoutMs: Int = 20_000) : GroqTransport {
    override suspend fun chat(apiKey: String, body: String): String =
        withContext(Dispatchers.IO) {
            val conn = URL(URL_CHAT).openConnection() as HttpURLConnection
            try {
                conn.requestMethod = "POST"
                conn.connectTimeout = timeoutMs
                conn.readTimeout = timeoutMs
                conn.doOutput = true
                conn.setRequestProperty("Content-Type", "application/json")
                conn.setRequestProperty("Authorization", "Bearer $apiKey")
                conn.outputStream.use { it.write(body.toByteArray()) }
                val code = conn.responseCode
                val stream = if (code in 200..299) conn.inputStream else conn.errorStream
                val text = stream?.bufferedReader()?.use { it.readText() }.orEmpty()
                if (code !in 200..299) throw GroqHttpException(code, text.take(300))
                text
            } finally {
                conn.disconnect()
            }
        }

    private companion object {
        const val URL_CHAT = "https://api.groq.com/openai/v1/chat/completions"
    }
}

/**
 * Groq AI 번역 엔진 (NA-13). Gemini와 같은 BYOK 방식이다. 키가 없으면 [TranslationError.NoApiKey],
 * 네트워크 문제는 [TranslationError.Network]로 돌려준다 (대체는 [FallbackTranslationEngine]).
 */
class GroqTranslationEngine(
    private val keys: ApiKeyProvider,
    private val transport: GroqTransport = GroqHttpTransport(),
    private val models: List<String> = MODELS,
) : TranslationEngine {

    override val id = EngineId.GROQ

    override fun supports(language: String) = language.isNotBlank()

    override suspend fun translate(request: TranslationRequest): EngineResult<TranslationResult> {
        if (request.text.isBlank() || request.source == request.target) {
            return EngineResult.Ok(TranslationResult(request.text, request.source, request.target, id))
        }
        return try {
            val key = keys.key()?.takeIf { it.isNotBlank() }
                ?: return EngineResult.Err(TranslationError.NoApiKey)
            val response = chatWithFallback(transport, key, models) { buildBody(request, it) }
            val translated = parse(response)
                ?: return EngineResult.Err(TranslationError.Unknown("빈 응답"))
            EngineResult.Ok(TranslationResult(translated, request.source, request.target, id))
        } catch (e: CancellationException) {
            throw e
        } catch (e: GroqHttpException) {
            EngineResult.Err(classify(e))
        } catch (e: IOException) {
            EngineResult.Err(TranslationError.Network)
        } catch (e: Exception) {
            EngineResult.Err(TranslationError.Unknown(e.message))
        }
    }

    override suspend fun isLanguageAvailable(language: String): EngineResult<Boolean> = EngineResult.Ok(true)

    override suspend fun downloadLanguage(language: String, policy: ModelDownloadPolicy): EngineResult<Unit> =
        EngineResult.Ok(Unit)

    override suspend fun deleteLanguage(language: String): EngineResult<Unit> = EngineResult.Ok(Unit)

    override fun close() = Unit

    companion object {
        /**
         * 앞에서부터 시도한다. 모델이 없거나 내려졌으면 다음 모델로.
         * 70B는 한국어 · 일본어 번역이 8B보다 안정적이고, 8B는 한도가 넉넉한 예비다.
         */
        val MODELS = listOf("llama-3.3-70b-versatile", "llama-3.1-8b-instant")

        /** 프롬프트를 바꾸면 올린다 (캐시 키에 넣을 값). Gemini와 같은 지시문을 쓴다. */
        const val PROMPT_VERSION = GeminiTranslationEngine.PROMPT_VERSION

        internal fun classify(e: GroqHttpException): TranslationError = when {
            e.code == 429 || e.code >= 500 -> TranslationError.ServiceBusy
            e.code == 401 -> TranslationError.InvalidApiKey
            e.code == 403 -> TranslationError.AccessDenied
            else -> TranslationError.Unknown(e.message)
        }

        internal fun buildBody(request: TranslationRequest, model: String): String {
            val from = if (request.source == AUTO_LANGUAGE) "the source language (detect it)" else request.source
            return chatBody(model, GeminiTranslationEngine.systemPrompt(request, from), request.text)
        }

        /** system + user 두 메시지로 된 chat/completions 본문. [json]이면 JSON 객체로만 답하게 한다. */
        internal fun chatBody(model: String, system: String, user: String, json: Boolean = false): String {
            val body = JSONObject()
                .put("model", model)
                .put(
                    "messages",
                    JSONArray()
                        .put(JSONObject().put("role", "system").put("content", system))
                        .put(JSONObject().put("role", "user").put("content", user)),
                )
                .put("temperature", 0)
            if (json) body.put("response_format", JSONObject().put("type", "json_object"))
            return body.toString()
        }

        internal fun parse(response: String): String? =
            JSONObject(response).optJSONArray("choices")?.optJSONObject(0)
                ?.optJSONObject("message")?.optString("content")?.trim()?.takeIf { it.isNotEmpty() }
    }
}

/**
 * [models]를 차례로 시도한다. 모델이 없거나(404) 내려졌을 때(model_decommissioned · model_not_found)만
 * 다음 모델로 넘어가고, 다른 오류는 그대로 던진다. [body]는 모델 이름을 받아 요청 본문을 만든다.
 */
internal suspend fun chatWithFallback(
    transport: GroqTransport,
    key: String,
    models: List<String>,
    body: (model: String) -> String,
): String {
    var last: GroqHttpException? = null
    for (model in models) {
        try {
            return transport.chat(key, body(model))
        } catch (e: GroqHttpException) {
            val gone = e.code == 404 || e.body.contains("model_decommissioned") || e.body.contains("model_not_found")
            if (!gone) throw e
            last = e
        }
    }
    throw last ?: IllegalArgumentException("모델 목록이 비어 있음")
}
