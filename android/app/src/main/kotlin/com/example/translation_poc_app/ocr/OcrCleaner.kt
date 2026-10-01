package com.example.translation_poc_app.ocr

/**
 * OCR 잡음 정리 (#19). 아이콘 · 구분선 · 상태 표시줄 숫자 같은 글자가 아닌 줄을 빼서
 * 언어 감지와 번역에 쓸데없는 호출이 가지 않게 한다. Android 의존 없음.
 */
object OcrCleaner {

    /** 글자(문자)가 하나도 없는 줄 — 기호 · 숫자뿐 — 은 번역할 게 없다. */
    fun isNoiseLine(text: String): Boolean = text.none { Character.isLetter(it) }

    /** 줄 안의 반복 공백 · 제어 문자를 정리한다. */
    fun cleanText(text: String): String =
        text.filter { !Character.isISOControl(it) || it == '\n' }
            .replace(Regex("[ \t\u00A0]+"), " ")
            .trim()

    /** 잡음 줄을 빼고 글자를 정리한다. 줄이 남지 않은 블록은 버린다. */
    fun clean(blocks: List<OcrBlock>): List<OcrBlock> = blocks.mapNotNull { block ->
        val kept = block.lines
            .map { it.copy(text = cleanText(it.text)) }
            .filter { it.text.isNotEmpty() && !isNoiseLine(it.text) }
        when {
            kept.isEmpty() -> null
            kept.size == block.lines.size && kept.zip(block.lines).all { (k, o) -> k.text == o.text } -> block
            else -> block.copy(text = kept.joinToString("\n") { it.text }, lines = kept)
        }
    }
}
