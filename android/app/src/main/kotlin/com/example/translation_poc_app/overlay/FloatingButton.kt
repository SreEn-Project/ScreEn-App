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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.geometry.Offset
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.ui.graphics.CompositingStrategy
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.translation_poc_app.R
import com.example.translation_poc_app.data.settings.CaptureRange
import com.example.translation_poc_app.data.settings.ResultDisplay

/** 버튼 창 크기 = 원 지름(설정 FL-07, 기본 52dp) + 그림자 여백 사방 8dp. */
internal const val BUTTON_SHADOW_MARGIN_DP = 16

internal fun buttonWindowDp(diameterDp: Int) = diameterDp + BUTTON_SHADOW_MARGIN_DP

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
internal fun FloatingButton(
    mode: CaptureRange,
    busy: Boolean,
    dragging: Boolean,
    diameterDp: Int,
    opacity: Float,
    auto: Boolean = false,
) {
    val colors = OverlayTheme.colors
    val scale by animateFloatAsState(if (dragging) 1.08f else 1f, label = "drag-scale")
    val description = stringResource(R.string.overlay_button_description)
    Box(Modifier.size(buttonWindowDp(diameterDp).dp).alpha(opacity), contentAlignment = Alignment.Center) {
        Box(
            modifier = Modifier
                .scale(scale)
                .size(diameterDp.dp)
                .overlayShadow(8.dp, CircleShape, colors.primary)
                .clip(CircleShape)
                .background(colors.surface)
                .semantics { contentDescription = description },
            contentAlignment = Alignment.Center,
        ) {
            SymbolIcon(mode.symbol(), colors.primary, size = (diameterDp / 2).dp)
            if (busy) BusyRing()
        }
        if (auto) AutoBadge(diameterDp, Modifier.align(Alignment.BottomEnd).padding(end = 6.dp, bottom = 6.dp))
    }
}

/** 자동 번역이 켜져 있다는 작고 둥근 표시. 탭하면 자동 번역이 시작된다. */
@Composable
private fun AutoBadge(diameterDp: Int, modifier: Modifier) {
    val colors = OverlayTheme.colors
    BasicText(
        text = stringResource(R.string.overlay_button_auto_badge),
        style = OverlayTheme.badge.copy(fontSize = (diameterDp / 5).coerceIn(8, 11).sp, color = colors.onPrimary),
        modifier = modifier
            .clip(RoundedCornerShape(50))
            .background(colors.primary)
            .padding(horizontal = 5.dp, vertical = 1.dp),
    )
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

/** 빠른 언어 목록의 한 줄. */
internal data class LanguageEntry(val label: String, val selected: Boolean, val onSelect: () -> Unit)

private enum class LanguageSide { SOURCE, TARGET }

private const val LANGUAGE_LIST_HEIGHT_DP = 172

/**
 * 빠른 언어 메뉴: 번역기 앱처럼 위쪽에 "원문 언어 ▾ ⇄ 번역 언어 ▾" 막대, 아래에 고정 높이 스크롤 목록.
 * 막대의 한쪽을 누르면 그쪽이 선택 상태(초록 테두리)가 되고, 목록에서 고르면 그쪽 언어가 바뀐다. ⇄는 두 언어를 맞바꾼다.
 * 고른 뒤에도 열려 있다. 값은 바뀌면 다시 읽도록 람다로 받는다.
 */
@Composable
internal fun LanguageMenu(
    sourceName: () -> String,
    targetName: () -> String,
    swapEnabled: () -> Boolean,
    swapDescription: String,
    onSwap: () -> Unit,
    source: () -> List<LanguageEntry>,
    target: () -> List<LanguageEntry>,
) {
    var side by remember { mutableStateOf(LanguageSide.TARGET) }
    MenuCard {
        Column(Modifier.width(224.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                LanguageTab(sourceName(), side == LanguageSide.SOURCE, Modifier.weight(1f)) { side = LanguageSide.SOURCE }
                SwapButton(swapEnabled(), swapDescription, onSwap)
                LanguageTab(targetName(), side == LanguageSide.TARGET, Modifier.weight(1f)) { side = LanguageSide.TARGET }
            }
            val entries = if (side == LanguageSide.SOURCE) source() else target()
            Column(
                Modifier
                    .fillMaxWidth()
                    .height(LANGUAGE_LIST_HEIGHT_DP.dp)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(2.dp),
            ) {
                entries.forEach { LanguageRow(it) }
            }
        }
    }
}

@Composable
private fun LanguageTab(name: String, focused: Boolean, modifier: Modifier, onClick: () -> Unit) {
    val colors = OverlayTheme.colors
    val shape = CircleShape
    val textColor = if (focused) colors.onPrimaryContainer else colors.onSurface
    Row(
        modifier = modifier
            .height(34.dp)
            .clip(shape)
            .background(if (focused) colors.primaryContainer else colors.surface)
            .border(if (focused) 1.5.dp else 1.dp, if (focused) colors.primary else colors.outline, shape)
            .pressable(onClick = onClick)
            .padding(horizontal = 8.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        BasicText(
            name,
            style = OverlayTheme.caption.copy(color = textColor, fontWeight = androidx.compose.ui.text.font.FontWeight.SemiBold),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f, fill = false),
        )
        Spacer(Modifier.width(4.dp))
        Canvas(Modifier.size(10.dp)) {
            val stroke = 1.6.dp.toPx()
            val w = size.width
            val h = size.height
            drawLine(textColor, Offset(w * 0.1f, h * 0.35f), Offset(w * 0.5f, h * 0.7f), stroke, StrokeCap.Round)
            drawLine(textColor, Offset(w * 0.5f, h * 0.7f), Offset(w * 0.9f, h * 0.35f), stroke, StrokeCap.Round)
        }
    }
}

/** ⇄ 맞바꾸기. 원문이 "자동"이면 바꿀 수 없어 흐리게 둔다. */
@Composable
private fun SwapButton(enabled: Boolean, description: String, onClick: () -> Unit) {
    val colors = OverlayTheme.colors
    val color = if (enabled) colors.onSurface else colors.outline
    Box(
        Modifier
            .size(32.dp)
            .clip(CircleShape)
            .pressable(enabled = enabled, onClick = onClick)
            .semantics { contentDescription = description },
        contentAlignment = Alignment.Center,
    ) {
        Canvas(Modifier.size(16.dp)) {
            val stroke = 1.8.dp.toPx()
            val w = size.width
            val h = size.height
            val top = h * 0.3f
            val bottom = h * 0.7f
            val head = w * 0.18f
            // 위: 오른쪽 화살표, 아래: 왼쪽 화살표.
            drawLine(color, Offset(w * 0.08f, top), Offset(w * 0.92f, top), stroke, StrokeCap.Round)
            drawLine(color, Offset(w * 0.92f - head, top - head), Offset(w * 0.92f, top), stroke, StrokeCap.Round)
            drawLine(color, Offset(w * 0.92f - head, top + head), Offset(w * 0.92f, top), stroke, StrokeCap.Round)
            drawLine(color, Offset(w * 0.08f, bottom), Offset(w * 0.92f, bottom), stroke, StrokeCap.Round)
            drawLine(color, Offset(w * 0.08f + head, bottom - head), Offset(w * 0.08f, bottom), stroke, StrokeCap.Round)
            drawLine(color, Offset(w * 0.08f + head, bottom + head), Offset(w * 0.08f, bottom), stroke, StrokeCap.Round)
        }
    }
}

@Composable
private fun LanguageRow(entry: LanguageEntry) {
    val colors = OverlayTheme.colors
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(36.dp)
            .clip(CircleShape)
            .background(if (entry.selected) colors.primaryContainer else colors.surface)
            .pressable { entry.onSelect() }
            .padding(horizontal = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        BasicText(
            entry.label,
            style = OverlayTheme.caption.copy(fontSize = 14.sp, color = if (entry.selected) colors.onPrimaryContainer else colors.onSurface),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f),
        )
        if (entry.selected) SymbolIcon(Symbol.CHECK, colors.onPrimaryContainer, size = 18.dp)
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

/** 길게 누른 채 버블 가운데에서 이 거리 안이면 그 버블 위에 있는 것으로 본다. 버블 사이(중심 간격 약 70dp)보다 좁게. */
internal const val BUBBLE_HIT_RADIUS_DP = 34

/** 이름표는 아이콘 옆(화면 안쪽)에 놓는다. 이름표 칸 너비와 아이콘과의 간격. */
internal const val BUBBLE_LABEL_WIDTH_DP = 100
internal const val BUBBLE_LABEL_GAP_DP = 6
internal const val BUBBLE_CELL_WIDTH_DP = BUBBLE_DIAMETER_DP + BUBBLE_LABEL_GAP_DP + BUBBLE_LABEL_WIDTH_DP

/**
 * 버블 창 크기 (dp). 버튼 가운데에서 바깥쪽으로 [BUBBLE_RING_OUTER_DP], 안쪽으로 [BUBBLE_RING_INNER_DP]를 잡는다.
 * 안쪽은 버블 아이콘 + 그 옆 이름표까지, 바깥쪽은 아이콘 반 칸 + 여백이다.
 * 눌림 · 튀어나오는 애니메이션 · 그림자가 창 밖으로 나가 잘리지 않게 [BUBBLE_RING_PAD_DP] 여백을 둔다.
 * 높이는 위 · 아래 끝 버블의 아이콘까지 양쪽으로 잡는다 ([OverlayGeometry.bubbleAngles]가 끝에서 버블을 안쪽으로 몰아 준다).
 */
internal const val BUBBLE_RING_PAD_DP = 20
internal const val BUBBLE_RING_OUTER_DP = BUBBLE_DIAMETER_DP / 2 + BUBBLE_RING_PAD_DP
internal const val BUBBLE_RING_INNER_DP =
    BUBBLE_RADIUS_DP + BUBBLE_DIAMETER_DP / 2 + BUBBLE_LABEL_GAP_DP + BUBBLE_LABEL_WIDTH_DP + BUBBLE_RING_PAD_DP
internal const val BUBBLE_RING_WIDTH_DP = BUBBLE_RING_OUTER_DP + BUBBLE_RING_INNER_DP
internal const val BUBBLE_RING_HEIGHT_DP = 2 * (BUBBLE_RADIUS_DP + BUBBLE_DIAMETER_DP / 2 + BUBBLE_RING_PAD_DP)

/**
 * O-02 버블 메뉴: 길게 누르면 버튼 주위(화면 안쪽 호)에 뜨는 카테고리 버블. 아이콘 원 + 그 옆(화면 안쪽) 이름표라 서로 겹치지 않는다.
 * [anchorXDp] · [anchorYDp]는 창 왼쪽 · 위쪽에서 버튼 가운데까지의 거리, [inwardRight]는 버튼이 왼쪽 가장자리일 때 true (안쪽이 오른쪽).
 */
@Composable
internal fun BubbleRing(
    bubbles: List<BubbleSpec>,
    inwardRight: Boolean,
    anchorXDp: Float,
    anchorYDp: Float,
    hovered: () -> Int,
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
            val lifted = pressed || hovered() == index
            val liftScale by animateFloatAsState(if (lifted) 1.12f else 1f, label = "bubble-lift")
            val rad = Math.toRadians(bubble.angleDeg.toDouble())
            val dx = (BUBBLE_RADIUS_DP * kotlin.math.cos(rad)).toFloat() * grow
            val dy = (BUBBLE_RADIUS_DP * kotlin.math.sin(rad)).toFloat() * grow
            val centerX = anchorXDp + if (inwardRight) dx else -dx
            val centerY = anchorYDp + dy
            val visible = grow.coerceIn(0f, 1f)
            // 칸은 아이콘 + 이름표. 아이콘 가운데가 호 위에 오도록 바깥쪽 끝을 맞춘다.
            val cellLeft = if (inwardRight) centerX - BUBBLE_DIAMETER_DP / 2f else centerX + BUBBLE_DIAMETER_DP / 2f - BUBBLE_CELL_WIDTH_DP
            Box(
                modifier = Modifier
                    .offset(x = cellLeft.dp, y = (centerY - BUBBLE_DIAMETER_DP / 2f).dp)
                    .size(BUBBLE_CELL_WIDTH_DP.dp, BUBBLE_DIAMETER_DP.dp)
                    // 알파를 겹쳐 그리는 레이어로 처리하면 이름표가 칸 밖에서 잘린다: 요소마다 따로 알파를 준다.
                    .graphicsLayer {
                        val s = (0.4f + 0.6f * visible) * liftScale
                        scaleX = s
                        scaleY = s
                        alpha = visible
                        compositingStrategy = CompositingStrategy.ModulateAlpha
                        // 커지는 기준은 아이콘 가운데.
                        val pivot = (BUBBLE_DIAMETER_DP / 2f) / BUBBLE_CELL_WIDTH_DP
                        transformOrigin = TransformOrigin(if (inwardRight) pivot else 1f - pivot, 0.5f)
                    }
                    // 누르거나 손가락이 올라간 버블은 맨 앞.
                    .zIndex(if (lifted) bubbles.size.toFloat() + 1f else (bubbles.size - index).toFloat()),
                contentAlignment = if (inwardRight) Alignment.CenterStart else Alignment.CenterEnd,
            ) {
                Row(
                    modifier = Modifier.clickable(interactionSource = pressSource, indication = null, role = Role.Button) { bubble.onClick() },
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    val icon: @Composable () -> Unit = {
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
                    }
                    val label: @Composable () -> Unit = {
                        BasicText(
                            bubble.label,
                            style = OverlayTheme.badge.copy(color = colors.onSurface, textAlign = TextAlign.Center),
                            maxLines = 1,
                            softWrap = false,
                            modifier = Modifier
                                .clip(RoundedCornerShape(50))
                                .background(colors.surface)
                                .padding(horizontal = 8.dp, vertical = 2.dp),
                        )
                    }
                    if (inwardRight) {
                        icon()
                        Spacer(Modifier.width(BUBBLE_LABEL_GAP_DP.dp))
                        label()
                    } else {
                        label()
                        Spacer(Modifier.width(BUBBLE_LABEL_GAP_DP.dp))
                        icon()
                    }
                }
            }
        }
    }
}
