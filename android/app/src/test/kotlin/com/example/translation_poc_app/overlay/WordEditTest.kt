package com.example.translation_poc_app.overlay

import com.example.translation_poc_app.translate.WordDefinition
import com.example.translation_poc_app.translate.WordEntry
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class WordEditTest {
    private fun entry(definition: WordDefinition?) = WordEntry(
        word = "apple",
        translation = "사과",
        definition = definition,
        aiError = null,
        sentence = "An apple a day.",
        sourceLanguage = "en",
        targetLanguage = "ko",
    )

    @Test
    fun `AI 풀이가 있으면 편집 칸이 그 내용으로 채워진다`() {
        val edit = WordEdit.of(entry(WordDefinition("과일 사과", "/ˈæp.əl/", "noun", "(과일)")))
        assertEquals("apple", edit.word)
        assertEquals("과일 사과", edit.meaning)
        assertEquals("/ˈæp.əl/", edit.pronunciation)
        assertEquals("noun", edit.partOfSpeech)
        assertEquals("(과일)", edit.contextMeaning)
        assertEquals("An apple a day.", edit.sentence)
    }

    @Test
    fun `AI 풀이가 없으면 번역이 뜻이고 나머지는 빈 칸이다`() {
        val edit = WordEdit.of(entry(null))
        assertEquals("사과", edit.meaning)
        assertEquals("", edit.pronunciation)
        assertEquals("", edit.partOfSpeech)
        assertEquals("", edit.contextMeaning)
    }

    @Test
    fun `단어나 뜻이 비면 저장할 수 없다`() {
        val edit = WordEdit.of(entry(null))
        assertTrue(edit.isSavable)
        assertFalse(edit.copy(word = "  ").isSavable)
        assertFalse(edit.copy(meaning = "").isSavable)
    }
}
