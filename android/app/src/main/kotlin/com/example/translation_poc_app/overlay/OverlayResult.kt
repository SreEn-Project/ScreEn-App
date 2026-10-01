package com.example.translation_poc_app.overlay

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.TextMeasurer
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.translation_poc_app.R
import com.example.translation_poc_app.data.settings.NormalizedRegion
import com.example.translation_poc_app.translate.TranslatedItem
import kotlin.math.roundToInt

/** 막 위에 그릴 수 있는 항목: 번역됐고 화면 위 자리를 아는 것. */
internal fun overlayItems(items: List<TranslatedItem>): List<TranslatedItem> =
    items.filter { !it.translated.isNullOrBlank() && it.bounds != null }

/** 막 색: 반투명 검정 (NA-22). */
private val BoxColor = Color.Black.copy(alpha = 0.78f)
private const val MAX_SP = 22
private const val MIN_SP = 8

/**
 * 원문 위에 덮기 (NA-22): 인식한 글자 영역마다 반투명 검은 막을 깔고 그 위, 원문 자리에 번역문을 흰 글자로 보여 준다.
 * 화면 아무 곳이나 누르면 닫힌다. 창이 화면 전체라서 비율 좌표를 그대로 창 크기에 곱한다.
 */
@Composable
internal fun OverlayResult(items: List<TranslatedItem>, onDismiss: () -> Unit) {
    val colors = OverlayTheme.colors
    val noRipple = remember { MutableInteractionSource() }
    val measurer = rememberTextMeasurer()
    val density = LocalDensity.current

    BoxWithConstraints(
        modifier = Modifier
            .fillMaxSize()
            .clickable(interactionSource = noRipple, indication = null, onClick = onDismiss),
    ) {
        val widthPx = constraints.maxWidth.toFloat()
        val heightPx = constraints.maxHeight.toFloat()
        val pad = with(density) { 3.dp.toPx() }
        for (item in items) {
            val region = item.bounds ?: continue
            val text = item.translated.orEmpty()
            val box = paddedBox(region, widthPx, heightPx, pad)
            val style = OverlayTheme.translated.copy(color = Color.White)
            val fontSp = fitFontSize(measurer, text, style, box.width, box.height, density)
            Box(
                modifier = Modifier
                    .offset { IntOffset(box.left.roundToInt(), box.top.roundToInt()) }
                    .size(
                        with(density) { box.width.toDp() },
                        with(density) { box.height.toDp() },
                    )
                    .clip(RoundedCornerShape(6.dp))
                    .background(BoxColor)
                    .padding(horizontal = 4.dp, vertical = 2.dp),
                contentAlignment = Alignment.CenterStart,
            ) {
                BasicText(
                    text,
                    style = style.copy(fontSize = fontSp.sp, lineHeight = (fontSp * 1.2f).sp),
                    overflow = TextOverflow.Clip,
                )
            }
        }
        BasicText(
            stringResource(R.string.result_overlay_hint),
            style = OverlayTheme.caption.copy(color = Color.White),
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .windowInsetsPadding(WindowInsets.navigationBars)
                .padding(bottom = 24.dp)
                .clip(RoundedCornerShape(50))
                .background(colors.onSurface.copy(alpha = 0.8f))
                .padding(horizontal = 14.dp, vertical = 6.dp),
        )
    }
}

internal data class PxBox(val left: Float, val top: Float, val width: Float, val height: Float)

/** 비율 영역 → 창 픽셀 상자. 글자가 막에 꽉 붙지 않게 [pad]만큼 넓히고 화면 안으로 자른다. */
internal fun paddedBox(region: NormalizedRegion, widthPx: Float, heightPx: Float, pad: Float): PxBox {
    val left = (region.left * widthPx - pad).coerceAtLeast(0f)
    val top = (region.top * heightPx - pad).coerceAtLeast(0f)
    val right = (region.right * widthPx + pad).coerceAtMost(widthPx)
    val bottom = (region.bottom * heightPx + pad).coerceAtMost(heightPx)
    return PxBox(left, top, (right - left).coerceAtLeast(1f), (bottom - top).coerceAtLeast(1f))
}

/** [text]가 [widthPx]x[heightPx] 안에 들어가는 가장 큰 글자 크기(sp). 끝까지 안 맞으면 최소 크기. */
private fun fitFontSize(
    measurer: TextMeasurer,
    text: String,
    style: TextStyle,
    widthPx: Float,
    heightPx: Float,
    density: Density,
): Int {
    // 막 안쪽 여백(가로 8dp, 세로 4dp)을 뺀 공간.
    val innerW = (widthPx - with(density) { 8.dp.toPx() }).coerceAtLeast(1f).toInt()
    val innerH = (heightPx - with(density) { 4.dp.toPx() }).coerceAtLeast(1f)
    for (sp in MAX_SP downTo MIN_SP) {
        val candidate = style.copy(fontSize = sp.sp, lineHeight = (sp * 1.2f).sp)
        val layout = measurer.measure(text, candidate, constraints = Constraints(maxWidth = innerW))
        if (layout.size.height <= innerH) return sp
    }
    return MIN_SP
}
