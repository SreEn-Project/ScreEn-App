package com.example.translation_poc_app.overlay

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.example.translation_poc_app.R
import com.example.translation_poc_app.data.settings.CaptureRange

/** 버튼 창 크기 = 원 52dp + 그림자 여백 사방 8dp. */
internal const val BUTTON_DIAMETER_DP = 52
internal const val BUTTON_WINDOW_DP = BUTTON_DIAMETER_DP + 16

/** 모드 메뉴 항목 (O-02). 앞의 셋은 캡처 범위를 고르고, 마지막은 고정 영역을 다시 지정한다. */
internal enum class ModeMenuItem(val symbol: Symbol, val label: Int, val range: CaptureRange?) {
    FULL_SCREEN(Symbol.FULLSCREEN, R.string.overlay_mode_full_screen, CaptureRange.FULL_SCREEN),
    DRAG_REGION(Symbol.CROP, R.string.overlay_mode_drag_region, CaptureRange.DRAG_REGION),
    FIXED_REGION(Symbol.PUSH_PIN, R.string.overlay_mode_fixed_region, CaptureRange.FIXED_REGION),
    EDIT_FIXED_REGION(Symbol.EDIT, R.string.overlay_mode_edit_fixed_region, null),
    ;

}

internal fun CaptureRange.symbol(): Symbol = when (this) {
    CaptureRange.FULL_SCREEN -> Symbol.FULLSCREEN
    CaptureRange.DRAG_REGION -> Symbol.CROP
    CaptureRange.FIXED_REGION -> Symbol.PUSH_PIN
}

/** O-01 플로팅 버튼: 흰 원 + 초록 그림자, 현재 모드 아이콘. 번역 중에는 둘레에 도는 호. */
@Composable
internal fun FloatingButton(mode: CaptureRange, busy: Boolean, dragging: Boolean) {
    val colors = OverlayTheme.colors
    val scale by animateFloatAsState(if (dragging) 1.08f else 1f, label = "drag-scale")
    val description = stringResource(R.string.overlay_button_description)
    Box(Modifier.size(BUTTON_WINDOW_DP.dp), contentAlignment = Alignment.Center) {
        Box(
            modifier = Modifier
                .scale(scale)
                .size(BUTTON_DIAMETER_DP.dp)
                .overlayShadow(8.dp, CircleShape, colors.primary)
                .clip(CircleShape)
                .background(colors.surface)
                .semantics { contentDescription = description },
            contentAlignment = Alignment.Center,
        ) {
            SymbolIcon(mode.symbol(), colors.primary, size = 26.dp)
            if (busy) BusyRing()
        }
    }
}

@Composable
private fun BusyRing() {
    val colors = OverlayTheme.colors
    val rotation by rememberInfiniteTransition(label = "busy").animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(tween(900, easing = LinearEasing), RepeatMode.Restart),
        label = "busy-rotation",
    )
    Canvas(Modifier.fillMaxSize().padding(3.dp)) {
        val stroke = 3.dp.toPx()
        drawArc(
            color = colors.primaryContainer,
            startAngle = 0f,
            sweepAngle = 360f,
            useCenter = false,
            style = Stroke(stroke),
        )
        drawArc(
            color = colors.primary,
            startAngle = rotation - 90f,
            sweepAngle = 100f,
            useCenter = false,
            style = Stroke(stroke, cap = StrokeCap.Round),
        )
    }
}

/** 끄는 동안 아래쪽에 뜨는 닫기 영역. 버튼이 들어오면 초록으로 채워지고 커진다. */
internal const val CLOSE_WINDOW_DP = 96
internal const val CLOSE_TARGET_DP = 60

@Composable
internal fun CloseTarget(active: Boolean) {
    val colors = OverlayTheme.colors
    val scale by animateFloatAsState(if (active) 1.2f else 1f, label = "close-scale")
    val description = stringResource(R.string.overlay_close_description)
    Box(Modifier.size(CLOSE_WINDOW_DP.dp), contentAlignment = Alignment.Center) {
        Box(
            modifier = Modifier
                .scale(scale)
                .size(CLOSE_TARGET_DP.dp)
                .overlayShadow(8.dp, CircleShape, colors.primary)
                .clip(CircleShape)
                .background(if (active) colors.primary else colors.surface)
                .semantics { contentDescription = description },
            contentAlignment = Alignment.Center,
        ) {
            SymbolIcon(Symbol.CLOSE, if (active) colors.onPrimary else colors.onSurface, size = 28.dp)
        }
    }
}

/** O-02 캡처 모드 메뉴: 버튼 옆에 펼쳐지는 흰 카드. 고른 모드는 연한 초록 줄. */
@Composable
internal fun ModeMenu(current: CaptureRange, onSelect: (ModeMenuItem) -> Unit) {
    val colors = OverlayTheme.colors
    val shape = RoundedCornerShape(24.dp)
    // 그림자가 잘리지 않도록 창 안에 여백을 둔다.
    Box(Modifier.padding(12.dp)) {
        Column(
            modifier = Modifier
                .width(IntrinsicSize.Max)
                .overlayShadow(12.dp, shape, colors.primary)
                .clip(shape)
                .background(colors.surface)
                .padding(8.dp),
            verticalArrangement = Arrangement.spacedBy(2.dp),
        ) {
            ModeMenuItem.entries.forEach { item ->
                val selected = item.range == current
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(16.dp))
                        .background(if (selected) colors.primaryContainer else colors.surface)
                        .pressable { onSelect(item) }
                        .padding(start = 8.dp, end = 12.dp, top = 8.dp, bottom = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    SymbolBadge(item.symbol, size = 36.dp, filled = !selected)
                    Spacer(Modifier.width(12.dp))
                    BasicText(
                        stringResource(item.label),
                        style = OverlayTheme.body.copy(color = if (selected) colors.onPrimaryContainer else colors.onSurface),
                    )
                }
            }
        }
    }
}
