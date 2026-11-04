package com.example.translation_poc_app.translate

import com.example.translation_poc_app.data.settings.AiTone
import com.example.translation_poc_app.data.settings.GlossaryEntry
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.withTimeoutOrNull

/**
 * Gemma 도우미 옵션 (#176). 번역은 ML Kit이 하고, Gemma는 앞뒤에서 보조만 한다.
 * 번역 요청에 실려 캐시 키에도 들어가서, 설정을 바꾸면 이전 결과가 섞이지 않는다.
 */
data class AssistOptions(
    /** 번역 전에 OCR 글자 · 줄바꿈을 고친다. */
    val fixOcr: Boolean = false,
    /** 번역 뒤에 말투 · 용어집에 맞게 다듬는다. */
    val polish: Boolean = false,
    val tone: AiTone = AiTone.STANDARD,
    val glossary: List<GlossaryEntry> = emptyList(),
) {
    val enabled: Boolean get() = fixOcr || polish

    companion object {
        val NONE = AssistOptions()
    }
}

/**
 * Gemma로 글을 고치는 도우미 (#176). 모든 메서드는 실패해도 원래 글을 그대로 돌려준다:
 * 모델이 없거나, 실행이 실패하거나, 시간이 걸리거나, 답이 원문에서 너무 벗어나면 보정 없이 넘어간다.
 */
class GemmaAssist(
    private val runtime: GemmaRuntime,
    private val timeoutMs: Long = TIMEOUT_MS,
    /** 진단 로그 (debug 빌드에서만 켜서 넘긴다). 호출 시간 · 입력 · 모델 답 · 채택 여부. 기본은 아무것도 안 한다. */
    private val log: (String) -> Unit = {},
    private val clock: () -> Long = System::currentTimeMillis,
) {
    /** OCR 보정: 잘못 읽은 글자와 잘못 합쳐진(또는 쪼개진) 줄바꿈을 고친다. 번역하지 않는다. */
    suspend fun fixOcr(text: String, language: String): String {
        if (!canRun(text)) return skip("OCR 보정", text)
        val raw = run("OCR 보정", fixOcrPrompt(text, language)) ?: return text
        val fixed = acceptFix(text, raw)
        log("OCR 보정 ${if (fixed == text) "원문 유지" else "채택"}: ${show(text)} → ${show(raw)}" + if (fixed == text && raw.isNotBlank() && GemmaTranslationEngine.clean(raw) != text) " (거절: 길이 벗어남)" else "")
        return fixed
    }

    /** 번역 다듬기: 초벌 번역 [draft]를 원문과 단어 단위로 견주어 어색하거나 틀린 단어를 고치고, 말투 · 용어집에 맞춘다. */
    suspend fun polish(source: String, draft: String, targetLanguage: String, tone: AiTone, glossary: List<GlossaryEntry>): String {
        if (!canRun(draft) || !canRun(source)) return skip("번역 검토", draft)
        val terms = glossaryHits(source, glossary)
        val raw = run("번역 검토", polishPrompt(source, draft, GemmaTranslationEngine.languageName(targetLanguage), tone, terms)) ?: return draft
        val polished = applyCorrections(draft, raw, terms)
        log("번역 검토 ${if (polished == draft) "초벌 유지" else "채택"}: ${show(draft)} → ${show(raw)} (말투=$tone, 용어 ${terms.size}개)")
        return polished
    }

    private fun skip(step: String, text: String): String {
        log("$step 건너뜀 (모델 없음 · 빈 글 · ${MAX_CHARS}자 초과): ${show(text)}")
        return text
    }

    private fun show(s: String) = "\"" + s.replace("\n", "⏎").take(LOG_CHARS) + (if (s.length > LOG_CHARS) "…" else "") + "\""

    private fun canRun(text: String) =
        text.isNotBlank() && text.length <= MAX_CHARS && runtime.isModelReady()

    /** 시간 안에 못 끝나거나 실패하면 null. 취소는 그대로 던진다. */
    private suspend fun run(step: String, prompt: String): String? {
        val start = clock()
        val result = try {
            withTimeoutOrNull(timeoutMs) { runtime.generate(prompt) }.also {
                if (it == null) log("$step 시간 초과 (${timeoutMs}ms)")
            }
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            log("$step 실패: ${e.message ?: e::class.java.simpleName}")
            null
        } catch (e: OutOfMemoryError) {
            log("$step 실패: 메모리 부족")
            null
        }
        if (result != null) log("$step 모델 응답 ${clock() - start}ms (프롬프트 ${prompt.length}자, 답 ${result.length}자)")
        return result
    }

    companion object {
        /** 도우미 한 번의 제한 시간. 넘으면 보정 없이 원래 결과를 쓴다. */
        const val TIMEOUT_MS = 20_000L

        /** 로그에 찍는 글 길이 상한. */
        private const val LOG_CHARS = 120

        /** 고칠 것이 없을 때 모델이 이 한 단어만 답하게 한다 (전체를 되풀이해 쓰는 시간을 아낀다). */
        internal const val OK_REPLY = "OK"

        /** 모델이 "고칠 것 없음"으로 답했는가 (OK, ok., "OK" 등). */
        internal fun isOkReply(cleaned: String) =
            cleaned.trim().trim('"', '\'', '.', '!', ' ').equals(OK_REPLY, ignoreCase = true)

        /** 이보다 긴 글은 보정하지 않는다 (모델 토큰 한도 안에서 입력 + 출력을 담기 위해). */
        const val MAX_CHARS = 400

        /** 프롬프트를 바꾸면 올린다. */
        const val PROMPT_VERSION = 1

        internal fun fixOcrPrompt(text: String, language: String): String {
            val lang = if (language == AUTO_LANGUAGE || language == "und") "the original language" else GemmaTranslationEngine.languageName(language)
            return "<start_of_turn>user\n" +
                "The text below was read from a phone screenshot by OCR. It is written in $lang. " +
                "Fix only clear OCR mistakes: wrongly recognized characters (for example 0/O, 1/l/I, rn/m), " +
                "stray symbols, and line breaks that were wrongly joined or split. " +
                "Keep the same language. Do not translate, summarize, add or remove content. " +
                "If the text already looks correct, reply with exactly: $OK_REPLY. Otherwise reply with the corrected text only.\n\n" +
                "Text:\n$text<end_of_turn>\n<start_of_turn>model\n"
        }

        internal fun polishPrompt(
            source: String,
            draft: String,
            targetName: String,
            tone: AiTone,
            terms: List<GlossaryEntry>,
        ): String {
            val sb = StringBuilder(
                "Below is a source text and its draft translation into $targetName. " +
                    "Check the draft word by word against the source. " +
                    "List only the words or phrases of the draft that are mistranslated, missing or unnatural, " +
                    "one per line, in the form: wrong => right. " +
                    "Copy each wrong word exactly as it appears in the draft. At most $MAX_CORRECTIONS lines. " +
                    "If nothing needs to change, reply with exactly: $OK_REPLY. No other text.",
            )
            when (tone) {
                AiTone.STANDARD -> Unit
                AiTone.FORMAL -> sb.append(" Also fix words so the speech level is polite and formal (for example 존댓말 in Korean, 敬語 in Japanese).")
                AiTone.INFORMAL -> sb.append(" Also fix words so the speech level is casual and informal (for example 반말 in Korean, タメ口 in Japanese).")
            }
            if (terms.isNotEmpty()) {
                sb.append(" These terms must be translated exactly like this:")
                terms.forEach { sb.append("\n- ").append(it.source).append(" => ").append(it.target) }
            }
            sb.append("\n\nSource:\n").append(source).append("\n\nDraft:\n").append(draft)
            sb.append("<end_of_turn>\n<start_of_turn>model\n")
            return "<start_of_turn>user\n$sb"
        }

        /** 이 글에 나오는 용어집 항목만. */
        internal fun glossaryHits(source: String, glossary: List<GlossaryEntry>): List<GlossaryEntry> {
            val lowered = source.lowercase()
            return glossary.filter { lowered.contains(it.source.lowercase()) }
        }

        private fun visibleLength(s: String) = s.count { !it.isWhitespace() }

        /** OCR 보정 결과 검사: 비었거나 길이가 크게 달라졌으면(번역 · 요약 · 군더더기) 원문을 쓴다. */
        internal fun acceptFix(original: String, raw: String): String {
            val fixed = GemmaTranslationEngine.clean(raw)
            if (fixed.isBlank() || isOkReply(fixed)) return original
            val before = visibleLength(original).coerceAtLeast(1)
            val ratio = visibleLength(fixed).toDouble() / before
            return if (ratio in 0.8..1.25) fixed else original
        }

        /** 한 번에 고칠 수 있는 단어 쌍의 수. */
        const val MAX_CORRECTIONS = 8

        private val ARROWS = listOf("=>", "->", "→", "⇒")

        /**
         * 모델이 답한 `틀린 단어 => 고친 단어` 줄을 초벌 번역에 직접 적용한다. 번역문을 통째로 받지 않으니 짧게 끝나고,
         * 앱이 초벌에 실제로 있는 단어만 바꾸므로 모델이 문장을 멋대로 바꿀 수 없다. 적용할 것이 없으면 초벌 그대로.
         * 건너뛰는 쌍: 초벌에 없는 단어, 같은 값, 지나치게 긴 바꿈, 용어집 번역어를 없애는 바꿈.
         */
        internal fun applyCorrections(draft: String, raw: String, terms: List<GlossaryEntry>): String {
            val cleaned = GemmaTranslationEngine.clean(raw)
            if (cleaned.isBlank() || isOkReply(cleaned)) return draft
            var result = draft
            var applied = 0
            for (line in cleaned.lines()) {
                if (applied >= MAX_CORRECTIONS) break
                val arrow = ARROWS.firstOrNull { line.contains(it) } ?: continue
                val old = unwrap(line.substringBefore(arrow))
                val new = unwrap(line.substringAfter(arrow))
                if (old.isEmpty() || new.isEmpty() || old == new) continue
                if (!result.contains(old)) continue
                if (new.length > old.length * 3 + 10) continue
                if (terms.any { result.contains(it.target) && old.contains(it.target) && !new.contains(it.target) }) continue
                result = result.replace(old, new)
                applied++
            }
            return result
        }

        /** 줄머리 기호(-, *, 번호)와 감싼 따옴표를 걷는다. */
        private fun unwrap(s: String): String =
            s.trim().trimStart('-', '*', '•', ' ').replace(Regex("^\\d+[.)]\\s*"), "").trim().trim('"', '\'', '`', '“', '”', '「', '」').trim()
    }
}

/**
 * 번역 엔진을 감싸서 Gemma 도우미를 앞뒤에 붙인다 (#176). 요청의 [TranslationRequest.assist]가 꺼져 있으면 그대로 넘긴다.
 * 다듬기는 ML Kit이 번역한 결과에만 한다: AI 엔진은 말투 · 용어집을 이미 따르기 때문이다.
 */
class GemmaAssistedEngine(
    private val inner: TranslationEngine,
    private val assist: GemmaAssist,
) : TranslationEngine by inner {

    override suspend fun translate(request: TranslationRequest): EngineResult<TranslationResult> {
        val options = request.assist
        if (!options.enabled) return inner.translate(request)
        val text = if (options.fixOcr) assist.fixOcr(request.text, request.source) else request.text
        val result = inner.translate(request.copy(text = text))
        if (!options.polish || result !is EngineResult.Ok || result.value.engine != EngineId.ML_KIT) return result
        val polished = assist.polish(text, result.value.text, request.target, options.tone, options.glossary)
        return EngineResult.Ok(result.value.copy(text = polished))
    }
}
