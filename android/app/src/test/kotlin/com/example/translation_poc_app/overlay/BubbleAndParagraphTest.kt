package com.example.translation_poc_app.overlay

import com.example.translation_poc_app.translate.ItemStatus
import com.example.translation_poc_app.translate.TranslatedItem
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class BubbleAndParagraphTest {

    private fun item(translated: String?) = TranslatedItem("원문", translated, "en", if (translated == null) ItemStatus.FAILED else ItemStatus.TRANSLATED)

    @Test
    fun `버블 각도 - 여유가 있으면 위에서 아래로`() {
        assertEquals(listOf(-66f, -22f, 22f, 66f), OverlayGeometry.bubbleAngles(spaceAboveDp = 400f, spaceBelowDp = 400f))
    }

    @Test
    fun `버블 각도 - 위쪽 끝이면 아래로 몰린다`() {
        assertEquals(listOf(0f, 30f, 60f, 90f), OverlayGeometry.bubbleAngles(spaceAboveDp = 40f, spaceBelowDp = 600f))
    }

    @Test
    fun `버블 각도 - 아래쪽 끝이면 위로 몰린다`() {
        assertEquals(listOf(-90f, -60f, -30f, 0f), OverlayGeometry.bubbleAngles(spaceAboveDp = 600f, spaceBelowDp = 40f))
    }

    private val angles = listOf(-66f, -22f, 22f, 66f)

    private fun hit(x: Float, y: Float, inwardRight: Boolean = true) =
        OverlayGeometry.bubbleHit(x, y, 0f, 0f, inwardRight, angles, radius = 100f, hitRadius = 34f)

    @Test
    fun `버블 위 판정 - 버블 가운데에 있으면 그 번호`() {
        // 22° 버블 가운데: (92.7, 37.5)
        assertEquals(2, hit(93f, 37f))
        assertEquals(0, hit(40f, -91f))
    }

    @Test
    fun `버블 위 판정 - 안쪽이 왼쪽이면 x가 반대로`() {
        assertEquals(2, hit(-93f, 37f, inwardRight = false))
    }

    @Test
    fun `버블 위 판정 - 버블 밖이나 버튼 위면 없음`() {
        assertEquals(-1, hit(0f, 0f))
        assertEquals(-1, hit(93f, 120f))
    }

    @Test
    fun `문단형은 번역문을 블록 구분 없이 공백으로 잇는다`() {
        assertEquals("안녕하세요 반갑습니다", paragraphText(listOf(item("안녕하세요"), item("반갑습니다")), "ko"))
    }

    @Test
    fun `문단형 - 띄어쓰기 없는 언어는 공백 없이 잇고 실패한 블록은 건너뛴다`() {
        assertEquals("こんにちは世界", paragraphText(listOf(item("こんにちは"), item(null), item("世界")), "ja"))
    }

    @Test
    fun `문단형 - 번역된 블록이 없으면 null`() {
        assertNull(paragraphText(listOf(item(null)), "ko"))
    }
}
