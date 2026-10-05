package com.example.translation_poc_app.overlay

import com.example.translation_poc_app.data.settings.Engine
import com.example.translation_poc_app.data.settings.Settings

/** 빠른 설정에서 목록에서 고르는 값들. 앱 설정 화면의 선택지와 같다. */
internal object QuickSettingChoices {
    private val HIDE_MS = listOf(0L, 500L, 1_000L, 2_000L, Settings.HIDE_NEVER)
    private val SHOW_DELAY_MS = listOf(0L, 1_000L, 2_000L, 3_000L)

    /** 닫기 시간 선택지. 자동 번역이 켜져 있으면 직접 닫기는 뺀다 (D-047). */
    fun hide(autoOn: Boolean): List<Long> = if (autoOn) HIDE_MS.dropLast(1) else HIDE_MS

    fun showDelay(): List<Long> = SHOW_DELAY_MS

    /** 엔진 선택지. Firebase AI는 아직 없어 뺀다 (앱 설정 화면과 같다). */
    fun engines(): List<Engine> = listOf(Engine.ML_KIT, Engine.GEMINI)
}
