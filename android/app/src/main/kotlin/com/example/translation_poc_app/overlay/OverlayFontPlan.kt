package com.example.translation_poc_app.overlay

/**
 * 덮어쓰기 번역문의 글자 크기 계획 (#21). 블록마다 "들어가는 가장 큰 크기"를 따로 고르면 크기가
 * 들쭉날쭉해진다. 대신 원문 줄 높이에서 크기를 뽑고, 화면 공통 기준(중앙값) 근처로 모아 일관되게 만든다.
 * Android 의존 없는 순수 로직.
 */
object OverlayFontPlan {

    /** 줄 높이(상자 높이) 대비 글자 크기. 줄 상자는 글자보다 약간 크다. */
    const val FONT_PER_LINE_HEIGHT = 0.8f

    /** 공통 기준 대비 허용 범위. 제목 · 작은 글자는 원문 크기를 따르되, 인식이 튄 값만 걸러 낸다. */
    const val MIN_RATIO = 0.6f
    const val MAX_RATIO = 1.8f

    /** 줄여서 맞춰 볼 수 있는 한계 (목표 크기 대비). 이보다 작아지면 줄이지 않고 막을 키운다. */
    const val SHRINK_FLOOR = 0.8f

    /**
     * 항목별 목표 글자 크기(px). [lineHeightsPx]는 항목별 원문 줄 높이(모르면 null).
     * 기준은 줄 높이 중앙값, 항목은 기준의 [MIN_RATIO]~[MAX_RATIO] 안으로 모으고 [minPx]~[maxPx]로 자른다.
     */
    fun targetSizes(lineHeightsPx: List<Float?>, minPx: Float, maxPx: Float): List<Float> {
        val raw = lineHeightsPx.map { h -> h?.takeIf { it > 0f }?.times(FONT_PER_LINE_HEIGHT) }
        val known = raw.filterNotNull().sorted()
        val base = if (known.isEmpty()) minPx else known[known.size / 2]
        return raw.map { r ->
            ((r ?: base).coerceIn(base * MIN_RATIO, base * MAX_RATIO)).coerceIn(minPx, maxPx)
        }
    }
}
