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
 * 저장한 단어 (AD-03, AD-05, AD-06): 단어장과 상관없는 공통 부분 — 글자 · 발음 · 품사 · 언어쌍.
 * 한 단어가 여러 단어장에 들 수 있다 ([WordbookWordEntity]). 뜻은 [WordMeaningEntity]에 여러 개 둔다.
 * 외움 표시 · 정답률은 단어장마다 따로 쌓인다 ([WordbookWordEntity]).
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
    val pronunciation: String? = null,
    val partOfSpeech: String? = null,
    val sourceLanguage: String,
    val targetLanguage: String,
    val createdAt: Long,
)

/** 단어의 뜻 하나. 단어마다 여러 개 둘 수 있고, 먼저 넣은 뜻(id가 작은)이 대표 뜻이다. */
@Entity(
    tableName = "word_meanings",
    foreignKeys = [
        ForeignKey(
            entity = WordEntity::class,
            parentColumns = ["id"],
            childColumns = ["wordId"],
            onDelete = ForeignKey.CASCADE,
        ),
    ],
    indices = [Index(value = ["wordId"])],
)
data class WordMeaningEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val wordId: Long,
    val meaning: String,
    /** 주변 문장 기준 문맥 뜻 (AI 엔진이 있을 때만). */
    val contextMeaning: String? = null,
    /** 단어를 고른 원래 문장. */
    val sentence: String? = null,
    /** 출처 앱 이름. */
    val sourceApp: String? = null,
    val createdAt: Long,
)

/**
 * 단어장에 든 단어 (단어장 ↔ 단어, 다대다) + 그 단어장에서의 학습 진도.
 * 단어장이나 단어가 지워지면 함께 지워진다.
 */
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
data class WordbookWordEntity(
    val wordbookId: Long,
    val wordId: Long,
    val memorized: Boolean = false,
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

/** 한 단어를 한 단어장에서 본 모습: 공통 부분 + 그 단어장의 진도. */
data class WordRow(
    val id: Long,
    val wordbookId: Long,
    val word: String,
    val pronunciation: String?,
    val partOfSpeech: String?,
    val sourceLanguage: String,
    val targetLanguage: String,
    val memorized: Boolean,
    val createdAt: Long,
    val correctCount: Int,
    val attemptCount: Int,
)

private const val WORD_ROW_SELECT =
    "SELECT w.id AS id, l.wordbookId AS wordbookId, w.word AS word, w.pronunciation AS pronunciation, " +
        "w.partOfSpeech AS partOfSpeech, w.sourceLanguage AS sourceLanguage, w.targetLanguage AS targetLanguage, " +
        "l.memorized AS memorized, w.createdAt AS createdAt, l.correctCount AS correctCount, l.attemptCount AS attemptCount " +
        "FROM vocabulary_words w JOIN wordbook_words l ON l.wordId = w.id "

@Dao
interface VocabularyDao {
    @Query(
        "SELECT b.id AS id, b.name AS name, b.createdAt AS createdAt, " +
            "COUNT(l.wordId) AS wordCount, COALESCE(SUM(l.memorized), 0) AS memorizedCount, " +
            "COALESCE(SUM(l.correctCount), 0) AS correctCount, COALESCE(SUM(l.attemptCount), 0) AS attemptCount " +
            "FROM wordbooks b LEFT JOIN wordbook_words l ON l.wordbookId = b.id " +
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

    /** 어느 단어장에도 들지 않은 단어를 지운다 (뜻도 함께 지워진다). */
    @Query("DELETE FROM vocabulary_words WHERE id NOT IN (SELECT wordId FROM wordbook_words)")
    suspend fun deleteOrphanWords()

    /** 단어장을 지운다. 다른 단어장에도 든 단어는 남기고, 이 단어장에만 있던 단어는 함께 지운다. */
    @Transaction
    suspend fun deleteWordbook(id: Long) {
        deleteWordbookRow(id)
        deleteOrphanWords()
    }

    /** [pattern]은 LIKE 패턴 (빈 문자열이면 전부). [sort]는 [WordSort.code]. 단어 · 모든 뜻에서 찾는다. */
    @Query(
        WORD_ROW_SELECT +
            "WHERE l.wordbookId = :wordbookId AND " +
            "(:pattern = '' OR w.word LIKE :pattern ESCAPE '\\' OR EXISTS " +
            "(SELECT 1 FROM word_meanings m WHERE m.wordId = w.id AND m.meaning LIKE :pattern ESCAPE '\\')) " +
            "ORDER BY (CASE WHEN :sort = 2 THEN w.word END) COLLATE NOCASE ASC, " +
            "(CASE WHEN :sort = 1 THEN w.createdAt END) ASC, w.createdAt DESC, w.id DESC",
    )
    suspend fun words(wordbookId: Long, pattern: String, sort: Int): List<WordRow>

    @Query(WORD_ROW_SELECT + "WHERE w.id = :id AND l.wordbookId = :wordbookId")
    suspend fun wordRow(id: Long, wordbookId: Long): WordRow?

    /** 단어장을 모를 때: 들어 있는 첫 단어장 기준. */
    @Query(WORD_ROW_SELECT + "WHERE w.id = :id ORDER BY l.wordbookId ASC LIMIT 1")
    suspend fun firstWordRow(id: Long): WordRow?

    @Query("SELECT * FROM vocabulary_words WHERE id = :id")
    suspend fun word(id: Long): WordEntity?

    /** 이 단어장에 든 같은 글자의 단어. */
    @Query(
        "SELECT w.* FROM vocabulary_words w JOIN wordbook_words l ON l.wordId = w.id " +
            "WHERE l.wordbookId = :wordbookId AND w.word = :word LIMIT 1",
    )
    suspend fun wordByText(wordbookId: Long, word: String): WordEntity?

    /** 단어장과 상관없이 같은 단어(글자 · 언어쌍이 같은)를 찾는다. 가장 먼저 저장한 것. */
    @Query(
        "SELECT * FROM vocabulary_words WHERE word = :word AND sourceLanguage = :sourceLanguage " +
            "AND targetLanguage = :targetLanguage ORDER BY id ASC LIMIT 1",
    )
    suspend fun wordAnywhere(word: String, sourceLanguage: String, targetLanguage: String): WordEntity?

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertWord(word: WordEntity): Long

    @Insert
    suspend fun insertMeaning(meaning: WordMeaningEntity): Long

    @Query("SELECT * FROM word_meanings WHERE wordId = :wordId ORDER BY id ASC")
    suspend fun meaningsOf(wordId: Long): List<WordMeaningEntity>

    @Query("SELECT * FROM word_meanings WHERE wordId IN (:wordIds) ORDER BY id ASC")
    suspend fun meaningsOfAll(wordIds: List<Long>): List<WordMeaningEntity>

    @Query("SELECT * FROM word_meanings WHERE id = :id")
    suspend fun meaning(id: Long): WordMeaningEntity?

    @Query("DELETE FROM word_meanings WHERE id = :id")
    suspend fun deleteMeaningRow(id: Long)

    @Query(
        "UPDATE word_meanings SET meaning = :meaning, contextMeaning = :contextMeaning, sentence = :sentence WHERE id = :id",
    )
    suspend fun updateMeaningFields(id: Long, meaning: String, contextMeaning: String?, sentence: String?)

    /** 같은 뜻을 다시 저장할 때 비어 있던 부가 정보만 채운다. */
    @Query(
        "UPDATE word_meanings SET contextMeaning = COALESCE(contextMeaning, :contextMeaning), " +
            "sentence = COALESCE(sentence, :sentence), sourceApp = COALESCE(sourceApp, :sourceApp) WHERE id = :id",
    )
    suspend fun fillMeaning(id: Long, contextMeaning: String?, sentence: String?, sourceApp: String?)

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertLink(link: WordbookWordEntity): Long

    @Query("DELETE FROM wordbook_words WHERE wordbookId = :wordbookId AND wordId = :wordId")
    suspend fun deleteLink(wordbookId: Long, wordId: Long)

    @Query("SELECT wordbookId FROM wordbook_words WHERE wordId = :wordId ORDER BY wordbookId ASC")
    suspend fun wordbookIdsOf(wordId: Long): List<Long>

    @Query("SELECT * FROM wordbook_words WHERE wordId = :wordId ORDER BY wordbookId ASC")
    suspend fun linksOf(wordId: Long): List<WordbookWordEntity>

    @Query("SELECT COUNT(*) FROM wordbooks WHERE id = :id")
    suspend fun wordbookExists(id: Long): Int

    @Query("UPDATE vocabulary_words SET word = :word, pronunciation = :pronunciation, partOfSpeech = :partOfSpeech WHERE id = :id")
    suspend fun updateWordFields(id: Long, word: String, pronunciation: String?, partOfSpeech: String?)

    @Query(
        "UPDATE vocabulary_words SET pronunciation = COALESCE(pronunciation, :pronunciation), " +
            "partOfSpeech = COALESCE(partOfSpeech, :partOfSpeech) WHERE id = :id",
    )
    suspend fun fillWord(id: Long, pronunciation: String?, partOfSpeech: String?)

    @Query("UPDATE wordbook_words SET memorized = :memorized WHERE wordbookId = :wordbookId AND wordId = :wordId")
    suspend fun setMemorized(wordbookId: Long, wordId: Long, memorized: Boolean)

    @Query("DELETE FROM vocabulary_words WHERE id = :id")
    suspend fun deleteWord(id: Long)

    /**
     * 한 번 푼 결과를 그 단어장의 진도에 더한다 (AD-18). [correct]는 맞으면 1, 틀리면 0.
     * 최근 10번 기준으로 보려고 10번을 넘기면 지난 기록을 9/10로 줄이고 새 결과를 더한다
     * (예전에 많이 틀려도 계속 맞히면 정답률이 오른다).
     */
    @Query(
        "UPDATE wordbook_words SET " +
            "correctCount = CASE WHEN attemptCount >= 10 " +
            "THEN CAST(ROUND(correctCount * 9.0 / attemptCount) AS INTEGER) + :correct " +
            "ELSE correctCount + :correct END, " +
            "attemptCount = MIN(attemptCount + 1, 10) WHERE wordbookId = :wordbookId AND wordId = :wordId",
    )
    suspend fun addAnswer(wordbookId: Long, wordId: Long, correct: Int)

    /**
     * [wordbookId] 단어장에 단어를 저장한다.
     * - 이 단어장 또는 다른 단어장에 같은 단어(글자 · 언어쌍)가 있으면 그 단어를 쓰고(이 단어장에 없으면 넣고),
     *   뜻이 없던 새 뜻이면 뜻을 더한다. 이미 있는 뜻이면 비어 있던 부가 정보만 채운다.
     * - 어디에도 없으면 단어와 뜻을 새로 만든다.
     * 단어 id를 돌려준다. 단어장이 없으면 -1.
     */
    @Transaction
    suspend fun saveWord(wordbookId: Long, word: WordEntity, meaning: WordMeaningEntity): Long {
        if (wordbookExists(wordbookId) == 0) return -1L
        val existing = wordByText(wordbookId, word.word) ?: wordAnywhere(word.word, word.sourceLanguage, word.targetLanguage)
        if (existing == null) {
            val id = insertWord(word)
            insertMeaning(meaning.copy(wordId = id))
            insertLink(WordbookWordEntity(wordbookId, id))
            return id
        }
        fillWord(existing.id, word.pronunciation, word.partOfSpeech)
        insertLink(WordbookWordEntity(wordbookId, existing.id))
        addOrFillMeaning(existing.id, meaning)
        return existing.id
    }

    /** 단어에 뜻을 더한다. 같은 뜻(공백 · 대소문자 무시)이 있으면 그 뜻의 빈 부가 정보만 채우고 false. */
    @Transaction
    suspend fun addOrFillMeaning(wordId: Long, meaning: WordMeaningEntity): Boolean {
        val same = meaningsOf(wordId).firstOrNull { sameMeaning(it.meaning, meaning.meaning) }
        if (same != null) {
            fillMeaning(same.id, meaning.contextMeaning, meaning.sentence, meaning.sourceApp)
            return false
        }
        insertMeaning(meaning.copy(wordId = wordId))
        return true
    }

    /**
     * 단어의 공통 부분(글자 · 발음 · 품사)과 대표 뜻(첫 뜻)을 고친다. 외움 · 정답률 · 저장 시각은 그대로.
     * 들어 있는 단어장 어디에든 같은 글자의 다른 단어가 있으면 false.
     */
    @Transaction
    suspend fun editWord(id: Long, edited: WordEntity, meaning: WordMeaningEntity): Boolean {
        if (word(id) == null) return false
        for (bookId in wordbookIdsOf(id)) {
            val clash = wordByText(bookId, edited.word)
            if (clash != null && clash.id != id) return false
        }
        updateWordFields(id, edited.word, edited.pronunciation, edited.partOfSpeech)
        val primary = meaningsOf(id).firstOrNull()
        if (primary == null) {
            insertMeaning(meaning.copy(wordId = id))
        } else {
            updateMeaningFields(primary.id, meaning.meaning, meaning.contextMeaning, meaning.sentence)
        }
        return true
    }

    /** 뜻 하나를 고친다. 같은 단어의 다른 뜻과 겹치면 false. */
    @Transaction
    suspend fun editMeaning(meaningId: Long, meaning: String, contextMeaning: String?, sentence: String?): Boolean {
        val current = meaning(meaningId) ?: return false
        val clash = meaningsOf(current.wordId).any { it.id != meaningId && sameMeaning(it.meaning, meaning) }
        if (clash) return false
        updateMeaningFields(meaningId, meaning, contextMeaning, sentence)
        return true
    }

    /** 뜻을 지운다. 마지막 하나는 지우지 않고 false. */
    @Transaction
    suspend fun deleteMeaning(meaningId: Long): Boolean {
        val current = meaning(meaningId) ?: return false
        if (meaningsOf(current.wordId).size <= 1) return false
        deleteMeaningRow(meaningId)
        return true
    }

    /**
     * 단어를 [wordbookId] 단어장에도 넣는다. 이미 들어 있거나, 그 단어장에 같은 글자의 다른 단어가 있으면 false.
     * 새 단어장에서의 진도는 0부터 시작한다.
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

    /** [from]에서 [to]로 옮긴다 (진도도 함께). [to]에 같은 단어가 이미 있으면 [from]에서만 뺀다(합친다). */
    @Transaction
    suspend fun moveWord(id: Long, from: Long, to: Long) {
        val word = word(id) ?: return
        if (from == to || wordbookExists(to) == 0) return
        val link = linksOf(id).firstOrNull { it.wordbookId == from } ?: return
        if (wordByText(to, word.word) == null) insertLink(link.copy(wordbookId = to))
        deleteLink(from, id)
        deleteOrphanWords()
    }
}

/** 뜻이 같은지 (앞뒤 공백 · 대소문자 무시). */
fun sameMeaning(a: String, b: String): Boolean = a.trim().equals(b.trim(), ignoreCase = true)
