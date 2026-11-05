package com.example.translation_poc_app.ocr

/**
 * 그림 속 아주 작은 글자 거르기 (#178). 화면 높이에 견줘 글자 높이가 아주 작은 줄은 사진 · 로고 ·
 * 배경 무늬일 가능성이 높아 잡음 번역이 된다. 높이가 작을수록 더 높은 신뢰도를 요구하고,
 * 짧은 라틴 조각(기호 사이 한두 글자)은 신뢰도가 낮으면 뺀다. Android 의존 없음 (높이는 [heightOf]로 받는다).
 */
object OcrTinyTextFilter {

    /** 줄 높이가 화면 높이의 이 비율 미만이면 신뢰도와 상관없이 버린다 (2400px 화면에서 약 12px). */
    const val DROP_HEIGHT_RATIO = 0.005f

    /** 줄 높이가 이 비율 미만이면 [TINY_MIN_CONFIDENCE] 이상일 때만 남긴다 (2400px 화면에서 약 19px). */
    const val TINY_HEIGHT_RATIO = 0.008f
    const val TINY_MIN_CONFIDENCE = 0.85f

    /** 라틴 글자만 있는 짧은 줄(이 글자 수 이하)은 [SHORT_MIN_CONFIDENCE] 미만이면 버린다. */
    const val SHORT_CHARS = 2
    const val SHORT_MIN_CONFIDENCE = 0.8f

    fun filter(
        blocks: List<OcrBlock>,
        referenceHeight: Float,
        heightOf: (OcrLine) -> Int? = { it.bounds?.height() },
    ): List<OcrBlock> = blocks.mapNotNull { block ->
        val kept = block.lines.filter { keep(it, referenceHeight, heightOf(it)) }
        when {
            kept.isEmpty() -> null
            kept.size == block.lines.size -> block
            else -> block.copy(text = kept.joinToString("\n") { it.text }, lines = kept)
        }
    }

    internal fun keep(line: OcrLine, referenceHeight: Float, height: Int?): Boolean {
        if (height != null && height > 0 && referenceHeight > 0f) {
            val ratio = height / referenceHeight
            if (ratio < DROP_HEIGHT_RATIO) return false
            if (ratio < TINY_HEIGHT_RATIO && line.confidence < TINY_MIN_CONFIDENCE) return false
        }
        val letters = line.text.filter { !it.isWhitespace() }
        if (letters.length <= SHORT_CHARS && letters.all { it.code < 0x2E80 } && line.confidence < SHORT_MIN_CONFIDENCE) {
            return false
        }
        return true
    }
}
