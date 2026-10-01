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
    /** 플로팅 버튼 "빠른 언어" 버블에 나오는 대상 언어 코드들. 앱 설정 화면(FL-04)에서 편집하며 Pigeon으로 주고받는다. */
    val quickLanguages: List<String> = DEFAULT_QUICK_LANGUAGES,
    /** 자동 번역 (#23): 번역한 뒤 화면이 바뀌면 알아서 다시 번역한다. 기본 꺼짐. */
    val autoTranslate: Boolean = false,
    /** 자동 번역의 화면 확인 간격 (ms). 짧을수록 빨리 따라가지만 열 · 배터리를 더 쓴다. */
    val autoCheckIntervalMs: Long = DEFAULT_AUTO_CHECK_INTERVAL_MS,
    /** 화면이 바뀐 뒤 멈추고 이만큼 기다렸다가 번역한다 (ms). */
    val autoSettleMs: Long = DEFAULT_AUTO_SETTLE_MS,
    /** 문자 인식 언어 ([SOURCE_LANGUAGE_AUTO] = 자동 판별). 플로팅 버튼 '빠른 언어' 버블에서 바꾼다. 네이티브 전용 (Pigeon 없음). */
    val sourceLanguage: String = SOURCE_LANGUAGE_AUTO,
) {
    companion object {
        const val DEFAULT_TARGET_LANGUAGE = "ko"
        const val SOURCE_LANGUAGE_AUTO = "auto"
        val DEFAULT_QUICK_LANGUAGES = listOf("ko", "en", "ja", "zh")
        const val DEFAULT_AUTO_CHECK_INTERVAL_MS = 2_000L
        const val DEFAULT_AUTO_SETTLE_MS = 1_000L

        /** 설정 화면이 고르게 하는 값의 범위. 저장된 값이 벗어나면 이 안으로 맞춘다. */
        val AUTO_CHECK_INTERVAL_RANGE_MS = 1_000L..5_000L
        val AUTO_SETTLE_RANGE_MS = 500L..3_000L
    }
}
