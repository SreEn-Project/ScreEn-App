package com.example.translation_poc_app.overlay

import com.example.translation_poc_app.data.settings.Engine
import com.example.translation_poc_app.data.settings.Settings
import org.junit.Assert.assertEquals
import org.junit.Test

class QuickSettingChoicesTest {

    @Test
    fun `닫기 시간 선택지는 마지막이 직접 닫기`() {
        assertEquals(listOf(0L, 500L, 1_000L, 2_000L, Settings.HIDE_NEVER), QuickSettingChoices.hide(autoOn = false))
    }

    @Test
    fun `자동 번역이 켜져 있으면 직접 닫기를 뺀다`() {
        assertEquals(listOf(0L, 500L, 1_000L, 2_000L), QuickSettingChoices.hide(autoOn = true))
    }

    @Test
    fun `대기 시간 선택지`() {
        assertEquals(listOf(0L, 1_000L, 2_000L, 3_000L), QuickSettingChoices.showDelay())
    }

    @Test
    fun `엔진 선택지는 ML Kit, Gemini, Groq`() {
        assertEquals(listOf(Engine.ML_KIT, Engine.GEMINI, Engine.GROQ, Engine.GEMMA), QuickSettingChoices.engines())
    }
}
