package com.example.translation_poc_app.translate

import kotlinx.coroutines.CancellationException

/**
 * AI가 번역문 대신 대답 문장("번역해 드릴게요"), 프롬프트 지시문, 원문 되풀이를 내놓았는지 거른다.
 * 순수 로직이라 Android 없이 시험할 수 있다. 걸러진 결과는 버리고 다음 엔진(마지막은 ML Kit)이 맡는다.
 */
object AiResponseGuard {

    /** 프롬프트 지시문이나 대답투가 그대로 나온 문장. */
    private val CHATTER = Regex(
        "(do not repeat|output only|reply with the translation|translation of the text|here is the translation|here's the translation" +
            "|sure[,!]? (here|i)|certainly[,!]|i('| a)?m sorry|as an ai|source language \\(detect" +
            "|번역해 드(리|릴)|번역해드(리|릴)|번역 결과는|번역은 다음과 같|다음은 번역|아래는 번역|물론이죠|죄송합니다" +
            "|翻訳します|翻訳は以下|以下が翻訳|翻译如下|以下是翻译)",
        RegexOption.IGNORE_CASE,
    )

    private val SCRIPT_BY_TARGET: Map<String, (Char) -> Boolean> = mapOf(
        "ko" to { c -> c in '가'..'힣' || c in 'ᄀ'..'ᇿ' || c in '㄰'..'㆏' },
        "ja" to { c -> c in '぀'..'ヿ' || c in '一'..'鿿' },
        "zh" to { c -> c in '一'..'鿿' },
    )

    /**
     * 원문 줄을 그대로 다시 보여 준 줄을 지운다 ("문장을 다시 보여주고 그 밑에 번역"). 지우고 나서 남는 게 없으면 그대로 둔다.
     * 한 줄짜리 원문이 번역에 그대로 들어 있고 번역이 더 길면 그 부분만 걷어낸다.
     */
    fun stripEchoedSource(source: String, translated: String): String {
        val srcLines = source.lines().map { it.trim() }.filter { it.length >= 4 }.toSet()
        if (srcLines.isEmpty()) return translated
        val lines = translated.lines()
        val kept = lines.filterNot { it.trim() in srcLines }
        if (kept.isNotEmpty() && kept.size < lines.size) return kept.joinToString("\n").trim()
        val one = source.trim()
        if (lines.size == 1 && one.length >= 8 && translated.length > one.length && translated.contains(one)) {
            val rest = translated.replace(one, "").trim().trim('-', '–', '—', ':', '/', '|', '(', ')', ' ')
            if (rest.isNotEmpty()) return rest
        }
        return translated
    }

    /** [translated]가 [source]를 [target] 언어로 옮긴 번역문으로 믿을 만한가. 짧은 글은 너무 엄격하지 않게 본다. */
    fun isPlausible(source: String, translated: String, target: String): Boolean {
        val out = translated.trim()
        if (out.isEmpty()) return false
        if (CHATTER.containsMatchIn(out) && !CHATTER.containsMatchIn(source)) return false
        val src = source.trim()
        // 너무 길거나(대답을 덧붙임) 너무 짧다(일부만 번역).
        if (out.length > src.length * 6 + 40) return false
        if (src.length >= 30 && out.length < src.length / 8) return false
        // 대상 언어 글자가 아예 없으면 번역이 아니다 (한 · 일 · 중 대상만 확인).
        val inScript = SCRIPT_BY_TARGET[target.substringBefore('-').lowercase()]
        if (inScript != null && out.count { it.isLetter() } >= 8 && out.none(inScript)) return false
        // 긴 글인데 원문과 똑같다 → 번역하지 않고 되돌려 준 것.
        if (src.length >= 20 && out.equals(src, ignoreCase = true)) return false
        return true
    }
}

/**
 * [inner] 엔진의 결과를 [AiResponseGuard]로 검사한다. 이상하면 [TranslationError.Unavailable]을 돌려줘
 * [FallbackTranslationEngine]이 다음 엔진 · ML Kit 결과로 대신하게 한다.
 */
class GuardedTranslationEngine(private val inner: TranslationEngine) : TranslationEngine by inner {

    override suspend fun translate(request: TranslationRequest): EngineResult<TranslationResult> =
        check(request, inner.translate(request))

    override val prefersBatch get() = inner.prefersBatch

    override suspend fun translateBatch(requests: List<TranslationRequest>): List<EngineResult<TranslationResult>> =
        inner.translateBatch(requests).mapIndexed { i, r -> check(requests[i], r) }

    private fun check(request: TranslationRequest, result: EngineResult<TranslationResult>): EngineResult<TranslationResult> {
        if (result !is EngineResult.Ok) return result
        val cleaned = AiResponseGuard.stripEchoedSource(request.text, result.value.text)
        return if (AiResponseGuard.isPlausible(request.text, cleaned, request.target)) {
            EngineResult.Ok(result.value.copy(text = cleaned))
        } else {
            EngineResult.Err(TranslationError.Unavailable("번역문이 아닌 응답"))
        }
    }
}
