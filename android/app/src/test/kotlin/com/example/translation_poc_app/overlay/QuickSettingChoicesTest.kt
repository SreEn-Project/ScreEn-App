package com.example.translation_poc_app.overlay

import com.example.translation_poc_app.data.settings.Settings
import org.junit.Assert.assertEquals
import org.junit.Test

class QuickSettingChoicesTest {

    @Test
    fun `닫기 시간은 탭할 때마다 돌고 마지막은 직접 닫기`() {
        val choices = QuickSettingChoices.hide(autoOn = false)
        assertEquals(500L, QuickSettingChoices.next(choices, 0L))
        assertEquals(Settings.HIDE_NEVER, QuickSettingChoices.next(choices, 2_000L))
        assertEquals(0L, QuickSettingChoices.next(choices, Settings.HIDE_NEVER))
    }

    @Test
    fun `자동 번역이 켜져 있으면 직접 닫기로 가지 않는다`() {
        val choices = QuickSettingChoices.hide(autoOn = true)
        assertEquals(0L, QuickSettingChoices.next(choices, 2_000L))
        // 저장값이 직접 닫기여도 처음(바로)에서 다음으로 넘어간다.
        assertEquals(0L, QuickSettingChoices.next(choices, Settings.HIDE_NEVER))
    }

    @Test
    fun `대기 시간은 가장 가까운 값에서 다음으로`() {
        val choices = QuickSettingChoices.showDelay()
        assertEquals(1_000L, QuickSettingChoices.next(choices, 0L))
        assertEquals(0L, QuickSettingChoices.next(choices, 3_000L))
        assertEquals(2_000L, QuickSettingChoices.next(choices, 900L))
    }
}
