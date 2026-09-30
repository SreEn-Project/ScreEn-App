package com.example.translation_poc_app.overlay

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.ViewConfiguration
import android.view.WindowInsets
import android.view.WindowManager
import android.widget.FrameLayout
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.ComposeView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleRegistry
import androidx.lifecycle.setViewTreeLifecycleOwner
import androidx.savedstate.SavedStateRegistry
import androidx.savedstate.SavedStateRegistryController
import androidx.savedstate.SavedStateRegistryOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner
import kotlin.math.hypot

/**
 * 다른 앱 위에 뜨는 창 하나 (TYPE_APPLICATION_OVERLAY) + 그 안의 Compose 화면.
 * 서비스에는 Activity가 없으므로 ComposeView가 필요로 하는 Lifecycle · SavedState 주인을 창마다 따로 둔다.
 */
internal class OverlayWindow(
    context: Context,
    private val windowManager: WindowManager,
    val params: WindowManager.LayoutParams,
    content: @Composable () -> Unit,
) {
    private val owner = OverlayViewOwner()
    val root = OverlayRootView(context)
    private val composeView = ComposeView(context).apply {
        setContent { OverlayTheme(content) }
    }

    var isShown = false
        private set

    init {
        root.addView(composeView)
        owner.attach(root)
    }

    fun show() {
        if (isShown) return
        windowManager.addView(root, params)
        isShown = true
    }

    fun update() {
        if (isShown) windowManager.updateViewLayout(root, params)
    }

    fun hide() {
        if (!isShown) return
        windowManager.removeViewImmediate(root)
        isShown = false
    }

    fun destroy() {
        hide()
        composeView.disposeComposition()
        owner.destroy()
    }

    companion object {
        /**
         * 오버레이 창 설정. 시스템 막대 영역까지 차지하게 해(fitInsets 없음) 좌표를 화면 기준으로 맞춘다.
         * 막대를 피하는 것은 [ScreenArea]로 계산한다.
         */
        fun params(width: Int, height: Int, flags: Int): WindowManager.LayoutParams =
            WindowManager.LayoutParams(
                width,
                height,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                flags or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = android.view.Gravity.TOP or android.view.Gravity.START
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) setFitInsetsTypes(0)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
                }
            }

        /** 지금 화면 크기와 시스템 막대 · 컷아웃 두께. */
        fun screenArea(context: Context, windowManager: WindowManager): ScreenArea {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val metrics = windowManager.currentWindowMetrics
                val insets = metrics.windowInsets.getInsetsIgnoringVisibility(
                    WindowInsets.Type.systemBars() or WindowInsets.Type.displayCutout(),
                )
                return ScreenArea(
                    metrics.bounds.width(),
                    metrics.bounds.height(),
                    insets.left,
                    insets.top,
                    insets.right,
                    insets.bottom,
                )
            }
            val display = context.resources.displayMetrics
            @Suppress("DEPRECATION")
            val real = android.util.DisplayMetrics().also { windowManager.defaultDisplay.getRealMetrics(it) }
            val density = display.density
            return ScreenArea(real.widthPixels, real.heightPixels, top = (24 * density).toInt(), bottom = (48 * density).toInt())
        }
    }
}

/** 오버레이 창의 뿌리 뷰. 뒤로 가기 · 창 바깥 터치 · 버튼 제스처를 받는다. */
internal class OverlayRootView(context: Context) : FrameLayout(context) {
    /** 설정하면 뒤로 가기를 받는다 (창이 포커스를 받을 수 있어야 한다). */
    var onBack: (() -> Unit)? = null

    /** FLAG_WATCH_OUTSIDE_TOUCH 창에서 바깥을 누르면. */
    var onOutsideTouch: (() -> Unit)? = null

    /** 설정하면 모든 터치를 여기서 처리한다 (플로팅 버튼: 창이 손가락을 따라 움직여 화면 좌표가 필요하다). */
    var touchHandler: ((MotionEvent) -> Boolean)? = null

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val back = onBack
        if (event.keyCode == KeyEvent.KEYCODE_BACK && back != null) {
            if (event.action == KeyEvent.ACTION_UP) back()
            return true
        }
        return super.dispatchKeyEvent(event)
    }

    @SuppressLint("ClickableViewAccessibility")
    override fun dispatchTouchEvent(event: MotionEvent): Boolean {
        if (event.actionMasked == MotionEvent.ACTION_OUTSIDE) {
            onOutsideTouch?.invoke()
            return true
        }
        touchHandler?.let { return it(event) }
        return super.dispatchTouchEvent(event)
    }
}

/**
 * 플로팅 버튼 제스처 (NA-18): 탭 · 길게 누르기 · 끌기. 창이 손가락을 따라 움직이므로 화면 좌표(rawX/Y)로 계산한다.
 * 길게 누른 뒤에는 끌기를 시작하지 않는다 (메뉴가 열린 상태).
 */
internal class ButtonGestures(
    context: Context,
    private val onDown: () -> Unit,
    private val onTap: () -> Unit,
    private val onLongPress: () -> Unit,
    private val onDragStart: () -> Unit,
    private val onDrag: (dx: Int, dy: Int) -> Unit,
    private val onDragEnd: () -> Unit,
) {
    private val touchSlop = ViewConfiguration.get(context).scaledTouchSlop
    private val longPressTimeout = ViewConfiguration.getLongPressTimeout().toLong()
    private val handler = Handler(Looper.getMainLooper())
    private var downX = 0f
    private var downY = 0f
    private var dragging = false
    private var longPressed = false
    private val longPress = Runnable {
        longPressed = true
        onLongPress()
    }

    fun onTouch(event: MotionEvent): Boolean {
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                downX = event.rawX
                downY = event.rawY
                dragging = false
                longPressed = false
                onDown()
                handler.postDelayed(longPress, longPressTimeout)
            }
            MotionEvent.ACTION_MOVE -> {
                val dx = event.rawX - downX
                val dy = event.rawY - downY
                if (!dragging && !longPressed && hypot(dx, dy) > touchSlop) {
                    dragging = true
                    handler.removeCallbacks(longPress)
                    onDragStart()
                }
                if (dragging) onDrag(dx.toInt(), dy.toInt())
            }
            MotionEvent.ACTION_UP -> {
                handler.removeCallbacks(longPress)
                when {
                    dragging -> onDragEnd()
                    !longPressed -> onTap()
                }
                dragging = false
            }
            MotionEvent.ACTION_CANCEL -> {
                handler.removeCallbacks(longPress)
                if (dragging) onDragEnd()
                dragging = false
            }
        }
        return true
    }

    fun cancel() = handler.removeCallbacks(longPress)
}

/** 창 하나의 Lifecycle · SavedState 주인. 창을 만들 때 RESUMED, 없앨 때 DESTROYED. */
private class OverlayViewOwner : SavedStateRegistryOwner {
    private val lifecycleRegistry = LifecycleRegistry(this)
    private val savedStateController = SavedStateRegistryController.create(this)

    override val lifecycle: Lifecycle get() = lifecycleRegistry
    override val savedStateRegistry: SavedStateRegistry get() = savedStateController.savedStateRegistry

    fun attach(view: android.view.View) {
        savedStateController.performAttach()
        savedStateController.performRestore(null)
        lifecycleRegistry.currentState = Lifecycle.State.RESUMED
        view.setViewTreeLifecycleOwner(this)
        view.setViewTreeSavedStateRegistryOwner(this)
    }

    fun destroy() {
        lifecycleRegistry.currentState = Lifecycle.State.DESTROYED
    }
}
