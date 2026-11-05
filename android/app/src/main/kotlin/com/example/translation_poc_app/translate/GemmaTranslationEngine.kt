package com.example.translation_poc_app.translate

import kotlinx.coroutines.CancellationException

/**
 * Gemma 온디바이스 번역 엔진 (#174). 키 · 인터넷 없이 기기 안에서 돈다.
 * 모델을 아직 받지 않았으면 [TranslationError.ModelNotDownloaded]를 돌려주고, 실행이 실패하면 [TranslationError.Unavailable]로 돌려준다
 * (다음 엔진으로 넘기는 것은 [FallbackTranslationEngine]).
 * 컨텍스트가 작은 모델이라 긴 글은 [chunk]로 잘라 차례로 번역한다.
 */
class GemmaTranslationEngine(
    private val runtime: GemmaRuntime,
) : TranslationEngine {

    override val id = EngineId.GEMMA

    override fun supports(language: String) = language.isNotBlank()

    override suspend fun translate(request: TranslationRequest): EngineResult<TranslationResult> {
        if (request.text.isBlank() || request.source == request.target) {
            return EngineResult.Ok(TranslationResult(request.text, request.source, request.target, id))
        }
        if (!runtime.isModelReady()) return EngineResult.Err(TranslationError.ModelNotDownloaded(listOf(MODEL_LABEL)))
        return try {
            // 작은 모델은 "en → ko" 같은 코드를 놓치고 영어로 답하기 쉬워서 언어 이름을 풀어 쓴다.
            val from = if (request.source == AUTO_LANGUAGE) "the source language (detect it)" else languageName(request.source)
            val targetName = languageName(request.target)
            val system = GeminiTranslationEngine.systemPrompt(request.copy(target = targetName), from)
            val parts = chunk(request.text).map { piece ->
                clean(runtime.generate(buildPrompt(system, piece, targetName)))
            }
            val translated = parts.joinToString("\n").trim()
            if (translated.isEmpty()) {
                EngineResult.Err(TranslationError.Unknown("빈 응답"))
            } else {
                EngineResult.Ok(TranslationResult(translated, request.source, request.target, id))
            }
        } catch (e: CancellationException) {
            throw e
        } catch (e: OutOfMemoryError) {
            EngineResult.Err(TranslationError.Unavailable("메모리 부족"))
        } catch (e: Exception) {
            EngineResult.Err(TranslationError.Unavailable(e.message))
        }
    }

    override suspend fun isLanguageAvailable(language: String): EngineResult<Boolean> = EngineResult.Ok(true)

    override suspend fun downloadLanguage(language: String, policy: ModelDownloadPolicy): EngineResult<Unit> =
        EngineResult.Ok(Unit)

    override suspend fun deleteLanguage(language: String): EngineResult<Unit> = EngineResult.Ok(Unit)

    override fun close() = Unit

    companion object {
        const val MODEL_LABEL = "gemma"

        /** 프롬프트를 바꾸면 올린다 (캐시 키에 넣을 값). */
        const val PROMPT_VERSION = 2

        /** 한 번에 보내는 글자 수 상한. 입력 + 출력이 모델 토큰 한도(1024) 안에 들어오게 넉넉히 잡았다. */
        const val MAX_CHUNK_CHARS = 500

        /** 언어 코드 → 영어 이름 (ko → Korean). 모르는 코드는 그대로. */
        internal fun languageName(code: String): String {
            val name = java.util.Locale.forLanguageTag(code).getDisplayLanguage(java.util.Locale.ENGLISH)
            return name.takeIf { it.isNotBlank() } ?: code
        }

        /**
         * Gemma 대화 형식. 시스템 지시는 따로 없어 사용자 턴 맨 앞에 넣는다.
         * 작은 모델은 텍스트 뒤에 붙은 지시문을 번역 결과로 따라 쓰므로, 지시는 텍스트 앞에만 두고 텍스트로 끝낸다.
         */
        internal fun buildPrompt(system: String, text: String, targetName: String): String =
            "<start_of_turn>user\n$system Output only the $targetName translation.\n\nText:\n$text" +
                "<end_of_turn>\n<start_of_turn>model\n"

        /** 줄 단위로 모아 [maxChars] 안으로 자른다. 한 줄이 더 길면 문장 끝에서, 그래도 길면 글자 수로 자른다. */
        internal fun chunk(text: String, maxChars: Int = MAX_CHUNK_CHARS): List<String> {
            val pieces = mutableListOf<String>()
            val current = StringBuilder()
            fun flush() {
                if (current.isNotBlank()) pieces += current.toString().trimEnd()
                current.clear()
            }
            for (line in text.lines()) {
                for (part in splitLong(line, maxChars)) {
                    if (current.isNotEmpty() && current.length + part.length + 1 > maxChars) flush()
                    if (current.isNotEmpty()) current.append('\n')
                    current.append(part)
                }
            }
            flush()
            return pieces
        }

        private fun splitLong(line: String, maxChars: Int): List<String> {
            if (line.length <= maxChars) return listOf(line)
            val out = mutableListOf<String>()
            var rest = line
            while (rest.length > maxChars) {
                val window = rest.substring(0, maxChars)
                val cut = window.lastIndexOfAny(charArrayOf('.', '!', '?', '。', '！', '？', ' ')).let {
                    if (it < maxChars / 3) maxChars else it + 1
                }
                out += rest.substring(0, cut).trim()
                rest = rest.substring(cut).trimStart()
            }
            if (rest.isNotBlank()) out += rest
            return out
        }

        /** 모델이 덧붙이는 종료 표식 · 머리말 · 감싼 따옴표를 걷어낸다. */
        internal fun clean(raw: String): String {
            var s = raw.replace("<end_of_turn>", "").replace("<start_of_turn>", "").trim()
            s = s.replace(Regex("^(translation|번역)\\s*[:：]\\s*", RegexOption.IGNORE_CASE), "")
            if (s.length >= 2 && ((s.first() == '"' && s.last() == '"') || (s.first() == '“' && s.last() == '”'))) {
                s = s.substring(1, s.length - 1)
            }
            return stripEchoedInstruction(s).trim()
        }

        /** 예전 프롬프트의 끝 지시문이나 그 비슷한 문장이 번역에 섞여 나오면 그 줄을 지운다. */
        private val ECHOED_INSTRUCTION = Regex(
            "(now write only|do not repeat the original|output only the .* translation|translation of the text above)",
            RegexOption.IGNORE_CASE,
        )

        internal fun stripEchoedInstruction(s: String): String =
            s.lines().filterNot { ECHOED_INSTRUCTION.containsMatchIn(it) }.joinToString("\n")
    }
}
