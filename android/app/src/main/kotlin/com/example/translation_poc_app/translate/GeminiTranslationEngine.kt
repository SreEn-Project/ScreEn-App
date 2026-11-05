package com.example.translation_poc_app.translate

import com.example.translation_poc_app.data.settings.AiTone
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import kotlinx.coroutines.CancellationException
import org.json.JSONArray
import org.json.JSONObject

/** Gemini 호출 한 번. 실패는 [GeminiHttpException] · [IOException]으로 던진다. 테스트에서 바꿔 끼운다. */
fun interface GeminiTransport {
    suspend fun generate(apiKey: String, model: String, body: String): String
}

class GeminiHttpException(val code: Int, val body: String) : IOException("HTTP $code: $body")

/** 키가 없으면 null. 저장 방식(NA-13 후속)이 정해지면 구현을 연결한다. */
fun interface ApiKeyProvider {
    suspend fun key(): String?
}

/** [HttpURLConnection]으로 Gemini REST를 부른다 (새 의존성 없음). 키는 헤더로만 보낸다. */
class GeminiHttpTransport(private val timeoutMs: Int = 20_000) : GeminiTransport {
    override suspend fun generate(apiKey: String, model: String, body: String): String =
        run {
            val conn = URL("$BASE/$model:generateContent").openConnection() as HttpURLConnection
            runCancellableHttp(conn) {
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
    private val models: List<String> = MODELS,
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
            val response = generateWithFallback(transport, key, models, buildBody(request))
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
        /** 앞에서부터 시도한다. 모델이 없으면(404) 다음 모델로. 2.5 계열은 새 프로젝트에서 막혀 있다. */
        val MODELS = listOf("gemini-3.5-flash-lite", "gemini-3.1-flash-lite")

        /** 프롬프트를 바꾸면 올린다 (캐시 키에 넣을 값). */
        const val PROMPT_VERSION = 2

        internal fun buildBody(request: TranslationRequest): String {
            val from = if (request.source == AUTO_LANGUAGE) "the source language (detect it)" else request.source
            val system = systemPrompt(request, from)
            return JSONObject()
                .put("systemInstruction", JSONObject().put("parts", JSONArray().put(JSONObject().put("text", system))))
                .put("contents", JSONArray().put(JSONObject().put("parts", JSONArray().put(JSONObject().put("text", request.text)))))
                .put("generationConfig", JSONObject().put("temperature", 0))
                .toString()
        }

        /** 말투(FL-11)와 용어집(FL-11)을 덧붙인 지시문. 용어집은 이 글에 나오는 항목만 넣어 요청을 작게 유지한다. */
        internal fun systemPrompt(request: TranslationRequest, from: String): String {
            val sb = StringBuilder(
                "You translate text captured from a phone screen. Translate from $from to " +
                    "${request.target}. Keep line breaks, numbers, names and symbols. " +
                    "Reply with the translation only, no notes or quotes.",
            )
            when (request.style.tone) {
                AiTone.STANDARD -> Unit
                AiTone.FORMAL -> sb.append(" Use a polite, formal speech level (for example 존댓말 in Korean, 敬語 in Japanese).")
                AiTone.INFORMAL -> sb.append(" Use a casual, informal speech level (for example 반말 in Korean, タメ口 in Japanese).")
            }
            val lowered = request.text.lowercase()
            val terms = request.style.glossary.filter { lowered.contains(it.source.lowercase()) }
            if (terms.isNotEmpty()) {
                sb.append(" Always translate these terms exactly as given, never differently:")
                terms.forEach { sb.append("\n- ").append(it.source).append(" => ").append(it.target) }
            }
            return sb.toString()
        }

        internal fun parse(response: String): String? =
            JSONObject(response).optJSONArray("candidates")?.optJSONObject(0)
                ?.optJSONObject("content")?.optJSONArray("parts")?.optJSONObject(0)
                ?.optString("text")?.trim()?.takeIf { it.isNotEmpty() }
    }
}

/** [models]를 차례로 시도한다. 404(모델 없음 · 접근 불가)일 때만 다음 모델로 넘어가고, 다른 오류는 그대로 던진다. */
internal suspend fun generateWithFallback(
    transport: GeminiTransport,
    key: String,
    models: List<String>,
    body: String,
): String {
    var last: GeminiHttpException? = null
    for (model in models) {
        try {
            return transport.generate(key, model, body)
        } catch (e: GeminiHttpException) {
            if (e.code != 404) throw e
            last = e
        }
    }
    throw last ?: IllegalArgumentException("모델 목록이 비어 있음")
}
