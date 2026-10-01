package com.example.translation_poc_app.ocr

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

private fun line(text: String, confidence: Float = 1f) = OcrLine(text, null, confidence)
private fun block(vararg lines: OcrLine) = OcrBlock(lines.joinToString("\n") { it.text }, null, lines.toList(), "und")

class OcrCleanAndMergeTest {

    @Test
    fun `글자 없는 줄은 잡음으로 버리고 줄이 안 남은 블록도 버린다`() {
        val cleaned = OcrCleaner.clean(
            listOf(block(line("Hello  world"), line("• • •"), line("12:30")), block(line("|||"))),
        )
        assertEquals(1, cleaned.size)
        assertEquals("Hello world", cleaned[0].text)
        assertEquals(1, cleaned[0].lines.size)
    }

    @Test
    fun `잡음이 없으면 블록을 그대로 둔다`() {
        val b = block(line("안녕하세요"))
        assertTrue(OcrCleaner.clean(listOf(b))[0] === b)
    }

    private val a = Box(100, 100, 600, 160)

    @Test
    fun `바로 아래 이어지는 문장 중간 블록은 묶는다`() {
        assertTrue(OcrBlockMerger.continues(a, 30, "this is the start of", Box(100, 175, 580, 235), 30, "a long paragraph"))
    }

    @Test
    fun `문장이 끝났거나 간격이 넓으면 묶지 않는다`() {
        assertFalse(OcrBlockMerger.continues(a, 30, "It ended.", Box(100, 175, 580, 235), 30, "Next"))
        assertFalse(OcrBlockMerger.continues(a, 30, "start of", Box(100, 260, 580, 320), 30, "far below"))
    }

    @Test
    fun `글자 크기 · 왼쪽 정렬 · 단이 다르면 묶지 않는다`() {
        assertFalse(OcrBlockMerger.continues(a, 30, "title", Box(100, 175, 580, 235), 50, "body"))
        assertFalse(OcrBlockMerger.continues(a, 30, "left", Box(300, 175, 580, 235), 30, "indented"))
        assertFalse(OcrBlockMerger.continues(a, 30, "col", Box(700, 100, 900, 160), 30, "other column"))
    }

    @Test
    fun `좌표가 없는 블록은 묶지 않는다`() {
        val blocks = listOf(block(line("a b")), block(line("c d")))
        assertEquals(2, OcrBlockMerger.merge(blocks).size)
    }

    @Test
    fun `첫 인식기 결과가 짧거나 신뢰도 낮으면 믿지 않는다`() {
        assertFalse(OcrSelection.isTrusted(emptyList()))
        assertFalse(OcrSelection.isTrusted(listOf(block(line("짧음")))))
        assertFalse(OcrSelection.isTrusted(listOf(block(line("this line is long enough but unsure", 0.6f)))))
        assertTrue(OcrSelection.isTrusted(listOf(block(line("this line is long enough and sure", 0.95f)))))
    }

    @Test
    fun `자동 모드 나머지 인식기는 첫 인식기를 뺀 둘`() {
        assertEquals(setOf(Script.JAPANESE, Script.CHINESE), OcrSelection.remainingAuto(Script.KOREAN))
        assertEquals(setOf(Script.KOREAN, Script.CHINESE), OcrSelection.remainingAuto(Script.JAPANESE))
    }
}
