package com.example.translation_poc_app.ocr

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

// 좌표(Rect)는 Android 클래스라 JVM 테스트에서는 null로 둔다.
private fun line(text: String, confidence: Float = 1f) = OcrLine(text, null, confidence)

private fun block(vararg lines: OcrLine) =
    OcrBlock(lines.joinToString("\n") { it.text }, null, lines.toList(), "und")

class OcrSelectionTest {

    @Test
    fun `자동이면 한중일 인식기를 함께 쓴다`() {
        assertEquals(
            setOf(Script.KOREAN, Script.JAPANESE, Script.CHINESE),
            OcrSelection.scriptsFor(null),
        )
        assertEquals(OcrSelection.scriptsFor(null), OcrSelection.scriptsFor("auto"))
    }

    @Test
    fun `원문 언어에 맞는 인식기 하나만 쓴다`() {
        assertEquals(setOf(Script.KOREAN), OcrSelection.scriptsFor("ko"))
        assertEquals(setOf(Script.CHINESE), OcrSelection.scriptsFor("zh-TW"))
        assertEquals(setOf(Script.DEVANAGARI), OcrSelection.scriptsFor("hi"))
        assertEquals(setOf(Script.LATIN), OcrSelection.scriptsFor("fr"))
    }

    @Test
    fun `신뢰도 낮은 줄은 빼고 블록 글자를 다시 만든다`() {
        val filtered = OcrSelection.filterLowConfidence(
            listOf(block(line("Hello", 0.9f), line("@#%", 0.2f), line("World", 0.8f))),
        )

        assertEquals(1, filtered.size)
        assertEquals("Hello\nWorld", filtered[0].text)
        assertEquals(2, filtered[0].lines.size)
    }

    @Test
    fun `남는 줄이 없는 블록은 버린다`() {
        val filtered = OcrSelection.filterLowConfidence(
            listOf(block(line("~~", 0.1f)), block(line("   ", 0.9f))),
        )

        assertTrue(filtered.isEmpty())
    }

    @Test
    fun `글자를 많이, 확실하게 읽은 결과를 고른다`() {
        val korean = OcrResult(Script.KOREAN, listOf(block(line("안녕하세요 반갑습니다", 0.9f))))
        val japanese = OcrResult(Script.JAPANESE, listOf(block(line("아녕", 0.4f))))
        val chinese = OcrResult(Script.CHINESE, emptyList())

        assertEquals(Script.KOREAN, OcrSelection.pickBest(listOf(japanese, korean, chinese))?.script)
    }

    @Test
    fun `결과가 없으면 null`() {
        assertNull(OcrSelection.pickBest(emptyList()))
    }

    @Test
    fun `긴 줄은 낮은 신뢰도도 남기고 짧은 줄은 엄격하게 거른다`() {
        val filtered = OcrSelection.filterLowConfidence(
            listOf(block(line("Settings page", 0.35f), line("ab", 0.35f))),
        )
        assertEquals(listOf("Settings page"), filtered.single().lines.map { it.text })
    }
}
