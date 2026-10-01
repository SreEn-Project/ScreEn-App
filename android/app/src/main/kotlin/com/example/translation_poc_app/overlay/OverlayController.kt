package com.example.translation_poc_app.overlay

import android.animation.ValueAnimator
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.animation.DecelerateInterpolator
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.example.translation_poc_app.data.settings.CaptureRange
import com.example.translation_poc_app.R
import com.example.translation_poc_app.data.settings.NormalizedRegion
import com.example.translation_poc_app.data.settings.ResultDisplay
import com.example.translation_poc_app.data.settings.SettingsRepository
import com.example.translation_poc_app.translate.TranslationOutcome
import com.example.translation_poc_app.translate.TranslationPipeline
import kotlinx.coroutines.CoroutineScope
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
    private val onStopRequested: () -> Unit,
) {
    private val windowManager = context.getSystemService(WindowManager::class.java)
    private val mainHandler = Handler(Looper.getMainLooper())
    private val density = context.resources.displayMetrics.density
    private fun dp(value: Int) = (value * density).toInt()

    private val buttonSize = dp(BUTTON_WINDOW_DP)
    private val closeWindowSize = dp(CLOSE_WINDOW_DP)
    private val closeBottomMargin = dp(72)
    private val closeRadius = dp(64)

    private var area = OverlayWindow.screenArea(context, windowManager)
    private var placement = lastPlacement?.takeIf { it.second == area }?.first
        ?: OverlayGeometry.initial(area, buttonSize)

    // Compose가 읽는 상태
    private var mode by mutableStateOf(CaptureRange.FULL_SCREEN)
    private var fixedRegion: NormalizedRegion? = null
    private var display = ResultDisplay.LIST
    private var targetLanguage = ""
    private var quickLanguages: List<String> = emptyList()
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
    )

    private val button = OverlayWindow(
        context,
        windowManager,
        OverlayWindow.params(
            buttonSize,
            buttonSize,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
        ),
    ) { FloatingButton(mode, busy, dragging) }.apply { root.touchHandler = gestures::onTouch }

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
    private var sheet: OverlayWindow? = null
    private var picker: OverlayWindow? = null
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
                mode = it.captureRange
                fixedRegion = it.fixedRegion
                display = it.resultDisplay
                targetLanguage = it.targetLanguage
                quickLanguages = it.quickLanguages
            }
        }
        return true
    }

    fun destroy() {
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
        scope.launch {
            // 버튼이 캡처에 찍히지 않도록 숨긴다. 캡처 쪽이 숨긴 뒤의 새 프레임을 기다린다.
            button.root.visibility = View.INVISIBLE
            val outcome = try {
                pipeline.run(region, onCaptured = { button.root.visibility = View.VISIBLE })
            } finally {
                button.root.visibility = View.VISIBLE
                busy = false
            }
            logOutcome(outcome)
            showSheet(outcome)
        }
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

    private fun onDragEnd() {
        dragging = false
        closeZone.hide()
        if (overClose) {
            overClose = false
            placement = dragStart
            onStopRequested()
            return
        }
        animateTo(OverlayGeometry.snap(placement.x, placement.y, buttonSize, area))
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

    private fun applyPlacement() {
        button.params.x = placement.x
        button.params.y = placement.y
        button.update()
    }

    // ── 버블 · 옵션 메뉴 (O-02) ───────────────────

    private enum class OptionKind { RANGE, DISPLAY, LANGUAGE }

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
        val angles = OverlayGeometry.bubbleAngles(
            spaceAboveDp = (centerY - area.top) / density,
            spaceBelowDp = (area.height - area.bottom - centerY) / density,
        )
        val bubbles = listOf(
            BubbleSpec(Symbol.CROP, context.getString(R.string.overlay_bubble_range), angles[0]) { showOptions(OptionKind.RANGE) },
            BubbleSpec(Symbol.VIEW_LIST, context.getString(R.string.overlay_bubble_display), angles[1]) { showOptions(OptionKind.DISPLAY) },
            BubbleSpec(Symbol.TRANSLATE, context.getString(R.string.overlay_bubble_language), angles[2]) { showOptions(OptionKind.LANGUAGE) },
        )
        val params = OverlayWindow.params(
            ringWidth,
            ringHeight,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = if (inwardRight) centerX else centerX - ringWidth
            y = windowY
        }
        val anchorYDp = (centerY - windowY) / density
        menu = OverlayWindow(context, windowManager, params) {
            BubbleRing(bubbles, inwardRight, anchorYDp, onBackgroundTap = { post(::dismissMenu) })
        }.apply {
            root.onOutsideTouch = { post(::dismissMenu) }
            show()
        }
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
            OptionKind.LANGUAGE -> quickLanguages.map { code ->
                MenuOption(Symbol.TRANSLATE, languageDisplayName(code, Locale.getDefault()), code == targetLanguage) {
                    scope.launch { settingsRepository.setTargetLanguage(code) }
                    post(::dismissMenu)
                }
            }
        }
        post {
            dismissMenu()
            openOptionWindow(options)
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

    private fun showSheet(outcome: TranslationOutcome) {
        dismissSheet()
        val params = OverlayWindow.params(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            // 뒤로 가기를 받으려고 포커스를 받는다. 시트가 떠 있는 동안만.
            0,
        )
        // 원문 위에 덮기(NA-22): 자리를 아는 번역 항목이 하나라도 있으면 막으로, 없으면 목록 시트로.
        val overItems = if (display == ResultDisplay.OVERLAY && outcome is TranslationOutcome.Translated) {
            overlayItems(outcome.items)
        } else {
            emptyList()
        }
        sheet = OverlayWindow(context, windowManager, params) {
            if (overItems.isNotEmpty()) {
                OverlayResult(overItems, onDismiss = { post(::dismissSheet) })
            } else {
                ResultSheet(outcome, display, onDismiss = { post(::dismissSheet) }, onCopy = ::copy)
            }
        }.apply {
            root.onBack = { post(::dismissSheet) }
            show()
        }
    }

    private fun dismissSheet() {
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

        /** 서비스를 다시 켜도 버튼이 마지막 자리에 뜨도록 (같은 화면 크기일 때만). 프로세스 안에서만 기억한다. */
        var lastPlacement: Pair<ButtonPlacement, ScreenArea>? = null
    }
}
