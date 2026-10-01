package com.example.translation_poc_app.overlay

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.ui.zIndex
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.example.translation_poc_app.R
import com.example.translation_poc_app.data.settings.CaptureRange
import com.example.translation_poc_app.data.settings.ResultDisplay

/** 버튼 창 크기 = 원 52dp + 그림자 여백 사방 8dp. */
internal const val BUTTON_DIAMETER_DP = 52
internal const val BUTTON_WINDOW_DP = BUTTON_DIAMETER_DP + 16

/** 캡처 범위 옵션 (O-02). 고르면 그 캡처 범위가 된다. 고정 영역은 고르는 즉시 영역 편집 화면이 열린다. */
internal enum class ModeMenuItem(val symbol: Symbol, val label: Int, val range: CaptureRange) {
    FULL_SCREEN(Symbol.FULLSCREEN, R.string.overlay_mode_full_screen, CaptureRange.FULL_SCREEN),
    DRAG_REGION(Symbol.CROP, R.string.overlay_mode_drag_region, CaptureRange.DRAG_REGION),
    FIXED_REGION(Symbol.PUSH_PIN, R.string.overlay_mode_fixed_region, CaptureRange.FIXED_REGION),
    ;
}

/** 결과 표시 옵션 (O-02). 원문 위에 덮기는 NA-22에서 동작한다 (그 전에는 목록으로 보인다). */
internal enum class DisplayMenuItem(val symbol: Symbol, val label: Int, val display: ResultDisplay) {
    LIST(Symbol.VIEW_LIST, R.string.overlay_display_list, ResultDisplay.LIST),
    PARAGRAPH(Symbol.NOTES, R.string.overlay_display_paragraph, ResultDisplay.PARAGRAPH),
    OVERLAY(Symbol.FLIP_TO_FRONT, R.string.overlay_display_overlay, ResultDisplay.OVERLAY),
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

/** 옵션 메뉴 한 줄. 고른 줄은 연한 초록. */
internal data class MenuOption(val symbol: Symbol, val label: String, val selected: Boolean, val onSelect: () -> Unit)

/** O-02 옵션 메뉴 (캡처 범위 · 결과 표시 · 설정 공용): 버튼 옆에 펼쳐지는 흰 카드. */
@Composable
internal fun OptionMenu(options: List<MenuOption>) {
    MenuCard {
        Column(Modifier.width(IntrinsicSize.Max), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            options.forEach { OptionRow(it) }
        }
    }
}

/**
 * 빠른 언어 메뉴: 왼쪽 "번역할 언어"(원문 인식), 오른쪽 "번역될 언어"(결과). 고른 뒤에도 열려 있어 둘을 이어서 고른다.
 * 목록은 고른 값이 바뀌면 다시 읽도록 람다로 받는다.
 */
@Composable
internal fun LanguageMenu(
    sourceTitle: String,
    targetTitle: String,
    source: () -> List<MenuOption>,
    target: () -> List<MenuOption>,
) {
    MenuCard {
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            LanguageColumn(sourceTitle, source())
            LanguageColumn(targetTitle, target())
        }
    }
}

@Composable
private fun LanguageColumn(title: String, options: List<MenuOption>) {
    val colors = OverlayTheme.colors
    Column(Modifier.width(IntrinsicSize.Max), verticalArrangement = Arrangement.spacedBy(2.dp)) {
        BasicText(
            title,
            style = OverlayTheme.badge.copy(color = colors.onSurfaceVariant),
            modifier = Modifier.padding(start = 8.dp, top = 4.dp, bottom = 4.dp),
        )
        options.forEach { OptionRow(it) }
    }
}

@Composable
private fun MenuCard(content: @Composable () -> Unit) {
    val colors = OverlayTheme.colors
    val shape = RoundedCornerShape(24.dp)
    // 그림자가 잘리지 않도록 창 안에 여백을 둔다.
    Box(Modifier.padding(12.dp)) {
        Box(
            Modifier
                .overlayShadow(12.dp, shape, colors.primary)
                .clip(shape)
                .background(colors.surface)
                .padding(8.dp),
        ) { content() }
    }
}

@Composable
private fun OptionRow(option: MenuOption) {
    val colors = OverlayTheme.colors
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(if (option.selected) colors.primaryContainer else colors.surface)
            .pressable { option.onSelect() }
            .padding(start = 8.dp, end = 12.dp, top = 8.dp, bottom = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        SymbolBadge(option.symbol, size = 36.dp, filled = !option.selected)
        Spacer(Modifier.width(12.dp))
        BasicText(
            option.label,
            style = OverlayTheme.body.copy(
                color = if (option.selected) colors.onPrimaryContainer else colors.onSurface,
            ),
        )
    }
}

/** 버블 한 개 (O-02). [angleDeg]는 안쪽(화면 가운데 쪽) 방향 기준 각도. */
internal data class BubbleSpec(val symbol: Symbol, val label: String, val angleDeg: Float, val onClick: () -> Unit)

/** 버블은 버튼 가운데에서 [BUBBLE_RADIUS_DP]만큼 떨어진 안쪽 호 위에 놓는다. */
internal const val BUBBLE_RADIUS_DP = 96
internal const val BUBBLE_DIAMETER_DP = 52
internal const val BUBBLE_CELL_WIDTH_DP = 76
internal const val BUBBLE_CELL_HEIGHT_DP = BUBBLE_DIAMETER_DP + 24

/**
 * 버블 창 크기 (dp). 버튼 가운데에서 바깥쪽으로 [BUBBLE_RING_OUTER_DP], 안쪽으로 [BUBBLE_RING_INNER_DP]를 잡는다.
 * 바깥쪽에도 버블 반 칸 + 여백을 두어 위 · 아래 끝에서 90°로 몰린 버블이 잘리지 않게 하고,
 * 눌림 · 튀어나오는 애니메이션 · 그림자가 창 밖으로 나가 잘리지 않게 [BUBBLE_RING_PAD_DP] 여백을 둔다.
 * 높이는 반지름 + 이름표까지 양쪽으로 잡는다 ([OverlayGeometry.bubbleAngles]가 위 · 아래 끝에서 버블을 안쪽으로 몰아 준다).
 */
internal const val BUBBLE_RING_PAD_DP = 20
internal const val BUBBLE_RING_OUTER_DP = BUBBLE_CELL_WIDTH_DP / 2 + BUBBLE_RING_PAD_DP
internal const val BUBBLE_RING_INNER_DP = BUBBLE_RADIUS_DP + BUBBLE_CELL_WIDTH_DP / 2 + BUBBLE_RING_PAD_DP
internal const val BUBBLE_RING_WIDTH_DP = BUBBLE_RING_OUTER_DP + BUBBLE_RING_INNER_DP
internal const val BUBBLE_RING_HEIGHT_DP = 2 * (BUBBLE_RADIUS_DP + BUBBLE_DIAMETER_DP / 2 + 24 + BUBBLE_RING_PAD_DP)

/**
 * O-02 버블 메뉴: 길게 누르면 버튼 주위(화면 안쪽 호)에 뜨는 카테고리 버블. 아이콘 원 + 아래 이름표.
 * [anchorXDp] · [anchorYDp]는 창 왼쪽 · 위쪽에서 버튼 가운데까지의 거리, [inwardRight]는 버튼이 왼쪽 가장자리일 때 true (안쪽이 오른쪽).
 */
@Composable
internal fun BubbleRing(
    bubbles: List<BubbleSpec>,
    inwardRight: Boolean,
    anchorXDp: Float,
    anchorYDp: Float,
    onBackgroundTap: () -> Unit,
) {
    val colors = OverlayTheme.colors
    var shown by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) { shown = true }
    val grow by animateFloatAsState(
        if (shown) 1f else 0f,
        animationSpec = spring(dampingRatio = 0.6f, stiffness = 400f),
        label = "bubble-grow",
    )
    Box(Modifier.size(BUBBLE_RING_WIDTH_DP.dp, BUBBLE_RING_HEIGHT_DP.dp).pressable(onClick = onBackgroundTap)) {
        bubbles.forEachIndexed { index, bubble ->
            val pressSource = remember { MutableInteractionSource() }
            val pressed by pressSource.collectIsPressedAsState()
            val rad = Math.toRadians(bubble.angleDeg.toDouble())
            val dx = (BUBBLE_RADIUS_DP * kotlin.math.cos(rad)).toFloat() * grow
            val dy = (BUBBLE_RADIUS_DP * kotlin.math.sin(rad)).toFloat() * grow
            val centerX = anchorXDp + if (inwardRight) dx else -dx
            val centerY = anchorYDp + dy
            val visible = grow.coerceIn(0f, 1f)
            Column(
                modifier = Modifier
                    .offset(
                        x = (centerX - BUBBLE_CELL_WIDTH_DP / 2f).dp,
                        y = (centerY - BUBBLE_DIAMETER_DP / 2f).dp,
                    )
                    .width(BUBBLE_CELL_WIDTH_DP.dp)
                    .scale(0.4f + 0.6f * visible)
                    .alpha(visible)
                    // 위 버블이 먼저 그려지면 아래 버블에 이름표가 가려진다: 위쪽이 앞, 누르고 있는 버블은 맨 앞.
                    .zIndex(if (pressed) bubbles.size.toFloat() + 1f else (bubbles.size - index).toFloat())
                    .pressable(interactionSource = pressSource) { bubble.onClick() },
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Box(
                    modifier = Modifier
                        .size(BUBBLE_DIAMETER_DP.dp)
                        .overlayShadow(8.dp, CircleShape, colors.primary)
                        .clip(CircleShape)
                        .background(colors.surface)
                        .semantics { contentDescription = bubble.label },
                    contentAlignment = Alignment.Center,
                ) {
                    SymbolIcon(bubble.symbol, colors.primary, size = 26.dp)
                }
                Spacer(Modifier.height(4.dp))
                BasicText(
                    bubble.label,
                    style = OverlayTheme.badge.copy(color = colors.onSurface, textAlign = TextAlign.Center),
                    maxLines = 1,
                    softWrap = false,
                    modifier = Modifier
                        .wrapContentWidth(Alignment.CenterHorizontally, unbounded = true)
                        .clip(RoundedCornerShape(50))
                        .background(colors.surface)
                        .padding(horizontal = 8.dp, vertical = 2.dp),
                )
            }
        }
    }
}
