package com.example.translation_poc_app.selection

import com.example.translation_poc_app.translate.AUTO_LANGUAGE
import com.example.translation_poc_app.translate.EngineId
import com.example.translation_poc_app.translate.EngineResult
import com.example.translation_poc_app.translate.ItemStatus
import com.example.translation_poc_app.translate.LanguagePlan
import com.example.translation_poc_app.translate.TranslatedItem
import com.example.translation_poc_app.translate.TranslationEngine
import com.example.translation_poc_app.translate.TranslationError
import com.example.translation_poc_app.translate.TranslationOutcome
import com.example.translation_poc_app.translate.TranslationRequest

/** 텍스트 선택 번역 한 번의 결과 (NA-24). */
sealed interface SelectionOutcome {
    data class Translated(
        val original: String,
        val translated: String,
        val sourceLanguage: String,
        val targetLanguage: String,
        val engine: EngineId,
    ) : SelectionOutcome {
        /** 번역 기록(NA-23)에 남길 형태. 화면 위치 정보는 없다. */
        fun toHistoryOutcome(): TranslationOutcome.Translated = TranslationOutcome.Translated(
            items = listOf(TranslatedItem(original, translated, sourceLanguage, ItemStatus.TRANSLATED)),
            engine = engine,
            targetLanguage = targetLanguage,
            skipped = 0,
        )
    }

    /** 선택한 글이 이미 대상 언어. */
    data class AlreadyInTarget(val targetLanguage: String) : SelectionOutcome

    /** 글이 비어 있다. */
    data object Empty : SelectionOutcome

    /** @param error 엔진이 알려 준 이유 (모델 내려받기 실패, 언어 미지원 등). */
    data class Failed(val error: TranslationError?) : SelectionOutcome
}

/**
 * 다른 앱에서 고른 글을 번역한다 (NA-24). 캡처 · OCR 없이 엔진만 쓰고, 원문 언어는 엔진이 감지한다.
 * 안드로이드 의존이 없어 단위 테스트할 수 있다.
 */
class SelectionTranslator(private val engine: TranslationEngine) {

    suspend fun translate(text: String, targetLanguage: String): SelectionOutcome {
        val original = text.trim()
        if (original.isEmpty()) return SelectionOutcome.Empty
        return when (val result = engine.translate(TranslationRequest(original, AUTO_LANGUAGE, targetLanguage))) {
            is EngineResult.Err -> SelectionOutcome.Failed(result.error)
            is EngineResult.Ok -> {
                val value = result.value
                if (LanguagePlan.normalize(value.sourceLanguage) == LanguagePlan.normalize(targetLanguage)) {
                    SelectionOutcome.AlreadyInTarget(targetLanguage)
                } else {
                    SelectionOutcome.Translated(
                        original, value.text, value.sourceLanguage, value.targetLanguage, value.engine,
                    )
                }
            }
        }
    }

    companion object {
        /** 너무 긴 글은 앞부분만 번역한다. */
        const val MAX_LENGTH = 5000
    }
}
