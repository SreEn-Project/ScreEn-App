package com.example.translation_poc_app.data.settings

/** 번역 엔진 (NA-11). AI 엔진은 3단계. */
enum class Engine { ML_KIT, GEMINI, FIREBASE_AI }

/** 캡처 범위 (NA-06). */
enum class CaptureRange { FULL_SCREEN, DRAG_REGION, FIXED_REGION }

/** 결과 표시 방식 (FL-07). PARAGRAPH = 블록 · 문장으로 나누지 않고 번역문을 한 문단으로 잇는다. */
enum class ResultDisplay { LIST, PARAGRAPH, OVERLAY }

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
    /** 플로팅 버튼 "빠른 언어" 버블에 나오는 대상 언어 코드들. 네이티브 전용 (편집 화면은 FL-04에서). */
    val quickLanguages: List<String> = DEFAULT_QUICK_LANGUAGES,
) {
    companion object {
        const val DEFAULT_TARGET_LANGUAGE = "ko"
        val DEFAULT_QUICK_LANGUAGES = listOf("ko", "en", "ja", "zh")
    }
}
