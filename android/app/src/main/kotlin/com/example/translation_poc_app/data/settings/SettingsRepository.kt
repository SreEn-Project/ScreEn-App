package com.example.translation_poc_app.data.settings

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map

private val Context.settingsDataStore: DataStore<Preferences> by preferencesDataStore(name = "settings")

/**
 * 설정 저장소 (NA-16). DataStore가 단일 원본이며,
 * 실행 중인 서비스 · 오버레이는 [settings]를 구독해 변경을 바로 반영한다.
 */
class SettingsRepository(context: Context) {
    private val dataStore = context.applicationContext.settingsDataStore

    val settings: Flow<Settings> = dataStore.data
        .map { it.toSettings() }
        .distinctUntilChanged()

    suspend fun current(): Settings = settings.first()

    suspend fun setTargetLanguage(languageCode: String) = edit { it[Keys.TARGET_LANGUAGE] = languageCode }

    suspend fun setEngine(engine: Engine) = edit { it[Keys.ENGINE] = engine.name }

    suspend fun setCaptureRange(range: CaptureRange) = edit { it[Keys.CAPTURE_RANGE] = range.name }

    suspend fun setResultDisplay(display: ResultDisplay) = edit { it[Keys.RESULT_DISPLAY] = display.name }

    suspend fun setFixedRegion(region: NormalizedRegion) = edit { it[Keys.FIXED_REGION] = region.encode() }

    suspend fun setQuickLanguages(codes: List<String>) = edit { it[Keys.QUICK_LANGUAGES] = codes.joinToString(",") }

    suspend fun setAutoTranslate(enabled: Boolean) = edit { it[Keys.AUTO_TRANSLATE] = enabled }

    suspend fun setAutoCheckIntervalMs(ms: Long) =
        edit { it[Keys.AUTO_CHECK_INTERVAL] = ms.coerceIn(Settings.AUTO_CHECK_INTERVAL_RANGE_MS) }

    suspend fun setAutoSettleMs(ms: Long) =
        edit { it[Keys.AUTO_SETTLE] = ms.coerceIn(Settings.AUTO_SETTLE_RANGE_MS) }

    suspend fun setOnboardingCompleted(completed: Boolean) =
        edit { it[Keys.ONBOARDING_COMPLETED] = completed }

    private suspend fun edit(block: (androidx.datastore.preferences.core.MutablePreferences) -> Unit) {
        dataStore.edit { block(it) }
    }

    private fun Preferences.toSettings(): Settings {
        val defaults = Settings()
        return Settings(
            targetLanguage = this[Keys.TARGET_LANGUAGE] ?: defaults.targetLanguage,
            engine = enumOrDefault(this[Keys.ENGINE], defaults.engine),
            captureRange = enumOrDefault(this[Keys.CAPTURE_RANGE], defaults.captureRange),
            resultDisplay = enumOrDefault(this[Keys.RESULT_DISPLAY], defaults.resultDisplay),
            onboardingCompleted = this[Keys.ONBOARDING_COMPLETED] ?: defaults.onboardingCompleted,
            fixedRegion = NormalizedRegion.decode(this[Keys.FIXED_REGION]),
            quickLanguages = this[Keys.QUICK_LANGUAGES]
                ?.split(",")?.map { it.trim() }?.filter { it.isNotEmpty() }
                ?.takeIf { it.isNotEmpty() }
                ?: defaults.quickLanguages,
            autoTranslate = this[Keys.AUTO_TRANSLATE] ?: defaults.autoTranslate,
            autoCheckIntervalMs = (this[Keys.AUTO_CHECK_INTERVAL] ?: defaults.autoCheckIntervalMs)
                .coerceIn(Settings.AUTO_CHECK_INTERVAL_RANGE_MS),
            autoSettleMs = (this[Keys.AUTO_SETTLE] ?: defaults.autoSettleMs)
                .coerceIn(Settings.AUTO_SETTLE_RANGE_MS),
        )
    }

    // 저장된 이름이 없어진 값이면(앱 업데이트 등) 기본값으로 돌아간다.
    private inline fun <reified T : Enum<T>> enumOrDefault(name: String?, default: T): T =
        name?.let { runCatching { enumValueOf<T>(it) }.getOrNull() } ?: default

    private object Keys {
        val TARGET_LANGUAGE = stringPreferencesKey("target_language")
        val ENGINE = stringPreferencesKey("engine")
        val CAPTURE_RANGE = stringPreferencesKey("capture_range")
        val RESULT_DISPLAY = stringPreferencesKey("result_display")
        val ONBOARDING_COMPLETED = booleanPreferencesKey("onboarding_completed")
        val FIXED_REGION = stringPreferencesKey("fixed_region")
        val QUICK_LANGUAGES = stringPreferencesKey("quick_languages")
        val AUTO_TRANSLATE = booleanPreferencesKey("auto_translate")
        val AUTO_CHECK_INTERVAL = longPreferencesKey("auto_check_interval_ms")
        val AUTO_SETTLE = longPreferencesKey("auto_settle_ms")
    }
}
