package com.example.translation_poc_app.data

import com.example.translation_poc_app.data.history.HistoryRepository
import com.example.translation_poc_app.translate.EngineId
import com.example.translation_poc_app.translate.ItemStatus
import com.example.translation_poc_app.translate.TranslatedItem
import com.example.translation_poc_app.translate.TranslationOutcome
import org.junit.Assert.assertEquals
import org.junit.Test

class HistoryRepositoryTest {
    private fun item(original: String, translated: String?, status: ItemStatus = ItemStatus.TRANSLATED) =
        TranslatedItem(original, translated, "en", status)

    private fun outcome(vararg items: TranslatedItem) =
        TranslationOutcome.Translated(items.toList(), EngineId.ML_KIT, "ko", skipped = 0)

    @Test
    fun `번역에 성공한 블록만 기록한다`() {
        val records = HistoryRepository.recordsOf(
            outcome(
                item("Hello", "안녕"),
                item("Fail", null, ItemStatus.FAILED),
                item("Unsupported", null, ItemStatus.UNSUPPORTED),
                item("same", "same"),
                item("  ", "공백"),
            ),
            now = 1000,
        )
        assertEquals(listOf("Hello"), records.map { it.original })
        assertEquals("ko", records.single().targetLanguage)
        assertEquals("ML_KIT", records.single().engine)
    }

    @Test
    fun `위쪽 블록일수록 나중 시각이라 최신순 목록에서 화면 순서로 나온다`() {
        val records = HistoryRepository.recordsOf(outcome(item("a", "가"), item("b", "나"), item("c", "다")), now = 1000)
        assertEquals(listOf("a", "b", "c"), records.sortedByDescending { it.createdAt }.map { it.original })
    }

    @Test
    fun `검색어의 LIKE 특수문자를 이스케이프한다`() {
        assertEquals("", HistoryRepository.likePattern(""))
        assertEquals("%100\\%%", HistoryRepository.likePattern("100%"))
        assertEquals("%a\\_b%", HistoryRepository.likePattern("a_b"))
        assertEquals("%a\\\\b%", HistoryRepository.likePattern("a\\b"))
    }
}
