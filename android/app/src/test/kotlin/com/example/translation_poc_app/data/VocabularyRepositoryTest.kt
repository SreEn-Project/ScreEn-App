package com.example.translation_poc_app.data

import com.example.translation_poc_app.data.vocabulary.VocabularyRepository
import com.example.translation_poc_app.data.vocabulary.WordDraft
import com.example.translation_poc_app.data.vocabulary.sameMeaning
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class VocabularyRepositoryTest {
    private fun draft(word: String = "apple", meaning: String = "사과") =
        WordDraft(word = word, meaning = meaning, sourceLanguage = "en", targetLanguage = "ko")

    @Test
    fun `단어장 이름은 앞뒤 공백을 걷고 길이를 제한한다`() {
        assertEquals("영어", VocabularyRepository.cleanName("  영어  "))
        assertEquals(VocabularyRepository.MAX_NAME_LENGTH, VocabularyRepository.cleanName("a".repeat(100))!!.length)
    }

    @Test
    fun `빈 이름은 거부한다`() {
        assertNull(VocabularyRepository.cleanName("   "))
        assertNull(VocabularyRepository.cleanName(""))
    }

    @Test
    fun `단어 · 뜻이 비면 저장하지 않는다`() {
        assertNull(VocabularyRepository.entityOf(draft(word = " "), 0))
        assertNull(VocabularyRepository.entityOf(draft(meaning = ""), 0))
    }

    @Test
    fun `저장할 단어는 다듬고 빈 부가 정보는 null로 둔다`() {
        val (word, meaning) = VocabularyRepository.entityOf(
            draft = draft(word = " apple ", meaning = " 사과 ").copy(pronunciation = "  ", sentence = " An apple. "),
            now = 42,
        )!!
        assertEquals("apple", word.word)
        assertNull(word.pronunciation)
        assertEquals(42L, word.createdAt)
        assertEquals("사과", meaning.meaning)
        assertEquals("An apple.", meaning.sentence)
    }

    @Test
    fun `뜻 비교는 공백과 대소문자를 무시한다`() {
        assertTrue(sameMeaning(" Apple ", "apple"))
        assertFalse(sameMeaning("사과", "배"))
    }
}
