package com.example.translation_poc_app.translate

import org.json.JSONArray
import org.json.JSONObject

/**
 * 한 화면의 모든 블록을 요청 한 번으로 번역하는 묶음 형식 (AI 엔진 공통).
 * 입력은 JSON 문자열 배열, 출력은 {"translations":[...]} 객체로 고정해 대답 문장이 섞여도 번역문만 꺼낸다.
 */
internal object BatchTranslation {

    /** 같은 (원문 언어, 대상 언어, 말투) 요청끼리 묶은 위치 목록. */
    fun groups(requests: List<TranslationRequest>): List<List<Int>> =
        requests.indices.groupBy { Triple(requests[it].source, requests[it].target, requests[it].style) }.values.toList()

    /** 묶음용 시스템 지시문. 단건 지시문(말투 · 용어집 포함)에 형식 규칙을 덧붙인다. */
    fun systemPrompt(first: TranslationRequest, joinedText: String, from: String): String =
        GeminiTranslationEngine.systemPrompt(first.copy(text = joinedText), from)
            .replace("Reply with the translation only, no notes or quotes.", "")
            .trim() + " " + FORMAT_RULES

    const val FORMAT_RULES =
        "The user message is a JSON array of strings. Translate every string independently and keep the order. " +
            "Reply with only a JSON object {\"translations\": [...]} that has exactly one translated string per input string. " +
            "Each translation contains only the translated text: never repeat or quote the original, never add notes, " +
            "greetings or explanations."

    fun userText(texts: List<String>): String = JSONArray(texts).toString()

    /** 모델 응답에서 번역 배열을 꺼낸다. 개수가 [expected]와 다르거나 형식이 틀리면 null. */
    fun parse(raw: String, expected: Int): List<String>? {
        val body = raw.trim().removePrefix("```json").removePrefix("```").removeSuffix("```").trim()
        return try {
            val array = if (body.startsWith("[")) JSONArray(body) else JSONObject(body).optJSONArray("translations")
            if (array == null || array.length() != expected) return null
            List(expected) { array.optString(it, "").trim() }.takeIf { list -> list.none { it.isEmpty() } }
        } catch (e: org.json.JSONException) {
            null
        }
    }
}
