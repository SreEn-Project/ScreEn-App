package com.example.translation_poc_app.data.history

import android.content.Context
import androidx.room.Dao
import androidx.room.Database
import androidx.room.Entity
import androidx.room.Index
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.PrimaryKey
import androidx.room.Query
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.Transaction

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

@Database(entities = [TranslationRecord::class], version = 1, exportSchema = true)
abstract class AppDatabase : RoomDatabase() {
    abstract fun history(): HistoryDao

    companion object {
        const val NAME = "screen_translator.db"

        fun create(context: Context): AppDatabase =
            Room.databaseBuilder(context.applicationContext, AppDatabase::class.java, NAME).build()
    }
}
