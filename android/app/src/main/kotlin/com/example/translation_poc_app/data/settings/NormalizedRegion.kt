package com.example.translation_poc_app.data.settings

/**
 * 화면 안의 영역 (NA-08). 화면 크기에 대한 비율(0..1)로 저장해 회전 · 해상도가 달라져도 같은 자리를 가리킨다.
 * 픽셀 변환은 [toPixels]. Android 의존 없는 순수 로직.
 */
data class NormalizedRegion(val left: Float, val top: Float, val right: Float, val bottom: Float) {

    /** 화면 [width]×[height] 안의 픽셀 사각형. 최소 1px, 화면 밖으로 나가지 않는다. */
    fun toPixels(width: Int, height: Int): PixelRect {
        val l = (left * width).toInt().coerceIn(0, width - 1)
        val t = (top * height).toInt().coerceIn(0, height - 1)
        val r = (right * width).toInt().coerceIn(l + 1, width)
        val b = (bottom * height).toInt().coerceIn(t + 1, height)
        return PixelRect(l, t, r, b)
    }

    fun encode(): String = "$left,$top,$right,$bottom"

    companion object {
        /** 저장 문자열 → 영역. 모양이 틀리거나 크기가 없으면 null. */
        fun decode(text: String?): NormalizedRegion? {
            val parts = text?.split(',')?.mapNotNull { it.toFloatOrNull() } ?: return null
            if (parts.size != 4) return null
            val (l, t, r, b) = parts
            if (parts.any { it < 0f || it > 1f } || r <= l || b <= t) return null
            return NormalizedRegion(l, t, r, b)
        }

        /** 픽셀 사각형 → 비율. 화면 안으로 자른다. */
        fun fromPixels(rect: PixelRect, width: Int, height: Int) = NormalizedRegion(
            (rect.left.toFloat() / width).coerceIn(0f, 1f),
            (rect.top.toFloat() / height).coerceIn(0f, 1f),
            (rect.right.toFloat() / width).coerceIn(0f, 1f),
            (rect.bottom.toFloat() / height).coerceIn(0f, 1f),
        )
    }
}

data class PixelRect(val left: Int, val top: Int, val right: Int, val bottom: Int) {
    val width: Int get() = right - left
    val height: Int get() = bottom - top
}
