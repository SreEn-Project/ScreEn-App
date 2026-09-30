package com.example.translation_poc_app.ocr

import android.graphics.Rect

/** ML Kit Text Recognition v2가 읽는 문자 체계 (NA-09). CJK · 데바나가리 인식기는 라틴도 함께 읽는다. */
enum class Script { LATIN, KOREAN, JAPANESE, CHINESE, DEVANAGARI }

/** 인식한 한 줄. [confidence]는 0~1 (ML Kit이 주지 않으면 1로 본다). */
data class OcrLine(
    val text: String,
    val bounds: Rect?,
    val confidence: Float,
)

/** 인식한 문단(블록). 번역 · 오버레이의 기본 단위. [language]는 ML Kit 추정 BCP-47, 모르면 "und". */
data class OcrBlock(
    val text: String,
    val bounds: Rect?,
    val lines: List<OcrLine>,
    val language: String,
)

/** 인식기 하나로 읽은 결과. */
data class OcrResult(
    val script: Script,
    val blocks: List<OcrBlock>,
)
