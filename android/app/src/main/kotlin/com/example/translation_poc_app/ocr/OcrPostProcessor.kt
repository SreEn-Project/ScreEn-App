package com.example.translation_poc_app.ocr

/**
 * 인식 후처리 (#45). 문자 인식이 자주 틀리는 라틴 글자(I/l/|, 0/O, 1/l, 5/S, 합자)를 보수적으로 고치고,
 * 짧은 UI 단어(OK · Cancel · Settings 등)는 사전으로 바로잡는다. 틀린 글자가 번역기에 들어가면
 * 단어가 통째로 오역되므로 번역 전에 한 번 거른다. Android 의존 없음.
 *
 * 원칙: 확실할 때만 고친다 — 영문자와 숫자가 섞인 단어에서 숫자가 글자 사이에 끼었을 때, 문장 첫머리의
 * "l'm" 같은 꼴 등. 한글 · 일본어 · 중국어 글자가 섞인 낱말, 주소 · 파일 이름 · 코드 조각은 건드리지 않는다.
 */
object OcrPostProcessor {

    private val TOKEN = Regex("[A-Za-z0-9|]+(?:['’][A-Za-z]+)?")
    private val CONTRACTION = Regex("^[l|I]['’](m|ll|ve|d)$")

    /** "l am" · "| think"처럼 I가 l이나 |로 읽힌 경우를 알아보는 뒤따르는 낱말. */
    private val AFTER_I = setOf(
        "am", "was", "have", "had", "will", "would", "think", "can", "could", "do", "did", "need", "want",
        "know", "like", "love", "am", "see", "feel", "hope", "should", "must", "may", "might", "just", "also",
    )

    /** 읽기 쉬운 UI 단어. 모양이 비슷한 글자(I · l · 1 · |)를 하나로 접어 견준다. */
    private val UI_WORDS = listOf(
        "OK", "Cancel", "Close", "Open", "Save", "Delete", "Edit", "Done", "Next", "Back", "Skip",
        "Settings", "Search", "Share", "Login", "Logout", "Sign in", "Sign up", "Home", "Menu", "More",
        "Help", "About", "Send", "Reply", "Apply", "Reset", "Retry", "Allow", "Deny", "Install",
        "Update", "Download", "Upload", "Continue", "Confirm", "Select", "All", "None", "Yes", "No",
        "Profile", "Account", "Password", "Notifications", "Language", "Privacy", "Terms", "Loading",
        "Error", "Warning", "Success", "Message", "Messages", "Friends", "Follow", "Comments", "Like",
        "Play", "Pause", "Stop", "Start", "Online", "Offline", "Free", "Premium", "Store", "Shop", "Cart",
    )

    private fun fold(s: String): String = buildString {
        for (c in s) append(
            when (c) {
                '0' -> 'o'
                '1', '|', 'I', 'i', 'l' -> 'l'
                '5' -> 's'
                else -> c.lowercaseChar()
            },
        )
    }

    /** 접힌 모양 → 정식 표기. 서로 다른 단어가 같은 접힌 모양이 되면 쓰지 않는다. */
    private val dictionary: Map<String, String> = run {
        val all = UI_WORDS.associateBy { fold(it) }
        val collisions = UI_WORDS.groupBy { fold(it) }.filterValues { it.size > 1 }.keys
        all - collisions
    }

    private val LIGATURES = mapOf(
        'ﬀ' to "ff", 'ﬁ' to "fi", 'ﬂ' to "fl", 'ﬃ' to "ffi", 'ﬄ' to "ffl", 'ﬅ' to "st", 'ﬆ' to "st",
    )

    /** 블록 글자를 고친다. 바뀐 게 없으면 같은 블록을 돌려준다. */
    fun process(blocks: List<OcrBlock>): List<OcrBlock> = blocks.map { block ->
        val fixed = block.lines.map { line ->
            val text = fixLine(line.text)
            if (text == line.text) line else line.copy(text = text)
        }
        if (fixed.zip(block.lines).all { (a, b) -> a === b }) {
            block
        } else {
            block.copy(text = fixed.joinToString("\n") { it.text }, lines = fixed)
        }
    }

    /** 한 줄을 고친다. */
    fun fixLine(line: String): String {
        val text = if (LIGATURES.keys.any { it in line }) {
            buildString { for (c in line) append(LIGATURES[c] ?: c.toString()) }
        } else {
            line
        }
        if (text.none { it in '0'..'9' || it == '|' || it == 'l' || it == 'I' }) return text
        // 사전은 줄 전체가 사전 문구이거나 낱말 하나일 때만 쓴다 (문장 속 낱말은 오탐 위험이 커서 제외).
        val whole = dictionaryPhrase(text)
        if (whole != null) return whole
        return TOKEN.replace(text) { m -> fixToken(text, m) }
    }

    private fun dictionaryPhrase(text: String): String? {
        val trimmed = text.trim()
        if (trimmed.length !in 2..16) return null
        val canonical = dictionary[fold(trimmed)] ?: return null
        if (canonical == trimmed) return null
        // 문자 열이 영문자 · 숫자 · | · 공백뿐일 때만 (한글 등이 섞이면 다른 글자다).
        if (!trimmed.all { it in 'A'..'Z' || it in 'a'..'z' || it in '0'..'9' || it == '|' || it == ' ' }) return null
        // 접힌 모양(i도 l로 접는다)이 같아도 글자가 둘 이상 다르면 (우연히 비슷한 단어) 고치지 않는다.
        val diff = trimmed.indices.count { trimmed[it] != matchCase(canonical, trimmed)[it] }
        if (trimmed.length != canonical.length || diff > 2) return null
        return text.replace(trimmed, matchCase(canonical, trimmed))
    }

    /** 원래 글의 대소문자 모양(모두 대문자 · 모두 소문자 · 첫 글자만 대문자)을 사전 표기에 입힌다. */
    private fun matchCase(canonical: String, original: String): String {
        val letters = original.filter { it.isLetter() }
        return when {
            canonical.all { !it.isLetter() || it.isUpperCase() } -> canonical // OK
            letters.isNotEmpty() && letters.all { it.isUpperCase() } && letters.length >= 2 -> canonical.uppercase()
            letters.isNotEmpty() && letters.all { it.isLowerCase() } -> canonical.lowercase()
            else -> canonical
        }
    }

    private fun fixToken(line: String, m: MatchResult): String {
        val token = m.value
        if (embeddedInCode(line, m.range)) return token
        CONTRACTION.matchEntire(token)?.let { return "I" + token.substring(1) }
        val next = nextWord(line, m.range.last + 1)
        if ((token == "l" || token == "|") && next != null && next in AFTER_I) return "I"
        if (token == "lt" || token == "lt's") return itRule(line, m, token)
        return fixNumbers(token) ?: fixLetters(token) ?: token
    }

    private fun itRule(line: String, m: MatchResult, token: String): String {
        val before = line.substring(0, m.range.first).trimEnd()
        val sentenceStart = before.isEmpty() || before.last() in ".!?\"“"
        return (if (sentenceStart) "It" else "it") + token.substring(2)
    }

    /** 숫자로 시작해 숫자로 끝나는 낱말 속 O · l · I는 0 · 1이다 ("2O24" → "2024", "1OO0" → "1000"). */
    private fun fixNumbers(token: String): String? {
        if (token.length < 3 || token.any { it !in "0123456789OolI" }) return null
        if (!token.first().isDigit() || !token.last().isDigit() || token.none { it in "OolI" }) return null
        return token.map { if (it == 'O' || it == 'o') '0' else if (it == 'l' || it == 'I') '1' else it }.joinToString("")
    }

    /** 글자 사이에 낀 0 · 1 · 5 · |와 소문자 사이의 I를 고친다 ("He11o" → "Hello", "heIlo" → "hello"). */
    private fun fixLetters(token: String): String? {
        val letters = token.count { it.isLetter() }
        if (letters < 3) return null
        val sb = StringBuilder(token)
        var changed = false
        var i = 0
        while (i < token.length) {
            val c = token[i]
            if (c in "015|") {
                // 연달아 붙은 숫자(최대 2개)가 글자 사이에 끼어야 한다. 아니면(예: "mp3", "win10") 숫자 낱말이니 통째로 건드리지 않는다.
                var end = i
                while (end + 1 < token.length && token[end + 1] in "015|") end++
                val left = token.getOrNull(i - 1)
                val right = token.getOrNull(end + 1)
                if (end - i >= 2 || left?.isLetter() != true || right?.isLetter() != true) return null
                val lower = left.isLowerCase() && right.isLowerCase()
                val upper = left.isUpperCase() && right.isUpperCase()
                if (!lower && !upper) return null
                for (k in i..end) {
                    sb[k] = when (token[k]) {
                        '0' -> if (lower) 'o' else 'O'
                        '5' -> if (lower) 's' else 'S'
                        else -> if (lower) 'l' else 'I'
                    }
                }
                changed = true
                i = end + 1
                continue
            }
            if (c.isDigit()) return null
            val flanked = i in 1 until token.length - 1
            if (c == 'I' && token[0].isLowerCase() && flanked && token[i - 1].isLowerCase() && token[i + 1].isLowerCase()) {
                sb[i] = 'l'
                changed = true
            }
            i++
        }
        return if (changed) sb.toString() else null
    }

    /** 주소 · 메일 · 파일 이름 · 경로 · 해시태그의 한 조각이면 건드리지 않는다. */
    private fun embeddedInCode(line: String, range: IntRange): Boolean {
        fun at(i: Int): Char? = line.getOrNull(i)
        val prev = at(range.first - 1)
        val next = at(range.last + 1)
        if (prev != null && prev in "@/\\_#") return true
        if (next != null && next in "@/\\_") return true
        if (prev == '.' && at(range.first - 2)?.isLetterOrDigit() == true) return true
        if (next == '.' && at(range.last + 2)?.isLetterOrDigit() == true) return true
        return false
    }

    private fun nextWord(line: String, from: Int): String? {
        var i = from
        if (i >= line.length || line[i] != ' ') return null
        while (i < line.length && line[i] == ' ') i++
        val start = i
        while (i < line.length && line[i].isLetter()) i++
        return if (i > start) line.substring(start, i) else null
    }
}
