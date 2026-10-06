package com.example.translation_poc_app.overlay

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.WindowManager
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp

/** 토스트 모양: 오류만 error 색 아이콘, 나머지는 primary (Flutter `AppToast`와 같은 규칙). */
enum class ToastKind { SUCCESS, INFO, ERROR }

/**
 * 오버레이 토스트 (Flutter `AppToast`와 같은 모양): 흰 알약 + 초록 그림자 + 아이콘 + 한 줄 글자.
 * 시스템 Toast 대신 쓴다. 터치를 가로채지 않고 잠깐 뒤 스스로 사라진다. 한 번에 하나만 뜬다.
 * 메인 스레드에서만 부른다.
 */
class OverlayToast(private val context: Context) {
    private val windowManager = context.getSystemService(WindowManager::class.java)
    private val handler = Handler(Looper.getMainLooper())
    private val density = context.resources.displayMetrics.density

    private var window: OverlayWindow? = null
    private var message by mutableStateOf("")
    private var kind by mutableStateOf(ToastKind.INFO)
    private val dismiss = Runnable { dismiss() }

    fun show(text: String, toastKind: ToastKind = ToastKind.INFO, durationMs: Long = DURATION_MS) {
        message = text
        kind = toastKind
        if (window == null) {
            val params = OverlayWindow.params(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
            ).apply {
                gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
                y = (BOTTOM_MARGIN_DP * density).toInt()
            }
            window = OverlayWindow(context, windowManager, params) { ToastPill(message, kind) }.also {
                runCatching { it.show() }
            }
        }
        handler.removeCallbacks(dismiss)
        handler.postDelayed(dismiss, durationMs)
    }

    fun dismiss() {
        handler.removeCallbacks(dismiss)
        window?.destroy()
        window = null
    }

    companion object {
        private const val DURATION_MS = 3_200L
        private const val BOTTOM_MARGIN_DP = 96
    }
}

/** 흰 알약 + 그림자 + 아이콘 + 글자 (Flutter `AppToast`). */
@Composable
fun ToastPill(text: String, kind: ToastKind, modifier: Modifier = Modifier) {
    val colors = OverlayTheme.colors
    val (symbol, tint) = when (kind) {
        ToastKind.SUCCESS -> Symbol.CHECK to colors.primary
        ToastKind.INFO -> Symbol.AUTO_AWESOME to colors.primary
        ToastKind.ERROR -> Symbol.ERROR to colors.error
    }
    // 그림자가 잘리지 않게 바깥에 여백을 둔다.
    Box(modifier.padding(horizontal = 20.dp, vertical = 16.dp)) {
        Row(
            modifier = Modifier
                .widthIn(max = 340.dp)
                .overlayShadow(8.dp, CircleShape, colors.primary)
                .clip(CircleShape)
                .background(colors.surface)
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            SymbolIcon(symbol, tint, size = 20.dp)
            Box(Modifier.padding(start = 8.dp))
            BasicText(
                text,
                style = OverlayTheme.label.copy(color = colors.onSurface),
                maxLines = 3,
                overflow = TextOverflow.Ellipsis,
            )
        }
    }
}
