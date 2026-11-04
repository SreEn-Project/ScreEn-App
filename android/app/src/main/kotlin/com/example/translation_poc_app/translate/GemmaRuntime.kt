package com.example.translation_poc_app.translate

import android.content.Context
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession
import java.io.Closeable
import java.io.File
import java.util.concurrent.Executors
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.asCoroutineDispatcher
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext

/** 문장 하나를 돌려주는 LLM 실행기. 테스트에서 가짜로 바꿔 끼운다. 호출은 [GemmaRuntime]이 한 번에 하나씩만 보낸다. */
interface LlmRunner : Closeable {
    /** 막히는 호출. 실패는 예외로 던진다. */
    fun generate(prompt: String): String
}

/** MediaPipe LLM Inference(`tasks-genai`)로 Gemma `.task` 모델을 돌린다 (#174). */
class MediaPipeLlmRunner(context: Context, modelFile: File) : LlmRunner {
    private val llm: LlmInference = LlmInference.createFromOptions(
        context.applicationContext,
        LlmInference.LlmInferenceOptions.builder()
            .setModelPath(modelFile.absolutePath)
            .setMaxTokens(MAX_TOKENS)
            .setMaxTopK(TOP_K)
            .build(),
    )

    /** 요청마다 새 세션을 만들어 앞선 번역의 문맥이 섞이지 않게 한다. 번역이라 무작위성은 낮춘다. */
    override fun generate(prompt: String): String {
        val options = LlmInferenceSession.LlmInferenceSessionOptions.builder()
            .setTopK(TOP_K)
            .setTemperature(TEMPERATURE)
            .build()
        return LlmInferenceSession.createFromOptions(llm, options).use { session ->
            session.addQueryChunk(prompt)
            session.generateResponse()
        }
    }

    override fun close() = llm.close()

    companion object {
        /** 입력 + 출력 토큰 합계 한도. 긴 글은 [GemmaTranslationEngine]이 잘라서 보낸다. */
        const val MAX_TOKENS = 1024
        const val TOP_K = 1
        const val TEMPERATURE = 0.1f
    }
}

/**
 * Gemma 실행기를 프로세스에서 하나만 두고 쓴다 (#174). 모델을 올리는 데 수 초 · 수백 MB가 들어서
 * 번역 때마다 만들지 않고, [idleMs] 동안 쓰지 않으면 내려서 메모리를 돌려준다.
 * 번역은 블록마다 동시에 요청되지만 실행은 한 번에 하나씩 순서대로 한다.
 */
class GemmaRuntime(
    private val modelFile: () -> File,
    private val isReady: () -> Boolean,
    private val createRunner: (File) -> LlmRunner,
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Default),
    private val idleMs: Long = IDLE_UNLOAD_MS,
) {
    private val mutex = Mutex()
    private val dispatcher = Executors.newSingleThreadExecutor { r -> Thread(r, "gemma-llm").also { it.isDaemon = true } }.asCoroutineDispatcher()
    private var runner: LlmRunner? = null
    private var idleJob: Job? = null

    fun isModelReady(): Boolean = isReady()

    suspend fun generate(prompt: String): String = mutex.withLock {
        idleJob?.cancel()
        try {
            withContext(dispatcher) {
                val r = runner ?: createRunner(modelFile()).also { runner = it }
                r.generate(prompt)
            }
        } finally {
            idleJob = scope.launch {
                delay(idleMs)
                unload()
            }
        }
    }

    /** 모델을 미리 올려 둔다 — 첫 호출이 로딩을 기다리지 않게. 모델이 없거나 실패하면 조용히 넘어간다. */
    suspend fun warmUp() {
        if (!isReady()) return
        mutex.withLock {
            idleJob?.cancel()
            try {
                withContext(dispatcher) {
                    if (runner == null) runner = createRunner(modelFile())
                }
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                // 번역할 때 다시 시도한다.
            } finally {
                idleJob = scope.launch {
                    delay(idleMs)
                    unload()
                }
            }
        }
    }

    /** 모델을 메모리에서 내린다. 파일은 그대로. 모델 파일을 지우기 전에도 부른다. */
    suspend fun unload() = mutex.withLock {
        withContext(dispatcher) {
            runner?.close()
            runner = null
        }
    }

    companion object {
        const val IDLE_UNLOAD_MS = 5 * 60 * 1000L
    }
}
