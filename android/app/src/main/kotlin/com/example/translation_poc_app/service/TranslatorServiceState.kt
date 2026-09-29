package com.example.translation_poc_app.service

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

enum class RunState { STOPPED, STARTING, RUNNING }

/**
 * 포그라운드 서비스 상태 (NA-02에서 갱신).
 * 서비스와 브리지가 같은 프로세스에서 이 값을 공유한다. Flutter 엔진이 없어도 동작한다.
 */
object TranslatorServiceState {
    private val _state = MutableStateFlow(RunState.STOPPED)
    val state: StateFlow<RunState> = _state.asStateFlow()

    fun update(state: RunState) {
        _state.value = state
    }
}
