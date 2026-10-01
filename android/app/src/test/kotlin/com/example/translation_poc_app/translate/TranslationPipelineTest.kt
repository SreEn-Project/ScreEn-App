package com.example.translation_poc_app.translate

import com.example.translation_poc_app.capture.CaptureResult
import com.example.translation_poc_app.capture.FrameStats
import com.example.translation_poc_app.data.settings.Settings
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/** Bitmap이 필요 없는 경로(보안 화면 · 캡처 실패)를 확인한다. 결과 조립은 [TranslationAssemblerTest]. */
class TranslationPipelineTest {

    private object NoEngine : TranslationEngine {
        override val id = EngineId.ML_KIT
        override fun supports(language: String) = error("엔진을 쓰면 안 됨")
        override suspend fun translate(request: TranslationRequest) = error("엔진을 쓰면 안 됨")
        override suspend fun isLanguageAvailable(language: String) = error("엔진을 쓰면 안 됨")
        override suspend fun downloadLanguage(language: String, policy: ModelDownloadPolicy) = error("엔진을 쓰면 안 됨")
        override suspend fun deleteLanguage(language: String) = error("엔진을 쓰면 안 됨")
        override fun close() = Unit
    }

    private fun pipeline(result: CaptureResult) = TranslationPipeline(
        capture = { result },
        recognize = { error("인식하면 안 됨") },
        detect = { _, _ -> error("감지하면 안 됨") },
        engineFor = { NoEngine },
        settings = { Settings() },
    )

    @Test
    fun `검은 화면이면 보안 화면 안내, 캡처 뒤 버튼을 다시 보인다`() = runTest {
        var shown = false
        val outcome = pipeline(CaptureResult.Blank).run(onCaptured = { shown = true })
        assertEquals(TranslationOutcome.SecureScreen, outcome)
        assertTrue(shown)
    }

    @Test
    fun `캡처 실패는 실패로`() = runTest {
        assertEquals(TranslationOutcome.Failed("x"), pipeline(CaptureResult.Failed("x")).run())
    }

    @Test
    fun `글자가 없고 대부분 검으면 보안 화면 (본문 창만 검게 찍힌 경우)`() {
        val mostlyBlack = FrameStats(meanLuma = 12f, blackShare = 0.85f)
        assertEquals(TranslationOutcome.SecureScreen, noTextOutcome(mostlyBlack, inRegion = false))
        assertEquals(TranslationOutcome.SecureScreen, noTextOutcome(mostlyBlack, inRegion = true))
    }

    @Test
    fun `글자가 없고 밝은 화면이면 일반 안내, 영역을 골랐으면 영역 안내`() {
        val bright = FrameStats(meanLuma = 180f, blackShare = 0f)
        assertEquals(TranslationOutcome.NoText, noTextOutcome(bright, inRegion = false))
        assertEquals(TranslationOutcome.NoText, noTextOutcome(null, inRegion = false))
        assertEquals(TranslationOutcome.NoTextInRegion, noTextOutcome(bright, inRegion = true))
    }
}
