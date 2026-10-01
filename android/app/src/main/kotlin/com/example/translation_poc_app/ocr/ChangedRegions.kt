package com.example.translation_poc_app.ocr

import kotlin.math.abs
import kotlin.math.ceil
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min

/**
 * 자동 번역에서 화면이 조금만 바뀌었을 때, 다시 읽을 영역을 정한다 (#43).
 * 직전에 읽은 화면과 지금 화면의 밝기 격자([COLS]×[ROWS])를 견줘 변한 칸을 찾고, 그 주변만 잘라 읽게 한다.
 * 안 바뀐 블록은 이전 결과를 그대로 쓴다. Android 의존 없는 순수 로직 ([Box] 사용).
 */
object ChangedRegions {
    const val COLS = 64
    const val ROWS = 128

    /** 칸 하나의 밝기가 이만큼(0~255) 넘게 달라야 "바뀐 칸". 압축 · 안티앨리어싱 잡음을 거른다. */
    const val LUMA_DELTA = 24

    /** 바뀐 칸이 전체의 이 비율을 넘으면 통째로 다시 읽는 편이 낫다 (스크롤 · 화면 전환). */
    const val FULL_RATIO = 0.4f

    /** 다시 읽을 영역 수 상한. 넘으면 통째로 읽는다. */
    const val MAX_REGIONS = 6

    /** 다시 읽을 영역의 넓이가 화면의 이 비율을 넘으면 통째로 읽는다. */
    const val MAX_AREA_RATIO = 0.5f

    /** 영역 둘레에 더하는 여유(px). 글자가 칸 경계에 걸쳐도 잘리지 않게 한다. */
    const val PAD_PX = 8

    /** 인식기가 받는 최소 변 길이(px)보다 작은 영역은 이 크기까지 넓힌다. */
    const val MIN_SIDE_PX = 64

    sealed interface Plan {
        /** 바뀐 칸이 없다 → 이전 결과를 그대로 쓴다. */
        data object Reuse : Plan

        /** 비교할 수 없거나 너무 많이 바뀌었다 → 통째로 읽는다. */
        data object Full : Plan

        /** [regions]만 다시 읽고, [keep]번째 이전 블록은 그대로 쓴다. */
        data class Partial(val regions: List<Box>, val keep: List<Int>) : Plan
    }

    /**
     * @param previous 직전에 읽은 화면의 격자, [current] 지금 화면의 격자 (둘 다 [COLS]×[ROWS], 행 우선).
     * @param width 이미지 크기 (px). 영역 좌표가 이 기준이다.
     * @param oldBlocks 직전 결과 블록의 자리 (같은 좌표계). 하나라도 자리를 모르면 통째로 읽는다.
     */
    fun plan(previous: IntArray, current: IntArray, width: Int, height: Int, oldBlocks: List<Box?>): Plan {
        if (previous.size != COLS * ROWS || current.size != previous.size || width <= 0 || height <= 0) return Plan.Full
        val changed = BooleanArray(previous.size) { abs(previous[it] - current[it]) > LUMA_DELTA }
        val count = changed.count { it }
        if (count == 0) return Plan.Reuse
        if (count.toFloat() / changed.size > FULL_RATIO) return Plan.Full
        if (oldBlocks.any { it == null }) return Plan.Full

        var boxes = components(dilate(changed), width, height).map { expand(it, width, height) }
        boxes = mergeUntilStable(boxes, oldBlocks.filterNotNull(), width, height)
        if (boxes.size > MAX_REGIONS) return Plan.Full
        val area = boxes.sumOf { it.width.toLong() * it.height }
        if (area > MAX_AREA_RATIO * width * height) return Plan.Full

        val keep = oldBlocks.indices.filter { i -> boxes.none { overlaps(it, oldBlocks[i]!!) } }
        return Plan.Partial(boxes, keep)
    }

    /** 변한 칸의 이웃 칸까지 포함한다. 글자 한 줄이 칸 두세 개에 걸치기 때문이다. */
    private fun dilate(mask: BooleanArray): BooleanArray {
        val out = BooleanArray(mask.size)
        for (r in 0 until ROWS) for (c in 0 until COLS) {
            if (!mask[r * COLS + c]) continue
            for (dr in -1..1) for (dc in -1..1) {
                val rr = r + dr
                val cc = c + dc
                if (rr in 0 until ROWS && cc in 0 until COLS) out[rr * COLS + cc] = true
            }
        }
        return out
    }

    /** 이어진 칸 덩어리마다 감싸는 사각형(px)을 하나씩. */
    private fun components(mask: BooleanArray, width: Int, height: Int): List<Box> {
        val seen = BooleanArray(mask.size)
        val result = mutableListOf<Box>()
        val stack = ArrayDeque<Int>()
        for (start in mask.indices) {
            if (!mask[start] || seen[start]) continue
            var minR = ROWS
            var maxR = -1
            var minC = COLS
            var maxC = -1
            stack.add(start)
            seen[start] = true
            while (stack.isNotEmpty()) {
                val i = stack.removeLast()
                val r = i / COLS
                val c = i % COLS
                minR = min(minR, r); maxR = max(maxR, r)
                minC = min(minC, c); maxC = max(maxC, c)
                for ((dr, dc) in NEIGHBORS) {
                    val rr = r + dr
                    val cc = c + dc
                    if (rr !in 0 until ROWS || cc !in 0 until COLS) continue
                    val j = rr * COLS + cc
                    if (mask[j] && !seen[j]) {
                        seen[j] = true
                        stack.add(j)
                    }
                }
            }
            result += Box(
                floor(minC * width / COLS.toFloat()).toInt(),
                floor(minR * height / ROWS.toFloat()).toInt(),
                ceil((maxC + 1) * width / COLS.toFloat()).toInt(),
                ceil((maxR + 1) * height / ROWS.toFloat()).toInt(),
            )
        }
        return result
    }

    private val NEIGHBORS = listOf(-1 to 0, 1 to 0, 0 to -1, 0 to 1)

    /** 여유를 더하고 최소 크기까지 넓힌 뒤 이미지 안으로 맞춘다. */
    private fun expand(box: Box, width: Int, height: Int): Box {
        var l = box.left - PAD_PX
        var t = box.top - PAD_PX
        var r = box.right + PAD_PX
        var b = box.bottom + PAD_PX
        if (r - l < MIN_SIDE_PX) {
            val mid = (l + r) / 2
            l = mid - MIN_SIDE_PX / 2; r = l + MIN_SIDE_PX
        }
        if (b - t < MIN_SIDE_PX) {
            val mid = (t + b) / 2
            t = mid - MIN_SIDE_PX / 2; b = t + MIN_SIDE_PX
        }
        // 이미지 밖으로 나가면 반대쪽으로 밀어 크기를 지킨다.
        if (l < 0) { r -= l; l = 0 }
        if (t < 0) { b -= t; t = 0 }
        if (r > width) { l -= r - width; r = width }
        if (b > height) { t -= b - height; b = height }
        return Box(max(0, l), max(0, t), min(width, r), min(height, b))
    }

    /**
     * 겹치는 영역을 합치고, 영역에 걸친 이전 블록은 통째로 영역에 넣는다 (블록을 반쪽만 다시 읽으면 글이 잘린다).
     * 합치거나 넓히면 새로 걸치는 블록이 생기므로 더 변하지 않을 때까지 되풀이한다.
     */
    private fun mergeUntilStable(start: List<Box>, blocks: List<Box>, width: Int, height: Int): List<Box> {
        var boxes = start
        while (true) {
            val next = mutableListOf<Box>()
            for (box in boxes) {
                var grown = box
                for (block in blocks) if (overlaps(grown, block)) grown = union(grown, block)
                grown = clip(grown, width, height)
                val i = next.indexOfFirst { overlaps(it, grown) }
                if (i >= 0) next[i] = union(next[i], grown) else next += grown
            }
            if (next == boxes) return next
            boxes = next
        }
    }

    private fun overlaps(a: Box, b: Box) = a.left < b.right && b.left < a.right && a.top < b.bottom && b.top < a.bottom

    private fun union(a: Box, b: Box) = Box(min(a.left, b.left), min(a.top, b.top), max(a.right, b.right), max(a.bottom, b.bottom))

    private fun clip(a: Box, width: Int, height: Int) = Box(max(0, a.left), max(0, a.top), min(width, a.right), min(height, a.bottom))
}
