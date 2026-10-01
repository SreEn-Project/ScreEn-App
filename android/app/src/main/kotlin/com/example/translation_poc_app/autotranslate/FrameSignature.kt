package com.example.translation_poc_app.autotranslate

import kotlin.math.abs

/**
 * 화면 한 장을 격자 밝기값으로 줄인 "지문" (자동 번역, #23). 비트맵으로 바꾸지 않고 프레임 버퍼에서 바로 뽑아
 * 확인 한 번의 비용이 격자 [COLS]×[ROWS]칸 읽기뿐이다. 두 지문을 견줘 화면이 뚜렷이 바뀌었는지만 판단한다.
 * Android 의존 없는 순수 로직.
 */
object FrameSignature {
    const val COLS = 64
    const val ROWS = 128

    /** 칸 하나의 밝기가 이만큼(0~255) 넘게 달라야 "바뀐 칸"으로 센다. 압축 · 안티앨리어싱 잡음을 거른다. */
    const val LUMA_DELTA = 24

    /** 바뀐 칸이 전체의 이 비율 이상이면 "화면이 뚜렷이 바뀜". 시계 · 커서 깜박임 정도(몇 칸)는 넘지 않는다. */
    const val CHANGE_RATIO = 0.005f

    fun luma(r: Int, g: Int, b: Int): Int = (77 * r + 150 * g + 29 * b) shr 8

    /** 두 지문에서 밝기가 [LUMA_DELTA] 넘게 다른 칸의 비율 (0~1). 크기가 다르면(회전 등) 완전히 바뀐 것으로 본다. */
    fun changedRatio(a: IntArray, b: IntArray): Float {
        if (a.size != b.size || a.isEmpty()) return 1f
        var changed = 0
        for (i in a.indices) if (abs(a[i] - b[i]) > LUMA_DELTA) changed++
        return changed.toFloat() / a.size
    }

    fun isChanged(a: IntArray, b: IntArray): Boolean = changedRatio(a, b) >= CHANGE_RATIO
}
