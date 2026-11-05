package com.example.translation_poc_app.ocr

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class OcrTinyTextFilterTest {
    private val heights = mapOf("tiny" to 8, "small" to 14, "normal" to 40, "x" to 40, "확인" to 40)
    private fun line(text: String, conf: Float) = OcrLine(text, null, conf)
    private fun block(vararg l: OcrLine) = OcrBlock(l.joinToString("\n") { it.text }, null, l.toList(), "und")
    private fun run(vararg b: OcrBlock) = OcrTinyTextFilter.filter(b.toList(), 2000f) { heights[it.text] }

    @Test
    fun `아주 작은 줄은 신뢰도와 상관없이 버린다`() {
        assertTrue(run(block(line("tiny", 0.99f))).isEmpty())
    }

    @Test
    fun `작은 줄은 신뢰도가 높을 때만 남긴다`() {
        assertTrue(run(block(line("small", 0.7f))).isEmpty())
        assertEquals(1, run(block(line("small", 0.9f))).size)
    }

    @Test
    fun `보통 크기 줄은 남기고 블록 글자를 다시 만든다`() {
        val out = run(block(line("normal", 0.6f), line("tiny", 0.9f)))
        assertEquals("normal", out.single().text)
    }

    @Test
    fun `짧은 라틴 조각은 신뢰도 낮으면 버리지만 한글은 남긴다`() {
        assertTrue(run(block(line("x", 0.6f))).isEmpty())
        assertEquals(1, run(block(line("확인", 0.6f))).size)
    }

    @Test
    fun `좌표가 없으면 크기 규칙은 건너뛴다`() {
        val out = OcrTinyTextFilter.filter(listOf(block(line("hello", 0.6f))), 2000f) { null }
        assertEquals(1, out.size)
    }
}
