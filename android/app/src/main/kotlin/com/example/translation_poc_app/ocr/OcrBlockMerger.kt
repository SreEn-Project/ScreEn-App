package com.example.translation_poc_app.ocr

import android.graphics.Rect

/** 좌표만 담은 순수 사각형. [Rect]는 JVM 테스트에서 쓸 수 없어 판단 로직은 이걸로 한다. */
data class Box(val left: Int, val top: Int, val right: Int, val bottom: Int) {
    val width get() = right - left
    val height get() = bottom - top
}

/**
 * 인접한 OCR 블록을 문단으로 묶는다 (#19). ML Kit은 한 문단을 여러 블록으로 쪼개기도 하는데,
 * 따로 번역하면 문장 중간에서 끊겨 번역이 어색해진다. 묶으면 문맥이 늘고 번역 호출 수도 줄어든다.
 * 서로 다른 UI 항목(목록 줄 등)을 잘못 묶지 않도록 보수적으로 판단한다.
 */
object OcrBlockMerger {

    /** 이 기호로 끝난 블록은 문장이 끝난 것으로 보고 다음 블록과 묶지 않는다. */
    private const val SENTENCE_END = ".!?。！？…:;"

    /** 줄 간격 상한 (평균 줄 높이 대비). 문단 안의 줄 간격은 대개 0.2~0.6배. */
    const val MAX_GAP_RATIO = 0.6f

    /** 줄 높이가 이 비율 이상 달라지면 다른 글자 크기(제목 ↔ 본문)로 본다. */
    const val MIN_HEIGHT_RATIO = 0.75f

    /** 왼쪽 정렬 오차 상한 (줄 높이 대비). */
    const val MAX_LEFT_SHIFT_RATIO = 1.0f

    /** 위에서 아래로, 화면 순서대로 정렬한 [blocks] 중 이어지는 것을 합친다. 좌표 없는 블록은 그대로 둔다. */
    fun merge(blocks: List<OcrBlock>): List<OcrBlock> {
        if (blocks.size < 2) return blocks
        val result = mutableListOf<OcrBlock>()
        for (block in blocks) {
            val last = result.lastOrNull()
            if (last != null && continues(last, block)) {
                result[result.lastIndex] = join(last, block)
            } else {
                result += block
            }
        }
        return result
    }

    private fun continues(a: OcrBlock, b: OcrBlock): Boolean {
        val boxA = a.bounds?.toBox() ?: return false
        val boxB = b.bounds?.toBox() ?: return false
        return continues(
            boxA, lineHeight(a, boxA), a.text,
            boxB, lineHeight(b, boxB), b.text,
        )
    }

    /** 순수 판단. [a]가 위, [b]가 아래에 있고 [b]가 [a]의 문단을 잇는가. */
    fun continues(a: Box, lineHeightA: Int, textA: String, b: Box, lineHeightB: Int, textB: String): Boolean {
        if (lineHeightA <= 0 || lineHeightB <= 0) return false
        val avg = (lineHeightA + lineHeightB) / 2f
        val gap = b.top - a.bottom
        // 아래에 있어야 하고(겹치는 정도는 허용), 간격이 좁아야 한다.
        if (gap < -avg * 0.5f || gap > avg * MAX_GAP_RATIO) return false
        val heightRatio = minOf(lineHeightA, lineHeightB).toFloat() / maxOf(lineHeightA, lineHeightB)
        if (heightRatio < MIN_HEIGHT_RATIO) return false
        if (kotlin.math.abs(a.left - b.left) > avg * MAX_LEFT_SHIFT_RATIO) return false
        // 가로로 충분히 겹쳐야 같은 단(column)이다.
        val overlap = minOf(a.right, b.right) - maxOf(a.left, b.left)
        if (overlap < minOf(a.width, b.width) * 0.5f) return false
        val endsSentence = textA.trimEnd().lastOrNull()?.let { it in SENTENCE_END } ?: false
        return !endsSentence
    }

    private fun lineHeight(block: OcrBlock, box: Box): Int {
        val heights = block.lines.mapNotNull { it.bounds?.height()?.takeIf { h -> h > 0 } }
        return if (heights.isEmpty()) box.height else heights.sorted()[heights.size / 2]
    }

    private fun join(a: OcrBlock, b: OcrBlock): OcrBlock {
        val ra = a.bounds
        val rb = b.bounds
        val union = if (ra != null && rb != null) {
            Rect(minOf(ra.left, rb.left), minOf(ra.top, rb.top), maxOf(ra.right, rb.right), maxOf(ra.bottom, rb.bottom))
        } else {
            ra ?: rb
        }
        // 언어 추정은 글자가 더 많은 쪽을 따른다.
        val language = if (a.text.length >= b.text.length) a.language else b.language
        return OcrBlock(a.text + "\n" + b.text, union, a.lines + b.lines, language)
    }
}

private fun Rect.toBox() = Box(left, top, right, bottom)
