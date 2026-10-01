package com.example.translation_poc_app.autotranslate

import com.example.translation_poc_app.autotranslate.AutoTranslateTracker.Decision
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AutoTranslateTrackerTest {

    private val size = FrameSignature.COLS * FrameSignature.ROWS

    private fun screen(brightness: Int = 100) = IntArray(size) { brightness }

    /** 앞쪽 [fraction] 만큼의 칸을 밝게 바꾼 화면. */
    private fun changed(fraction: Float, base: Int = 100) =
        IntArray(size) { if (it < size * fraction) base + 100 else base }

    private val config = AutoTranslateConfig(checkIntervalMs = 500, minTranslateGapMs = 3_000)

    private fun tracker() = AutoTranslateTracker { config }.also { it.onTranslated(0) }

    @Test
    fun `지문 비교 - 같은 화면은 0, 크기가 다르면 전부 바뀐 것`() {
        assertEquals(0f, FrameSignature.changedRatio(screen(), screen()), 0f)
        assertEquals(1f, FrameSignature.changedRatio(screen(), IntArray(10)), 0f)
        assertFalse(FrameSignature.isChanged(screen(), changed(0.001f)))
        assertTrue(FrameSignature.isChanged(screen(), changed(0.02f)))
    }

    @Test
    fun `작은 밝기 차이는 변화로 세지 않는다`() {
        assertFalse(FrameSignature.isChanged(screen(100), screen(100 + FrameSignature.LUMA_DELTA)))
        assertTrue(FrameSignature.isChanged(screen(100), screen(100 + FrameSignature.LUMA_DELTA + 1)))
    }

    @Test
    fun `번역 직후 첫 지문은 기준이 될 뿐 번역하지 않는다`() {
        val t = tracker()
        assertEquals(Decision.WAIT, t.onSample(screen(), 5_000))
    }

    @Test
    fun `화면이 그대로면 번역하지 않는다`() {
        val t = tracker()
        t.onSample(screen(), 5_000)
        repeat(20) { assertEquals(Decision.WAIT, t.onSample(screen(), 7_000L + it * 2_000)) }
    }

    @Test
    fun `바뀐 화면이 멈추면(연속된 두 지문이 같음) 바로 번역한다`() {
        val t = tracker()
        t.onSample(screen(), 5_000)
        val next = changed(0.3f)
        assertEquals(Decision.WAIT, t.onSample(next, 7_000)) // 막 바뀐 것을 봄: 아직 움직이는 중
        assertEquals(Decision.TRANSLATE, t.onSample(next, 7_500)) // 멈춤 → 바로
    }

    @Test
    fun `계속 움직이는 동안(스크롤)은 번역하지 않고 조작이 끝난 시각을 갱신한다`() {
        val t = tracker()
        t.onSample(screen(), 5_000)
        assertEquals(Decision.WAIT, t.onSample(changed(0.3f), 7_000))
        assertEquals(Decision.WAIT, t.onSample(changed(0.5f), 8_500)) // 또 달라짐
        assertEquals(8_500, t.interactionEndedAt)
        assertEquals(Decision.TRANSLATE, t.onSample(changed(0.5f), 9_000))
        assertEquals(8_500, t.interactionEndedAt) // 멈춘 뒤에는 그대로
    }

    @Test
    fun `바뀌었다가 기준으로 돌아오면 번역하지 않는다`() {
        val t = tracker()
        t.onSample(screen(), 5_000)
        t.onSample(changed(0.3f), 7_000)
        assertEquals(Decision.WAIT, t.onSample(screen(), 7_500))
        assertEquals(Decision.WAIT, t.onSample(screen(), 9_000))
    }

    @Test
    fun `마지막 번역으로부터 최소 간격 전에는 번역하지 않는다`() {
        val t = AutoTranslateTracker { config }.also { it.onTranslated(10_000) }
        t.onSample(screen(), 10_500)
        t.onSample(changed(0.3f), 11_000)
        assertEquals(Decision.WAIT, t.onSample(changed(0.3f), 12_000)) // 멈췄지만 2000 < 3000
        assertEquals(Decision.TRANSLATE, t.onSample(changed(0.3f), 13_000))
    }

    @Test
    fun `번역하면 기준을 새로 잡는다`() {
        val t = tracker()
        t.onSample(screen(), 5_000)
        t.onSample(changed(0.3f), 7_000)
        assertEquals(Decision.TRANSLATE, t.onSample(changed(0.3f), 8_000))
        t.onTranslated(8_000)
        // 새 기준: 바뀐 화면. 같은 화면이 이어지면 번역하지 않는다.
        assertEquals(Decision.WAIT, t.onSample(changed(0.3f), 9_000))
        assertEquals(Decision.WAIT, t.onSample(changed(0.3f), 12_000))
    }

    @Test
    fun `변화가 없을수록 확인 간격이 늘어나되 너무 길어지지 않는다`() {
        val t = tracker()
        t.onSample(screen(), 5_000)
        assertEquals(500, t.nextDelayMs())
        repeat(AutoTranslateTracker.IDLE_SHORT) { t.onSample(screen(), 6_000L + it) }
        assertEquals(1_000, t.nextDelayMs())
        repeat(AutoTranslateTracker.IDLE_LONG) { t.onSample(screen(), 60_000L + it) }
        assertEquals(AutoTranslateTracker.MAX_IDLE_DELAY_MS, t.nextDelayMs())
    }

    @Test
    fun `바뀜을 기다리는 중에는 설정 간격 그대로`() {
        val t = tracker()
        repeat(80) { t.onSample(screen(), 5_000L + it) }
        t.onSample(changed(0.3f), 90_000)
        assertEquals(500, t.nextDelayMs())
    }

    @Test
    fun `간격 설정이 크면 늘어난 간격도 그보다 작아지지 않는다`() {
        val slow = AutoTranslateConfig(checkIntervalMs = 5_000)
        val t = AutoTranslateTracker { slow }.also { it.onTranslated(0) }
        repeat(80) { t.onSample(screen(), 1_000L + it) }
        assertEquals(5_000, t.nextDelayMs())
    }

    @Test
    fun `새 번역을 올릴 가장 이른 시각은 조작이 끝난 시각 더하기 표시 시점`() {
        var delay = 0L
        val t = AutoTranslateTracker { AutoTranslateConfig(showDelayMs = delay, minTranslateGapMs = 0) }.also { it.onTranslated(0) }
        t.onSample(screen(), 1_000)
        t.onSample(changed(0.3f), 2_000)
        t.onSample(changed(0.5f), 2_500) // 마지막으로 움직인 때
        assertEquals(Decision.TRANSLATE, t.onSample(changed(0.5f), 3_000))
        assertEquals(2_500, t.showNotBefore()) // 바로: 번역이 되는 대로
        delay = 2_000
        assertEquals(4_500, t.showNotBefore())
    }

    @Test
    fun `이전 결과 숨김은 바뀐 걸 안 뒤 숨김 시간이 지나면 true, 기준으로 돌아오면 false`() {
        val c = AutoTranslateConfig(hideMs = 1_000)
        val t = AutoTranslateTracker { c }.also { it.onTranslated(0) }
        t.onSample(screen(), 1_000)
        assertFalse(t.isStale(1_000))
        t.onSample(changed(0.3f), 2_000)
        assertFalse(t.isStale(2_500))
        assertTrue(t.isStale(3_000))
        t.onSample(screen(), 3_500)
        assertFalse(t.isStale(4_000))
    }

    @Test
    fun `숨김 시간 0은 바뀐 걸 안 즉시 숨기고, 음수는 숨기지 않는다`() {
        val now = AutoTranslateTracker { AutoTranslateConfig(hideMs = 0) }.also { it.onTranslated(0) }
        now.onSample(screen(), 1_000)
        now.onSample(changed(0.3f), 2_000)
        assertTrue(now.isStale(2_000))

        val never = AutoTranslateTracker { AutoTranslateConfig(hideMs = -1) }.also { it.onTranslated(0) }
        never.onSample(screen(), 1_000)
        never.onSample(changed(0.3f), 2_000)
        assertFalse(never.isStale(60_000))
    }

    @Test
    fun `번역을 취소하면 조작이 끝난 시각을 그 시점으로 다시 센다`() {
        val c = AutoTranslateConfig(showDelayMs = 1_000, minTranslateGapMs = 0)
        val t = AutoTranslateTracker { c }.also { it.onTranslated(0) }
        t.onSample(screen(), 1_000)
        t.onSample(changed(0.3f), 2_000)
        assertEquals(Decision.TRANSLATE, t.onSample(changed(0.3f), 2_500)) // 안정 → 번역 시작
        assertEquals(3_000, t.showNotBefore()) // 조작이 끝난 시각 2_000 + 1_000
        t.observe(changed(0.6f)) // 번역 중 또 바뀜
        t.onCanceled(3_500)
        assertEquals(4_500, t.showNotBefore())
        // 번역 중 본 지문이 직전 지문이라 멈춘 걸 바로 알아본다.
        assertEquals(Decision.TRANSLATE, t.onSample(changed(0.6f), 4_000))
    }
}
