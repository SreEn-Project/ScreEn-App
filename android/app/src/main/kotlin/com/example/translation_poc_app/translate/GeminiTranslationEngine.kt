package com.example.translation_poc_app.translate

import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject

/** Gemini 호출 한 번. 실패는 [GeminiHttpException] · [IOException]으로 던진다. 테스트에서 바꿔 끼운다. */
fun interface GeminiTransport {
    suspend fun generate(apiKey: String, model: String, body: String): String
}

class GeminiHttpException(val code: Int, message: String?) : IOException("HTTP $code: $message")

/** 키가 없으면 null. 저장 방식(NA-13 후속)이 정해지면 구현을 연결한다. */
fun interface ApiKeyProvider {
    suspend fun key(): String?
}

/** [HttpURLConnection]으로 Gemini REST를 부른다 (새 의존성 없음). 키는 헤더로만 보낸다. */
class GeminiHttpTransport(private val timeoutMs: Int = 20_000) : GeminiTransport {
    override suspend fun generate(apiKey: String, model: String, body: String): String =
        withContext(Dispatchers.IO) {
            val conn = URL("$BASE/$model:generateContent").openConnection() as HttpURLConnection
            try {
                conn.requestMethod = "POST"
                conn.connectTimeout = timeoutMs
                conn.readTimeout = timeoutMs
                conn.doOutput = true
                conn.setRequestProperty("Content-Type", "application/json")
                conn.setRequestProperty("x-goog-api-key", apiKey)
                conn.outputStream.use { it.write(body.toByteArray()) }
                val code = conn.responseCode
                val stream = if (code in 200..299) conn.inputStream else conn.errorStream
                val text = stream?.bufferedReader()?.use { it.readText() }.orEmpty()
                if (code !in 200..299) throw GeminiHttpException(code, text.take(300))
                text
            } finally {
                conn.disconnect()
            }
        }

    private companion object {
        const val BASE = "https://generativelanguage.googleapis.com/v1beta/models"
    }
}

/**
 * Gemini AI 번역 엔진 (NA-13). 클라우드라 언어 모델이 없다. 키가 없으면 [TranslationError.Unavailable],
 * 네트워크 문제는 [TranslationError.Network]로 돌려준다 (대체는 [FallbackTranslationEngine]).
 */
class GeminiTranslationEngine(
    private val keys: ApiKeyProvider,
    private val transport: GeminiTransport = GeminiHttpTransport(),
    private val model: String = MODEL,
) : TranslationEngine {

    override val id = EngineId.GEMINI

    override fun supports(language: String) = language.isNotBlank()

    override suspend fun translate(request: TranslationRequest): EngineResult<TranslationResult> {
        if (request.text.isBlank() || request.source == request.target) {
            return EngineResult.Ok(TranslationResult(request.text, request.source, request.target, id))
        }
        return try {
            val key = keys.key()?.takeIf { it.isNotBlank() }
                ?: return EngineResult.Err(TranslationError.NoApiKey)
            val response = transport.generate(key, model, buildBody(request))
            val translated = parse(response)
                ?: return EngineResult.Err(TranslationError.Unknown("빈 응답"))
            EngineResult.Ok(TranslationResult(translated, request.source, request.target, id))
        } catch (e: CancellationException) {
            throw e
        } catch (e: GeminiHttpException) {
            EngineResult.Err(
                if (e.code == 429 || e.code >= 500) TranslationError.ServiceBusy
                else classifyClientError(e),
            )
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

    private fun classifyClientError(e: GeminiHttpException): TranslationError {
        return when {
            e.message?.contains("API_KEY_INVALID") == true || e.message?.contains("API key not valid") == true ->
                TranslationError.InvalidApiKey
            e.code == 403 -> TranslationError.AccessDenied
            else -> TranslationError.Unknown(e.message)
        }
    }

    companion object {
        const val MODEL = "gemini-2.5-flash"

        /** 프롬프트를 바꾸면 올린다 (캐시 키에 넣을 값). */
        const val PROMPT_VERSION = 1

        internal fun buildBody(request: TranslationRequest): String {
            val from = if (request.source == AUTO_LANGUAGE) "the source language (detect it)" else request.source
            val system = "You translate text captured from a phone screen. Translate from $from to " +
                "${request.target}. Keep line breaks, numbers, names and symbols. " +
                "Reply with the translation only, no notes or quotes."
            return JSONObject()
                .put("systemInstruction", JSONObject().put("parts", JSONArray().put(JSONObject().put("text", system))))
                .put("contents", JSONArray().put(JSONObject().put("parts", JSONArray().put(JSONObject().put("text", request.text)))))
                .put("generationConfig", JSONObject().put("temperature", 0))
                .toString()
        }

        internal fun parse(response: String): String? =
            JSONObject(response).optJSONArray("candidates")?.optJSONObject(0)
                ?.optJSONObject("content")?.optJSONArray("parts")?.optJSONObject(0)
                ?.optString("text")?.trim()?.takeIf { it.isNotEmpty() }
    }
}
