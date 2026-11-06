package com.example.translation_poc_app.data.history

import android.content.Context
import androidx.room.Dao
import androidx.room.AutoMigration
import androidx.room.Database
import androidx.room.Entity
import androidx.room.Index
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.PrimaryKey
import androidx.room.Query
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import androidx.room.Transaction
import com.example.translation_poc_app.data.vocabulary.VocabularyDao
import com.example.translation_poc_app.data.vocabulary.WordEntity
import com.example.translation_poc_app.data.vocabulary.WordbookEntity
import com.example.translation_poc_app.data.vocabulary.WordbookWordEntity

/**
 * 번역 기록 한 줄 (NA-23, FL-13): 번역된 블록 하나. 같은 (원문, 번역, 언어, 엔진)은 한 줄이고
 * 다시 번역하면 [createdAt]만 새로 고친다 (자동 번역이 같은 화면을 반복해 번역해도 기록이 불어나지 않는다).
 * 단어장(AD-)은 이 표를 건드리지 않고 자기 표를 [id]로 가리킬 수 있다.
 */
@Entity(
    tableName = "translation_records",
    indices = [
        Index(value = ["original", "translated", "sourceLanguage", "targetLanguage", "engine"], unique = true),
        Index(value = ["createdAt"]),
    ],
)
data class TranslationRecord(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val original: String,
    val translated: String,
    val sourceLanguage: String,
    val targetLanguage: String,
    /** [com.example.translation_poc_app.translate.EngineId] 이름. */
    val engine: String,
    /** 마지막으로 번역한 시각 (epoch ms). */
    val createdAt: Long,
)

@Dao
interface HistoryDao {
    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertIgnore(record: TranslationRecord): Long

    @Query(
        "UPDATE translation_records SET createdAt = :createdAt WHERE original = :original AND translated = :translated " +
            "AND sourceLanguage = :sourceLanguage AND targetLanguage = :targetLanguage AND engine = :engine",
    )
    suspend fun touch(
        original: String,
        translated: String,
        sourceLanguage: String,
        targetLanguage: String,
        engine: String,
        createdAt: Long,
    )

    /** 이미 있으면 시각만 새로 고치고, 없으면 넣는다. */
    @Transaction
    suspend fun upsert(record: TranslationRecord) {
        if (insertIgnore(record) == -1L) {
            touch(record.original, record.translated, record.sourceLanguage, record.targetLanguage, record.engine, record.createdAt)
        }
    }

    /** [pattern]은 LIKE 패턴 (`%` · `_` · `\`는 호출 쪽에서 이스케이프). 빈 문자열이면 전부. */
    @Query(
        "SELECT * FROM translation_records WHERE createdAt >= :since AND " +
            "(:pattern = '' OR original LIKE :pattern ESCAPE '\\' OR translated LIKE :pattern ESCAPE '\\') " +
            "ORDER BY createdAt DESC, id DESC LIMIT :limit",
    )
    suspend fun search(pattern: String, since: Long, limit: Int): List<TranslationRecord>

    @Query("DELETE FROM translation_records WHERE id = :id")
    suspend fun delete(id: Long)

    @Query("DELETE FROM translation_records")
    suspend fun clear()

    /** 최신 [keep]개만 남기고 지운다. */
    @Query(
        "DELETE FROM translation_records WHERE id NOT IN " +
            "(SELECT id FROM translation_records ORDER BY createdAt DESC, id DESC LIMIT :keep)",
    )
    suspend fun trim(keep: Int)
}

/** 버전 2: 단어장 표 추가 (AD-03). 버전 3: 단어별 정답 · 시도 횟수 열 추가 (AD-18). 둘 다 자동 마이그레이션.
 * 버전 4: 한 단어를 여러 단어장에 넣으려고 단어장-단어 연결 표를 따로 둔다 ([MIGRATION_3_4], 직접 작성). */
@Database(
    entities = [TranslationRecord::class, WordbookEntity::class, WordEntity::class, WordbookWordEntity::class],
    version = 4,
    exportSchema = true,
    autoMigrations = [AutoMigration(from = 1, to = 2), AutoMigration(from = 2, to = 3)],
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun history(): HistoryDao

    abstract fun vocabulary(): VocabularyDao

    companion object {
        const val NAME = "screen_translator.db"

        /**
         * 단어의 `wordbookId` 열을 연결 표(`wordbook_words`)로 옮긴다. 단어 id는 그대로라서
         * 기존 단어장 · 단어 · 외움 · 정답률이 모두 유지된다. 같은 글자가 다른 단어장에 있던 것은 따로 둔 채 그대로 둔다.
         */
        val MIGRATION_3_4 = object : Migration(3, 4) {
            override fun migrate(db: SupportSQLiteDatabase) {
                db.execSQL(
                    "CREATE TABLE IF NOT EXISTS `vocabulary_words_new` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " +
                        "`word` TEXT NOT NULL, `meaning` TEXT NOT NULL, `pronunciation` TEXT, `partOfSpeech` TEXT, " +
                        "`contextMeaning` TEXT, `sentence` TEXT, `sourceApp` TEXT, `sourceLanguage` TEXT NOT NULL, " +
                        "`targetLanguage` TEXT NOT NULL, `memorized` INTEGER NOT NULL, `createdAt` INTEGER NOT NULL, " +
                        "`correctCount` INTEGER NOT NULL DEFAULT 0, `attemptCount` INTEGER NOT NULL DEFAULT 0)",
                )
                db.execSQL(
                    "INSERT INTO `vocabulary_words_new` (id, word, meaning, pronunciation, partOfSpeech, contextMeaning, " +
                        "sentence, sourceApp, sourceLanguage, targetLanguage, memorized, createdAt, correctCount, attemptCount) " +
                        "SELECT id, word, meaning, pronunciation, partOfSpeech, contextMeaning, sentence, sourceApp, " +
                        "sourceLanguage, targetLanguage, memorized, createdAt, correctCount, attemptCount FROM `vocabulary_words`",
                )
                // 옛 표를 지우면 연결이 사라지므로 단어장-단어 짝을 임시 표에 먼저 담아 둔다.
                db.execSQL("CREATE TEMP TABLE `wordbook_words_tmp` AS SELECT `wordbookId`, `id` AS `wordId` FROM `vocabulary_words`")
                db.execSQL("DROP TABLE `vocabulary_words`")
                db.execSQL("ALTER TABLE `vocabulary_words_new` RENAME TO `vocabulary_words`")
                db.execSQL(
                    "CREATE TABLE IF NOT EXISTS `wordbook_words` (`wordbookId` INTEGER NOT NULL, `wordId` INTEGER NOT NULL, " +
                        "PRIMARY KEY(`wordbookId`, `wordId`), " +
                        "FOREIGN KEY(`wordbookId`) REFERENCES `wordbooks`(`id`) ON UPDATE NO ACTION ON DELETE CASCADE, " +
                        "FOREIGN KEY(`wordId`) REFERENCES `vocabulary_words`(`id`) ON UPDATE NO ACTION ON DELETE CASCADE)",
                )
                db.execSQL("INSERT INTO `wordbook_words` (`wordbookId`, `wordId`) SELECT `wordbookId`, `wordId` FROM `wordbook_words_tmp`")
                db.execSQL("DROP TABLE `wordbook_words_tmp`")
                db.execSQL("CREATE INDEX IF NOT EXISTS `index_vocabulary_words_word` ON `vocabulary_words` (`word`)")
                db.execSQL("CREATE INDEX IF NOT EXISTS `index_vocabulary_words_createdAt` ON `vocabulary_words` (`createdAt`)")
                db.execSQL("CREATE INDEX IF NOT EXISTS `index_wordbook_words_wordId` ON `wordbook_words` (`wordId`)")
            }
        }

        fun create(context: Context): AppDatabase =
            Room.databaseBuilder(context.applicationContext, AppDatabase::class.java, NAME)
                .addMigrations(MIGRATION_3_4)
                .build()
    }
}
