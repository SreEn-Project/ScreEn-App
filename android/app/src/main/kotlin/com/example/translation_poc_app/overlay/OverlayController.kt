package com.example.translation_poc_app.overlay

import android.animation.ValueAnimator
import android.content.ClipData
import android.content.ClipboardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.input.InputManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.os.SystemClock
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.WindowManager
import android.view.animation.DecelerateInterpolator
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.example.translation_poc_app.autotranslate.AutoTranslateConfig
import com.example.translation_poc_app.autotranslate.AutoTranslateWatcher
import com.example.translation_poc_app.autotranslate.FrameSignature
import com.example.translation_poc_app.data.settings.CaptureRange
import com.example.translation_poc_app.R
import com.example.translation_poc_app.data.settings.NormalizedRegion
import com.example.translation_poc_app.data.settings.ResultDisplay
import com.example.translation_poc_app.data.settings.Settings as AppSettings
import com.example.translation_poc_app.data.settings.SettingsRepository
import com.example.translation_poc_app.translate.TranslatedItem
import com.example.translation_poc_app.translate.TranslationOutcome
import com.example.translation_poc_app.translate.TranslationPipeline
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.withContext
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import java.util.Locale

/**
 * 오버레이 전체 (NA-18 플로팅 버튼 · 모드 메뉴, NA-19 결과 시트). [TranslatorService]가 세션 동안 하나 가진다.
 *
 * - 버튼: 탭 = 현재 모드로 번역, 길게 누르기 = 카테고리 버블(캡처 범위 · 결과 표시 · 빠른 언어, O-02),
 *   버블을 누르면 그 옵션 메뉴(O-02), 끌기 = 이동(놓으면 가장자리에 붙음), 아래 닫기 영역에 놓기 = 서비스 종료.
 * - 번역: 캡처에 버튼이 찍히지 않도록 숨기고 찍은 뒤 다시 보여 주고, 끝날 때까지 진행 표시.
 * - 결과: 화면 전체를 덮는 시트 창. 바깥 · 뒤로 가기로 닫는다.
 *
 * 모든 창 조작은 메인 스레드에서 한다 ([scope]는 서비스 lifecycleScope).
 */
class OverlayController(
    private val context: Context,
    private val scope: CoroutineScope,
    private val settingsRepository: SettingsRepository,
    private val pipeline: TranslationPipeline,
    /** 자동 번역(#23)이 화면이 바뀌었는지 볼 때 쓰는 가벼운 화면 지문. [region]만 본다. 프레임이 없으면 null. */
    private val sampleSignature: suspend (region: NormalizedRegion?) -> IntArray?,
    private val onStopRequested: () -> Unit,
    /** 번역이 화면에 올랐다: 번역 기록(NA-23)에 남긴다. 번역이 모두 끝난 결과만 온다 (일부만 끝난 것 제외). */
    private val onTranslated: (TranslationOutcome.Translated) -> Unit = {},
) {
    private val windowManager = context.getSystemService(WindowManager::class.java)
    private val mainHandler = Handler(Looper.getMainLooper())
    private val density = context.resources.displayMetrics.density
    private fun dp(value: Int) = (value * density).toInt()

    /** 버튼 창 크기 (px). 설정(FL-07)의 버튼 크기가 바뀌면 [resizeButton]이 갱신한다. */
    private var buttonSize = dp(buttonWindowDp(AppSettings.DEFAULT_BUTTON_SIZE_DP))
    private val closeWindowSize = dp(CLOSE_WINDOW_DP)
    private val closeBottomMargin = dp(72)
    private val closeRadius = dp(64)

    private var area = OverlayWindow.screenArea(context, windowManager)
    private val placementPrefs = context.getSharedPreferences(PLACEMENT_PREFS, Context.MODE_PRIVATE)
    private var placement = lastPlacement?.takeIf { it.second == area }?.first
        ?: restorePlacement()
        ?: OverlayGeometry.initial(area, buttonSize)

    // Compose가 읽는 상태
    private var mode by mutableStateOf(CaptureRange.FULL_SCREEN)
    private var fixedRegion: NormalizedRegion? = null
    private var display = ResultDisplay.LIST
    private var targetLanguage by mutableStateOf("")
    private var quickLanguages: List<String> = emptyList()
    private var autoConfig = AutoTranslateConfig(
        showDelayMs = AppSettings.DEFAULT_AUTO_SHOW_DELAY_MS,
        hideMs = AppSettings.DEFAULT_HIDE_AFTER_INTERACTION_MS,
        retranslate = false,
    )
    private var autoTranslate by mutableStateOf(false)
    private var settingsSeen = false
    private var sourceLanguage by mutableStateOf(AppSettings.SOURCE_LANGUAGE_AUTO)

    /** 마지막으로 번역한 영역 (자동 번역이 같은 영역을 다시 번역한다). null = 화면 전체. */
    private var lastRegion: NormalizedRegion? = null

    /** 지금 떠 있는 결과의 항목. 자동 번역 결과가 같으면 시트를 바꾸지 않는다. */
    private var shownItems: List<TranslatedItem>? = null

    /**
     * 결과가 터치를 통과시키는 '원문 위에 덮기'로 떠 있다 (자동 번역 중이거나 닫힘 시간이 정해져 있을 때). 버튼을 누르면 닫는다.
     * 목록 · 문장 시트와 '직접 닫기'의 덮기는 뒤 앱을 막고, 사용자가 닫을 때까지 둔다.
     */
    private var passthrough = false

    /** 화면이 바뀌어서 낡은 결과를 숨기는 중이다 (#29, #35). 새 결과가 뜨면 풀린다. */
    private var staleHidden = false

    private val watcher = AutoTranslateWatcher(
        scope = scope,
        sample = { withContext(Dispatchers.Default) { sampleSignature(lastRegion) } },
        config = { autoConfig },
        translate = ::autoTranslateOnce,
        setStale = ::setStaleHidden,
    )
    private val screenOffReceiver = object : BroadcastReceiver() {
        // 화면이 꺼지거나 절전 모드가 켜지면 감시를 멈춘다 (배터리). 다음 번역 때 다시 시작한다.
        override fun onReceive(context: Context, intent: Intent) {
            // 화면이 켜지거나 절전 모드가 바뀌면 다시 판단한다: 떠 있는 결과가 아직 지켜볼 대상이면 이어서 지켜본다
            // (화면을 껐다 켜도 닫힘이 멈추지 않게).
            val resume = intent.action != Intent.ACTION_SCREEN_OFF && sheet != null && !staleHidden && !busy && shouldWatch()
            if (resume) watcher.arm() else watcher.stop()
        }
    }
    private val powerManager = context.getSystemService(PowerManager::class.java)
    private var buttonDiameterDp by mutableIntStateOf(AppSettings.DEFAULT_BUTTON_SIZE_DP)
    private var buttonOpacity by mutableFloatStateOf(AppSettings.DEFAULT_BUTTON_OPACITY_PERCENT / 100f)
    private var busy by mutableStateOf(false)
    private var dragging by mutableStateOf(false)
    private var overClose by mutableStateOf(false)

    private val gestures = ButtonGestures(
        context,
        onDown = ::onButtonDown,
        onTap = ::onButtonTap,
        onLongPress = ::toggleMenu,
        onDragStart = ::onDragStart,
        onDrag = ::onDrag,
        onDragEnd = ::onDragEnd,
        onHold = ::onHold,
        onHoldRelease = ::onHoldRelease,
    )

    private val button = OverlayWindow(
        context,
        windowManager,
        OverlayWindow.params(
            buttonSize,
            buttonSize,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
        ),
    ) { FloatingButton(mode, busy, dragging, buttonDiameterDp, buttonOpacity, autoTranslate) }.apply { root.touchHandler = gestures::onTouch }

    private val closeZone = OverlayWindow(
        context,
        windowManager,
        OverlayWindow.params(
            closeWindowSize,
            closeWindowSize,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
        ),
    ) { CloseTarget(overClose) }

    private var menu: OverlayWindow? = null

    /** 길게 누른 채 손가락이 올라가 있는 버블 번호 (없으면 -1). 버블 창이 있는 동안만 쓴다. */
    private var hoveredBubble by mutableIntStateOf(-1)
    private var bubbleAnglesNow: List<Float> = emptyList()
    private var bubbleActions: List<() -> Unit> = emptyList()
    private var sheet: OverlayWindow? = null

    /** 떠 있는 하단 시트(목록)가 보여 주는 결과. 바뀌면 시트 안에서 내용만 바뀐다. */
    private var sheetOutcome by mutableStateOf<TranslationOutcome?>(null)
    private var sheetIsList = false
    private var picker: OverlayWindow? = null

    /** 번역 중인 작업 (버튼 탭 · 화면 이동으로 취소한다). 자동 번역의 다시 번역은 감시가 따로 가진다. */
    private var translateJob: Job? = null

    /** 번역 중에 아직 번역이 안 끝난 글자 자리. 덮어쓰기 막이 로딩 표시로 그린다. */
    private var pendingRegions: List<NormalizedRegion> = emptyList()

    /** 덮어쓰기 막 창이 떠 있다 (목록 시트가 아님). 같은 창에서 내용만 바꿔 깜빡임을 막는다. */
    private var sheetIsLayer = false
    private var layerTouchless = false
    private var layerItems by mutableStateOf<List<TranslatedItem>>(emptyList())
    private var layerPending by mutableStateOf<List<NormalizedRegion>>(emptyList())
    private var overlayQuietUntil = 0L
    private var settingsJob: Job? = null
    private var snapAnimator: ValueAnimator? = null
    private var dragStart = placement
    private var menuClosedAt = 0L
    private var tapClosesMenu = false

    /** 다른 앱 위 표시 권한이 없으면 띄우지 않는다 (서비스는 계속 돈다). */
    fun show(): Boolean {
        if (!Settings.canDrawOverlays(context)) {
            Log.w(TAG, "다른 앱 위 표시 권한이 없어 플로팅 버튼을 띄우지 않음")
            return false
        }
        applyPlacement()
        button.show()
        settingsJob = scope.launch {
            settingsRepository.settings.collect {
                // 캡처 영역 종류 · 고정 영역이 바뀌면 이전 영역으로 이어 가던 자동 번역을 끝낸다. 다음 탭이 새 영역으로 시작한다 (#69).
                if (settingsSeen && (it.captureRange != mode || it.fixedRegion != fixedRegion)) resetAutoArea()
                settingsSeen = true
                mode = it.captureRange
                fixedRegion = it.fixedRegion
                display = it.resultDisplay
                targetLanguage = it.targetLanguage
                quickLanguages = it.quickLanguages
                // 자동 번역은 결과가 '본문 위에 표시'일 때만 쓴다. 설정 값은 그대로 두어, 다시 덮어쓰기로 바꾸면 이어진다.
                autoTranslate = it.autoTranslate && it.resultDisplay == ResultDisplay.OVERLAY
                sourceLanguage = it.sourceLanguage
                buttonOpacity = it.buttonOpacityPercent / 100f
                if (it.buttonSizeDp != buttonDiameterDp) resizeButton(it.buttonSizeDp)
                autoConfig = AutoTranslateConfig(
                    showDelayMs = it.autoShowDelayMs,
                    hideMs = it.hideAfterInteractionMs,
                    retranslate = autoTranslate,
                    // 닫힘 시간만 쓸 때는 반응이 빠르도록 더 자주 본다 (다시 번역하지 않으니 비용은 지문 읽기뿐).
                    checkIntervalMs = if (autoTranslate) AutoTranslateConfig.CHECK_INTERVAL_MS else AutoTranslateConfig.HIDE_ONLY_CHECK_INTERVAL_MS,
                )
                // 자동 번역을 꺼도 조작 뒤 숨김이 켜진 채 덮어쓰기 결과가 떠 있으면 숨김 감시는 이어간다 (다시 번역만 멈춘다).
                if (!autoTranslate && !(passthrough && autoConfig.hideMs >= 0)) {
                    watcher.stop()
                    setStaleHidden(false)
                }
            }
        }
        context.registerReceiver(
            screenOffReceiver,
            IntentFilter(Intent.ACTION_SCREEN_OFF).apply {
                addAction(Intent.ACTION_SCREEN_ON)
                addAction(PowerManager.ACTION_POWER_SAVE_MODE_CHANGED)
            },
        )
        return true
    }

    fun destroy() {
        watcher.stop()
        runCatching { context.unregisterReceiver(screenOffReceiver) }
        settingsJob?.cancel()
        snapAnimator?.cancel()
        gestures.cancel()
        dismissMenu()
        dismissSheet()
        dismissPicker()
        closeZone.destroy()
        button.destroy()
        lastPlacement = placement to area
    }

    /** 회전 등으로 화면 크기가 바뀌면 같은 가장자리 · 같은 높이 비율로 옮긴다. */
    fun onConfigurationChanged() {
        val newArea = OverlayWindow.screenArea(context, windowManager)
        if (newArea == area) return
        snapAnimator?.cancel()
        dismissMenu()
        placement = OverlayGeometry.rotate(placement, area, newArea, buttonSize)
        area = newArea
        applyPlacement()
    }

    // ── 버튼 ─────────────────────────────────────────────

    private fun onButtonDown() {
        // 메뉴가 열려 있을 때 버튼을 누르면 메뉴만 닫는다. 메뉴 창은 바깥 터치로 먼저 닫힐 수 있어 시간도 본다.
        tapClosesMenu = menu != null || SystemClock.uptimeMillis() - menuClosedAt < MENU_CLOSE_GRACE_MS
    }

    private fun onButtonTap() {
        if (tapClosesMenu) {
            dismissMenu()
            return
        }
        if (busy) {
            // 번역 중에 버튼을 누르면 번역을 취소한다. 자동 번역이 다시 번역하는 중이면 결과 · 감시를 걷는다.
            if (translateJob?.isActive == true) translateJob?.cancel() else dismissSheet()
            return
        }
        if (passthrough && !staleHidden) {
            // 터치를 통과시키는 막은 화면에서 바로 닫을 수 없다. 버튼으로 닫는다 (감시도 멈춘다).
            // 낡아서 숨겨진 막은 보이는 게 없으니 이 탭은 닫기가 아니라 다시 번역이다.
            dismissSheet()
            return
        }
        startTranslation()
    }

    /** 버튼을 누른 것과 같다: 캡처 범위 모드에 맞게 번역을 시작한다 (드래그 · 고정 영역 미지정이면 영역 선택부터). */
    private fun startTranslation() {
        when (mode) {
            CaptureRange.FULL_SCREEN -> translate()
            CaptureRange.DRAG_REGION -> showPicker(RegionPickMode.DRAG) { translate(it) }
            CaptureRange.FIXED_REGION -> fixedRegion?.let { translate(it) } ?: showPicker(RegionPickMode.EDIT, ::saveFixedRegion)
        }
    }

    private fun translate(region: NormalizedRegion? = null) {
        if (busy) return
        dismissMenu()
        dismissSheet()
        busy = true
        lastRegion = region
        pendingRegions = emptyList()
        translateJob = scope.launch {
            // 버튼이 캡처에 찍히지 않도록 숨긴다. 캡처 쪽이 숨긴 뒤의 새 프레임을 기다린다.
            button.setHidden(true)
            var moveWatch: Job? = null
            var outcome: TranslationOutcome? = null
            try {
                outcome = pipeline.run(
                    region,
                    onCaptured = {
                        button.setHidden(false)
                        // 번역하는 동안 화면이 움직이면 그 번역은 버린다 (자동 번역과 같은 규칙).
                        moveWatch = watchForMovement()
                    },
                    // 글자 자리를 먼저 보여 주고 번역이 끝날 때까지 로딩 표시를 건다 (덮어쓰기 표시일 때).
                    onPending = { regions ->
                        if (display == ResultDisplay.OVERLAY && regions.isNotEmpty()) {
                            pendingRegions = regions
                            showSheet(null, regions, final = false)
                        }
                    },
                    // 끝난 블록부터 먼저 보여 준다 (#41). 마지막에 전체 결과로 바뀐다.
                    onPartial = { partial ->
                        val done = partial.items.mapNotNull { it.bounds }.toSet()
                        pendingRegions = pendingRegions.filter { it !in done }
                        showSheet(partial, pendingRegions, final = false)
                    },
                )
            } finally {
                moveWatch?.cancel()
                button.setHidden(false)
                busy = false
                translateJob = null
                pendingRegions = emptyList()
                // 취소 · 예외로 끝났다: 번역 중에 올린 로딩 · 일부 결과를 걷는다.
                if (outcome == null) removeSheet()
            }
            val result = outcome ?: return@launch
            logOutcome(result)
            showSheet(result)
            if (result is TranslationOutcome.Translated) onTranslated(result)
            // 번역이 화면에 올랐으면 이제부터 화면 변화를 지켜본다: 자동 번역은 다시 번역하고 (#23),
            // 조작 뒤 숨김이 켜진 덮어쓰기 결과(passthrough)는 숨김만 한다 (#35).
            if (shouldWatch() && result is TranslationOutcome.Translated) {
                watcher.arm()
            }
        }
    }

    /**
     * 번역하는 동안 화면이 움직이는지 지켜보고, 움직이면 번역을 취소한다 (일반 번역도 자동 번역처럼).
     * 우리 로딩 표시 · 일부 결과가 화면에 올라오면 지문이 달라지므로, 올릴 때마다 [overlayQuietUntil]까지 쉬고 기준을 다시 잡는다.
     * 버튼의 도는 호가 지문에 조금 잡히므로 자동 번역 감시보다 넉넉한 기준을 쓴다.
     */
    private fun watchForMovement(): Job = scope.launch {
        overlayQuietUntil = SystemClock.uptimeMillis() + MOVE_SETTLE_MS
        var base: IntArray? = null
        while (isActive) {
            delay(MOVE_CHECK_MS)
            val signature = withContext(Dispatchers.Default) { sampleSignature(lastRegion) } ?: continue
            if (SystemClock.uptimeMillis() < overlayQuietUntil) {
                base = null
            } else if (base == null) {
                base = signature
            } else if (FrameSignature.changedRatio(base, signature) >= MOVE_CHANGE_RATIO) {
                Log.i(TAG, "번역 중 화면이 움직여 번역을 취소")
                translateJob?.cancel()
                return@launch
            }
        }
    }

    /**
     * 자동 번역(#23)이 부른다: 화면이 바뀌어 안정됐으니 같은 영역을 다시 번역한다. 지금 할 수 없으면 false.
     * 떠 있는 결과가 캡처에 찍히지 않게 잠깐 숨겼다가, 결과가 같으면 그대로 다시 보이고 다르면 새 결과로 바꾼다.
     * 번역은 바로 하되, 화면에 올리는 것은 [showNotBefore](조작이 끝난 시각 + 표시 시점 설정)까지 기다린다 (#35).
     */
    private suspend fun autoTranslateOnce(showNotBefore: Long): Boolean {
        if (busy || menu != null || picker != null || dragging) return false
        busy = true
        val old = sheet
        old?.setHidden(true)
        button.setHidden(true)
        // 사용자가 또 조작해서 감시가 이 번역을 취소하면 finally만 돌고 결과는 버려진다.
        val outcome = try {
            pipeline.run(lastRegion, incremental = true, onCaptured = {
                button.setHidden(false)
                old?.setHidden(staleHidden)
                watcher.markCaptured()
            })
        } finally {
            button.setHidden(false)
            old?.setHidden(staleHidden)
            busy = false
        }
        logOutcome(outcome)
        // 새 번역이 일찍 끝나도 설정한 시점 전에는 올리지 않는다. 기다리는 동안 또 조작하면 감시가 이 작업을 취소한다.
        val changesScreen = outcome is TranslationOutcome.Translated || outcome == TranslationOutcome.NoText ||
            outcome is TranslationOutcome.AlreadyInTarget
        if (changesScreen) {
            val wait = showNotBefore - watcher.now()
            if (wait > 0) delay(wait)
        }
        when (outcome) {
            is TranslationOutcome.Translated -> if (outcome.items != shownItems) {
                showSheet(outcome)
                onTranslated(outcome)
            } else {
                // 같은 결과가 다시 맞는다: 숨겼던 것을 다시 보인다.
                staleHidden = false
                sheet?.setHidden(false)
            }
            // 번역할 글이 없어졌다: 낡은 결과를 걷는다. 감시는 계속한다.
            TranslationOutcome.NoText, is TranslationOutcome.AlreadyInTarget -> removeSheet()
            // 보안 화면 · 실패: 있던 결과를 그대로 둔다.
            else -> Unit
        }
        return true
    }

    /** 영역 종류가 바뀌었다: 이전 영역의 감시 · 결과를 걷고 다음 번역이 새 영역을 쓰게 한다. */
    private fun resetAutoArea() {
        watcher.stop()
        removeSheet()
        lastRegion = null
    }

    /**
     * 번역한 화면의 변화를 지켜볼지: 자동 번역은 절전 모드가 아닐 때만 (배터리), 닫힘 시간만 쓰는 덮기는 절전이어도 지켜본다
     * (지켜보지 않으면 결과가 닫히지 않는다).
     */
    private fun shouldWatch(): Boolean =
        (autoTranslate && !powerManager.isPowerSaveMode) || (passthrough && autoConfig.hideMs >= 0)

    /** 자동 번역 감시가 부른다: 화면이 바뀌어 낡은 결과를 숨기거나(true), 바뀐 화면이 번역한 화면으로 돌아와 다시 보인다(false). */
    private fun setStaleHidden(hidden: Boolean) {
        if (staleHidden == hidden) return
        staleHidden = hidden
        // 번역 중이면 번역이 끝날 때 이 상태로 맞춘다 (캡처에 안 찍히게 이미 숨겨 둔 상태일 수 있다).
        if (!busy) sheet?.setHidden(staleHidden)
    }

    private fun onDragStart() {
        snapAnimator?.cancel()
        dismissMenu()
        dragStart = placement
        dragging = true
        val (zoneX, zoneY) = OverlayGeometry.closeZoneCenter(area, closeBottomMargin)
        closeZone.params.x = zoneX - closeWindowSize / 2
        closeZone.params.y = zoneY - closeWindowSize / 2
        closeZone.show()
    }

    private fun onDrag(dx: Int, dy: Int) {
        val (x, y) = OverlayGeometry.clamp(dragStart.x + dx, dragStart.y + dy, buttonSize, area)
        placement = placement.copy(x = x, y = y)
        applyPlacement()
        overClose = OverlayGeometry.isOverCloseZone(x, y, buttonSize, area, closeBottomMargin, closeRadius)
    }

    private fun onDragEnd(cancelled: Boolean = false) {
        dragging = false
        closeZone.hide()
        // 시스템이 터치를 가져간 경우(취소)는 놓은 것이 아니다: 닫기 영역 위여도 서비스를 끄지 않는다.
        if (overClose && !cancelled) {
            overClose = false
            placement = dragStart
            onStopRequested()
            return
        }
        overClose = false
        val target = OverlayGeometry.snap(placement.x, placement.y, buttonSize, area)
        savePlacement(target)
        animateTo(target)
    }

    /** 놓은 자리를 저장한다: 서비스가 다시 시작되거나 프로세스가 새로 떠도 같은 자리(가장자리 · 높이 비율)에 뜬다. */
    private fun savePlacement(target: ButtonPlacement) {
        val ratio = if (area.height > 0) target.y.toFloat() / area.height else 0.35f
        placementPrefs.edit().putBoolean(KEY_EDGE_LEFT, target.edge == Edge.LEFT).putFloat(KEY_Y_RATIO, ratio).apply()
    }

    private fun restorePlacement(): ButtonPlacement? {
        if (!placementPrefs.contains(KEY_Y_RATIO)) return null
        val left = placementPrefs.getBoolean(KEY_EDGE_LEFT, false)
        val ratio = placementPrefs.getFloat(KEY_Y_RATIO, 0.35f)
        return OverlayGeometry.snap(if (left) 0 else area.width, (area.height * ratio).toInt(), buttonSize, area)
    }

    private fun animateTo(target: ButtonPlacement) {
        val from = placement
        snapAnimator?.cancel()
        snapAnimator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = 220
            interpolator = DecelerateInterpolator()
            addUpdateListener {
                val t = it.animatedValue as Float
                placement = ButtonPlacement(
                    (from.x + (target.x - from.x) * t).toInt(),
                    (from.y + (target.y - from.y) * t).toInt(),
                    target.edge,
                )
                applyPlacement()
            }
            start()
        }
    }

    /** 설정에서 버튼 크기가 바뀌었다 (FL-07): 가운데는 그대로 두고 창 크기를 바꾼 뒤 가장자리에 다시 붙인다. */
    private fun resizeButton(diameterDp: Int) {
        snapAnimator?.cancel()
        dismissMenu()
        val newSize = dp(buttonWindowDp(diameterDp))
        val centerX = placement.x + buttonSize / 2
        val centerY = placement.y + buttonSize / 2
        buttonSize = newSize
        buttonDiameterDp = diameterDp
        placement = OverlayGeometry.snap(centerX - newSize / 2, centerY - newSize / 2, newSize, area)
        savePlacement(placement)
        button.params.width = newSize
        button.params.height = newSize
        applyPlacement()
    }

    private fun applyPlacement() {
        button.params.x = placement.x
        button.params.y = placement.y
        button.update()
    }

    // ── 버블 · 옵션 메뉴 (O-02) ───────────────────

    private enum class OptionKind { RANGE, DISPLAY, LANGUAGE, SETTINGS }

    /** 길게 누르기: 버블이 떠 있으면 닫고, 아니면 버튼 주위에 카테고리 버블을 띄운다. */
    private fun toggleMenu() {
        if (menu != null) {
            dismissMenu()
            return
        }
        if (busy) return
        val ringWidth = dp(BUBBLE_RING_WIDTH_DP)
        val ringHeight = dp(BUBBLE_RING_HEIGHT_DP)
        val centerX = placement.x + buttonSize / 2
        val centerY = placement.y + buttonSize / 2
        val inwardRight = placement.edge == Edge.LEFT
        val windowY = (centerY - ringHeight / 2)
            .coerceIn(area.top, (area.height - area.bottom - ringHeight).coerceAtLeast(area.top))
        // 바깥쪽에도 여백이 있어야 해서 가장자리에 붙은 버튼이면 창이 화면 밖으로 나간다 → 화면 안으로 맞추고 버튼 위치는 따로 넘긴다.
        val idealX = if (inwardRight) centerX - dp(BUBBLE_RING_OUTER_DP) else centerX - dp(BUBBLE_RING_INNER_DP)
        val windowX = idealX.coerceIn(area.left, (area.width - area.right - ringWidth).coerceAtLeast(area.left))
        val angles = OverlayGeometry.bubbleAngles(
            spaceAboveDp = (centerY - area.top) / density,
            spaceBelowDp = (area.height - area.bottom - centerY) / density,
        )
        bubbleAnglesNow = angles
        hoveredBubble = -1
        val bubbles = listOf(
            BubbleSpec(Symbol.CROP, context.getString(R.string.overlay_bubble_range), angles[0]) { showOptions(OptionKind.RANGE) },
            BubbleSpec(Symbol.VIEW_LIST, context.getString(R.string.overlay_bubble_display), angles[1]) { showOptions(OptionKind.DISPLAY) },
            BubbleSpec(Symbol.TRANSLATE, context.getString(R.string.overlay_bubble_language), angles[2]) { showOptions(OptionKind.LANGUAGE) },
            BubbleSpec(Symbol.SETTINGS, context.getString(R.string.overlay_bubble_settings), angles[3]) { showOptions(OptionKind.SETTINGS) },
        )
        bubbleActions = bubbles.map { it.onClick }
        val params = OverlayWindow.params(
            ringWidth,
            ringHeight,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = windowX
            y = windowY
        }
        val anchorXDp = (centerX - windowX) / density
        val anchorYDp = (centerY - windowY) / density
        menu = OverlayWindow(context, windowManager, params) {
            BubbleRing(bubbles, inwardRight, anchorXDp, anchorYDp, hovered = { hoveredBubble }, onBackgroundTap = { post(::dismissMenu) })
        }.apply {
            root.onOutsideTouch = { post(::dismissMenu) }
            show()
        }
    }

    private fun bubbleUnder(x: Float, y: Float): Int {
        if (menu == null || x < 0f) return -1
        return OverlayGeometry.bubbleHit(
            fingerX = x,
            fingerY = y,
            centerX = (placement.x + buttonSize / 2).toFloat(),
            centerY = (placement.y + buttonSize / 2).toFloat(),
            inwardRight = placement.edge == Edge.LEFT,
            angles = bubbleAnglesNow,
            radius = BUBBLE_RADIUS_DP * density,
            hitRadius = BUBBLE_HIT_RADIUS_DP * density,
        )
    }

    /** 길게 누른 채 손가락을 움직이면 그 아래 버블을 앞으로 올린다. */
    private fun onHold(x: Float, y: Float) {
        hoveredBubble = bubbleUnder(x, y)
    }

    /** 길게 누른 채 버블 위에서 손가락을 떼면 그 버블을 누른 것으로 친다. */
    private fun onHoldRelease(x: Float, y: Float) {
        val index = bubbleUnder(x, y)
        hoveredBubble = -1
        if (index in bubbleActions.indices) bubbleActions[index]()
    }

    /** 버블을 누르면 버블은 닫고 그 종류의 옵션 메뉴를 버튼 옆에 연다. */
    private fun showOptions(kind: OptionKind) {
        val options = when (kind) {
            OptionKind.RANGE -> ModeMenuItem.entries.map { item ->
                MenuOption(item.symbol, context.getString(item.label), item.range == mode) { onRangeSelect(item) }
            }
            OptionKind.DISPLAY -> DisplayMenuItem.entries.map { item ->
                MenuOption(item.symbol, context.getString(item.label), item.display == display) {
                    scope.launch { settingsRepository.setResultDisplay(item.display) }
                    post(::dismissMenu)
                }
            }
            OptionKind.LANGUAGE -> emptyList()
            OptionKind.SETTINGS -> settingsOptions()
        }
        post {
            dismissMenu()
            if (kind == OptionKind.LANGUAGE) openLanguageWindow() else openOptionWindow(options)
        }
    }

    /** '설정' 버블: 지금은 자동 번역 켜기 · 끄기만. 항목은 나중에 늘린다. 저장은 앱 설정과 같은 DataStore. */
    private fun settingsOptions(): List<MenuOption> {
        // 드래그 영역이나 덮어쓰기가 아닌 표시에서는 자동 번역을 쓸 수 없다: 끈 채로 비활성으로 보인다 (#71).
        val available = mode != CaptureRange.DRAG_REGION && display == ResultDisplay.OVERLAY
        val autoLabel = if (available) {
            context.getString(
                R.string.overlay_setting_auto_translate,
                context.getString(if (autoTranslate) R.string.overlay_on else R.string.overlay_off),
            )
        } else {
            context.getString(R.string.overlay_setting_auto_translate_drag)
        }
        return listOf(
            MenuOption(Symbol.AUTO_AWESOME, autoLabel, autoTranslate, enabled = available) {
                val enable = !autoTranslate
                // 저장된 설정이 돌아오기 전에 바로 번역을 시작하므로 켜진 상태를 먼저 반영한다 (끝난 번역이 감시를 시작하도록).
                autoTranslate = enable
                scope.launch { settingsRepository.setAutoTranslate(enable) }
                post(::dismissMenu)
                // 켜면 지금 화면부터 바로 번역한다 (버튼을 한 번 누른 것과 같다).
                if (enable) post(::startTranslation)
            },
        )
    }

    /**
     * 빠른 언어 메뉴: 위 막대에서 원문(자동 포함) · 번역 언어 쪽을 고르고 아래 목록에서 정한다.
     * 고른 뒤에도 열려 있어 이어서 다른 쪽을 고를 수 있다. 바깥을 누르면 닫는다.
     */
    private fun openLanguageWindow() {
        val locale = Locale.getDefault()
        val anchor = OverlayGeometry.menu(placement, buttonSize, area, gap = 0)
        val params = OverlayWindow.params(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
        ).apply {
            gravity = Gravity.TOP or if (anchor.alignEnd) Gravity.END else Gravity.START
            x = anchor.x
            y = anchor.y
        }
        val sourceCodes = listOf(AppSettings.SOURCE_LANGUAGE_AUTO) + quickLanguages
        fun sourceLabel(code: String) =
            if (code == AppSettings.SOURCE_LANGUAGE_AUTO) context.getString(R.string.overlay_source_auto) else languageDisplayName(code, locale)
        menu = OverlayWindow(context, windowManager, params) {
            LanguageMenu(
                sourceName = { sourceLabel(sourceLanguage) },
                targetName = { languageDisplayName(targetLanguage, locale) },
                swapEnabled = { sourceLanguage != AppSettings.SOURCE_LANGUAGE_AUTO },
                swapDescription = context.getString(R.string.overlay_lang_swap),
                onSwap = {
                    val newSource = targetLanguage
                    val newTarget = sourceLanguage
                    if (newTarget != AppSettings.SOURCE_LANGUAGE_AUTO) {
                        sourceLanguage = newSource
                        targetLanguage = newTarget
                        scope.launch {
                            settingsRepository.setSourceLanguage(newSource)
                            settingsRepository.setTargetLanguage(newTarget)
                        }
                    }
                },
                source = {
                    sourceCodes.map { code ->
                        LanguageEntry(sourceLabel(code), code == sourceLanguage) {
                            sourceLanguage = code
                            scope.launch { settingsRepository.setSourceLanguage(code) }
                        }
                    }
                },
                target = {
                    quickLanguages.map { code ->
                        LanguageEntry(languageDisplayName(code, locale), code == targetLanguage) {
                            targetLanguage = code
                            scope.launch { settingsRepository.setTargetLanguage(code) }
                        }
                    }
                },
            )
        }.apply {
            root.onOutsideTouch = { post(::dismissMenu) }
            show()
        }
    }

    private fun openOptionWindow(options: List<MenuOption>) {
        val anchor = OverlayGeometry.menu(placement, buttonSize, area, gap = 0)
        val params = OverlayWindow.params(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
        ).apply {
            gravity = Gravity.TOP or if (anchor.alignEnd) Gravity.END else Gravity.START
            x = anchor.x
            y = anchor.y
        }
        menu = OverlayWindow(context, windowManager, params) {
            OptionMenu(options)
        }.apply {
            root.onOutsideTouch = { post(::dismissMenu) }
            show()
        }
    }

    private fun onRangeSelect(item: ModeMenuItem) {
        scope.launch { settingsRepository.setCaptureRange(item.range) }
        post(::dismissMenu)
        // 고정 영역을 고르면 바로 영역을 지정 · 수정한다. 이후 버튼 탭 = 번역.
        if (item.range == CaptureRange.FIXED_REGION) post { showPicker(RegionPickMode.EDIT, ::saveFixedRegion) }
    }

    // ── 영역 선택 (NA-20 · NA-21) ────────────────────────

    /** 고정 영역을 저장한다 (모드는 메뉴에서 이미 고정 영역). */
    private fun saveFixedRegion(region: NormalizedRegion) {
        scope.launch {
            settingsRepository.setFixedRegion(region)
        }
    }

    /** 화면 전체를 덮는 영역 선택 창. 고르면 [onPicked]. 취소 · 뒤로 가기는 그냥 닫는다. */
    private fun showPicker(pickMode: RegionPickMode, onPicked: (NormalizedRegion) -> Unit) {
        if (busy || picker != null) return
        dismissMenu()
        dismissSheet()
        val params = OverlayWindow.params(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            // 뒤로 가기를 받으려고 포커스를 받는다.
            0,
        )
        picker = OverlayWindow(context, windowManager, params) {
            RegionPicker(
                pickMode,
                initial = fixedRegion,
                onDone = { region -> post { dismissPicker(); onPicked(region) } },
                onCancel = { post(::dismissPicker) },
            )
        }.apply {
            root.onBack = { post(::dismissPicker) }
            show()
        }
    }

    private fun dismissPicker() {
        val current = picker ?: return
        picker = null
        current.destroy()
    }

    private fun dismissMenu() {
        val current = menu ?: return
        menu = null
        menuClosedAt = SystemClock.uptimeMillis()
        current.destroy()
    }

    // ── 결과 시트 (NA-19) ───────────────────────────────

    /**
     * 결과를 올린다. [outcome]이 null이면 아직 결과 없이 로딩 표시([pending])만. [final]이 false면 번역 중의 중간 상태라
     * 막은 항상 터치를 통과시킨다 (번역하는 동안 뒤 앱을 막지 않고, 끝날 때 한 번만 창을 바꾼다).
     */
    private fun showSheet(outcome: TranslationOutcome?, pending: List<NormalizedRegion> = emptyList(), final: Boolean = true) {
        // 원문 위에 덮기(NA-22): 자리를 아는 번역 항목이 하나라도 있으면 막으로, 없으면 목록 시트로.
        val overItems = if (display == ResultDisplay.OVERLAY && outcome is TranslationOutcome.Translated) {
            overlayItems(outcome.items)
        } else {
            emptyList()
        }
        val layerPendingNow = if (display == ResultDisplay.OVERLAY) pending else emptyList()
        val isLayer = overItems.isNotEmpty() || layerPendingNow.isNotEmpty()
        // 자동 번역 중이거나 닫힘 시간이 정해져 있으면 막이 터치를 통과시켜 아래 앱을 그대로 스크롤할 수 있게 한다
        // (#23, #35). '직접 닫기'(자동 번역 꺼짐)는 화면 전체를 막고 사용자가 닫을 때까지 둔다. 목록 · 문장 시트는 항상 막는다.
        val newPassthrough = (autoTranslate || autoConfig.hideMs >= 0) && overItems.isNotEmpty()
        val touchless = isLayer && (!final || newPassthrough)
        shownItems = (outcome as? TranslationOutcome.Translated)?.items
        // 우리가 올린 표시가 바뀌면 화면 지문도 바뀐다: 번역 중 이동 감시가 이를 이동으로 보지 않게 잠시 쉰다.
        overlayQuietUntil = SystemClock.uptimeMillis() + MOVE_SETTLE_MS
        // 같은 종류의 창이 떠 있으면 창을 다시 만들지 않고 내용만 바꾼다. 결과가 바뀔 때마다 창이 사라졌다 다시 생기며
        // 깜빡이는 것(새 창의 첫 프레임이 검게 비침 · 하단 시트가 다시 올라옴)을 막는다.
        if (sheet != null && ((isLayer && sheetIsLayer && layerTouchless == touchless) || (!isLayer && sheetIsList))) {
            if (isLayer) {
                layerItems = overItems
                layerPending = layerPendingNow
            } else {
                sheetOutcome = outcome
            }
            passthrough = newPassthrough
            staleHidden = false
            sheet?.setHidden(false)
            return
        }
        removeSheet()
        staleHidden = false
        passthrough = newPassthrough
        sheetIsLayer = isLayer
        sheetIsList = !isLayer
        layerTouchless = touchless
        layerItems = overItems
        layerPending = layerPendingNow
        sheetOutcome = outcome
        val params = OverlayWindow.params(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            // 뒤로 가기를 받으려고 포커스를 받는다. 시트가 떠 있는 동안만.
            if (touchless) WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE else 0,
        ).apply {
            // Android 12+는 불투명한 오버레이 뒤의 앱이 터치를 못 받게 막는다. 시스템이 허용하는 최대 불투명도로 맞춘다.
            if (touchless && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                alpha = context.getSystemService(InputManager::class.java).maximumObscuringOpacityForTouch
            }
        }
        sheet = OverlayWindow(context, windowManager, params) {
            if (isLayer) {
                OverlayResult(layerItems, layerPending, onDismiss = { post(::dismissSheet) })
            } else {
                sheetOutcome?.let { ResultSheet(it, display, onDismiss = { post(::dismissSheet) }, onCopy = ::copy) }
            }
        }.apply {
            if (!touchless) root.onBack = { post(::dismissSheet) }
            show()
        }
    }

    /** 사용자가 결과를 닫았다: 자동 번역 감시도 멈춘다. */
    private fun dismissSheet() {
        watcher.stop()
        removeSheet()
    }

    /** 결과 창만 걷는다. 자동 번역이 결과를 바꿀 때는 감시를 멈추지 않는다. */
    private fun removeSheet() {
        passthrough = false
        staleHidden = false
        shownItems = null
        sheetIsList = false
        sheetIsLayer = false
        sheetOutcome = null
        val current = sheet ?: return
        sheet = null
        current.destroy()
    }

    private fun copy(text: String) {
        val clipboard = context.getSystemService(ClipboardManager::class.java)
        clipboard.setPrimaryClip(ClipData.newPlainText("translation", text))
    }

    /** 창 콜백(클릭 등) 안에서 그 창을 없애지 않도록 다음 차례로 미룬다. */
    private fun post(action: () -> Unit) {
        mainHandler.post(action)
    }

    private fun logOutcome(outcome: TranslationOutcome) {
        val summary = when (outcome) {
            is TranslationOutcome.Translated -> "번역 ${outcome.items.size}개 (${outcome.engine}), 건너뜀 ${outcome.skipped}개"
            else -> outcome.toString()
        }
        Log.i(TAG, "번역 결과: $summary")
    }

    private companion object {
        const val TAG = "OverlayController"
        const val MENU_CLOSE_GRACE_MS = 300L
        const val MOVE_CHECK_MS = 250L
        const val MOVE_SETTLE_MS = 700L

        /** 번역 중 화면 이동으로 보는 바뀐 칸 비율. 스크롤 · 화면 전환은 이보다 훨씬 크다. */
        const val MOVE_CHANGE_RATIO = 0.04f
        const val PLACEMENT_PREFS = "overlay_button"
        const val KEY_EDGE_LEFT = "edge_left"
        const val KEY_Y_RATIO = "y_ratio"

        /** 서비스를 다시 켜도 버튼이 마지막 자리에 뜨도록 (같은 화면 크기일 때만). 프로세스 안에서만 기억한다. */
        var lastPlacement: Pair<ButtonPlacement, ScreenArea>? = null
    }
}
