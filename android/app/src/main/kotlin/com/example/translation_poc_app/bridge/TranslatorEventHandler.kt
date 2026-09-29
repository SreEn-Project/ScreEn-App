package com.example.translation_poc_app.bridge

import com.example.translation_poc_app.data.settings.SettingsRepository
import com.example.translation_poc_app.service.TranslatorServiceState
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach

/**
 * 네이티브 → Flutter 이벤트 (NA-01).
 * Flutter가 구독하는 동안에만 상태 Flow를 수집한다. StateFlow · DataStore Flow라 구독 직후 현재 값이 한 번 간다.
 */
class TranslatorEventHandler(private val settingsRepository: SettingsRepository) : EventsStreamHandler() {
    private var scope: CoroutineScope? = null

    override fun onListen(p0: Any?, sink: PigeonEventSink<TranslatorEvent>) {
        scope?.cancel()
        scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate).also { scope ->
            TranslatorServiceState.state
                .onEach { sink.success(ServiceStateChanged(it.toPigeon())) }
                .launchIn(scope)
            settingsRepository.settings
                .onEach { sink.success(SettingsChanged(it.toPigeon())) }
                .launchIn(scope)
        }
    }

    override fun onCancel(p0: Any?) {
        dispose()
    }

    fun dispose() {
        scope?.cancel()
        scope = null
    }
}
