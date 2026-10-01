package com.example.translation_poc_app.translate

/** 블록 하나를 어떻게 할지 (NA-10). */
enum class BlockAction {
    /** 번역한다. */
    TRANSLATE,

    /** 원문이 이미 대상 언어라 번역하지 않는다. */
    SKIP_SAME_AS_TARGET,

    /** 번역 엔진이 이 원문 언어를 지원하지 않는다 → 안내. */
    UNSUPPORTED,

    /** 언어를 알아내지 못했다 (짧은 글자 · 숫자 · 기호 등) → 번역하지 않는다. */
    UNKNOWN,
}

data class BlockDecision(val language: String, val action: BlockAction)

/**
 * 감지한 언어로 블록별 할 일을 정한다 (NA-10, D-021). Android 의존 없는 순수 로직.
 */
object LanguagePlan {

    /** Language ID가 모를 때 쓰는 값. */
    const val UNDETERMINED = "und"

    /**
     * ML Kit Language ID · OCR 결과 언어 태그를 번역 엔진이 쓰는 기본 코드로 맞춘다.
     * - 지역 · 문자 표기는 떼어 낸다 ("zh-Hant" → "zh", "pt-BR" → "pt").
     * - 로마자로 적은 비라틴 언어("ja-Latn", "hi-Latn" 등)는 해당 언어 모델로 번역할 수 없으니 모름으로 본다.
     * - 옛 코드는 새 코드로 ("iw" → "he", "in" → "id", "ji" → "yi", "nb" → "no", "fil" → "tl").
     */
    fun normalize(tag: String?): String {
        if (tag.isNullOrBlank()) return UNDETERMINED
        val parts = tag.trim().replace('_', '-').lowercase().split('-')
        if (parts.drop(1).any { it == "latn" } && parts[0] !in LATIN_BASED) return UNDETERMINED
        return when (val base = parts[0]) {
            "iw" -> "he"
            "in" -> "id"
            "ji" -> "yi"
            "nb", "nn" -> "no"
            "fil" -> "tl"
            "", UNDETERMINED -> UNDETERMINED
            else -> base
        }
    }

    /**
     * @param detected Language ID 결과 (없거나 모르면 null · "und")
     * @param ocrHint OCR 인식기가 추정한 언어 (Language ID가 모를 때만 쓴다)
     * @param target 대상 언어
     * @param supported 번역 엔진이 원문으로 받을 수 있는 언어
     * @param text 블록 글자. 한글 · 가나가 있으면 Language ID 결과보다 우선한다 ([scriptLanguage]).
     */
    fun decide(
        detected: String?,
        ocrHint: String?,
        target: String,
        supported: Set<String>,
        text: String? = null,
    ): BlockDecision {
        val fromId = text?.let(::scriptLanguage) ?: normalize(detected)
        val language = if (fromId != UNDETERMINED) fromId else normalize(ocrHint)
        val action = when {
            language == UNDETERMINED -> BlockAction.UNKNOWN
            language == normalize(target) -> BlockAction.SKIP_SAME_AS_TARGET
            language !in supported -> BlockAction.UNSUPPORTED
            else -> BlockAction.TRANSLATE
        }
        return BlockDecision(language, action)
    }

    /**
     * 글자 체계만으로 언어가 확실한 경우 (#19). 한글이 있으면 ko, 가나가 있으면 ja.
     * Language ID는 한자가 많은 일본어를 zh로, 영어가 섞인 한국어를 en으로 읽는 일이 있다.
     * 글자 수의 [MIN_SHARE] 이상일 때만 따라 우연히 섞인 글자에 끌려가지 않게 한다.
     */
    fun scriptLanguage(text: String): String? {
        var hangul = 0
        var kana = 0
        var total = 0
        for (c in text) {
            if (!c.isLetter()) continue
            total++
            when (Character.UnicodeScript.of(c.code)) {
                Character.UnicodeScript.HANGUL -> hangul++
                Character.UnicodeScript.HIRAGANA, Character.UnicodeScript.KATAKANA -> kana++
                else -> Unit
            }
        }
        if (total == 0) return null
        return when {
            hangul >= kana && hangul.toFloat() / total >= MIN_SHARE -> "ko"
            kana.toFloat() / total >= MIN_SHARE -> "ja"
            else -> null
        }
    }

    private const val MIN_SHARE = 0.3f

    /** 로마자 표기가 원래 표기인 언어 ("en-Latn" 같은 태그도 그대로 쓴다). */
    private val LATIN_BASED = setOf(
        "af", "ca", "cs", "cy", "da", "de", "en", "eo", "es", "et", "fi", "fr", "ga", "gl", "hr",
        "ht", "hu", "id", "is", "it", "lt", "lv", "ms", "mt", "nl", "no", "pl", "pt", "ro", "sk",
        "sl", "sq", "sv", "sw", "tl", "tr", "vi",
    )
}
