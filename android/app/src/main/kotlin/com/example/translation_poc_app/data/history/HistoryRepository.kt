package com.example.translation_poc_app.data.history

import com.example.translation_poc_app.translate.ItemStatus
import com.example.translation_poc_app.translate.TranslationOutcome

/** 번역 기록 저장 · 조회 (NA-23). 오버레이가 저장하고, Flutter(Pigeon)가 조회 · 삭제한다. */
class HistoryRepository(
    private val dao: HistoryDao,
    private val clock: () -> Long = System::currentTimeMillis,
) {
    /** 번역에 성공한 블록만 저장한다. 실패 · 미지원 블록과 원문과 같은 번역은 남기지 않는다. */
    suspend fun record(outcome: TranslationOutcome.Translated) {
        val records = recordsOf(outcome, clock())
        if (records.isEmpty()) return
        records.forEach { dao.upsert(it) }
        dao.trim(MAX_RECORDS)
    }

    /** @param query 원문 · 번역에서 찾을 글자 (빈 문자열 = 전부). @param sinceMs 이 시각(epoch ms) 이후만. */
    suspend fun search(query: String, sinceMs: Long, limit: Int): List<TranslationRecord> =
        dao.search(likePattern(query.trim()), sinceMs, limit)

    suspend fun delete(id: Long) = dao.delete(id)

    suspend fun clear() = dao.clear()

    companion object {
        /** 이만큼을 넘으면 오래된 기록부터 지운다. */
        const val MAX_RECORDS = 2000

        /** 한 번에 저장한 블록은 위쪽 블록일수록 나중 시각을 줘서, 목록(최신순)에서 화면 위→아래 순서로 보이게 한다. */
        fun recordsOf(outcome: TranslationOutcome.Translated, now: Long): List<TranslationRecord> {
            val valid = outcome.items.mapNotNull { item ->
                val translated = item.translated?.trim()
                if (item.status != ItemStatus.TRANSLATED || translated.isNullOrEmpty()) return@mapNotNull null
                val original = item.original.trim()
                if (original.isEmpty() || original == translated) return@mapNotNull null
                TranslationRecord(
                    original = original,
                    translated = translated,
                    sourceLanguage = item.sourceLanguage,
                    targetLanguage = outcome.targetLanguage,
                    engine = outcome.engine.name,
                    createdAt = now,
                )
            }
            return valid.mapIndexed { index, record -> record.copy(createdAt = now + (valid.size - index)) }
        }

        /** 사용자가 친 글자를 LIKE 패턴으로 (`\`로 이스케이프). 빈 문자열은 그대로 (= 전부). */
        fun likePattern(query: String): String =
            if (query.isEmpty()) "" else "%" + query.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%"
    }
}
