package com.example.translation_poc_app.translate

import com.example.translation_poc_app.ocr.OcrBlock
import com.example.translation_poc_app.ocr.OcrLine
import org.junit.Assert.assertEquals
import org.junit.Test

class TranslationAssemblerTest {

    private fun block(vararg lines: String) = OcrBlock(
        text = lines.joinToString("\n"),
        bounds = null,
        lines = lines.map { OcrLine(it, null, 1f) },
        language = "und",
    )

    private fun detected(action: BlockAction, language: String, vararg lines: String) =
        DetectedBlock(block(*lines), BlockDecision(language, action))

    private fun ok(text: String, source: String) =
        EngineResult.Ok(TranslationResult(text, source, "ko", EngineId.ML_KIT))

    @Test
    fun `줄을 한 문단으로 잇고 띄어쓰기 없는 언어는 붙인다`() {
        assertEquals("Hello world again", TranslationAssembler.sourceText(block("Hello world", " again "), "en"))
        assertEquals("今日は晴れです", TranslationAssembler.sourceText(block("今日は", "晴れです"), "ja"))
    }

    @Test
    fun `번역할 블록만 감지한 원문 언어로 요청한다`() {
        val requests = TranslationAssembler.requests(
            listOf(
                detected(BlockAction.TRANSLATE, "en", "Hello"),
                detected(BlockAction.SKIP_SAME_AS_TARGET, "ko", "안녕"),
                detected(BlockAction.UNSUPPORTED, "xx", "???"),
                detected(BlockAction.TRANSLATE, "ja", "こんにちは"),
            ),
            "ko",
        )
        assertEquals(
            listOf(TranslationRequest("Hello", "en", "ko"), TranslationRequest("こんにちは", "ja", "ko")),
            requests,
        )
    }

    @Test
    fun `번역문을 화면 순서대로 붙이고 미지원 · 실패 블록은 원문만`() {
        val outcome = TranslationAssembler.assemble(
            listOf(
                detected(BlockAction.TRANSLATE, "en", "Hello"),
                detected(BlockAction.UNSUPPORTED, "la", "Salve"),
                detected(BlockAction.SKIP_SAME_AS_TARGET, "ko", "안녕"),
                detected(BlockAction.UNKNOWN, "und", "123"),
                detected(BlockAction.TRANSLATE, "ja", "ありがとう"),
                detected(BlockAction.TRANSLATE, "fr", "Merci"),
            ),
            listOf(
                ok("안녕하세요", "en"),
                ok("고마워요", "ja"),
                EngineResult.Err(TranslationError.Unknown("x")),
            ),
            EngineId.ML_KIT,
            "ko",
        )
        assertEquals(
            TranslationOutcome.Translated(
                items = listOf(
                    TranslatedItem("Hello", "안녕하세요", "en"),
                    TranslatedItem("Salve", null, "la", ItemStatus.UNSUPPORTED),
                    TranslatedItem("ありがとう", "고마워요", "ja"),
                    TranslatedItem("Merci", null, "fr", ItemStatus.FAILED),
                ),
                engine = EngineId.ML_KIT,
                targetLanguage = "ko",
                skipped = 1,
            ),
            outcome,
        )
    }

    @Test
    fun `모두 실패하면 엔진 이유로 실패, 미지원만이면 목록`() {
        val blocks = listOf(detected(BlockAction.TRANSLATE, "en", "Hello"), detected(BlockAction.TRANSLATE, "fr", "Salut"))
        assertEquals(
            TranslationOutcome.Failed("번역 실패", TranslationError.Network),
            TranslationAssembler.assemble(
                blocks,
                listOf(EngineResult.Err(TranslationError.Network), EngineResult.Err(TranslationError.Network)),
                EngineId.ML_KIT,
                "ko",
            ),
        )
        val unsupported = TranslationAssembler.assemble(
            blocks.take(1),
            listOf(EngineResult.Err(TranslationError.UnsupportedLanguage("en"))),
            EngineId.ML_KIT,
            "ko",
        )
        assertEquals(
            listOf(TranslatedItem("Hello", null, "en", ItemStatus.UNSUPPORTED)),
            (unsupported as TranslationOutcome.Translated).items,
        )
    }

    @Test
    fun `모두 대상 언어면 AlreadyInTarget, 알 수 없는 것뿐이면 NoText`() {
        assertEquals(
            TranslationOutcome.AlreadyInTarget("ko"),
            TranslationAssembler.assemble(
                listOf(detected(BlockAction.SKIP_SAME_AS_TARGET, "ko", "안녕"), detected(BlockAction.UNKNOWN, "und", "1")),
                emptyList(),
                EngineId.ML_KIT,
                "ko",
            ),
        )
        assertEquals(
            TranslationOutcome.NoText,
            TranslationAssembler.assemble(listOf(detected(BlockAction.UNKNOWN, "und", "1")), emptyList(), EngineId.ML_KIT, "ko"),
        )
    }

    @Test
    fun `엔진 결과 수가 다르면 실패`() {
        val outcome = TranslationAssembler.assemble(
            listOf(detected(BlockAction.TRANSLATE, "en", "Hello")),
            emptyList(),
            EngineId.ML_KIT,
            "ko",
        )
        assertEquals(TranslationOutcome.Failed("번역 결과 수가 맞지 않음 (1 → 0)"), outcome)
    }
}
