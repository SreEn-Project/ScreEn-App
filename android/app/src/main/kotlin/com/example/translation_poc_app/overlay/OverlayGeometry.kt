package com.example.translation_poc_app.overlay

/** 화면 크기와 가장자리 시스템 막대 · 컷아웃 두께 (픽셀). 오버레이는 막대 안쪽에만 놓는다. */
data class ScreenArea(
    val width: Int,
    val height: Int,
    val left: Int = 0,
    val top: Int = 0,
    val right: Int = 0,
    val bottom: Int = 0,
)

enum class Edge { LEFT, RIGHT }

/** 플로팅 버튼 창의 왼쪽 위 위치 (Gravity TOP|START 기준). */
data class ButtonPlacement(val x: Int, val y: Int, val edge: Edge)

/** 모드 메뉴 창 위치. [alignEnd]이면 [x]는 화면 오른쪽 끝에서의 거리 (Gravity TOP|END). */
data class MenuPlacement(val x: Int, val y: Int, val alignEnd: Boolean)

/**
 * 플로팅 버튼 · 메뉴 · 닫기 영역 위치 계산 (NA-18). Android 의존 없는 순수 로직.
 * 모든 값은 픽셀. [size]는 버튼 창 크기(그림자 여백 포함, 정사각형).
 */
object OverlayGeometry {

    /** 처음 위치: 오른쪽 가장자리, 화면 높이의 35%. */
    fun initial(area: ScreenArea, size: Int): ButtonPlacement =
        snap(area.width, (area.height * 0.35f).toInt(), size, area)

    /** 놓은 곳에서 가까운 왼쪽 · 오른쪽 가장자리에 붙이고, 위아래는 시스템 막대 안으로 맞춘다. */
    fun snap(x: Int, y: Int, size: Int, area: ScreenArea): ButtonPlacement {
        val edge = if (x + size / 2 < area.width / 2) Edge.LEFT else Edge.RIGHT
        val snappedX = if (edge == Edge.LEFT) area.left else maxX(size, area)
        return ButtonPlacement(snappedX, clampY(y, size, area), edge)
    }

    /** 끄는 동안 버튼이 화면 밖으로 나가지 않게 한다. */
    fun clamp(x: Int, y: Int, size: Int, area: ScreenArea): Pair<Int, Int> =
        x.coerceIn(area.left, maxX(size, area)) to clampY(y, size, area)

    /** 화면이 돌아가면 같은 가장자리 · 같은 높이 비율로 옮긴다. */
    fun rotate(old: ButtonPlacement, oldArea: ScreenArea, newArea: ScreenArea, size: Int): ButtonPlacement {
        val ratio = if (oldArea.height > 0) old.y.toFloat() / oldArea.height else 0.35f
        val x = if (old.edge == Edge.LEFT) 0 else newArea.width
        return snap(x, (newArea.height * ratio).toInt(), size, newArea)
    }

    /** 닫기 영역: 아래쪽 가운데. 버튼 가운데가 [radius] 안에 들어오면 놓았을 때 서비스를 끈다. */
    fun closeZoneCenter(area: ScreenArea, bottomMargin: Int): Pair<Int, Int> =
        (area.left + area.width - area.right) / 2 to area.height - area.bottom - bottomMargin

    fun isOverCloseZone(buttonX: Int, buttonY: Int, size: Int, area: ScreenArea, bottomMargin: Int, radius: Int): Boolean {
        val (zoneX, zoneY) = closeZoneCenter(area, bottomMargin)
        val dx = (buttonX + size / 2 - zoneX).toLong()
        val dy = (buttonY + size / 2 - zoneY).toLong()
        return dx * dx + dy * dy <= radius.toLong() * radius
    }

    /** 모드 메뉴는 버튼 옆, 화면 안쪽으로 펼친다. */
    fun menu(button: ButtonPlacement, size: Int, area: ScreenArea, gap: Int): MenuPlacement =
        if (button.edge == Edge.RIGHT) {
            MenuPlacement(area.width - button.x + gap, button.y, alignEnd = true)
        } else {
            MenuPlacement(button.x + size + gap, button.y, alignEnd = false)
        }

    /**
     * 버블 4개의 각도 (안쪽 방향 기준, 도). 보통은 위에서 아래로 고르게 벌리고,
     * 버튼이 화면 위(아래) 끝에 가까워 호가 잘리면 버블을 아래(위)쪽으로 몰아 낸다. 간격은 dp.
     */
    fun bubbleAngles(spaceAboveDp: Float, spaceBelowDp: Float, radiusDp: Int = 96): List<Float> {
        val spread = 66f
        val half = (radiusDp * kotlin.math.sin(Math.toRadians(spread.toDouble()))).toFloat()
        val needAbove = half + 26f // 위 버블 중심 위로 원 반지름
        val needBelow = half + 50f // 아래 버블 중심 아래로 원 반지름 + 이름표
        return when {
            spaceAboveDp < needAbove -> listOf(0f, 30f, 60f, 90f)
            spaceBelowDp < needBelow -> listOf(-90f, -60f, -30f, 0f)
            else -> listOf(-spread, -spread / 3, spread / 3, spread)
        }
    }

    /**
     * 길게 누른 채 손가락이 올라가 있는 버블 번호 (없으면 -1). 버블 가운데에서 [hitRadius] 안이고 가장 가까운 것.
     * [centerX] · [centerY]는 버튼 가운데 (화면 좌표), [inwardRight]는 버튼이 왼쪽 가장자리일 때 true. 모두 픽셀.
     */
    fun bubbleHit(
        fingerX: Float,
        fingerY: Float,
        centerX: Float,
        centerY: Float,
        inwardRight: Boolean,
        angles: List<Float>,
        radius: Float,
        hitRadius: Float,
    ): Int {
        var best = -1
        var bestDistance = hitRadius
        angles.forEachIndexed { index, angle ->
            val rad = Math.toRadians(angle.toDouble())
            val dx = (radius * kotlin.math.cos(rad)).toFloat()
            val x = centerX + if (inwardRight) dx else -dx
            val y = centerY + (radius * kotlin.math.sin(rad)).toFloat()
            val distance = kotlin.math.hypot(fingerX - x, fingerY - y)
            if (distance <= bestDistance) {
                best = index
                bestDistance = distance
            }
        }
        return best
    }

    private fun maxX(size: Int, area: ScreenArea): Int = (area.width - area.right - size).coerceAtLeast(area.left)

    private fun clampY(y: Int, size: Int, area: ScreenArea): Int {
        val max = (area.height - area.bottom - size).coerceAtLeast(area.top)
        return y.coerceIn(area.top, max)
    }
}
