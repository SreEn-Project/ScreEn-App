package com.example.translation_poc_app.data.settings

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import org.json.JSONArray
import org.json.JSONObject

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

    // Gemini는 만 18세 확인(FL-09) 뒤에만 고른다: 확인 전 요청은 무시한다.
    suspend fun setEngine(engine: Engine) = edit {
        if (engine == Engine.GEMINI && it[Keys.AGE_CONFIRMED] != true) return@edit
        it[Keys.ENGINE] = engine.name
    }

    // 확인을 거두면 AI 엔진도 ML Kit으로 되돌린다.
    suspend fun setAgeConfirmed(confirmed: Boolean) = edit {
        it[Keys.AGE_CONFIRMED] = confirmed
        if (!confirmed) it[Keys.ENGINE] = Engine.ML_KIT.name
    }

    suspend fun setAiTone(tone: AiTone) = edit { it[Keys.AI_TONE] = tone.name }

    suspend fun setGlossary(entries: List<GlossaryEntry>) =
        edit { it[Keys.GLOSSARY] = encodeGlossary(Settings.normalizeGlossary(entries)) }

    // 드래그 영역에서는 자동 번역을 쓸 수 없다: 드래그로 바뀌면 자동 번역도 함께 끈다 (#71).
    suspend fun setCaptureRange(range: CaptureRange) = edit {
        it[Keys.CAPTURE_RANGE] = range.name
        if (range == CaptureRange.DRAG_REGION) it[Keys.AUTO_TRANSLATE] = false
    }

    suspend fun setResultDisplay(display: ResultDisplay) = edit { it[Keys.RESULT_DISPLAY] = display.name }

    suspend fun setFixedRegion(region: NormalizedRegion) = edit { it[Keys.FIXED_REGION] = region.encode() }

    suspend fun clearFixedRegion() = edit { it.remove(Keys.FIXED_REGION) }

    suspend fun setButtonSizeDp(dp: Int) =
        edit { it[Keys.BUTTON_SIZE_DP] = dp.coerceIn(Settings.BUTTON_SIZE_RANGE_DP) }

    suspend fun setButtonOpacityPercent(percent: Int) =
        edit { it[Keys.BUTTON_OPACITY_PERCENT] = percent.coerceIn(Settings.BUTTON_OPACITY_RANGE_PERCENT) }

    suspend fun setQuickLanguages(codes: List<String>) = edit { it[Keys.QUICK_LANGUAGES] = codes.joinToString(",") }

    suspend fun setAutoTranslate(enabled: Boolean) = edit {
        val range = enumOrDefault(it[Keys.CAPTURE_RANGE], Settings().captureRange)
        it[Keys.AUTO_TRANSLATE] = enabled && range != CaptureRange.DRAG_REGION
    }

    suspend fun setAutoShowDelayMs(ms: Long) =
        edit { it[Keys.AUTO_SHOW_DELAY] = ms.coerceIn(Settings.AUTO_SHOW_DELAY_RANGE_MS) }

    suspend fun setHideAfterInteractionMs(ms: Long) =
        edit { it[Keys.HIDE_AFTER_INTERACTION] = Settings.normalizeHideAfterInteraction(ms) }

    suspend fun setSourceLanguage(code: String) = edit { it[Keys.SOURCE_LANGUAGE] = code }

    suspend fun setWifiOnlyModelDownload(enabled: Boolean) = edit { it[Keys.WIFI_ONLY_MODEL_DOWNLOAD] = enabled }

    suspend fun setOnboardingCompleted(completed: Boolean) =
        edit { it[Keys.ONBOARDING_COMPLETED] = completed }

    private suspend fun edit(block: (androidx.datastore.preferences.core.MutablePreferences) -> Unit) {
        dataStore.edit { block(it) }
    }

    private fun Preferences.toSettings(): Settings {
        val defaults = Settings()
        val ageConfirmed = this[Keys.AGE_CONFIRMED] ?: defaults.ageConfirmed
        val range = enumOrDefault(this[Keys.CAPTURE_RANGE], defaults.captureRange)
        return Settings(
            targetLanguage = this[Keys.TARGET_LANGUAGE] ?: defaults.targetLanguage,
            // 연령 확인 전에 저장된 Gemini(이전 버전 등)는 ML Kit으로 본다.
            engine = enumOrDefault(this[Keys.ENGINE], defaults.engine).takeIf { ageConfirmed || it != Engine.GEMINI }
                ?: Engine.ML_KIT,
            captureRange = range,
            resultDisplay = enumOrDefault(this[Keys.RESULT_DISPLAY], defaults.resultDisplay),
            onboardingCompleted = this[Keys.ONBOARDING_COMPLETED] ?: defaults.onboardingCompleted,
            fixedRegion = NormalizedRegion.decode(this[Keys.FIXED_REGION]),
            quickLanguages = this[Keys.QUICK_LANGUAGES]
                ?.split(",")?.map { it.trim() }?.filter { it.isNotEmpty() }
                ?.takeIf { it.isNotEmpty() }
                ?: defaults.quickLanguages,
            autoTranslate = (this[Keys.AUTO_TRANSLATE] ?: defaults.autoTranslate) && range != CaptureRange.DRAG_REGION,
            autoShowDelayMs = (this[Keys.AUTO_SHOW_DELAY] ?: defaults.autoShowDelayMs)
                .coerceIn(Settings.AUTO_SHOW_DELAY_RANGE_MS),
            hideAfterInteractionMs = Settings.normalizeHideAfterInteraction(
                this[Keys.HIDE_AFTER_INTERACTION] ?: defaults.hideAfterInteractionMs,
            ),
            sourceLanguage = this[Keys.SOURCE_LANGUAGE]?.takeIf { it.isNotBlank() } ?: defaults.sourceLanguage,
            wifiOnlyModelDownload = this[Keys.WIFI_ONLY_MODEL_DOWNLOAD] ?: defaults.wifiOnlyModelDownload,
            buttonSizeDp = (this[Keys.BUTTON_SIZE_DP] ?: defaults.buttonSizeDp)
                .coerceIn(Settings.BUTTON_SIZE_RANGE_DP),
            buttonOpacityPercent = (this[Keys.BUTTON_OPACITY_PERCENT] ?: defaults.buttonOpacityPercent)
                .coerceIn(Settings.BUTTON_OPACITY_RANGE_PERCENT),
            ageConfirmed = ageConfirmed,
            aiTone = enumOrDefault(this[Keys.AI_TONE], defaults.aiTone),
            glossary = decodeGlossary(this[Keys.GLOSSARY]),
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
        val AUTO_SHOW_DELAY = longPreferencesKey("auto_show_delay_ms")

        // 이름은 자동 번역 전용이던 때(#29) 그대로 둔다: 저장된 값을 이어 받는다.
        val HIDE_AFTER_INTERACTION = longPreferencesKey("auto_hide_ms")
        val SOURCE_LANGUAGE = stringPreferencesKey("source_language")
        val WIFI_ONLY_MODEL_DOWNLOAD = booleanPreferencesKey("wifi_only_model_download")
        val BUTTON_SIZE_DP = intPreferencesKey("button_size_dp")
        val BUTTON_OPACITY_PERCENT = intPreferencesKey("button_opacity_percent")
        val AGE_CONFIRMED = booleanPreferencesKey("age_confirmed")
        val AI_TONE = stringPreferencesKey("ai_tone")
        val GLOSSARY = stringPreferencesKey("glossary")
    }
}

/** 용어집 저장 형식: [{"s":"원문","t":"번역어"}, ...] JSON. */
internal fun encodeGlossary(entries: List<GlossaryEntry>): String =
    JSONArray().apply {
        entries.forEach { put(JSONObject().put("s", it.source).put("t", it.target)) }
    }.toString()

/** 깨졌거나 없으면 빈 목록. */
internal fun decodeGlossary(json: String?): List<GlossaryEntry> {
    if (json.isNullOrBlank()) return emptyList()
    return runCatching {
        val array = JSONArray(json)
        Settings.normalizeGlossary(
            (0 until array.length()).mapNotNull { i ->
                array.optJSONObject(i)?.let { GlossaryEntry(it.optString("s"), it.optString("t")) }
            },
        )
    }.getOrDefault(emptyList())
}
