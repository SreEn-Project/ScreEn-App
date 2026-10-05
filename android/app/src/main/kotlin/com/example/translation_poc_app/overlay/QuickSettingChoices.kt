package com.example.translation_poc_app.overlay

import com.example.translation_poc_app.data.settings.Settings

/** 빠른 설정에서 탭할 때마다 돌려 가며 고르는 값들. 앱 설정 화면의 선택지와 같다. */
internal object QuickSettingChoices {
    private val HIDE_MS = listOf(0L, 500L, 1_000L, 2_000L, Settings.HIDE_NEVER)
    private val SHOW_DELAY_MS = listOf(0L, 1_000L, 2_000L, 3_000L)

    /** 닫기 시간 선택지. 자동 번역이 켜져 있으면 직접 닫기는 뺀다 (D-047). */
    fun hide(autoOn: Boolean): List<Long> = if (autoOn) HIDE_MS.dropLast(1) else HIDE_MS

    fun showDelay(): List<Long> = SHOW_DELAY_MS

    /** [current]에 가장 가까운 값의 다음 선택지 (끝이면 처음으로). 직접 닫기(음수)는 정확히 일치할 때만 그 자리로 본다. */
    fun next(choices: List<Long>, current: Long): Long {
        val index = if (current < 0) choices.indexOf(Settings.HIDE_NEVER) else choices.filter { it >= 0 }.let { nonNeg ->
            nonNeg.indices.minByOrNull { kotlin.math.abs(nonNeg[it] - current) } ?: -1
        }
        // 직접 닫기가 선택지에 없는데(자동 번역) 저장값이 직접 닫기면 기본 시간(첫 값)에서 시작한다.
        return choices[(index + 1).mod(choices.size)]
    }
}
