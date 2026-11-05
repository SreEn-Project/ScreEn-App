package com.example.translation_poc_app.service

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.ServiceInfo
import android.content.res.Configuration
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.ServiceCompat
import androidx.core.content.IntentCompat
import androidx.lifecycle.LifecycleService
import androidx.lifecycle.lifecycleScope
import com.example.translation_poc_app.capture.CaptureResult
import com.example.translation_poc_app.capture.ScreenCapturer
import com.example.translation_poc_app.ocr.OcrResult
import com.example.translation_poc_app.ocr.ScreenTextRecognizer
import com.example.translation_poc_app.AppGraph
import com.example.translation_poc_app.R
import com.example.translation_poc_app.data.settings.Engine
import com.example.translation_poc_app.data.settings.Settings
import com.example.translation_poc_app.overlay.OverlayController
import com.example.translation_poc_app.overlay.OverlayToast
import com.example.translation_poc_app.overlay.ToastKind
import com.example.translation_poc_app.overlay.WordTarget
import com.example.translation_poc_app.translate.DetectedBlock
import com.example.translation_poc_app.translate.LanguageDetector
import com.example.translation_poc_app.translate.ApiKeyProvider
import com.example.translation_poc_app.translate.FallbackTranslationEngine
import com.example.translation_poc_app.translate.GeminiDictionary
import com.example.translation_poc_app.translate.WordLookup
import com.example.translation_poc_app.translate.WordLookupOutcome
import com.example.translation_poc_app.translate.GeminiTranslationEngine
import com.example.translation_poc_app.translate.GemmaAssist
import com.example.translation_poc_app.translate.GemmaAssistedEngine
import com.example.translation_poc_app.translate.GemmaTranslationEngine
import com.example.translation_poc_app.translate.GroqDictionary
import com.example.translation_poc_app.translate.GroqTranslationEngine
import com.example.translation_poc_app.translate.MlKitTranslationEngine
import com.example.translation_poc_app.translate.ModelDownloadPolicy
import com.example.translation_poc_app.translate.TranslationEngine
import com.example.translation_poc_app.translate.TranslationError
import com.example.translation_poc_app.translate.TranslationOutcome
import com.example.translation_poc_app.translate.TranslationPipeline
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

/**
 * 번역 포그라운드 서비스 (NA-02). Flutter 엔진 없이 독립적으로 돈다.
 * 화면 캡처 동의 결과로만 시작하며([CaptureConsentActivity]), MediaProjection 세션을 가진다.
 * 캡처(NA-05) · 오버레이(NA-18, NA-19)는 이 서비스 안에 붙인다.
 */
class TranslatorService : LifecycleService() {

    private var projection: MediaProjection? = null
    private var capturer: ScreenCapturer? = null
    private val textRecognizer by lazy { ScreenTextRecognizer() }
    private val languageDetector by lazy { LanguageDetector() }
    private var overlay: OverlayController? = null

    /** 시스템 Toast 대신 오버레이 토스트 (design.md "오버레이"). */
    private val toast by lazy { OverlayToast(this) }
    private var mlKitEngine: MlKitTranslationEngine? = null

    /** 플로팅 버튼 한 번 = 캡처 → 문자 인식 → 언어 감지 → 번역 (NA-18 → NA-19). */
    private val pipeline by lazy {
        TranslationPipeline(
            capture = {
                // 버튼을 숨긴 뒤의 화면을 찍는다.
                capturer?.awaitFreshFrame()
                captureFrame()
            },
            recognize = { frame, incremental ->
                val source = AppGraph.settingsRepository(this).current().sourceLanguage
                recognizeText(frame, source.takeIf { it != Settings.SOURCE_LANGUAGE_AUTO }, incremental)
            },
            detect = { ocr, target -> languageDetector.detect(ocr.blocks, target) },
            engineFor = { translationEngine(it) },
            settings = { AppGraph.settingsRepository(this).current() },
            onTimings = { Log.i(TAG, "번역 시간 $it total=${it.total}ms") },
            log = { Log.i(TAG, it) },
        )
    }

    private val projectionCallback = object : MediaProjection.Callback() {
        // 사용자가 시스템 UI(상태 표시줄 칩 등)에서 공유를 끄면 서비스도 멈춘다 (NA-04).
        override fun onStop() {
            Log.i(TAG, "시스템이 화면 공유를 끝냈다 → 서비스 종료")
            stopSelf()
        }

        // 캡처 대상 크기가 바뀌면(회전 등, Android 14+) 캡처 크기도 맞춘다.
        override fun onCapturedContentResize(width: Int, height: Int) {
            capturer?.resize(width, height)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        when (intent?.action) {
            ACTION_START -> handleStart(intent)
            ACTION_STOP -> stopSelf()
            ACTION_DEBUG_CAPTURE -> debugCapture()
            // 시스템이 다시 살린 경우(동의 토큰 없음)는 이어갈 수 없으니 멈춘다. 이미 도는 중이면 모르는 명령은 무시한다.
            else -> if (TranslatorServiceState.state.value != RunState.RUNNING) stopSelf()
        }
        // 동의 토큰은 한 번만 쓸 수 있어 재시작해도 이어갈 수 없다.
        return START_NOT_STICKY
    }

    private fun handleStart(intent: Intent) {
        val resultCode = intent.getIntExtra(EXTRA_RESULT_CODE, Activity.RESULT_CANCELED)
        val data = IntentCompat.getParcelableExtra(intent, EXTRA_DATA, Intent::class.java)
        if (data == null) {
            fail("캡처 동의 데이터 없음")
            return
        }

        ServiceNotification.ensureChannel(this)
        // mediaProjection 유형으로 먼저 포그라운드가 된 뒤에 MediaProjection을 얻어야 한다 (Android 14+).
        try {
            ServiceCompat.startForeground(
                this,
                ServiceNotification.ID,
                ServiceNotification.build(this),
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
                } else {
                    0
                },
            )
        } catch (e: Exception) {
            fail("포그라운드 시작 실패", e)
            return
        }

        val manager = getSystemService(MediaProjectionManager::class.java)
        projection?.unregisterCallback(projectionCallback)
        projection?.stop()
        projection = manager.getMediaProjection(resultCode, data)?.also {
            it.registerCallback(projectionCallback, Handler(Looper.getMainLooper()))
        }
        if (projection == null) {
            fail("MediaProjection을 얻지 못함")
            return
        }

        // 토큰 하나로 VirtualDisplay는 한 번만 만들 수 있어 세션 동안 유지한다 (NA-05).
        capturer?.release()
        capturer = try {
            ScreenCapturer(this, projection!!).also { it.start() }
        } catch (e: Exception) {
            fail("캡처 시작 실패", e)
            return
        }

        TranslatorServiceState.update(RunState.RUNNING)
        showOverlay()
        warmUp()
    }

    /**
     * 설정(FL-06)에서 고른 번역 엔진 (NA-11): ML Kit(NA-12), Gemini · Groq(NA-13), Gemma 온디바이스(#174).
     * 고른 AI 엔진이 1순위이고, 실패하면 쓸 수 있는 다른 AI 엔진(키가 있거나 모델을 받아 둔 것) → ML Kit 순으로 넘어간다.
     */
    private fun translationEngine(settings: Settings): TranslationEngine {
        val base = baseEngine(settings)
        // Gemma 도우미(#176): 켜 둔 것이 있을 때만 감싼다.
        if (!settings.gemmaPolish) return base
        return GemmaAssistedEngine(base, GemmaAssist(AppGraph.gemmaRuntime(this), log = assistLog()))
    }

    /** Gemma 도우미 진단 로그: debug 빌드에서만 남긴다 (화면 글자가 들어 있어 release에서는 끈다). logcat 태그 `GemmaAssist`. */
    private fun assistLog(): (String) -> Unit =
        if ((applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
            { Log.d("GemmaAssist", it) }
        } else {
            {}
        }

    private fun baseEngine(settings: Settings): TranslationEngine {
        val mlKit = mlKit()
        val order = aiOrder(settings)
        if (order.isEmpty()) return mlKit
        val chain = order.map(::aiEngine).reduceRight { engine, rest ->
            FallbackTranslationEngine(engine, rest, ::notifyAiSwitch)
        }
        return FallbackTranslationEngine(chain, mlKit, ::notifyAiFallback)
    }

    /** 쓸 AI 엔진을 순서대로. 고른 엔진이 맨 앞이고, ML Kit을 골랐으면 비어 있다. */
    private fun aiOrder(settings: Settings): List<Engine> {
        val first = settings.engine
        if (!first.isAi) return emptyList()
        // 설정이 연령 확인 전 클라우드 AI를 ML Kit으로 돌려주지만(FL-09), 서비스에서도 한 번 더 막는다.
        if (first.needsApiKey && !settings.ageConfirmed) return emptyList()
        val others = Engine.entries.filter { e ->
            e.isAi && e != first && when {
                e.needsApiKey -> settings.ageConfirmed && hasKey(e)
                else -> AppGraph.gemmaModelManager(this).isReady()
            }
        }
        return listOf(first) + others
    }

    private fun aiEngine(engine: Engine): TranslationEngine = when (engine) {
        Engine.GROQ -> GroqTranslationEngine(keysFor(Engine.GROQ))
        Engine.GEMMA -> GemmaTranslationEngine(AppGraph.gemmaRuntime(this))
        else -> GeminiTranslationEngine(keysFor(Engine.GEMINI))
    }

    // 엔진을 만드는 시점의 조회라 짧게 블로킹한다 (암호화 저장소 읽기).
    private fun hasKey(engine: Engine) = !AppGraph.apiKeyStore(this).get(engine).isNullOrBlank()

    private fun mlKit(): MlKitTranslationEngine = mlKitEngine ?: MlKitTranslationEngine(
        downloadPolicyProvider = {
            ModelDownloadPolicy(AppGraph.settingsRepository(this).current().wifiOnlyModelDownload)
        },
    ).also { mlKitEngine = it }

    /**
     * 고른 단어의 사전 카드 내용 (AD-02): 번역은 ML Kit, 뜻 · 발음 · 품사 · 문맥 뜻은 AI 엔진을 쓰고 있을 때만 (키 · 연령 확인 포함).
     */
    private suspend fun lookupWord(target: WordTarget, targetLanguage: String): WordLookupOutcome {
        val settings = AppGraph.settingsRepository(this).current()
        val useAi = settings.engine.isAi && settings.ageConfirmed &&
            withContext(Dispatchers.IO) { !AppGraph.apiKeyStore(this@TranslatorService).get(settings.engine).isNullOrBlank() }
        val dictionary = when {
            !useAi -> null
            settings.engine == Engine.GROQ -> GroqDictionary(keysFor(Engine.GROQ))
            else -> GeminiDictionary(keysFor(Engine.GEMINI))
        }
        return WordLookup(mlKit(), dictionary)
            .lookup(target.word, target.sentence, target.sourceLanguage, targetLanguage)
    }

    private var lastFallbackNoticeMs = 0L

    /** AI 번역이 실패해 ML Kit으로 대신 번역했음을 짧게 알린다 (NA-13). 블록마다 뜨지 않게 일정 시간에 한 번만. */
    private fun notifyAiFallback(error: TranslationError) {
        Log.w(TAG, "AI 번역 실패 → ML Kit: $error")
        val now = android.os.SystemClock.elapsedRealtime()
        if (now - lastFallbackNoticeMs < FALLBACK_NOTICE_INTERVAL_MS) return
        lastFallbackNoticeMs = now
        val message = when (error) {
            TranslationError.NoApiKey -> R.string.ai_fallback_no_key
            TranslationError.InvalidApiKey -> R.string.ai_fallback_invalid_key
            TranslationError.AccessDenied -> R.string.ai_fallback_denied
            TranslationError.ServiceBusy -> R.string.ai_fallback_busy
            TranslationError.Network -> R.string.ai_fallback_offline
            else -> R.string.ai_fallback_failed
        }
        Handler(Looper.getMainLooper()).post { toast.show(getString(message), ToastKind.INFO) }
    }

    /** 1순위 AI가 실패해 다른 AI 엔진으로 넘어갔음을 알린다. 실제 안내는 ML Kit까지 갈 때만 띄운다 (로그만). */
    private fun notifyAiSwitch(error: TranslationError) {
        Log.w(TAG, "1순위 AI 번역 실패 → 2순위 AI: $error")
    }

    private fun keysFor(engine: Engine) = ApiKeyProvider { AppGraph.apiKeyStore(this).get(engine) }

    /** 번역 결과를 기록에 남긴다 (NA-23). 실패해도 번역에는 영향이 없다. */
    private fun recordHistory(outcome: TranslationOutcome.Translated) {
        lifecycleScope.launch(Dispatchers.IO) {
            try {
                AppGraph.historyRepository(this@TranslatorService).record(outcome)
            } catch (e: Exception) {
                Log.w(TAG, "번역 기록 저장 실패", e)
            }
        }
    }

    /** 첫 번역이 느리지 않도록 문자 인식기를 미리 불러 둔다 (#11). 실패해도 번역 때 다시 시도한다. */
    private fun warmUp() {
        lifecycleScope.launch(Dispatchers.Default) {
            try {
                textRecognizer.warmUp()
            } catch (e: Exception) {
                Log.w(TAG, "인식기 예열 실패", e)
            }
            // Gemma 도우미를 켜 뒀으면 모델도 미리 올려 첫 번역이 로딩을 기다리지 않게 한다 (#176).
            try {
                val s = AppGraph.settingsRepository(this@TranslatorService).current()
                if (s.gemmaPolish) AppGraph.gemmaRuntime(this@TranslatorService).warmUp()
            } catch (e: Exception) {
                Log.w(TAG, "Gemma 예열 실패", e)
            }
        }
    }

    /** 플로팅 버튼을 띄운다 (NA-18). 권한이 없으면 띄우지 않고 서비스만 돈다. */
    private fun showOverlay() {
        overlay?.destroy()
        overlay = OverlayController(
            context = this,
            scope = lifecycleScope,
            settingsRepository = AppGraph.settingsRepository(this),
            pipeline = pipeline,
            sampleSignature = { region -> capturer?.captureSignature(region) },
            onStopRequested = { stopSelf() },
            onTranslated = ::recordHistory,
            hasAiKey = { engine ->
                if (engine == Engine.GEMMA) {
                    AppGraph.gemmaModelManager(this).isReady()
                } else {
                    AppGraph.settingsRepository(this).current().ageConfirmed &&
                        !AppGraph.apiKeyStore(this).get(engine).isNullOrBlank()
                }
            },
            vocabulary = AppGraph.vocabularyRepository(this),
            lookupWord = ::lookupWord,
        ).takeIf { it.show() }
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        capturer?.onDisplayChanged()
        overlay?.onConfigurationChanged()
    }

    /**
     * 화면 한 장을 찍는다 (NA-05). 플로팅 버튼(NA-18)은 [pipeline]으로 부르며,
     * 찍기 전에 버튼을 숨기고 찍은 뒤 다시 보여 번역 대상에 섞이지 않게 한다.
     */
    suspend fun captureFrame(): CaptureResult =
        capturer?.capture() ?: CaptureResult.Failed("서비스가 실행 중이 아님")

    /** 캡처한 화면에서 글자를 읽는다 (NA-09). [sourceLanguage] null = 자동. */
    suspend fun recognizeText(frame: CaptureResult.Frame, sourceLanguage: String? = null, incremental: Boolean = false): OcrResult =
        textRecognizer.recognize(frame.bitmap, sourceLanguage, incremental)

    /** 블록별 원문 언어를 감지해 번역할지 정한다 (NA-10). 대상 언어는 저장된 설정(NA-16)을 쓴다. */
    suspend fun detectLanguages(ocr: OcrResult): List<DetectedBlock> {
        val target = AppGraph.settingsRepository(this).current().targetLanguage
        return languageDetector.detect(ocr.blocks, target)
    }

    /** 디버그 빌드 전용: 알림의 "캡처 테스트"로 한 장 찍어 앱 캐시에 저장하고 결과를 로그로 남긴다. */
    private fun debugCapture() {
        if (!isDebuggable()) return
        lifecycleScope.launch {
            // 알림 창이 닫히는 애니메이션이 찍히지 않도록 잠시 기다린다.
            delay(1_000)
            when (val result = captureFrame()) {
                is CaptureResult.Frame -> {
                    val file = File(cacheDir, "debug_capture.png")
                    withContext(Dispatchers.IO) {
                        file.outputStream().use {
                            result.bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, it)
                        }
                    }
                    Log.i(TAG, "캡처 성공 ${result.bitmap.width}x${result.bitmap.height} → ${file.absolutePath}")
                    val started = System.currentTimeMillis()
                    val ocr = recognizeText(result)
                    Log.i(
                        TAG,
                        "문자 인식 ${ocr.script} 블록 ${ocr.blocks.size}개, ${System.currentTimeMillis() - started}ms: " +
                            ocr.blocks.take(5).joinToString(" | ") { "${it.language}:${it.text.replace('\n', ' ')}" },
                    )
                    val detected = detectLanguages(ocr)
                    Log.i(
                        TAG,
                        "언어 감지: " + detected.groupBy { it.decision.action }
                            .map { (action, blocks) -> "$action ${blocks.size}개(${blocks.map { it.decision.language }.distinct().joinToString(",")})" }
                            .joinToString(" / "),
                    )
                    result.bitmap.recycle()
                }
                CaptureResult.Blank -> Log.i(TAG, "캡처 결과: 검은 화면 (보안 화면일 수 있음)")
                is CaptureResult.Failed -> Log.w(TAG, "캡처 실패: ${result.reason}")
            }
        }
    }

    private fun fail(reason: String, error: Throwable? = null) {
        Log.e(TAG, reason, error)
        TranslatorServiceState.update(RunState.ERROR)
        stopForegroundCompat()
        stopSelf()
    }

    private fun stopForegroundCompat() {
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
    }

    override fun onDestroy() {
        toast.dismiss()
        overlay?.destroy()
        overlay = null
        mlKitEngine?.close()
        mlKitEngine = null
        textRecognizer.close()
        languageDetector.close()
        capturer?.release()
        capturer = null
        projection?.unregisterCallback(projectionCallback)
        projection?.stop()
        projection = null
        if (TranslatorServiceState.state.value != RunState.ERROR) {
            TranslatorServiceState.update(RunState.STOPPED)
        }
        super.onDestroy()
    }

    companion object {
        private const val TAG = "TranslatorService"
        private const val FALLBACK_NOTICE_INTERVAL_MS = 20_000L
        private const val ACTION_START = "com.example.translation_poc_app.action.START"
        const val ACTION_STOP = "com.example.translation_poc_app.action.STOP"
        private const val ACTION_DEBUG_CAPTURE = "com.example.translation_poc_app.action.DEBUG_CAPTURE"
        private const val EXTRA_RESULT_CODE = "result_code"
        private const val EXTRA_DATA = "data"

        /** 캡처 동의 결과로 서비스를 시작한다. [CaptureConsentActivity]에서만 부른다. */
        fun start(context: Context, resultCode: Int, data: Intent) {
            val intent = Intent(context, TranslatorService::class.java)
                .setAction(ACTION_START)
                .putExtra(EXTRA_RESULT_CODE, resultCode)
                .putExtra(EXTRA_DATA, data)
            context.startForegroundService(intent)
        }

        fun stop(context: Context) {
            // 실행 중이 아니면 startService가 서비스를 새로 만들지 않도록 stopService를 쓴다.
            context.stopService(Intent(context, TranslatorService::class.java))
        }

        fun stopIntent(context: Context): Intent =
            Intent(context, TranslatorService::class.java).setAction(ACTION_STOP)

        fun debugCaptureIntent(context: Context): Intent =
            Intent(context, TranslatorService::class.java).setAction(ACTION_DEBUG_CAPTURE)

        fun Context.isDebuggable(): Boolean =
            applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0
    }
}
