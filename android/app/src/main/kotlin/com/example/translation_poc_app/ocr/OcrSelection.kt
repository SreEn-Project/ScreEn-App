package com.example.translation_poc_app.ocr

/**
 * 인식 결과 고르기 · 거르기 (NA-09, D-020). Android 의존 없는 순수 로직이라 단위 테스트로 검증한다.
 */
object OcrSelection {

    /** 이보다 낮은 신뢰도의 줄은 버린다. 화면 장식 · 아이콘을 글자로 잘못 읽는 경우가 대부분이다. */
    const val MIN_LINE_CONFIDENCE = 0.5f

    /** 글자가 [LONG_LINE_CHARS]자 이상인 줄은 이 신뢰도부터 남긴다. 긴 줄은 장식일 가능성이 낮다 (#21). */
    const val MIN_LONG_LINE_CONFIDENCE = 0.3f
    const val LONG_LINE_CHARS = 5

    /** 읽은 글자 수(공백 제외). 첫 인식이 빈약한지 볼 때 쓴다. */
    fun charCount(blocks: List<OcrBlock>): Int =
        blocks.sumOf { b -> b.lines.sumOf { l -> l.text.count { !it.isWhitespace() } } }

    /** 진단 로그용: 읽은 글자 수와 글자 가중 평균 신뢰도 (#25). */
    fun describe(raw: List<OcrBlock>): String {
        var chars = 0
        var weighted = 0.0
        for (block in raw) for (line in block.lines) {
            val n = line.text.count { !it.isWhitespace() }
            chars += n
            weighted += n * line.confidence
        }
        return if (chars == 0) "0자" else "${chars}자 신뢰도 %.2f".format(weighted / chars)
    }

    private fun minConfidenceFor(line: OcrLine, minConfidence: Float): Float =
        if (line.text.count { !it.isWhitespace() } >= LONG_LINE_CHARS) minOf(minConfidence, MIN_LONG_LINE_CONFIDENCE) else minConfidence

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

    /** 자동 모드의 첫 시도에 쓰는 인식기 (직전에 잘 읽은 것이 없을 때). 한 · 영을 읽고 가장 가볍게 시작한다. */
    val DEFAULT_FIRST: Script = Script.KOREAN

    /** 자동 모드에서 [first]를 뺀 나머지 한중일 인식기. 첫 시도 결과가 미덥지 않을 때만 돌린다. */
    fun remainingAuto(first: Script): Set<Script> =
        setOf(Script.KOREAN, Script.JAPANESE, Script.CHINESE) - first

    /** 첫 시도에서 이 글자 수 미만이면 인식기가 안 맞았을 수 있다. */
    const val MIN_TRUSTED_CHARS = 12

    /** 첫 시도의 글자 가중 평균 신뢰도가 이보다 낮으면 다른 문자 체계가 섞여 있을 수 있다. */
    const val MIN_TRUSTED_CONFIDENCE = 0.8f

    /**
     * 인식기 하나로 읽은 결과가 믿을 만한지 (거르기 전 줄 기준). 믿기 어려우면 나머지 인식기도 돌려
     * 가장 잘 읽은 걸 고른다. 맞지 않는 인식기는 글자를 적게 · 낮은 신뢰도로 읽는 점을 이용한다 (D-030).
     */
    fun isTrusted(raw: List<OcrBlock>): Boolean {
        var chars = 0
        var weighted = 0.0
        for (block in raw) for (line in block.lines) {
            val n = line.text.count { !it.isWhitespace() }
            chars += n
            weighted += n * line.confidence
        }
        // 읽은 게 없는 경우도 믿지 않는다: 맞지 않는 인식기는 아예 아무것도 못 읽기도 한다.
        return chars >= MIN_TRUSTED_CHARS && weighted / chars >= MIN_TRUSTED_CONFIDENCE
    }

    /** 신뢰도 낮은 줄을 빼고, 줄이 남지 않은 블록은 버린다. 블록 글자는 남은 줄로 다시 만든다. */
    fun filterLowConfidence(
        blocks: List<OcrBlock>,
        minConfidence: Float = MIN_LINE_CONFIDENCE,
    ): List<OcrBlock> = blocks.mapNotNull { block ->
        val kept = block.lines.filter { it.text.isNotBlank() && it.confidence >= minConfidenceFor(it, minConfidence) }
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
