package com.example.translation_poc_app.data.settings

/** 번역 엔진 (NA-11). AI 엔진은 3단계. */
enum class Engine { ML_KIT, GEMINI, FIREBASE_AI }

/** 캡처 범위 (NA-06). */
enum class CaptureRange { FULL_SCREEN, DRAG_REGION, FIXED_REGION }

/** 결과 표시 방식 (FL-07). */
enum class ResultDisplay { LIST, OVERLAY }

/**
 * 네이티브 쪽 설정 모델 (NA-16).
 * 서비스 · 오버레이는 Pigeon 생성 타입 대신 이 모델을 쓴다. 변환은 bridge/Mappers.kt.
 */
data class Settings(
    val targetLanguage: String = DEFAULT_TARGET_LANGUAGE,
    val engine: Engine = Engine.ML_KIT,
    val captureRange: CaptureRange = CaptureRange.FULL_SCREEN,
    val resultDisplay: ResultDisplay = ResultDisplay.LIST,
    val onboardingCompleted: Boolean = false,
    /** 고정 영역 모드가 번역할 영역 (NA-08). 아직 안 정했으면 null. 네이티브 전용 (Pigeon 없음). */
    val fixedRegion: NormalizedRegion? = null,
) {
    companion object {
        const val DEFAULT_TARGET_LANGUAGE = "ko"
    }
}
