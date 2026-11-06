package com.example.translation_poc_app.data.vocabulary

import androidx.room.ColumnInfo
import androidx.room.Dao
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.PrimaryKey
import androidx.room.Query
import androidx.room.Transaction

/** 단어장 (AD-03, AD-04). 이름은 겹치지 않는다. 기록 표와 같은 DB(AppDatabase)에 둔다. */
@Entity(tableName = "wordbooks", indices = [Index(value = ["name"], unique = true)])
data class WordbookEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val name: String,
    val createdAt: Long,
)

/**
 * 저장한 단어 (AD-03, AD-05, AD-06). 어느 단어장에 들었는지는 [WordbookWordEntity]가 가진다 —
 * 한 단어가 여러 단어장에 들 수 있고, 외운 표시 · 정답률 · 내용은 단어 하나에 하나라서 단어장이 달라도 같다.
 * 어느 단어장에도 들지 않은 단어는 지운다. 같은 단어장에 같은 [word]는 한 줄이다 (코드에서 지킨다).
 * 번역 기록(translation_records)과는 이어 두지 않는다 — 기록은 2000개 넘으면 지워지기 때문.
 */
@Entity(
    tableName = "vocabulary_words",
    indices = [Index(value = ["word"]), Index(value = ["createdAt"])],
)
data class WordEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val word: String,
    val meaning: String,
    val pronunciation: String? = null,
    val partOfSpeech: String? = null,
    /** 주변 문장 기준 문맥 뜻 (AI 엔진이 있을 때만). */
    val contextMeaning: String? = null,
    /** 단어를 고른 원래 문장. */
    val sentence: String? = null,
    /** 출처 앱 이름. */
    val sourceApp: String? = null,
    val sourceLanguage: String,
    val targetLanguage: String,
    val memorized: Boolean = false,
    val createdAt: Long,
    /** 테스트 · 게임에서 맞힌 횟수와 푼 횟수 (AD-18). */
    @ColumnInfo(defaultValue = "0") val correctCount: Int = 0,
    @ColumnInfo(defaultValue = "0") val attemptCount: Int = 0,
)

/** 단어장에 든 단어 (단어장 ↔ 단어, 다대다). 단어장이나 단어가 지워지면 함께 지워진다. */
@Entity(
    tableName = "wordbook_words",
    primaryKeys = ["wordbookId", "wordId"],
    foreignKeys = [
        ForeignKey(
            entity = WordbookEntity::class,
            parentColumns = ["id"],
            childColumns = ["wordbookId"],
            onDelete = ForeignKey.CASCADE,
        ),
        ForeignKey(
            entity = WordEntity::class,
            parentColumns = ["id"],
            childColumns = ["wordId"],
            onDelete = ForeignKey.CASCADE,
        ),
    ],
    indices = [Index(value = ["wordId"])],
)
data class WordbookWordEntity(val wordbookId: Long, val wordId: Long)

/** 목록용: 단어장 + 단어 수 · 외운 단어 수. */
data class WordbookRow(
    val id: Long,
    val name: String,
    val createdAt: Long,
    val wordCount: Int,
    val memorizedCount: Int,
    val correctCount: Int,
    val attemptCount: Int,
)

@Dao
interface VocabularyDao {
    @Query(
        "SELECT b.id AS id, b.name AS name, b.createdAt AS createdAt, " +
            "COUNT(w.id) AS wordCount, COALESCE(SUM(w.memorized), 0) AS memorizedCount, " +
            "COALESCE(SUM(w.correctCount), 0) AS correctCount, COALESCE(SUM(w.attemptCount), 0) AS attemptCount " +
            "FROM wordbooks b LEFT JOIN wordbook_words l ON l.wordbookId = b.id " +
            "LEFT JOIN vocabulary_words w ON w.id = l.wordId " +
            "GROUP BY b.id ORDER BY b.createdAt ASC, b.id ASC",
    )
    suspend fun wordbooks(): List<WordbookRow>

    @Query("SELECT * FROM wordbooks WHERE name = :name LIMIT 1")
    suspend fun wordbookByName(name: String): WordbookEntity?

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertWordbook(wordbook: WordbookEntity): Long

    @Query("UPDATE wordbooks SET name = :name WHERE id = :id")
    suspend fun renameWordbook(id: Long, name: String)

    @Query("DELETE FROM wordbooks WHERE id = :id")
    suspend fun deleteWordbookRow(id: Long)

    /** 어느 단어장에도 들지 않은 단어를 지운다. */
    @Query("DELETE FROM vocabulary_words WHERE id NOT IN (SELECT wordId FROM wordbook_words)")
    suspend fun deleteOrphanWords()

    /** 단어장을 지운다. 다른 단어장에도 든 단어는 남기고, 이 단어장에만 있던 단어는 함께 지운다. */
    @Transaction
    suspend fun deleteWordbook(id: Long) {
        deleteWordbookRow(id)
        deleteOrphanWords()
    }

    /** [pattern]은 LIKE 패턴 (빈 문자열이면 전부). [sort]는 [WordSort.code]. */
    @Query(
        "SELECT w.* FROM vocabulary_words w JOIN wordbook_words l ON l.wordId = w.id WHERE l.wordbookId = :wordbookId AND " +
            "(:pattern = '' OR w.word LIKE :pattern ESCAPE '\\' OR w.meaning LIKE :pattern ESCAPE '\\') " +
            "ORDER BY (CASE WHEN :sort = 2 THEN w.word END) COLLATE NOCASE ASC, " +
            "(CASE WHEN :sort = 1 THEN w.createdAt END) ASC, w.createdAt DESC, w.id DESC",
    )
    suspend fun words(wordbookId: Long, pattern: String, sort: Int): List<WordEntity>

    @Query("SELECT * FROM vocabulary_words WHERE id = :id")
    suspend fun word(id: Long): WordEntity?

    /** 이 단어장에 든 같은 글자의 단어. */
    @Query(
        "SELECT w.* FROM vocabulary_words w JOIN wordbook_words l ON l.wordId = w.id " +
            "WHERE l.wordbookId = :wordbookId AND w.word = :word LIMIT 1",
    )
    suspend fun wordByText(wordbookId: Long, word: String): WordEntity?

    /** 단어장과 상관없이 같은 단어(글자 · 언어 쌍이 같은)를 찾는다. 가장 먼저 저장한 것. */
    @Query(
        "SELECT * FROM vocabulary_words WHERE word = :word AND sourceLanguage = :sourceLanguage " +
            "AND targetLanguage = :targetLanguage ORDER BY id ASC LIMIT 1",
    )
    suspend fun wordAnywhere(word: String, sourceLanguage: String, targetLanguage: String): WordEntity?

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertWord(word: WordEntity): Long

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertLink(link: WordbookWordEntity): Long

    @Query("DELETE FROM wordbook_words WHERE wordbookId = :wordbookId AND wordId = :wordId")
    suspend fun deleteLink(wordbookId: Long, wordId: Long)

    @Query("SELECT wordbookId FROM wordbook_words WHERE wordId = :wordId ORDER BY wordbookId ASC")
    suspend fun wordbookIdsOf(wordId: Long): List<Long>

    @Query("SELECT COUNT(*) FROM wordbooks WHERE id = :id")
    suspend fun wordbookExists(id: Long): Int

    @Query(
        "UPDATE vocabulary_words SET meaning = :meaning, pronunciation = :pronunciation, partOfSpeech = :partOfSpeech, " +
            "contextMeaning = :contextMeaning, sentence = :sentence, sourceApp = :sourceApp WHERE id = :id",
    )
    suspend fun updateWordContent(
        id: Long,
        meaning: String,
        pronunciation: String?,
        partOfSpeech: String?,
        contextMeaning: String?,
        sentence: String?,
        sourceApp: String?,
    )

    @Query(
        "UPDATE vocabulary_words SET word = :word, meaning = :meaning, pronunciation = :pronunciation, " +
            "partOfSpeech = :partOfSpeech, contextMeaning = :contextMeaning, sentence = :sentence WHERE id = :id",
    )
    suspend fun updateWordFields(
        id: Long,
        word: String,
        meaning: String,
        pronunciation: String?,
        partOfSpeech: String?,
        contextMeaning: String?,
        sentence: String?,
    )

    /** 단어의 내용을 고친다. 외운 표시 · 정답률 · 저장 시각 · 출처는 그대로. 같은 단어장의 다른 단어와 겹치면 false. */
    @Transaction
    suspend fun editWord(id: Long, edited: WordEntity): Boolean {
        if (word(id) == null) return false
        for (bookId in wordbookIdsOf(id)) {
            val clash = wordByText(bookId, edited.word)
            if (clash != null && clash.id != id) return false
        }
        updateWordFields(
            id, edited.word, edited.meaning, edited.pronunciation, edited.partOfSpeech,
            edited.contextMeaning, edited.sentence,
        )
        return true
    }

    @Query("UPDATE vocabulary_words SET memorized = :memorized WHERE id = :id")
    suspend fun setMemorized(id: Long, memorized: Boolean)

    @Query("DELETE FROM vocabulary_words WHERE id = :id")
    suspend fun deleteWord(id: Long)

    /**
     * 한 번 푼 결과를 더한다 (AD-18). [correct]는 맞으면 1, 틀리면 0.
     * 최근 10번 기준으로 보려고 10번을 넘기면 지난 기록을 9/10로 줄이고 새 결과를 더한다
     * (예전에 많이 틀려도 계속 맞히면 정답률이 오른다).
     */
    @Query(
        "UPDATE vocabulary_words SET " +
            "correctCount = CASE WHEN attemptCount >= 10 " +
            "THEN CAST(ROUND(correctCount * 9.0 / attemptCount) AS INTEGER) + :correct " +
            "ELSE correctCount + :correct END, " +
            "attemptCount = MIN(attemptCount + 1, 10) WHERE id = :id",
    )
    suspend fun addAnswer(id: Long, correct: Int)

    /**
     * [wordbookId] 단어장에 단어를 저장한다. 이 단어장에 같은 단어가 있으면 내용만 새로 고치고(외운 표시 · 저장 시각 유지),
     * 다른 단어장에 같은 단어가 있으면 그 단어를 이 단어장에도 넣고(내용은 새로 고침), 어디에도 없으면 새로 만든다.
     * 단어 id를 돌려준다. 단어장이 없으면 -1.
     */
    @Transaction
    suspend fun upsertWord(wordbookId: Long, word: WordEntity): Long {
        if (wordbookExists(wordbookId) == 0) return -1L
        val here = wordByText(wordbookId, word.word)
        val existing = here ?: wordAnywhere(word.word, word.sourceLanguage, word.targetLanguage)
        if (existing == null) {
            val id = insertWord(word)
            insertLink(WordbookWordEntity(wordbookId, id))
            return id
        }
        updateWordContent(
            existing.id, word.meaning, word.pronunciation, word.partOfSpeech,
            word.contextMeaning, word.sentence, word.sourceApp,
        )
        if (here == null) insertLink(WordbookWordEntity(wordbookId, existing.id))
        return existing.id
    }

    /**
     * 단어를 [wordbookId] 단어장에도 넣는다. 이미 들어 있거나, 그 단어장에 같은 글자의 다른 단어가 있으면 false.
     * (같은 글자가 이미 있을 때 합치지 않는다 — 사용자가 직접 고르는 동작이라 알려 준다.)
     */
    @Transaction
    suspend fun addToWordbook(id: Long, wordbookId: Long): Boolean {
        val word = word(id) ?: return false
        if (wordbookExists(wordbookId) == 0) return false
        if (wordByText(wordbookId, word.word) != null) return false
        return insertLink(WordbookWordEntity(wordbookId, id)) != -1L
    }

    /** 단어를 한 단어장에서 뺀다. 어느 단어장에도 안 남으면 단어도 지운다. */
    @Transaction
    suspend fun removeFromWordbook(id: Long, wordbookId: Long) {
        deleteLink(wordbookId, id)
        deleteOrphanWords()
    }

    /** [from]에서 [to]로 옮긴다. [to]에 같은 단어가 이미 있으면 [from]에서만 뺀다(합친다). */
    @Transaction
    suspend fun moveWord(id: Long, from: Long, to: Long) {
        val word = word(id) ?: return
        if (from == to || wordbookExists(to) == 0) return
        if (wordbookIdsOf(id).none { it == from }) return
        if (wordByText(to, word.word) == null) insertLink(WordbookWordEntity(to, id))
        deleteLink(from, id)
        deleteOrphanWords()
    }
}
