package com.example.translation_poc_app.data.settings

/**
 * 번역 엔진 (NA-11). ML_KIT = 기기 내 번역, GEMINI · GROQ = 내 API 키 (NA-13),
 * GEMMA = 기기 안에서 도는 AI 모델 (#174, 키 · 인터넷 없음, 모델을 먼저 받아야 한다).
 */
enum class Engine {
    ML_KIT,
    GEMINI,
    GROQ,
    GEMMA,
    ;

    /** 말투 · 용어집(FL-11)을 따르는 AI(LLM) 엔진인가. */
    val isAi: Boolean get() = this != ML_KIT

    /** 사용자가 발급한 API 키가 있어야 쓰는 클라우드 AI 엔진인가. 만 18세 확인(FL-09)도 필요하다. */
    val needsApiKey: Boolean get() = this == GEMINI || this == GROQ
}

/** 캡처 범위 (NA-06). */
enum class CaptureRange { FULL_SCREEN, DRAG_REGION, FIXED_REGION }

/** 결과 표시 방식 (FL-07). PARAGRAPH = 블록 · 문장으로 나누지 않고 번역문을 한 문단으로 잇는다. */
enum class ResultDisplay { LIST, PARAGRAPH, OVERLAY }

/** AI 번역 말투 (FL-11). STANDARD = 지정하지 않음. */
enum class AiTone { STANDARD, FORMAL, INFORMAL }

/** AI 번역 용어집 한 줄 (FL-11): [source] 표현은 항상 [target]으로 옮긴다. */
data class GlossaryEntry(val source: String, val target: String)

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
    /** 자동 번역이 새 번역을 보여 주는 시점 (ms): 조작이 끝난 뒤 이 시간 이후. 0 = 번역이 되는 대로 바로. */
    val autoShowDelayMs: Long = DEFAULT_AUTO_SHOW_DELAY_MS,
    /**
     * 사용자가 화면을 조작한 뒤 이전 번역(덮어쓰기)을 숨기기까지의 시간 (ms). 자동 번역과 무관하게 적용된다 (#35).
     * 0 = 바로, [HIDE_NEVER] = 숨기지 않고 새 번역이 뜰 때까지 둔다.
     */
    val hideAfterInteractionMs: Long = DEFAULT_HIDE_AFTER_INTERACTION_MS,
    /** 문자 인식 언어 ([SOURCE_LANGUAGE_AUTO] = 자동 판별). 플로팅 버튼 '빠른 언어' 버블에서 바꾼다. 네이티브 전용 (Pigeon 없음). */
    val sourceLanguage: String = SOURCE_LANGUAGE_AUTO,
    /** 언어 모델을 Wi-Fi에서만 받는다 (FL-05). 번역 중 자동으로 받을 때도 적용된다. */
    val wifiOnlyModelDownload: Boolean = true,
    /** 플로팅 버튼 원 지름 (dp, FL-07). 창은 여기에 그림자 여백을 더한 크기. */
    val buttonSizeDp: Int = DEFAULT_BUTTON_SIZE_DP,
    /** 플로팅 버튼 불투명도 (%, FL-07). */
    val buttonOpacityPercent: Int = DEFAULT_BUTTON_OPACITY_PERCENT,
    /** 만 18세 이상 확인 (FL-09). 확인 전에는 AI 엔진을 쓰지 않는다 (Gemini API 약관). */
    val ageConfirmed: Boolean = false,
    /** AI 번역 말투 (FL-11). */
    val aiTone: AiTone = AiTone.STANDARD,
    /** AI 번역 용어집 (FL-11). */
    val glossary: List<GlossaryEntry> = emptyList(),
) {
    companion object {
        const val DEFAULT_TARGET_LANGUAGE = "ko"
        const val SOURCE_LANGUAGE_AUTO = "auto"
        val DEFAULT_QUICK_LANGUAGES = listOf("ko", "en", "ja", "zh")
        const val DEFAULT_AUTO_SHOW_DELAY_MS = 0L
        const val DEFAULT_HIDE_AFTER_INTERACTION_MS = 0L
        const val HIDE_NEVER = -1L
        const val DEFAULT_BUTTON_SIZE_DP = 52
        const val DEFAULT_BUTTON_OPACITY_PERCENT = 100
        val BUTTON_SIZE_RANGE_DP = 40..72
        val BUTTON_OPACITY_RANGE_PERCENT = 30..100

        /** 설정 화면이 고르게 하는 값의 범위. 저장된 값이 벗어나면 이 안으로 맞춘다. */
        val AUTO_SHOW_DELAY_RANGE_MS = 0L..5_000L
        val HIDE_AFTER_INTERACTION_RANGE_MS = 0L..5_000L

        const val MAX_GLOSSARY_ENTRIES = 50
        const val MAX_GLOSSARY_TEXT_LENGTH = 60

        /** 용어집 정리: 앞뒤 공백을 걷고, 빈 칸 · 같은 원문(대소문자 무시) 중복을 빼고, 길이 · 개수를 제한한다. 앞의 항목이 이긴다. */
        fun normalizeGlossary(entries: List<GlossaryEntry>): List<GlossaryEntry> =
            entries
                .map {
                    GlossaryEntry(
                        it.source.trim().take(MAX_GLOSSARY_TEXT_LENGTH),
                        it.target.trim().take(MAX_GLOSSARY_TEXT_LENGTH),
                    )
                }
                .filter { it.source.isNotEmpty() && it.target.isNotEmpty() }
                .distinctBy { it.source.lowercase() }
                .take(MAX_GLOSSARY_ENTRIES)

        /** 숨김 시간: 음수는 "안 숨김", 나머지는 범위 안으로. */
        fun normalizeHideAfterInteraction(ms: Long): Long =
            if (ms < 0) HIDE_NEVER else ms.coerceIn(HIDE_AFTER_INTERACTION_RANGE_MS)
    }
}
