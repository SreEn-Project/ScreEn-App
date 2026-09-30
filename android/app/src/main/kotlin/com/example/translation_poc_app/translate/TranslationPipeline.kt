package com.example.translation_poc_app.translate

import com.example.translation_poc_app.capture.CaptureResult
import android.graphics.Bitmap
import com.example.translation_poc_app.data.settings.NormalizedRegion
import com.example.translation_poc_app.data.settings.Settings
import com.example.translation_poc_app.ocr.OcrBlock
import com.example.translation_poc_app.ocr.OcrResult
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope

enum class ItemStatus {
    TRANSLATED,

    /** 엔진이 원문 언어를 지원하지 않는다 → 원문만 보여 주고 안내. */
    UNSUPPORTED,

    /** 이 블록만 번역하지 못했다 (다른 블록은 됨). */
    FAILED,
}

/** 결과 시트 한 줄 (NA-19). [translated]는 [status]가 TRANSLATED일 때만 있다. */
data class TranslatedItem(
    val original: String,
    val translated: String?,
    val sourceLanguage: String,
    val status: ItemStatus = ItemStatus.TRANSLATED,
)

/** 플로팅 버튼 한 번 누른 결과 (NA-18 → NA-19). */
sealed interface TranslationOutcome {
    data class Translated(
        val items: List<TranslatedItem>,
        val engine: EngineId,
        val targetLanguage: String,
        /** 이미 대상 언어라 건너뛴 블록 수. */
        val skipped: Int,
    ) : TranslationOutcome

    /** 캡처가 전부 검다 → 보안 화면. */
    data object SecureScreen : TranslationOutcome

    /** 읽은 글자가 없거나 언어를 알 수 없는 것뿐. */
    data object NoText : TranslationOutcome

    /** 읽은 글이 모두 이미 대상 언어. */
    data class AlreadyInTarget(val targetLanguage: String) : TranslationOutcome

    /** @param error 엔진이 알려 준 이유 (모델 내려받기 실패 등). 캡처 · 인식 실패면 null. */
    data class Failed(val reason: String, val error: TranslationError? = null) : TranslationOutcome
}

/**
 * 캡처 → 문자 인식 → 언어 감지 → 엔진 번역을 한 번 돈다 (architecture.md "번역 파이프라인" 2~5).
 * 각 단계는 함수로 받아서 서비스 없이도 시험할 수 있다. 오버레이 표시는 부른 쪽(OverlayController)이 한다.
 */
/** 단계별 소요 시간 (ms). 속도 조정용 로그. */
data class PipelineTimings(
    val capture: Long,
    val ocr: Long = 0,
    val detect: Long = 0,
    val translate: Long = 0,
    val blocks: Int = 0,
    val segments: Int = 0,
) {
    val total: Long get() = capture + ocr + detect + translate
}

/** 캡처 프레임에서 [region]만 잘라낸 새 프레임. 원래 비트맵은 그대로 둔다 (부른 쪽이 해제). */
private fun CaptureResult.Frame.cropped(region: NormalizedRegion): CaptureResult.Frame {
    val rect = region.toPixels(bitmap.width, bitmap.height)
    return CaptureResult.Frame(Bitmap.createBitmap(bitmap, rect.left, rect.top, rect.width, rect.height))
}

class TranslationPipeline(
    private val capture: suspend () -> CaptureResult,
    private val recognize: suspend (CaptureResult.Frame) -> OcrResult,
    private val detect: suspend (OcrResult, targetLanguage: String) -> List<DetectedBlock>,
    private val engineFor: (Settings) -> TranslationEngine,
    private val settings: suspend () -> Settings,
    private val onTimings: (PipelineTimings) -> Unit = {},
    private val clock: () -> Long = System::currentTimeMillis,
) {
    /**
     * @param region 이 영역만 번역한다 (NA-07). null이면 화면 전체.
     * @param onCaptured 화면을 찍은 직후 — 캡처 동안 숨긴 오버레이를 다시 보여 줄 때.
     */
    suspend fun run(region: NormalizedRegion? = null, onCaptured: () -> Unit = {}): TranslationOutcome {
        var mark = clock()
        fun lap(): Long = clock().let { now -> (now - mark).also { mark = now } }
        val shot = try {
            capture()
        } finally {
            onCaptured()
        }
        val frame = when (shot) {
            is CaptureResult.Frame -> shot
            CaptureResult.Blank -> return TranslationOutcome.SecureScreen
            is CaptureResult.Failed -> return TranslationOutcome.Failed(shot.reason)
        }

        val captureMs = lap()
        return try {
            val current = settings()
            val target = if (region != null) frame.cropped(region) else frame
            val ocr = try {
                recognize(target)
            } finally {
                target.bitmap.recycle()
                frame.bitmap.recycle()
            }
            val ocrMs = lap()
            if (ocr.blocks.isEmpty()) {
                onTimings(PipelineTimings(captureMs, ocrMs))
                return TranslationOutcome.NoText
            }

            val detected = detect(ocr, current.targetLanguage)
            val detectMs = lap()
            val engine = engineFor(current)
            val requests = TranslationAssembler.requests(detected, current.targetLanguage)
            val results = translateAll(engine, requests)
            onTimings(PipelineTimings(captureMs, ocrMs, detectMs, lap(), ocr.blocks.size, requests.size))
            TranslationAssembler.assemble(detected, results, engine.id, current.targetLanguage)
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            TranslationOutcome.Failed(e.message ?: e::class.java.simpleName)
        }
    }

    /** 블록마다 따로 요청하고 동시에 기다린다. ML Kit은 블록 하나씩, AI 엔진(3단계)은 묶음 호출로 바꿀 수 있다. */
    private suspend fun translateAll(
        engine: TranslationEngine,
        requests: List<TranslationRequest>,
    ): List<EngineResult<TranslationResult>> = coroutineScope {
        requests.map { async { engine.translate(it) } }.awaitAll()
    }
}

/** 언어 감지 결과 + 엔진 결과 → 결과 시트 목록. Android 의존 없는 순수 로직. */
object TranslationAssembler {

    /** 글자 사이에 띄어쓰기를 하지 않는 언어. 줄을 이을 때 공백을 넣지 않는다. */
    private val NO_SPACE_LANGUAGES = setOf("ja", "zh", "th", "lo", "km", "my")

    /**
     * 블록 안의 줄을 한 문단으로 잇는다. OCR 줄바꿈은 화면 폭 때문에 생긴 것이라 문장 중간에서 끊겨
     * 번역 품질을 떨어뜨린다.
     */
    fun sourceText(block: OcrBlock, language: String): String {
        val lines = block.lines.map { it.text.trim() }.filter { it.isNotEmpty() }
        if (lines.isEmpty()) return block.text.trim()
        return lines.joinToString(if (language in NO_SPACE_LANGUAGES) "" else " ")
    }

    /** 엔진에 넘길 요청. [BlockAction.TRANSLATE] 블록만, 화면 순서대로. 원문 언어는 감지한 값을 넘긴다. */
    fun requests(detected: List<DetectedBlock>, targetLanguage: String): List<TranslationRequest> =
        detected.filter { it.decision.action == BlockAction.TRANSLATE }
            .map { TranslationRequest(sourceText(it.block, it.decision.language), it.decision.language, targetLanguage) }

    fun assemble(
        detected: List<DetectedBlock>,
        results: List<EngineResult<TranslationResult>>,
        engine: EngineId,
        targetLanguage: String,
    ): TranslationOutcome {
        val expected = detected.count { it.decision.action == BlockAction.TRANSLATE }
        if (results.size != expected) {
            return TranslationOutcome.Failed("번역 결과 수가 맞지 않음 ($expected → ${results.size})")
        }
        // 번역할 블록이 모두 실패했으면(모델 내려받기 실패 등) 목록 대신 이유를 알린다.
        val errors = results.filterIsInstance<EngineResult.Err>()
        if (results.isNotEmpty() && errors.size == results.size &&
            errors.none { it.error is TranslationError.UnsupportedLanguage }
        ) {
            return TranslationOutcome.Failed("번역 실패", errors.first().error)
        }

        val next = results.iterator()
        val items = detected.mapNotNull { (block, decision) ->
            val original = sourceText(block, decision.language)
            when (decision.action) {
                BlockAction.TRANSLATE -> when (val result = next.next()) {
                    is EngineResult.Ok -> TranslatedItem(original, result.value.text, decision.language)
                    is EngineResult.Err -> TranslatedItem(
                        original,
                        null,
                        decision.language,
                        if (result.error is TranslationError.UnsupportedLanguage) ItemStatus.UNSUPPORTED else ItemStatus.FAILED,
                    )
                }
                BlockAction.UNSUPPORTED -> TranslatedItem(original, null, decision.language, ItemStatus.UNSUPPORTED)
                BlockAction.SKIP_SAME_AS_TARGET, BlockAction.UNKNOWN -> null
            }
        }
        val skipped = detected.count { it.decision.action == BlockAction.SKIP_SAME_AS_TARGET }

        return when {
            items.isNotEmpty() -> TranslationOutcome.Translated(items, engine, targetLanguage, skipped)
            skipped > 0 -> TranslationOutcome.AlreadyInTarget(targetLanguage)
            else -> TranslationOutcome.NoText
        }
    }
}
