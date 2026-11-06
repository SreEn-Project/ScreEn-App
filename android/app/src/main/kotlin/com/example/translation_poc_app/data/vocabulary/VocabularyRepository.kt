package com.example.translation_poc_app.data.vocabulary

import com.example.translation_poc_app.data.history.HistoryRepository

/** 단어 목록 정렬. [code]는 DAO 쿼리의 `:sort` 값. */
enum class WordSort(val code: Int) { NEWEST(0), OLDEST(1), ALPHABETICAL(2) }

/** 저장할 단어 한 건의 내용 (AD-03). */
data class WordDraft(
    val word: String,
    val meaning: String,
    val pronunciation: String? = null,
    val partOfSpeech: String? = null,
    val contextMeaning: String? = null,
    val sentence: String? = null,
    val sourceApp: String? = null,
    val sourceLanguage: String,
    val targetLanguage: String,
)

/** 단어장 · 단어 저장과 조회 (AD-03~06). 오버레이가 저장하고, Flutter(Pigeon)가 관리한다. */
class VocabularyRepository(
    private val dao: VocabularyDao,
    private val clock: () -> Long = System::currentTimeMillis,
) {
    suspend fun wordbooks(): List<WordbookRow> = dao.wordbooks()

    /** 같은 이름이 이미 있으면 그 단어장을 돌려준다. 이름이 비었으면 null. */
    suspend fun createWordbook(name: String): WordbookEntity? {
        val clean = cleanName(name) ?: return null
        dao.wordbookByName(clean)?.let { return it }
        dao.insertWordbook(WordbookEntity(name = clean, createdAt = clock()))
        return dao.wordbookByName(clean)
    }

    /** 이름이 비었거나 다른 단어장과 겹치면 false. 자기 이름 그대로면 true. */
    suspend fun renameWordbook(id: Long, name: String): Boolean {
        val clean = cleanName(name) ?: return false
        val same = dao.wordbookByName(clean)
        if (same != null) return same.id == id
        dao.renameWordbook(id, clean)
        return true
    }

    suspend fun deleteWordbook(id: Long) = dao.deleteWordbook(id)

    suspend fun words(wordbookId: Long, query: String, sort: WordSort): List<WordEntity> =
        dao.words(wordbookId, HistoryRepository.likePattern(query.trim()), sort.code)

    suspend fun word(id: Long): WordEntity? = dao.word(id)

    /** 단어장에 단어를 저장한다. 비어 있는 단어 · 뜻이면 저장하지 않고 null. 같은 단어면 내용만 새로 고친다. */
    suspend fun saveWord(wordbookId: Long, draft: WordDraft): Long? {
        val entity = entityOf(draft, clock()) ?: return null
        val id = dao.upsertWord(wordbookId, entity)
        return id.takeIf { it != -1L }
    }

    /** 저장된 단어의 내용을 고친다. 비어 있는 단어 · 뜻이거나 들어 있는 단어장의 다른 단어와 겹치면 false. */
    suspend fun updateWord(id: Long, draft: WordDraft): Boolean {
        val current = dao.word(id) ?: return false
        val entity = entityOf(draft, current.createdAt) ?: return false
        return dao.editWord(id, entity)
    }

    suspend fun moveWord(id: Long, fromWordbookId: Long, toWordbookId: Long) =
        dao.moveWord(id, fromWordbookId, toWordbookId)

    /** 단어를 다른 단어장에도 넣는다. 이미 있거나 그 단어장에 같은 글자가 있으면 false. */
    suspend fun addToWordbook(id: Long, wordbookId: Long): Boolean = dao.addToWordbook(id, wordbookId)

    /** 한 단어장에서만 뺀다. 마지막 단어장이었으면 단어도 지운다. */
    suspend fun removeFromWordbook(id: Long, wordbookId: Long) = dao.removeFromWordbook(id, wordbookId)

    suspend fun wordbookIdsOf(id: Long): List<Long> = dao.wordbookIdsOf(id)

    /** 모든 단어장에서 지운다. */
    suspend fun deleteWord(id: Long) = dao.deleteWord(id)

    suspend fun setMemorized(id: Long, memorized: Boolean) = dao.setMemorized(id, memorized)

    /** 테스트 · 게임에서 푼 결과를 단어별로 쌓는다 (AD-18). */
    suspend fun recordAnswers(answers: List<Pair<Long, Boolean>>) {
        for ((id, correct) in answers) dao.addAnswer(id, if (correct) 1 else 0)
    }

    companion object {
        const val MAX_NAME_LENGTH = 30

        /** 앞뒤 공백을 걷고 [MAX_NAME_LENGTH]자로 자른다. 비면 null. */
        fun cleanName(name: String): String? = name.trim().take(MAX_NAME_LENGTH).trim().ifEmpty { null }

        fun entityOf(draft: WordDraft, now: Long): WordEntity? {
            val word = draft.word.trim()
            val meaning = draft.meaning.trim()
            if (word.isEmpty() || meaning.isEmpty()) return null
            return WordEntity(
                word = word,
                meaning = meaning,
                pronunciation = draft.pronunciation.blankToNull(),
                partOfSpeech = draft.partOfSpeech.blankToNull(),
                contextMeaning = draft.contextMeaning.blankToNull(),
                sentence = draft.sentence.blankToNull(),
                sourceApp = draft.sourceApp.blankToNull(),
                sourceLanguage = draft.sourceLanguage,
                targetLanguage = draft.targetLanguage,
                createdAt = now,
            )
        }

        private fun String?.blankToNull(): String? = this?.trim()?.ifEmpty { null }
    }
}
