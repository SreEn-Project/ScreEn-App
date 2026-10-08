package com.example.translation_poc_app.translate

import java.io.IOException
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import org.json.JSONObject

/** AI가 알려 준 단어 풀이 (AD-02). 비어 있는 항목은 null. */
data class WordDefinition(
    val meaning: String?,
    val pronunciation: String?,
    val partOfSpeech: String?,
    /** 주변 문장 기준 뜻. 문장이 없으면 null. */
    val contextMeaning: String?,
)

/** 단어 풀이를 해 주는 AI (AD-02). 키가 없거나 실패하면 [EngineResult.Err]. 테스트에서 바꿔 끼운다. */
fun interface WordDictionary {
    suspend fun define(word: String, sentence: String?, source: String, target: String): EngineResult<WordDefinition>
}

/** 사전 카드(X-01)에 보여 줄 내용 (AD-02). */
data class WordEntry(
    val word: String,
    /** ML Kit 등 번역 엔진이 준 번역. 단어 저장 때 뜻이 없으면 이 값을 쓴다. */
    val translation: String,
    val definition: WordDefinition?,
    /** AI 풀이를 받지 못한 이유 (AI를 쓰지 않으면 null). 번역만 보여 주는 이유를 알릴 때 쓴다. */
    val aiError: TranslationError?,
    val sentence: String?,
    val sourceLanguage: String,
    val targetLanguage: String,
) {
    /** 단어장에 저장할 뜻: AI 뜻이 있으면 그것, 없으면 번역. */
    val savedMeaning: String get() = definition?.meaning ?: translation
}

sealed interface WordLookupOutcome {
    data class Found(val entry: WordEntry) : WordLookupOutcome

    /** 번역도 풀이도 못 얻었다. @param error 번역 엔진이 알려 준 이유. */
    data class Failed(val error: TranslationError?) : WordLookupOutcome
}

/**
 * 선택한 단어의 사전 카드 내용을 만든다 (AD-02): 번역 엔진(ML Kit)으로 번역하고, [dictionary](AI 엔진일 때만)로
 * 뜻 · 발음 · 품사 · 문맥 뜻을 받는다. 둘은 동시에 요청한다. AI가 실패해도 번역은 보여 준다.
 * 안드로이드 의존이 없어 단위 테스트할 수 있다.
 */
class WordLookup(
    private val translator: TranslationEngine,
    private val dictionary: WordDictionary?,
) {
    suspend fun lookup(word: String, sentence: String?, sourceLanguage: String, targetLanguage: String): WordLookupOutcome {
        val clean = word.trim()
        if (clean.isEmpty()) return WordLookupOutcome.Failed(null)
        val context = sentence?.trim()?.takeIf { it.isNotEmpty() }
        val source = sourceLanguage.ifBlank { AUTO_LANGUAGE }
        return coroutineScope {
            val translation = async { translator.translate(TranslationRequest(clean, source, targetLanguage)) }
            val definition = dictionary?.let { async { it.define(clean, context, source, targetLanguage) } }
            val translated = translation.await()
            val defined = definition?.await()
            val definitionValue = (defined as? EngineResult.Ok)?.value
            val aiError = (defined as? EngineResult.Err)?.error
            val text = (translated as? EngineResult.Ok)?.value?.text?.trim()?.takeIf { it.isNotEmpty() }
                // 번역 엔진이 실패해도 AI 뜻이 있으면 그것으로 카드를 만든다.
                ?: definitionValue?.meaning
            if (text == null) {
                WordLookupOutcome.Failed((translated as? EngineResult.Err)?.error ?: aiError)
            } else {
                val resolvedSource = (translated as? EngineResult.Ok)?.value?.sourceLanguage ?: source
                WordLookupOutcome.Found(
                    WordEntry(clean, text, definitionValue, aiError, context, resolvedSource, targetLanguage),
                )
            }
        }
    }
}

/** Gemini로 단어 풀이를 받는다 (AD-02). 번역과 같은 키 · 모델 · 전송을 쓴다. */
class GeminiDictionary(
    private val keys: ApiKeyProvider,
    private val transport: GeminiTransport = GeminiHttpTransport(),
    private val models: List<String> = GeminiTranslationEngine.MODELS,
) : WordDictionary {

    override suspend fun define(word: String, sentence: String?, source: String, target: String): EngineResult<WordDefinition> =
        try {
            val key = keys.key()?.takeIf { it.isNotBlank() }
                ?: return EngineResult.Err(TranslationError.NoApiKey)
            val response = generateWithFallback(transport, key, models, buildBody(word, sentence, source, target))
            parse(response)?.let { EngineResult.Ok(it) }
                ?: EngineResult.Err(TranslationError.Unknown("풀이를 읽지 못함"))
        } catch (e: CancellationException) {
            throw e
        } catch (e: GeminiHttpException) {
            EngineResult.Err(
                when {
                    e.code == 429 || e.code >= 500 -> TranslationError.ServiceBusy
                    e.message?.contains("API_KEY_INVALID") == true || e.message?.contains("API key not valid") == true ->
                        TranslationError.InvalidApiKey
                    e.code == 403 -> TranslationError.AccessDenied
                    else -> TranslationError.Unknown(e.message)
                },
            )
        } catch (e: IOException) {
            EngineResult.Err(TranslationError.Network)
        } catch (e: Exception) {
            EngineResult.Err(TranslationError.Unknown(e.message))
        }

    companion object {
        internal fun systemPrompt(source: String, target: String): String {
            val from = if (source == AUTO_LANGUAGE) "the word's own language (detect it)" else source
            return "You are a bilingual dictionary. Explain one word for a language learner. " +
                "The word is in $from; write every field in $target. " +
                "Reply with a single JSON object and nothing else, with these string fields: " +
                "\"meaning\" (short dictionary meaning), " +
                "\"pronunciation\" (IPA, or the reading for Japanese/Chinese; empty if not applicable), " +
                "\"partOfSpeech\" (short, for example noun or verb), " +
                "\"contextMeaning\" (the meaning in the given sentence; empty if no sentence is given)."
        }

        internal fun userPrompt(word: String, sentence: String?): String = buildString {
            append("Word: ").append(word)
            if (!sentence.isNullOrBlank()) append("\nSentence: ").append(sentence)
        }

        internal fun buildBody(word: String, sentence: String?, source: String, target: String): String {
            val system = systemPrompt(source, target)
            val user = userPrompt(word, sentence)
            return JSONObject()
                .put(
                    "systemInstruction",
                    JSONObject().put("parts", org.json.JSONArray().put(JSONObject().put("text", system))),
                )
                .put(
                    "contents",
                    org.json.JSONArray().put(
                        JSONObject().put("parts", org.json.JSONArray().put(JSONObject().put("text", user))),
                    ),
                )
                .put(
                    "generationConfig",
                    JSONObject().put("temperature", 0).put("responseMimeType", "application/json"),
                )
                .toString()
        }

        /** 응답 → 풀이. 코드 펜스(```json)가 붙어 와도 읽는다. 뜻이 하나도 없으면 null. */
        internal fun parse(response: String): WordDefinition? {
            val text = GeminiTranslationEngine.parse(response) ?: return null
            return parseText(text)
        }

        /** 모델이 쓴 글 → 풀이. [parse]와 Groq가 같이 쓴다. */
        internal fun parseText(text: String): WordDefinition? {
            val json = runCatching { JSONObject(stripFence(text)) }.getOrNull() ?: return null
            val definition = WordDefinition(
                meaning = json.field("meaning"),
                pronunciation = json.field("pronunciation"),
                partOfSpeech = json.field("partOfSpeech"),
                contextMeaning = json.field("contextMeaning"),
            )
            return definition.takeIf { it.meaning != null || it.contextMeaning != null }
        }

        private fun stripFence(text: String): String =
            text.trim().removePrefix("```json").removePrefix("```").removeSuffix("```").trim()

        private fun JSONObject.field(name: String): String? = optString(name, "").trim().takeIf { it.isNotEmpty() }
    }
}

/** Groq로 단어 풀이를 받는다 (AD-02). 번역과 같은 키 · 모델 · 전송을 쓰고, 지시문은 [GeminiDictionary]와 같다. */
class GroqDictionary(
    private val keys: ApiKeyProvider,
    private val transport: GroqTransport = GroqHttpTransport(),
    private val models: List<String> = GroqTranslationEngine.MODELS,
) : WordDictionary {

    override suspend fun define(word: String, sentence: String?, source: String, target: String): EngineResult<WordDefinition> =
        try {
            val key = keys.key()?.takeIf { it.isNotBlank() }
                ?: return EngineResult.Err(TranslationError.NoApiKey)
            val response = chatWithFallback(transport, key, models) { buildBody(word, sentence, source, target, it) }
            parse(response)?.let { EngineResult.Ok(it) }
                ?: EngineResult.Err(TranslationError.Unknown("풀이를 읽지 못함"))
        } catch (e: CancellationException) {
            throw e
        } catch (e: GroqHttpException) {
            EngineResult.Err(GroqTranslationEngine.classify(e))
        } catch (e: IOException) {
            EngineResult.Err(TranslationError.Network)
        } catch (e: Exception) {
            EngineResult.Err(TranslationError.Unknown(e.message))
        }

    companion object {
        internal fun buildBody(word: String, sentence: String?, source: String, target: String, model: String): String =
            GroqTranslationEngine.chatBody(
                model,
                GeminiDictionary.systemPrompt(source, target),
                GeminiDictionary.userPrompt(word, sentence),
                json = true,
            )

        internal fun parse(response: String): WordDefinition? =
            GroqTranslationEngine.parse(response)?.let { GeminiDictionary.parseText(it) }
    }
}
