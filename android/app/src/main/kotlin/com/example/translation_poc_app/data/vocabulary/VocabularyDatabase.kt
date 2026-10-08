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
 * 저장한 단어 (AD-03, AD-05, AD-06). 단어장을 지우면 안의 단어도 함께 지워진다.
 * 같은 단어장에 같은 [word]는 한 줄이다 (다시 저장하면 내용만 새로 고친다).
 * 번역 기록(translation_records)과는 이어 두지 않는다 — 기록은 2000개 넘으면 지워지기 때문.
 */
@Entity(
    tableName = "vocabulary_words",
    foreignKeys = [
        ForeignKey(
            entity = WordbookEntity::class,
            parentColumns = ["id"],
            childColumns = ["wordbookId"],
            onDelete = ForeignKey.CASCADE,
        ),
    ],
    indices = [
        Index(value = ["wordbookId", "word"], unique = true),
        Index(value = ["createdAt"]),
    ],
)
data class WordEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val wordbookId: Long,
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
            "FROM wordbooks b LEFT JOIN vocabulary_words w ON w.wordbookId = b.id " +
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
    suspend fun deleteWordbook(id: Long)

    /** [pattern]은 LIKE 패턴 (빈 문자열이면 전부). [sort]는 [WordSort.code]. */
    @Query(
        "SELECT * FROM vocabulary_words WHERE wordbookId = :wordbookId AND " +
            "(:pattern = '' OR word LIKE :pattern ESCAPE '\\' OR meaning LIKE :pattern ESCAPE '\\') " +
            "ORDER BY (CASE WHEN :sort = 2 THEN word END) COLLATE NOCASE ASC, " +
            "(CASE WHEN :sort = 1 THEN createdAt END) ASC, createdAt DESC, id DESC",
    )
    suspend fun words(wordbookId: Long, pattern: String, sort: Int): List<WordEntity>

    @Query("SELECT * FROM vocabulary_words WHERE id = :id")
    suspend fun word(id: Long): WordEntity?

    @Query("SELECT * FROM vocabulary_words WHERE wordbookId = :wordbookId AND word = :word LIMIT 1")
    suspend fun wordByText(wordbookId: Long, word: String): WordEntity?

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertWord(word: WordEntity): Long

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
        val current = word(id) ?: return false
        val clash = wordByText(current.wordbookId, edited.word)
        if (clash != null && clash.id != id) return false
        updateWordFields(
            id, edited.word, edited.meaning, edited.pronunciation, edited.partOfSpeech,
            edited.contextMeaning, edited.sentence,
        )
        return true
    }

    @Query("UPDATE vocabulary_words SET wordbookId = :wordbookId WHERE id = :id")
    suspend fun moveWord(id: Long, wordbookId: Long)

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

    /** 같은 단어면 내용만 새로 고치고(외운 표시 · 저장 시각은 유지), 없으면 넣는다. 단어 id를 돌려준다. */
    @Transaction
    suspend fun upsertWord(word: WordEntity): Long {
        val inserted = insertWord(word)
        if (inserted != -1L) return inserted
        val existing = wordByText(word.wordbookId, word.word) ?: return -1L
        updateWordContent(
            existing.id, word.meaning, word.pronunciation, word.partOfSpeech,
            word.contextMeaning, word.sentence, word.sourceApp,
        )
        return existing.id
    }

    /** 옮길 단어장에 같은 단어가 이미 있으면 옮기는 쪽을 지우고(합친다), 아니면 옮긴다. */
    @Transaction
    suspend fun moveOrMerge(id: Long, wordbookId: Long) {
        val word = word(id) ?: return
        if (word.wordbookId == wordbookId) return
        if (wordByText(wordbookId, word.word) != null) deleteWord(id) else moveWord(id, wordbookId)
    }
}
