package com.example.translation_poc_app.ocr

import org.junit.Assert.assertEquals
import org.junit.Assert.assertSame
import org.junit.Test

class OcrPostProcessorTest {

    private fun fix(s: String) = OcrPostProcessor.fixLine(s)

    @Test
    fun `글자 사이에 낀 숫자와 파이프를 글자로 고친다`() {
        assertEquals("Hello world", fix("He11o w0rld"))
        assertEquals("words menu", fix("w0rds menu"))
        assertEquals("hello", fix("he|lo"))
        assertEquals("GOLD", fix("G0LD"))
    }

    @Test
    fun `소문자 사이의 대문자 I는 l로 고친다`() {
        assertEquals("hello", fix("heIlo"))
        assertEquals("McIntyre", fix("McIntyre"))
    }

    @Test
    fun `숫자 낱말과 코드 조각은 건드리지 않는다`() {
        for (s in listOf("mp3", "win10", "H2O", "a1b2c3", "10l", "v1.0", "foo_b1ar", "user@exampl3.com", "path/to/f1le", "#Hell0")) {
            assertEquals(s, fix(s))
        }
    }

    @Test
    fun `숫자 사이의 O와 l은 숫자로 고친다`() {
        assertEquals("2024", fix("2O24"))
        assertEquals("Price 1000", fix("Price 1OO0"))
        assertEquals("Total", fix("Total"))
    }

    @Test
    fun `I가 l이나 파이프로 읽힌 경우를 고친다`() {
        assertEquals("I'm fine", fix("l'm fine"))
        assertEquals("I'll go", fix("|'ll go"))
        assertEquals("I am here", fix("l am here"))
        assertEquals("I think so", fix("| think so"))
        assertEquals("It works", fix("lt works"))
        assertEquals("so it works", fix("so lt works"))
        // 목록 · 단위로 보이는 l은 그대로.
        assertEquals("2 l water", fix("2 l water"))
    }

    @Test
    fun `합자를 풀어 쓴다`() {
        assertEquals("office file", fix("oﬃce ﬁle"))
    }

    @Test
    fun `짧은 UI 단어는 사전으로 바로잡는다`() {
        assertEquals("OK", fix("0K"))
        assertEquals("Cancel", fix("Cance1"))
        assertEquals("Settings", fix("Sett1ngs"))
        assertEquals("Login", fix("Iogin"))
        assertEquals("LOGIN", fix("L0GIN"))
        assertEquals("No", fix("N0"))
    }

    @Test
    fun `사전과 비슷해도 다른 낱말이나 문장은 고치지 않는다`() {
        assertEquals("Illinois", fix("Illinois"))
        assertEquals("Cancel", fix("Cancel"))
        assertEquals("한국어 0K", fix("한국어 0K"))
    }

    @Test
    fun `바뀐 게 없으면 블록을 그대로 둔다`() {
        val b = OcrBlock("Hello\n안녕", null, listOf(OcrLine("Hello", null, 1f), OcrLine("안녕", null, 1f)), "und")
        assertSame(b, OcrPostProcessor.process(listOf(b))[0])
    }

    @Test
    fun `고친 블록은 글자와 줄을 함께 바꾼다`() {
        val b = OcrBlock("He11o\nworld", null, listOf(OcrLine("He11o", null, 1f), OcrLine("world", null, 0.9f)), "en")
        val out = OcrPostProcessor.process(listOf(b))[0]
        assertEquals("Hello\nworld", out.text)
        assertEquals(listOf("Hello", "world"), out.lines.map { it.text })
        assertEquals(0.9f, out.lines[1].confidence, 0f)
    }
}
