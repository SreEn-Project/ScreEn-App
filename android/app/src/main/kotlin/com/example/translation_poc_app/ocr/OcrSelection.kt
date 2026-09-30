package com.example.translation_poc_app.ocr

/**
 * 인식 결과 고르기 · 거르기 (NA-09, D-020). Android 의존 없는 순수 로직이라 단위 테스트로 검증한다.
 */
object OcrSelection {

    /** 이보다 낮은 신뢰도의 줄은 버린다. 화면 장식 · 아이콘을 글자로 잘못 읽는 경우가 대부분이다. */
    const val MIN_LINE_CONFIDENCE = 0.5f

    /**
     * 원문 언어(BCP-47)에 맞는 인식기. null이면 자동: 한국어 · 일본어 · 중국어를 함께 돌리고
     * ([pickBest]로 하나를 고른다) 각 인식기가 라틴 글자도 읽으므로 라틴은 따로 돌리지 않는다.
     */
    fun scriptsFor(sourceLanguage: String?): Set<Script> = when (sourceLanguage?.substringBefore('-')) {
        null, "", "auto" -> setOf(Script.KOREAN, Script.JAPANESE, Script.CHINESE)
        "ko" -> setOf(Script.KOREAN)
        "ja" -> setOf(Script.JAPANESE)
        "zh" -> setOf(Script.CHINESE)
        "hi", "mr", "ne" -> setOf(Script.DEVANAGARI)
        else -> setOf(Script.LATIN)
    }

    /** 신뢰도 낮은 줄을 빼고, 줄이 남지 않은 블록은 버린다. 블록 글자는 남은 줄로 다시 만든다. */
    fun filterLowConfidence(
        blocks: List<OcrBlock>,
        minConfidence: Float = MIN_LINE_CONFIDENCE,
    ): List<OcrBlock> = blocks.mapNotNull { block ->
        val kept = block.lines.filter { it.confidence >= minConfidence && it.text.isNotBlank() }
        when {
            kept.isEmpty() -> null
            kept.size == block.lines.size -> block
            else -> block.copy(text = kept.joinToString("\n") { it.text }, lines = kept)
        }
    }

    /**
     * 여러 인식기 결과 중 하나를 고른다: 읽은 글자 수 × 신뢰도 합이 가장 큰 것.
     * 맞지 않는 인식기는 글자를 적게 · 낮은 신뢰도로 읽기 때문에 이 점수가 작다.
     */
    fun pickBest(results: List<OcrResult>): OcrResult? = results.maxByOrNull(::score)

    internal fun score(result: OcrResult): Float = result.blocks.sumOf { block ->
        block.lines.sumOf { line ->
            (line.text.count { !it.isWhitespace() } * line.confidence).toDouble()
        }
    }.toFloat()
}
