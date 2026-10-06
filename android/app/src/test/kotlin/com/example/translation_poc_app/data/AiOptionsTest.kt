package com.example.translation_poc_app.data

import com.example.translation_poc_app.data.settings.GlossaryEntry
import com.example.translation_poc_app.data.settings.Settings
import com.example.translation_poc_app.data.settings.decodeGlossary
import com.example.translation_poc_app.data.settings.encodeGlossary
import org.junit.Assert.assertEquals
import org.junit.Test

class AiOptionsTest {
    @Test
    fun `용어집은 공백 · 빈 칸 · 대소문자 중복을 정리한다`() {
        val result = Settings.normalizeGlossary(
            listOf(
                GlossaryEntry("  Mana ", " 마나 "),
                GlossaryEntry("mana", "마나2"),
                GlossaryEntry("", "x"),
                GlossaryEntry("y", "  "),
                GlossaryEntry("Quest", "퀘스트"),
            ),
        )
        assertEquals(listOf(GlossaryEntry("Mana", "마나"), GlossaryEntry("Quest", "퀘스트")), result)
    }

    @Test
    fun `용어집은 50개 · 60자로 제한한다`() {
        val many = (1..80).map { GlossaryEntry("s$it", "t$it") }
        assertEquals(Settings.MAX_GLOSSARY_ENTRIES, Settings.normalizeGlossary(many).size)
        val long = Settings.normalizeGlossary(listOf(GlossaryEntry("a".repeat(100), "b".repeat(100))))
        assertEquals(Settings.MAX_GLOSSARY_TEXT_LENGTH, long.single().source.length)
        assertEquals(Settings.MAX_GLOSSARY_TEXT_LENGTH, long.single().target.length)
    }

    @Test
    fun `용어집 저장 형식은 되돌아오고 깨진 값은 빈 목록이다`() {
        val entries = listOf(GlossaryEntry("a\"b", "가\n나"), GlossaryEntry("Quest", "퀘스트"))
        assertEquals(entries, decodeGlossary(encodeGlossary(entries)))
        assertEquals(emptyList<GlossaryEntry>(), decodeGlossary(null))
        assertEquals(emptyList<GlossaryEntry>(), decodeGlossary("not json"))
    }
}
