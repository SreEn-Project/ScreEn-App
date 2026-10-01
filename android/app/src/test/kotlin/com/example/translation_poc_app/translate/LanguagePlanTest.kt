package com.example.translation_poc_app.translate

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class LanguagePlanTest {

    private val supported = setOf("en", "ja", "ko", "zh", "he", "id", "pt", "no", "tl")

    private fun decide(detected: String?, hint: String? = null, target: String = "ko") =
        LanguagePlan.decide(detected, hint, target, supported)

    @Test
    fun `지역 · 문자 표기를 떼고 옛 코드를 바꾼다`() {
        assertEquals("zh", LanguagePlan.normalize("zh-Hant"))
        assertEquals("pt", LanguagePlan.normalize("pt_BR"))
        assertEquals("he", LanguagePlan.normalize("iw"))
        assertEquals("id", LanguagePlan.normalize("in"))
        assertEquals("no", LanguagePlan.normalize("nb"))
        assertEquals("tl", LanguagePlan.normalize("fil"))
        assertEquals("en", LanguagePlan.normalize("en-Latn"))
    }

    @Test
    fun `로마자로 적은 비라틴 언어는 모름으로 본다`() {
        assertEquals(LanguagePlan.UNDETERMINED, LanguagePlan.normalize("ja-Latn"))
        assertEquals(LanguagePlan.UNDETERMINED, LanguagePlan.normalize("hi-Latn"))
    }

    @Test
    fun `대상 언어와 같으면 건너뛴다`() {
        assertEquals(BlockAction.SKIP_SAME_AS_TARGET, decide("ko").action)
        assertEquals(BlockAction.SKIP_SAME_AS_TARGET, decide("zh-Hans", target = "zh-TW").action)
    }

    @Test
    fun `지원하는 다른 언어면 번역한다`() {
        assertEquals(BlockDecision("ja", BlockAction.TRANSLATE), decide("ja"))
    }

    @Test
    fun `엔진이 모르는 언어면 지원 안 함`() {
        assertEquals(BlockDecision("xx", BlockAction.UNSUPPORTED), decide("xx"))
    }

    @Test
    fun `Language ID가 모르면 OCR 추정을 쓴다`() {
        assertEquals(BlockDecision("en", BlockAction.TRANSLATE), decide("und", hint = "en"))
    }

    @Test
    fun `둘 다 모르면 번역하지 않는다`() {
        assertEquals(BlockAction.UNKNOWN, decide("und", hint = "und").action)
        assertEquals(BlockAction.UNKNOWN, decide(null, hint = null).action)
    }
}

class ScriptLanguageTest {
    @Test
    fun `한글 · 가나가 있으면 글자 체계로 정한다`() {
        assertEquals("ko", LanguagePlan.scriptLanguage("오늘 날씨 Weather"))
        assertEquals("ja", LanguagePlan.scriptLanguage("今日はいい天気です"))
        assertNull(LanguagePlan.scriptLanguage("今日天气很好"))
        assertNull(LanguagePlan.scriptLanguage("Hello 안"))
        assertNull(LanguagePlan.scriptLanguage("1234"))
    }

    @Test
    fun `글자 체계가 Language ID보다 우선한다`() {
        val d = LanguagePlan.decide("zh", null, "en", setOf("ja", "zh", "ko"), "今日はいい天気です")
        assertEquals("ja", d.language)
    }
}
