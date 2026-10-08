package com.example.translation_poc_app.translate

import java.io.IOException
import kotlinx.coroutines.CancellationException
import org.json.JSONObject

/** 입력한 Groq 키로 짧게 번역해 보고 실패 이유를 사람이 읽는 문장으로 돌려준다 (NA-13). */
object GroqKeyTester {

    /** 성공이면 null. */
    suspend fun test(apiKey: String, transport: GroqTransport = GroqHttpTransport()): String? =
        try {
            val request = TranslationRequest("hello", "en", "ko")
            chatWithFallback(transport, apiKey.filterNot { it.isWhitespace() }, GroqTranslationEngine.MODELS) {
                GroqTranslationEngine.buildBody(request, it)
            }
            null
        } catch (e: CancellationException) {
            throw e
        } catch (e: GroqHttpException) {
            describe(e)
        } catch (e: IOException) {
            "네트워크에 연결하지 못했어요"
        } catch (e: Exception) {
            e.message ?: "알 수 없는 오류"
        }

    /** 응답 본문의 error.message를 꺼낸다. 없으면 HTTP 코드. */
    internal fun describe(e: GroqHttpException): String {
        val reason = try {
            JSONObject(e.body).optJSONObject("error")?.optString("message")?.takeIf { it.isNotBlank() }
        } catch (_: Exception) {
            null
        }
        return "(${e.code}) ${reason ?: e.body.take(200)}"
    }
}
