package com.example.translation_poc_app.bridge

import android.content.Context
import com.example.translation_poc_app.data.settings.SettingsRepository
import com.example.translation_poc_app.service.CaptureConsentActivity
import com.example.translation_poc_app.service.RunState
import com.example.translation_poc_app.service.TranslatorService
import com.example.translation_poc_app.service.TranslatorServiceState

/** Flutter → 네이티브 설정 호출 (NA-01, NA-16). */
class SettingsHostApiImpl(private val repository: SettingsRepository) : SettingsHostApi {
    override suspend fun getSettings(): AppSettings = repository.current().toPigeon()

    override suspend fun setTargetLanguage(languageCode: String) =
        repository.setTargetLanguage(languageCode)

    override suspend fun setEngine(engine: EngineType) = repository.setEngine(engine.toNative())

    override suspend fun setCaptureMode(mode: CaptureMode) = repository.setCaptureRange(mode.toNative())

    override suspend fun setDisplayMode(mode: DisplayMode) = repository.setResultDisplay(mode.toNative())

    override suspend fun setQuickLanguages(languageCodes: List<String>) =
        repository.setQuickLanguages(languageCodes)

    override suspend fun setAutoTranslate(enabled: Boolean) = repository.setAutoTranslate(enabled)

    override suspend fun setAutoShowDelayMs(ms: Long) = repository.setAutoShowDelayMs(ms)

    override suspend fun setHideAfterInteractionMs(ms: Long) = repository.setHideAfterInteractionMs(ms)

    override suspend fun setOnboardingCompleted(completed: Boolean) =
        repository.setOnboardingCompleted(completed)
}

/** 서비스 상태 조회 · 시작 · 중지 (NA-01, NA-02). */
class ServiceHostApiImpl(private val context: Context) : ServiceHostApi {
    override fun getServiceState(): ServiceState = TranslatorServiceState.state.value.toPigeon()

    override fun startService() {
        if (TranslatorServiceState.state.value == RunState.RUNNING) return
        // STARTING이어도 다시 띄운다: 동의 창을 두고 다른 앱으로 간 경우 되찾는 길.
        CaptureConsentActivity.launch(context)
    }

    override fun stopService() {
        TranslatorService.stop(context)
    }
}
