package com.example.translation_poc_app.overlay

import java.text.BreakIterator

/** 화면에서 고른 단어 하나 (AD-01). [sentence]는 단어가 든 원래 글(문맥 뜻 · 문맥 예문에 쓴다). */
data class WordTarget(
    val word: String,
    val sentence: String?,
    /** 원문 언어 코드. 모르면 빈 문자열(엔진이 감지). */
    val sourceLanguage: String,
)

/** 글에서 탭한 자리의 단어 찾기 (AD-01). 안드로이드의 BreakIterator는 일본어 · 중국어도 단어로 끊는다. */
internal object WordSelection {
    /** [offset] 위치가 속한 단어의 범위. 글자나 숫자가 없는 자리(공백 · 기호)면 null. */
    fun wordRange(text: String, offset: Int): IntRange? {
        if (text.isEmpty()) return null
        val iterator = BreakIterator.getWordInstance().apply { setText(text) }
        val at = offset.coerceIn(0, text.length - 1)
        val end = iterator.following(at).takeIf { it != BreakIterator.DONE } ?: text.length
        val start = iterator.preceding(end).takeIf { it != BreakIterator.DONE } ?: 0
        if (start >= end) return null
        val word = text.substring(start, end)
        return if (word.any { it.isLetterOrDigit() }) start until end else null
    }

    /** [offset]의 단어. 없으면 null. */
    fun wordAt(text: String, offset: Int): String? = wordRange(text, offset)?.let { text.substring(it) }
}
