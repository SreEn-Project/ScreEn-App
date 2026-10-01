package com.example.translation_poc_app.autotranslate

import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.delay
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.currentTime
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class AutoTranslateWatcherTest {

    private val size = FrameSignature.COLS * FrameSignature.ROWS
    private val still = IntArray(size) { 100 }
    private val scrolled = IntArray(size) { if (it % 2 == 0) 200 else 100 }
    private val config = AutoTranslateConfig(checkIntervalMs = 1_000, minTranslateGapMs = 3_000)

    private fun TestScope.watcher(
        samples: () -> IntArray?,
        translate: suspend (Long) -> Boolean,
    ) = AutoTranslateWatcher(this, { samples() }, { config }, translate, clock = { currentTime })

    @Test
    fun `화면이 안 바뀌면 번역하지 않는다`() = runTest {
        var translated = 0
        val w = watcher({ still }) { translated++; true }
        w.arm()
        advanceTimeBy(60_000)
        assertEquals(0, translated)
        w.stop()
    }

    @Test
    fun `화면이 바뀌고 안정되면 한 번 번역하고 기준을 새로 잡는다`() = runTest {
        var screen = still
        var translated = 0
        val w = watcher({ screen }) { translated++; true }
        w.arm()
        advanceTimeBy(5_000)
        screen = scrolled
        advanceTimeBy(10_000)
        assertEquals(1, translated)
        w.stop()
    }

    @Test
    fun `번역을 못 하는 중이면 다음 확인에서 다시 시도한다`() = runTest {
        var screen = still
        var attempts = 0
        val w = watcher({ screen }) { attempts++; attempts >= 3 }
        w.arm()
        advanceTimeBy(5_000)
        screen = scrolled
        advanceTimeBy(20_000)
        assertTrue(attempts >= 3)
        w.stop()
    }

    @Test
    fun `stop 하면 더 이상 확인하지 않는다`() = runTest {
        var sampled = 0
        val w = watcher({ sampled++; still }) { true }
        w.arm()
        advanceTimeBy(5_000)
        assertTrue(w.isWatching)
        w.stop()
        val after = sampled
        advanceTimeBy(30_000)
        assertEquals(after, sampled)
        assertFalse(w.isWatching)
    }

    @Test
    fun `프레임이 없으면(null) 건너뛴다`() = runTest {
        var translated = 0
        val w = watcher({ null }) { translated++; true }
        w.arm()
        advanceTimeBy(20_000)
        assertEquals(0, translated)
        w.stop()
    }

    @Test
    fun `번역 중 캡처한 뒤 화면이 또 바뀌면 그 번역을 취소하고 조작이 끝나면 다시 번역한다`() = runTest {
        var screen = still
        var started = 0
        var finished = 0
        var cancelled = 0
        lateinit var w: AutoTranslateWatcher
        val fast = AutoTranslateConfig(checkIntervalMs = 500, minTranslateGapMs = 0)
        w = AutoTranslateWatcher(this, { screen }, { fast }, { _ ->
            started++
            try {
                w.markCaptured()
                delay(10_000) // 오래 걸리는 번역
                finished++
                true
            } catch (e: CancellationException) {
                cancelled++
                throw e
            }
        }, clock = { currentTime })
        w.arm()
        advanceTimeBy(5_000)
        screen = scrolled // 조작 → 바로 번역 시작
        advanceTimeBy(2_000)
        assertEquals(1, started)
        screen = IntArray(size) { if (it % 3 == 0) 220 else 90 } // 번역 중 또 조작
        advanceTimeBy(1_500)
        assertEquals(1, cancelled)
        assertEquals(0, finished)
        advanceTimeBy(1_500) // 조작이 끝났다 → 바로 다시 번역
        assertEquals(2, started)
        w.stop()
    }

    @Test
    fun `다시 번역을 끄면 숨김만 한다 - 화면이 바뀌면 숨김 시간 뒤 낡은 결과를 숨기고 돌아오면 다시 보인다`() = runTest {
        var screen = still
        val events = mutableListOf<Boolean>()
        val cfg = AutoTranslateConfig(checkIntervalMs = 500, hideMs = 1_000, retranslate = false)
        val w = AutoTranslateWatcher(this, { screen }, { cfg }, { true }, { events += it }, { currentTime })
        w.arm()
        advanceTimeBy(5_000)
        assertTrue(events.isEmpty())
        screen = scrolled
        advanceTimeBy(3_000)
        assertEquals(listOf(true), events)
        screen = still // 번역한 화면으로 돌아옴 → 다시 보임
        advanceTimeBy(3_000)
        assertEquals(listOf(true, false), events)
        w.stop()
    }

    @Test
    fun `다시 번역을 끄면 화면이 바뀌어도 번역하지 않는다`() = runTest {
        var screen = still
        var translated = 0
        val off = AutoTranslateConfig(checkIntervalMs = 500, hideMs = 1_000, retranslate = false)
        val w = AutoTranslateWatcher(this, { screen }, { off }, { translated++; true }, clock = { currentTime })
        w.arm()
        advanceTimeBy(5_000)
        screen = scrolled
        advanceTimeBy(10_000)
        assertEquals(0, translated)
        w.stop()
    }

    @Test
    fun `번역에는 조작이 끝난 시각에 표시 시점을 더한 시각이 넘어간다`() = runTest {
        var screen = still
        var showNotBefore = -1L
        val cfg = AutoTranslateConfig(checkIntervalMs = 500, showDelayMs = 2_000, minTranslateGapMs = 0)
        val w = AutoTranslateWatcher(this, { screen }, { cfg }, { showNotBefore = it; true }, clock = { currentTime })
        w.arm()
        advanceTimeBy(5_000)
        screen = scrolled
        val changedAt = currentTime
        advanceTimeBy(3_000)
        assertTrue(showNotBefore >= changedAt + 2_000)
        assertTrue(showNotBefore <= changedAt + 2_000 + 1_000)
        w.stop()
    }
}
