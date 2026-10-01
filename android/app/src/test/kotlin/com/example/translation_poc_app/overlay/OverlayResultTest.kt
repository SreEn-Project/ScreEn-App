package com.example.translation_poc_app.overlay

import com.example.translation_poc_app.data.settings.NormalizedRegion
import com.example.translation_poc_app.ocr.OcrBlock
import com.example.translation_poc_app.ocr.OcrLine
import com.example.translation_poc_app.translate.BlockAction
import com.example.translation_poc_app.translate.BlockDecision
import com.example.translation_poc_app.translate.DetectedBlock
import com.example.translation_poc_app.translate.EngineId
import com.example.translation_poc_app.translate.EngineResult
import com.example.translation_poc_app.translate.ItemStatus
import com.example.translation_poc_app.translate.TranslatedItem
import com.example.translation_poc_app.translate.TranslationAssembler
import com.example.translation_poc_app.translate.TranslationOutcome
import com.example.translation_poc_app.translate.TranslationResult
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/** 원문 위에 덮기 (NA-22): 자리 정보 전달과 막 상자 계산. */
class OverlayResultTest {

    private val region = NormalizedRegion(0.1f, 0.2f, 0.5f, 0.3f)

    private fun item(translated: String?, bounds: NormalizedRegion?) =
        TranslatedItem("원문", translated, "en", if (translated == null) ItemStatus.FAILED else ItemStatus.TRANSLATED, bounds)

    @Test
    fun `번역됐고 자리를 아는 항목만 막으로 그린다`() {
        val items = listOf(
            item("안녕", region),
            item("자리 없음", null),
            item(null, region),
            item("  ", region),
        )
        assertEquals(listOf(items[0]), overlayItems(items))
    }

    @Test
    fun `조립 때 블록 자리를 항목에 붙인다`() {
        val block = OcrBlock("Hello", null, listOf(OcrLine("Hello", null, 1f)), "en")
        val outcome = TranslationAssembler.assemble(
            listOf(DetectedBlock(block, BlockDecision("en", BlockAction.TRANSLATE))),
            listOf(EngineResult.Ok(TranslationResult("안녕", "en", "ko", EngineId.ML_KIT))),
            EngineId.ML_KIT,
            "ko",
        ) { region } as TranslationOutcome.Translated
        assertEquals(region, outcome.items.single().bounds)
    }

    @Test
    fun `막 상자는 여백만큼 넓히고 화면 밖으로 나가지 않는다`() {
        val box = paddedBox(NormalizedRegion(0.1f, 0.2f, 0.5f, 0.3f), 1000f, 2000f, 4f)
        assertEquals(96f, box.left, 0.01f)
        assertEquals(396f, box.top, 0.01f)
        assertEquals(408f, box.width, 0.01f)
        assertEquals(208f, box.height, 0.01f)

        val edge = paddedBox(NormalizedRegion(0f, 0f, 1f, 1f), 1000f, 2000f, 4f)
        assertEquals(PxBox(0f, 0f, 1000f, 2000f), edge)
        assertTrue(paddedBox(NormalizedRegion(0.5f, 0.5f, 0.5f, 0.5f), 100f, 100f, 0f).width >= 1f)
    }
}
