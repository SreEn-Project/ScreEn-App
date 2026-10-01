package com.example.translation_poc_app.capture

import android.graphics.Bitmap

/**
 * 캡처 한 장의 간단한 통계 (#25). 진단 로그와 "글자가 없는 이유" 판단에 쓴다.
 * [blackShare]는 거의 완전한 검정(밝기 ≤ 8) 표본의 비율이다.
 */
data class FrameStats(val meanLuma: Float, val blackShare: Float) {

    /**
     * 글자를 못 읽은 화면이 대부분 검정이면 보안 화면(FLAG_SECURE) 창이 검게 찍힌 것이다.
     * 시스템은 보안 창만 검게 칠하고 나머지(상태 표시줄 등)는 그대로 주므로, 화면 전체가 검지 않아도
     * 본문 창이 검게 나올 수 있다 (구글 로그인 · 결제 · 은행 화면).
     */
    val looksSecure: Boolean get() = blackShare >= SECURE_BLACK_SHARE

    override fun toString() = "밝기평균=%.1f 검정비율=%.0f%%".format(meanLuma, blackShare * 100)

    companion object {
        const val SECURE_BLACK_SHARE = 0.7f

        /** 격자 표본 [samples]×[samples]로 통계를 낸다. */
        fun of(bitmap: Bitmap, samples: Int = 24): FrameStats {
            var sum = 0.0
            var black = 0
            var count = 0
            for (i in 0 until samples) {
                for (j in 0 until samples) {
                    val x = ((bitmap.width - 1).toLong() * i / (samples - 1)).toInt()
                    val y = ((bitmap.height - 1).toLong() * j / (samples - 1)).toInt()
                    val p = bitmap.getPixel(x, y)
                    val r = (p shr 16) and 0xFF
                    val g = (p shr 8) and 0xFF
                    val b = p and 0xFF
                    sum += 0.299 * r + 0.587 * g + 0.114 * b
                    if (r <= 8 && g <= 8 && b <= 8) black++
                    count++
                }
            }
            return FrameStats((sum / count).toFloat(), black.toFloat() / count)
        }
    }
}
