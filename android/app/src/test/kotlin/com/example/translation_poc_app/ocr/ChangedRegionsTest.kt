package com.example.translation_poc_app.ocr

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class ChangedRegionsTest {
    private val w = 640
    private val h = 1280
    private val cols = ChangedRegions.COLS
    private val rows = ChangedRegions.ROWS

    private fun grid(value: Int = 100) = IntArray(cols * rows) { value }

    /** [from, to) 행 · 열 범위를 밝게 바꾼 격자. */
    private fun changed(r0: Int, r1: Int, c0: Int, c1: Int): IntArray = grid().also {
        for (r in r0 until r1) for (c in c0 until c1) it[r * cols + c] = 200
    }

    private fun plan(current: IntArray, blocks: List<Box?>) = ChangedRegions.plan(grid(), current, w, h, blocks)

    @Test
    fun `바뀐 칸이 없으면 이전 결과를 쓴다`() {
        assertEquals(ChangedRegions.Plan.Reuse, plan(grid(), listOf(Box(0, 0, 100, 20))))
    }

    @Test
    fun `잡음 정도의 밝기 차이는 바뀐 것으로 안 센다`() {
        assertEquals(ChangedRegions.Plan.Reuse, plan(grid(100 + ChangedRegions.LUMA_DELTA), emptyList()))
    }

    @Test
    fun `크기가 안 맞으면 통째로 읽는다`() {
        assertEquals(ChangedRegions.Plan.Full, ChangedRegions.plan(IntArray(10), grid(), w, h, emptyList()))
    }

    @Test
    fun `대부분 바뀌면 통째로 읽는다`() {
        assertEquals(ChangedRegions.Plan.Full, plan(changed(0, rows, 0, cols / 2), emptyList()))
    }

    @Test
    fun `이전 블록 자리를 모르면 통째로 읽는다`() {
        assertEquals(ChangedRegions.Plan.Full, plan(changed(10, 12, 10, 12), listOf(null)))
    }

    @Test
    fun `바뀐 곳만 다시 읽고 먼 블록은 재사용한다`() {
        val far = Box(0, 1100, 300, 1130)
        val p = plan(changed(20, 24, 20, 30), listOf(far)) as ChangedRegions.Plan.Partial
        assertEquals(1, p.regions.size)
        assertEquals(listOf(0), p.keep)
        // 바뀐 칸을 덮는다 (행 20 → y 200, 열 20 → x 200).
        val r = p.regions[0]
        assertTrue(r.left <= 200 && r.top <= 200 && r.right >= 300 && r.bottom >= 240)
    }

    @Test
    fun `영역에 걸친 블록은 통째로 다시 읽는다`() {
        // 바뀐 칸(y 200~240) 근처에서 y 230~330까지 뻗은 블록 하나.
        val block = Box(180, 230, 420, 330)
        val p = plan(changed(20, 24, 20, 30), listOf(block)) as ChangedRegions.Plan.Partial
        assertTrue(p.keep.isEmpty())
        val r = p.regions.single()
        assertTrue(r.left <= block.left && r.top <= block.top && r.right >= block.right && r.bottom >= block.bottom)
    }

    @Test
    fun `멀리 떨어진 변화는 따로 읽는다`() {
        val current = changed(10, 12, 5, 8).also { for (r in 100 until 102) for (c in 40 until 44) it[r * cols + c] = 200 }
        val p = plan(current, emptyList()) as ChangedRegions.Plan.Partial
        assertEquals(2, p.regions.size)
    }

    @Test
    fun `영역은 최소 크기를 지키고 이미지 안에 든다`() {
        val p = plan(changed(0, 1, 0, 1), emptyList()) as ChangedRegions.Plan.Partial
        val r = p.regions.single()
        assertTrue(r.width >= ChangedRegions.MIN_SIDE_PX && r.height >= ChangedRegions.MIN_SIDE_PX)
        assertTrue(r.left >= 0 && r.top >= 0 && r.right <= w && r.bottom <= h)
    }

    @Test
    fun `영역이 너무 많으면 통째로 읽는다`() {
        val current = grid()
        // 서로 멀리 떨어진 일곱 곳.
        for (i in 0 until 7) current[(i * 18 + 2) * cols + (if (i % 2 == 0) 3 else 55)] = 200
        assertEquals(ChangedRegions.Plan.Full, plan(current, emptyList()))
    }
}
