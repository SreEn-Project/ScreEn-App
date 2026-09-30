package com.example.translation_poc_app.overlay

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class OverlayGeometryTest {

    // 1080×2340 세로 화면, 상태 표시줄 100, 내비게이션 막대 60
    private val area = ScreenArea(width = 1080, height = 2340, top = 100, bottom = 60)
    private val size = 180

    @Test
    fun `처음에는 오른쪽 가장자리 35퍼센트 높이`() {
        val p = OverlayGeometry.initial(area, size)
        assertEquals(ButtonPlacement(900, 819, Edge.RIGHT), p)
    }

    @Test
    fun `가까운 가장자리에 붙는다`() {
        assertEquals(ButtonPlacement(0, 1000, Edge.LEFT), OverlayGeometry.snap(300, 1000, size, area))
        assertEquals(ButtonPlacement(900, 1000, Edge.RIGHT), OverlayGeometry.snap(500, 1000, size, area))
    }

    @Test
    fun `시스템 막대 안쪽으로 맞춘다`() {
        assertEquals(100, OverlayGeometry.snap(0, -50, size, area).y)
        assertEquals(2340 - 60 - 180, OverlayGeometry.snap(0, 3000, size, area).y)
        // 가로 화면에서 옆 내비게이션 막대
        val landscape = ScreenArea(width = 2340, height = 1080, top = 60, right = 120)
        assertEquals(2340 - 120 - 180, OverlayGeometry.snap(2000, 500, size, landscape).x)
    }

    @Test
    fun `끄는 동안 화면 밖으로 나가지 않는다`() {
        assertEquals(0 to 100, OverlayGeometry.clamp(-500, -500, size, area))
        assertEquals(900 to 2100, OverlayGeometry.clamp(5000, 5000, size, area))
    }

    @Test
    fun `회전하면 같은 가장자리 같은 높이 비율`() {
        val landscape = ScreenArea(width = 2340, height = 1080, top = 60)
        val p = OverlayGeometry.rotate(ButtonPlacement(0, 1170, Edge.LEFT), area, landscape, size)
        assertEquals(ButtonPlacement(0, 540, Edge.LEFT), p)
    }

    @Test
    fun `닫기 영역은 아래 가운데, 반경 안에서만`() {
        val margin = 200
        val radius = 150
        assertEquals(540 to 2080, OverlayGeometry.closeZoneCenter(area, margin))
        // 버튼 가운데 = 닫기 영역 가운데
        assertTrue(OverlayGeometry.isOverCloseZone(450, 1990, size, area, margin, radius))
        assertTrue(OverlayGeometry.isOverCloseZone(550, 2090, size, area, margin, radius))
        assertFalse(OverlayGeometry.isOverCloseZone(570, 2110, size, area, margin, radius))
        assertFalse(OverlayGeometry.isOverCloseZone(0, 800, size, area, margin, radius))
    }

    @Test
    fun `메뉴는 화면 안쪽으로 펼친다`() {
        val right = OverlayGeometry.menu(ButtonPlacement(900, 800, Edge.RIGHT), size, area, gap = 10)
        assertEquals(MenuPlacement(x = 190, y = 800, alignEnd = true), right)
        val left = OverlayGeometry.menu(ButtonPlacement(0, 800, Edge.LEFT), size, area, gap = 10)
        assertEquals(MenuPlacement(x = 190, y = 800, alignEnd = false), left)
    }
}
