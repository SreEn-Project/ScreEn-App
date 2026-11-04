package com.example.translation_poc_app

import android.content.Context
import com.example.translation_poc_app.data.settings.ApiKeyStore
import com.example.translation_poc_app.data.history.AppDatabase
import com.example.translation_poc_app.data.history.HistoryRepository
import com.example.translation_poc_app.data.settings.SettingsRepository
import com.example.translation_poc_app.data.vocabulary.VocabularyRepository
import com.example.translation_poc_app.translate.GemmaModelManager
import com.example.translation_poc_app.translate.GemmaRuntime
import com.example.translation_poc_app.translate.MediaPipeLlmRunner

/**
 * 프로세스 단위 공유 객체. Activity(Flutter 브리지)와 서비스가 같은 인스턴스를 쓴다.
 * 의존성이 늘어나면 DI 도입을 검토한다.
 */
object AppGraph {
    @Volatile
    private var settingsRepository: SettingsRepository? = null

    fun settingsRepository(context: Context): SettingsRepository =
        settingsRepository ?: synchronized(this) {
            settingsRepository ?: SettingsRepository(context.applicationContext).also {
                settingsRepository = it
            }
        }

    @Volatile
    private var database: AppDatabase? = null

    /** 기록 · 단어장이 함께 쓰는 DB. 처음 쓸 때 연다 (NA-23, AD-03). */
    private fun database(context: Context): AppDatabase =
        database ?: synchronized(this) {
            database ?: AppDatabase.create(context).also { database = it }
        }

    @Volatile
    private var historyRepository: HistoryRepository? = null

    /** 번역 기록 (NA-23). */
    fun historyRepository(context: Context): HistoryRepository =
        historyRepository ?: synchronized(this) {
            historyRepository ?: HistoryRepository(database(context).history()).also {
                historyRepository = it
            }
        }

    @Volatile
    private var vocabularyRepository: VocabularyRepository? = null

    /** 단어장 (AD-03). */
    fun vocabularyRepository(context: Context): VocabularyRepository =
        vocabularyRepository ?: synchronized(this) {
            vocabularyRepository ?: VocabularyRepository(database(context).vocabulary()).also {
                vocabularyRepository = it
            }
        }

    @Volatile
    private var gemmaModelManager: GemmaModelManager? = null

    /** Gemma 온디바이스 모델 파일 관리 (#174). */
    fun gemmaModelManager(context: Context): GemmaModelManager =
        gemmaModelManager ?: synchronized(this) {
            gemmaModelManager ?: GemmaModelManager(
                context.applicationContext,
                tokenProvider = { apiKeyStore(context).huggingFaceToken() },
            ).also { gemmaModelManager = it }
        }

    @Volatile
    private var gemmaRuntime: GemmaRuntime? = null

    /** Gemma 실행기. 프로세스에서 하나만 두고, 안 쓰면 알아서 메모리에서 내린다 (#174). */
    fun gemmaRuntime(context: Context): GemmaRuntime =
        gemmaRuntime ?: synchronized(this) {
            gemmaRuntime ?: gemmaModelManager(context).let { models ->
                GemmaRuntime(
                    modelFile = { models.modelFile },
                    isReady = { models.isReady() },
                    createRunner = { MediaPipeLlmRunner(context.applicationContext, it) },
                )
            }.also { gemmaRuntime = it }
        }

    @Volatile
    private var apiKeyStore: ApiKeyStore? = null

    /** AI 번역 API 키 보관소 (NA-13). */
    fun apiKeyStore(context: Context): ApiKeyStore =
        apiKeyStore ?: synchronized(this) {
            apiKeyStore ?: ApiKeyStore(context).also { apiKeyStore = it }
        }
}
