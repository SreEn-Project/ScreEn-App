package com.example.translation_poc_app.data

import com.example.translation_poc_app.data.settings.NormalizedRegion
import com.example.translation_poc_app.data.settings.PixelRect
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class NormalizedRegionTest {

    @Test
    fun `저장했다 읽으면 같은 영역`() {
        val region = NormalizedRegion(0.1f, 0.25f, 0.9f, 0.5f)
        assertEquals(region, NormalizedRegion.decode(region.encode()))
    }

    @Test
    fun `깨진 저장값은 null`() {
        assertNull(NormalizedRegion.decode(null))
        assertNull(NormalizedRegion.decode("a,b,c,d"))
        assertNull(NormalizedRegion.decode("0.1,0.2,0.3"))
        assertNull(NormalizedRegion.decode("0.5,0.5,0.4,0.9")) // 폭이 없음
        assertNull(NormalizedRegion.decode("0,0,1.5,1")) // 화면 밖
    }

    @Test
    fun `픽셀로 바꾸면 화면 안에 들어간다`() {
        assertEquals(PixelRect(100, 400, 900, 800), NormalizedRegion(0.1f, 0.25f, 0.9f, 0.5f).toPixels(1000, 1600))
        assertEquals(PixelRect(0, 0, 1000, 1600), NormalizedRegion(0f, 0f, 1f, 1f).toPixels(1000, 1600))
    }

    @Test
    fun `너무 얇은 영역도 최소 1픽셀`() {
        val rect = NormalizedRegion(0.5f, 0.5f, 0.5001f, 0.5001f).toPixels(1000, 1000)
        assertEquals(1, rect.width)
        assertEquals(1, rect.height)
    }

    @Test
    fun `화면 크기가 달라도 같은 비율`() {
        val region = NormalizedRegion.fromPixels(PixelRect(100, 200, 500, 600), 1000, 2000)
        assertEquals(PixelRect(50, 100, 250, 300), region.toPixels(500, 1000))
    }
}
