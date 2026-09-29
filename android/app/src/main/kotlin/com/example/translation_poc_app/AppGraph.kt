package com.example.translation_poc_app

import android.content.Context
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
}
