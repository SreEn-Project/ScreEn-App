package com.example.translation_poc_app.overlay

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class WordSelectionTest {
    private val text = "Hello, brave new world!"

    @Test
    fun `단어 가운데를 탭하면 그 단어다`() {
        assertEquals("brave", WordSelection.wordAt(text, text.indexOf("brave") + 2))
    }

    @Test
    fun `단어의 첫 글자와 끝 글자도 그 단어다`() {
        assertEquals("world", WordSelection.wordAt(text, text.indexOf("world")))
        assertEquals("world", WordSelection.wordAt(text, text.indexOf("world") + 4))
    }

    @Test
    fun `쉼표나 느낌표에는 단어가 없다`() {
        assertNull(WordSelection.wordAt(text, text.indexOf(',')))
        assertNull(WordSelection.wordAt(text, text.indexOf('!')))
    }

    @Test
    fun `공백에는 단어가 없다`() {
        assertNull(WordSelection.wordAt(text, text.indexOf(' ')))
    }

    @Test
    fun `글 밖의 자리는 가장자리로 맞춘다`() {
        assertEquals("Hello", WordSelection.wordAt(text, -5))
        assertNull(WordSelection.wordAt(text, 999))
    }

    @Test
    fun `빈 글에는 단어가 없다`() {
        assertNull(WordSelection.wordAt("", 0))
    }

    @Test
    fun `한글 단어도 고른다`() {
        val korean = "오늘 날씨가 좋다"
        assertEquals("날씨가", WordSelection.wordAt(korean, korean.indexOf("씨")))
    }

    @Test
    fun `숫자도 단어다`() {
        assertEquals("2026", WordSelection.wordAt("Year 2026.", 7))
    }
}
