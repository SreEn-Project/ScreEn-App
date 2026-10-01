package com.example.translation_poc_app.overlay

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/*
 * 오버레이용 자체 컴포넌트. Flutter lib/core/ui 와 같은 모양(design.md "컴포넌트")을 Compose로 옮긴 것.
 * Material 컴포넌트는 쓰지 않는다.
 */

/** 눌리면 97% 크기 + 살짝 흐려짐. 물결 효과 없음 (Flutter `Pressable`). */
@Composable
fun Modifier.pressable(
    enabled: Boolean = true,
    role: Role = Role.Button,
    interactionSource: MutableInteractionSource? = null,
    onClick: () -> Unit,
): Modifier {
    val interaction = interactionSource ?: remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    return this
        .graphicsLayer {
            val scale = if (pressed) 0.97f else 1f
            scaleX = scale
            scaleY = scale
            alpha = if (pressed) 0.85f else 1f
        }
        .clickable(interactionSource = interaction, indication = null, enabled = enabled, role = role, onClick = onClick)
}

/** 초록으로 살짝 물든 그림자 (design.md 카드 그림자). */
fun Modifier.overlayShadow(elevation: Dp, shape: androidx.compose.ui.graphics.Shape, color: Color): Modifier =
    shadow(elevation, shape, clip = false, ambientColor = color, spotColor = color)

enum class PillStyle { PRIMARY, SECONDARY }

/** 알약 버튼 (Flutter `AppButton`). primary = 초록 알약, secondary = 연한 배경 알약. */
@Composable
fun PillButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    style: PillStyle = PillStyle.PRIMARY,
    icon: Symbol? = null,
    enabled: Boolean = true,
) {
    val colors = OverlayTheme.colors
    val background = if (style == PillStyle.PRIMARY) colors.primary else colors.background
    val content = if (style == PillStyle.PRIMARY) colors.onPrimary else colors.onSurface
    Row(
        modifier = modifier
            .alpha(if (enabled) 1f else 0.4f)
            .then(
                if (style == PillStyle.PRIMARY && enabled) {
                    Modifier.overlayShadow(8.dp, CircleShape, colors.primary)
                } else {
                    Modifier
                },
            )
            .clip(CircleShape)
            .background(background)
            .pressable(enabled = enabled, onClick = onClick)
            .heightIn(min = 48.dp)
            .padding(horizontal = 20.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = androidx.compose.foundation.layout.Arrangement.Center,
    ) {
        if (icon != null) {
            SymbolIcon(icon, content, size = 20.dp)
            Box(Modifier.size(8.dp))
        }
        BasicText(text, style = OverlayTheme.label.copy(color = content))
    }
}

/** 배경 없는 원형 아이콘 버튼 (Flutter `AppIconButton` plain). */
@Composable
fun PlainIconButton(symbol: Symbol, description: String, color: Color, onClick: () -> Unit, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .size(40.dp)
            .clip(CircleShape)
            .pressable(onClick = onClick)
            .semantics { contentDescription = description },
        contentAlignment = Alignment.Center,
    ) {
        SymbolIcon(symbol, color, size = 22.dp)
    }
}

/** 작은 연두 배지 (Flutter `AppBadge`). */
@Composable
fun OverlayBadge(text: String, modifier: Modifier = Modifier) {
    val colors = OverlayTheme.colors
    BasicText(
        text = text,
        style = OverlayTheme.badge.copy(color = colors.onPrimaryContainer),
        modifier = modifier
            .clip(RoundedCornerShape(50))
            .background(colors.primaryContainer)
            .padding(horizontal = 10.dp, vertical = 4.dp),
    )
}

/** 연한 초록 원 + 선 아이콘 (Flutter `IconBadge`). */
@Composable
fun SymbolBadge(symbol: Symbol, modifier: Modifier = Modifier, size: Dp = 40.dp, filled: Boolean = true) {
    val colors = OverlayTheme.colors
    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(if (filled) colors.primaryContainer else colors.background),
        contentAlignment = Alignment.Center,
    ) {
        SymbolIcon(symbol, colors.onPrimaryContainer, size = size * 0.55f)
    }
}
