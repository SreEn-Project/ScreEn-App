package com.example.translation_poc_app.overlay

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class OverlayFontPlanTest {

    @Test
    fun `비슷한 줄 높이는 같은 크기로 모인다`() {
        val sizes = OverlayFontPlan.targetSizes(listOf(40f, 42f, 38f, 41f), 10f, 100f)
        assertTrue(sizes.max() - sizes.min() <= sizes.max() * 0.2f)
    }

    @Test
    fun `기준에서 크게 벗어난 줄 높이는 허용 범위로 자른다`() {
        val sizes = OverlayFontPlan.targetSizes(listOf(40f, 40f, 40f, 200f, 5f), 1f, 1000f)
        val base = 40f * OverlayFontPlan.FONT_PER_LINE_HEIGHT
        assertEquals(base * OverlayFontPlan.MAX_RATIO, sizes[3], 0.01f)
        assertEquals(base * OverlayFontPlan.MIN_RATIO, sizes[4], 0.01f)
    }

    @Test
    fun `줄 높이를 모르는 항목은 기준을 따르고 절대 상하한을 지킨다`() {
        val sizes = OverlayFontPlan.targetSizes(listOf(50f, null, 50f), 10f, 30f)
        assertEquals(30f, sizes[0], 0.01f)
        assertEquals(sizes[0], sizes[1], 0.01f)
    }

    @Test
    fun `아무 것도 모르면 최소 크기`() {
        assertEquals(listOf(12f), OverlayFontPlan.targetSizes(listOf(null), 12f, 40f))
    }
}
