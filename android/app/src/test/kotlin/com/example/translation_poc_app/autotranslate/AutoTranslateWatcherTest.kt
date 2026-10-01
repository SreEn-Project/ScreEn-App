package com.example.translation_poc_app.autotranslate

import kotlinx.coroutines.ExperimentalCoroutinesApi
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
    private val config = AutoTranslateConfig(checkIntervalMs = 1_000, settleMs = 1_000, minTranslateGapMs = 3_000)

    private fun TestScope.watcher(
        samples: () -> IntArray?,
        translate: suspend () -> Boolean,
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
}
