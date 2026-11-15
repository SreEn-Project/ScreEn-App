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

/** 단어 한 줄 + 그 단어의 모든 뜻 (첫 뜻이 대표). */
data class WordWithMeanings(val row: WordRow, val meanings: List<WordMeaningEntity>)

/** 한 번 푼 결과 (어느 단어장에서 푼 단어인지 포함). */
data class WordAnswerEntry(val wordbookId: Long, val wordId: Long, val correct: Boolean)

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

    suspend fun words(wordbookId: Long, query: String, sort: WordSort): List<WordWithMeanings> {
        val rows = dao.words(wordbookId, HistoryRepository.likePattern(query.trim()), sort.code)
        return withMeanings(rows)
    }

    /** 단어장을 모르면(상세 화면) 들어 있는 첫 단어장 기준으로 본다. */
    suspend fun word(id: Long, wordbookId: Long? = null): WordWithMeanings? {
        val row = (if (wordbookId != null) dao.wordRow(id, wordbookId) else null) ?: dao.firstWordRow(id) ?: return null
        return withMeanings(listOf(row)).firstOrNull()
    }

    /** 같은 단어(글자 · 언어쌍)가 이미 저장돼 있으면 돌려준다. 저장하기 전에 뜻을 더할지 물을 때 쓴다. */
    suspend fun findSame(word: String, sourceLanguage: String, targetLanguage: String): WordWithMeanings? {
        val found = dao.wordAnywhere(word.trim(), sourceLanguage, targetLanguage) ?: return null
        return word(found.id)
    }

    /** 단어가 들어 있는 단어장마다의 진도. */
    suspend fun progressOf(id: Long): List<WordbookWordEntity> = dao.linksOf(id)

    private suspend fun withMeanings(rows: List<WordRow>): List<WordWithMeanings> {
        if (rows.isEmpty()) return emptyList()
        val byWord = HashMap<Long, MutableList<WordMeaningEntity>>()
        // SQLite는 한 쿼리에 변수를 999개까지만 받는다.
        for (chunk in rows.map { it.id }.distinct().chunked(500)) {
            for (meaning in dao.meaningsOfAll(chunk)) byWord.getOrPut(meaning.wordId) { mutableListOf() }.add(meaning)
        }
        return rows.map { WordWithMeanings(it, byWord[it.id].orEmpty()) }
    }

    /**
     * 단어장에 단어를 저장한다. 비어 있는 단어 · 뜻이면 저장하지 않고 null.
     * 같은 단어가 이미 있으면 그 단어를 이 단어장에도 넣고, 새로운 뜻이면 뜻을 더한다.
     */
    suspend fun saveWord(wordbookId: Long, draft: WordDraft): Long? {
        val (word, meaning) = entityOf(draft, clock()) ?: return null
        val id = dao.saveWord(wordbookId, word, meaning)
        return id.takeIf { it != -1L }
    }

    /** 저장된 단어의 공통 부분과 대표 뜻을 고친다. 비어 있는 단어 · 뜻이거나 들어 있는 단어장의 다른 단어와 겹치면 false. */
    suspend fun updateWord(id: Long, draft: WordDraft): Boolean {
        val current = dao.word(id) ?: return false
        val (word, meaning) = entityOf(draft, current.createdAt) ?: return false
        return dao.editWord(id, word, meaning)
    }

    /** 단어에 뜻을 더한다. 비어 있는 뜻이거나 같은 뜻이 이미 있으면 false. */
    suspend fun addMeaning(id: Long, draft: WordDraft): Boolean {
        if (dao.word(id) == null) return false
        val (_, meaning) = entityOf(draft, clock()) ?: return false
        return dao.addOrFillMeaning(id, meaning)
    }

    suspend fun updateMeaning(meaningId: Long, draft: WordDraft): Boolean {
        val (_, meaning) = entityOf(draft, clock()) ?: return false
        return dao.editMeaning(meaningId, meaning.meaning, meaning.contextMeaning, meaning.sentence)
    }

    /** 뜻을 지운다. 마지막 뜻이면 false. */
    suspend fun deleteMeaning(meaningId: Long): Boolean = dao.deleteMeaning(meaningId)

    suspend fun moveWord(id: Long, fromWordbookId: Long, toWordbookId: Long) =
        dao.moveWord(id, fromWordbookId, toWordbookId)

    /** 단어를 다른 단어장에도 넣는다. 이미 있거나 그 단어장에 같은 글자가 있으면 false. */
    suspend fun addToWordbook(id: Long, wordbookId: Long): Boolean = dao.addToWordbook(id, wordbookId)

    /** 한 단어장에서만 뺀다. 마지막 단어장이었으면 단어도 지운다. */
    suspend fun removeFromWordbook(id: Long, wordbookId: Long) = dao.removeFromWordbook(id, wordbookId)

    suspend fun wordbookIdsOf(id: Long): List<Long> = dao.wordbookIdsOf(id)

    /** 모든 단어장에서 지운다. */
    suspend fun deleteWord(id: Long) = dao.deleteWord(id)

    /** 그 단어장에서의 외움 표시. */
    suspend fun setMemorized(wordbookId: Long, id: Long, memorized: Boolean) = dao.setMemorized(wordbookId, id, memorized)

    /** 테스트 · 게임에서 푼 결과를 (단어장, 단어)별로 쌓는다 (AD-18). */
    suspend fun recordAnswers(answers: List<WordAnswerEntry>) {
        for (a in answers) dao.addAnswer(a.wordbookId, a.wordId, if (a.correct) 1 else 0)
    }

    companion object {
        const val MAX_NAME_LENGTH = 30

        /** 앞뒤 공백을 걷고 [MAX_NAME_LENGTH]자로 자른다. 비면 null. */
        fun cleanName(name: String): String? = name.trim().take(MAX_NAME_LENGTH).trim().ifEmpty { null }

        /** 저장할 단어(공통 부분)와 첫 뜻으로 나눈다. 단어 · 뜻이 비었으면 null. 뜻의 wordId는 저장할 때 채운다. */
        fun entityOf(draft: WordDraft, now: Long): Pair<WordEntity, WordMeaningEntity>? {
            val word = draft.word.trim()
            val meaning = draft.meaning.trim()
            if (word.isEmpty() || meaning.isEmpty()) return null
            return WordEntity(
                word = word,
                pronunciation = draft.pronunciation.blankToNull(),
                partOfSpeech = draft.partOfSpeech.blankToNull(),
                sourceLanguage = draft.sourceLanguage,
                targetLanguage = draft.targetLanguage,
                createdAt = now,
            ) to WordMeaningEntity(
                wordId = 0,
                meaning = meaning,
                contextMeaning = draft.contextMeaning.blankToNull(),
                sentence = draft.sentence.blankToNull(),
                sourceApp = draft.sourceApp.blankToNull(),
                createdAt = now,
            )
        }

        private fun String?.blankToNull(): String? = this?.trim()?.ifEmpty { null }
    }
}
