package com.example.translation_poc_app.data

import com.example.translation_poc_app.data.vocabulary.VocabularyRepository
import com.example.translation_poc_app.data.vocabulary.WordDraft
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
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
        val entity = VocabularyRepository.entityOf(
            draft = draft(word = " apple ", meaning = " 사과 ").copy(pronunciation = "  ", sentence = " An apple. "),
            now = 42,
        )!!
        assertEquals("apple", entity.word)
        assertEquals("사과", entity.meaning)
        assertNull(entity.pronunciation)
        assertEquals("An apple.", entity.sentence)
        assertEquals(42L, entity.createdAt)
        assertFalse(entity.memorized)
    }
}
