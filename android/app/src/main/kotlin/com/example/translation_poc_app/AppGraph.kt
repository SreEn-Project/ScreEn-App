package com.example.translation_poc_app

import android.content.Context
import com.example.translation_poc_app.data.history.AppDatabase
import com.example.translation_poc_app.data.history.HistoryRepository
import com.example.translation_poc_app.data.settings.SettingsRepository

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
    private var historyRepository: HistoryRepository? = null

    /** 번역 기록 (NA-23). DB는 처음 쓸 때 연다. */
    fun historyRepository(context: Context): HistoryRepository =
        historyRepository ?: synchronized(this) {
            historyRepository ?: HistoryRepository(AppDatabase.create(context).history()).also {
                historyRepository = it
            }
        }
}
