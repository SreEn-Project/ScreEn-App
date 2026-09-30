package com.example.translation_poc_app.overlay

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import com.example.translation_poc_app.R
import com.example.translation_poc_app.data.settings.NormalizedRegion
import kotlin.math.max
import kotlin.math.min

/** 영역을 고르는 방식. */
internal enum class RegionPickMode {
    /** 끌어서 새 영역을 그린다. 손을 떼면 바로 확정 (NA-20). */
    DRAG,

    /** 저장된 영역을 옮기고 모서리를 끌어 크기를 바꾼 뒤 저장 버튼으로 확정 (NA-21). */
    EDIT,
}

/**
 * 화면 전체를 덮는 영역 선택 화면 (O-03). 고른 영역 밖은 어둡게 덮는다.
 * 좌표는 창 안 픽셀이고, 확정할 때 창 크기 대비 비율로 바꿔 넘긴다.
 */
@Composable
internal fun RegionPicker(
    mode: RegionPickMode,
    initial: NormalizedRegion?,
    onDone: (NormalizedRegion) -> Unit,
    onCancel: () -> Unit,
) {
    val colors = OverlayTheme.colors
    val density = LocalDensity.current
    val minSide = with(density) { MIN_SIDE_DP.dp.toPx() }
    val handleRadius = with(density) { HANDLE_RADIUS_DP.dp.toPx() }
    val grabRadius = with(density) { GRAB_RADIUS_DP.dp.toPx() }
    val strokeWidth = with(density) { 2.dp.toPx() }

    var size by remember { mutableStateOf(IntSize.Zero) }
    var rect by remember { mutableStateOf<Rect?>(null) }

    // 편집은 처음 크기가 정해지면 저장된 영역(없으면 가운데 기본 영역)으로 시작한다.
    if (mode == RegionPickMode.EDIT && rect == null && size != IntSize.Zero) {
        rect = initial?.let { Rect(it.left * size.width, it.top * size.height, it.right * size.width, it.bottom * size.height) }
            ?: Rect(size.width * 0.1f, size.height * 0.35f, size.width * 0.9f, size.height * 0.65f)
    }

    val currentMode by rememberUpdatedState(mode)
    val currentDone by rememberUpdatedState(onDone)

    Box(
        Modifier
            .fillMaxSize()
            .onSizeChanged { size = it },
    ) {
        Canvas(
            Modifier
                .fillMaxSize()
                .pointerInput(Unit) {
                    var start = Offset.Zero
                    var grab = Grab.NONE
                    detectDragGestures(
                        onDragStart = { point ->
                            start = point
                            if (currentMode == RegionPickMode.DRAG) {
                                rect = Rect(point, Size.Zero)
                            } else {
                                grab = rect?.let { Grab.at(it, point, grabRadius) } ?: Grab.NONE
                            }
                        },
                        onDrag = { change, delta ->
                            change.consume()
                            val screen = Rect(0f, 0f, size.width.toFloat(), size.height.toFloat())
                            if (currentMode == RegionPickMode.DRAG) {
                                val end = Offset(
                                    change.position.x.coerceIn(0f, screen.right),
                                    change.position.y.coerceIn(0f, screen.bottom),
                                )
                                rect = Rect(
                                    min(start.x, end.x), min(start.y, end.y),
                                    max(start.x, end.x), max(start.y, end.y),
                                )
                            } else {
                                rect = rect?.let { grab.apply(it, delta, screen, minSide) }
                            }
                        },
                        onDragEnd = {
                            if (currentMode == RegionPickMode.DRAG) {
                                val picked = rect
                                if (picked != null && picked.width >= minSide && picked.height >= minSide) {
                                    currentDone(
                                        NormalizedRegion(
                                            picked.left / size.width,
                                            picked.top / size.height,
                                            picked.right / size.width,
                                            picked.bottom / size.height,
                                        ),
                                    )
                                } else {
                                    rect = null
                                }
                            }
                            grab = Grab.NONE
                        },
                        onDragCancel = {
                            if (currentMode == RegionPickMode.DRAG) rect = null
                            grab = Grab.NONE
                        },
                    )
                },
        ) {
            val picked = rect
            if (picked == null) {
                drawRect(colors.scrim)
                return@Canvas
            }
            // 고른 영역 바깥 네 조각만 어둡게 덮는다.
            drawRect(colors.scrim, Offset.Zero, Size(this.size.width, picked.top))
            drawRect(colors.scrim, Offset(0f, picked.bottom), Size(this.size.width, this.size.height - picked.bottom))
            drawRect(colors.scrim, Offset(0f, picked.top), Size(picked.left, picked.height))
            drawRect(colors.scrim, Offset(picked.right, picked.top), Size(this.size.width - picked.right, picked.height))
            drawRect(colors.primary, picked.topLeft, picked.size, style = Stroke(strokeWidth))
            if (mode == RegionPickMode.EDIT) {
                listOf(picked.topLeft, picked.topRight, picked.bottomLeft, picked.bottomRight).forEach {
                    drawCircle(colors.surface, handleRadius, it)
                    drawCircle(colors.primary, handleRadius, it, style = Stroke(strokeWidth))
                }
            }
        }

        BasicText(
            stringResource(if (mode == RegionPickMode.DRAG) R.string.region_hint_drag else R.string.region_hint_edit),
            style = OverlayTheme.label.copy(color = colors.onSurface),
            modifier = Modifier
                .align(Alignment.TopCenter)
                .padding(top = 72.dp, start = 24.dp, end = 24.dp)
                .clip(CircleShape)
                .background(colors.surface)
                .padding(horizontal = 18.dp, vertical = 10.dp),
        )

        Row(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 72.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            PillButton(stringResource(R.string.region_cancel), onCancel, style = PillStyle.SECONDARY)
            if (mode == RegionPickMode.EDIT) {
                PillButton(
                    stringResource(R.string.region_save),
                    onClick = {
                        rect?.let {
                            onDone(NormalizedRegion(it.left / size.width, it.top / size.height, it.right / size.width, it.bottom / size.height))
                        }
                    },
                    icon = Symbol.CHECK,
                )
            }
        }
    }
}

private const val MIN_SIDE_DP = 56
private const val HANDLE_RADIUS_DP = 10
private const val GRAB_RADIUS_DP = 36

/** 편집 중 손가락이 잡은 곳: 네 모서리 중 하나, 영역 안쪽(이동), 또는 아무것도 아님. */
internal enum class Grab {
    NONE, TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT, MOVE;

    /** [delta]만큼 끈 영역. 화면 밖으로 나가지 않고 한 변이 [minSide]보다 작아지지 않는다. */
    fun apply(rect: Rect, delta: Offset, screen: Rect, minSide: Float): Rect {
        var (l, t, r, b) = listOf(rect.left, rect.top, rect.right, rect.bottom)
        when (this) {
            NONE -> return rect
            MOVE -> {
                val dx = delta.x.coerceIn(screen.left - l, screen.right - r)
                val dy = delta.y.coerceIn(screen.top - t, screen.bottom - b)
                return rect.translate(dx, dy)
            }
            TOP_LEFT -> { l += delta.x; t += delta.y }
            TOP_RIGHT -> { r += delta.x; t += delta.y }
            BOTTOM_LEFT -> { l += delta.x; b += delta.y }
            BOTTOM_RIGHT -> { r += delta.x; b += delta.y }
        }
        val left = if (this == TOP_LEFT || this == BOTTOM_LEFT) l.coerceIn(screen.left, r - minSide) else l
        val right = if (this == TOP_RIGHT || this == BOTTOM_RIGHT) r.coerceIn(l + minSide, screen.right) else r
        val top = if (this == TOP_LEFT || this == TOP_RIGHT) t.coerceIn(screen.top, b - minSide) else t
        val bottom = if (this == BOTTOM_LEFT || this == BOTTOM_RIGHT) b.coerceIn(t + minSide, screen.bottom) else b
        return Rect(left, top, right, bottom)
    }

    companion object {
        fun at(rect: Rect, point: Offset, grabRadius: Float): Grab {
            val corners = listOf(
                TOP_LEFT to rect.topLeft,
                TOP_RIGHT to rect.topRight,
                BOTTOM_LEFT to rect.bottomLeft,
                BOTTOM_RIGHT to rect.bottomRight,
            )
            val nearest = corners.minBy { (_, corner) -> (corner - point).getDistance() }
            return when {
                (nearest.second - point).getDistance() <= grabRadius -> nearest.first
                rect.contains(point) -> MOVE
                else -> NONE
            }
        }
    }
}
