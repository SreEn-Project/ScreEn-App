package com.example.translation_poc_app.bridge

import com.example.translation_poc_app.data.settings.AiTone
import com.example.translation_poc_app.data.settings.CaptureRange
import com.example.translation_poc_app.data.settings.Engine
import com.example.translation_poc_app.data.settings.ResultDisplay
import com.example.translation_poc_app.data.settings.Settings
import com.example.translation_poc_app.service.RunState

// 네이티브 모델 ↔ Pigeon 생성 타입 변환.

fun Settings.toPigeon() = AppSettings(
    targetLanguage = targetLanguage,
    engine = engine.toPigeon(),
    captureMode = captureRange.toPigeon(),
    displayMode = resultDisplay.toPigeon(),
    onboardingCompleted = onboardingCompleted,
    quickLanguages = quickLanguages,
    autoTranslate = autoTranslate,
    autoShowDelayMs = autoShowDelayMs,
    hideAfterInteractionMs = hideAfterInteractionMs,
    wifiOnlyModelDownload = wifiOnlyModelDownload,
    buttonSizeDp = buttonSizeDp.toLong(),
    buttonOpacityPercent = buttonOpacityPercent.toLong(),
    hasFixedRegion = fixedRegion != null,
    ageConfirmed = ageConfirmed,
    aiTone = aiTone.toPigeon(),
    glossary = glossary.map { GlossaryEntry(it.source, it.target) },
)

fun AiTone.toPigeon() = when (this) {
    AiTone.STANDARD -> com.example.translation_poc_app.bridge.AiTone.STANDARD
    AiTone.FORMAL -> com.example.translation_poc_app.bridge.AiTone.FORMAL
    AiTone.INFORMAL -> com.example.translation_poc_app.bridge.AiTone.INFORMAL
}

fun com.example.translation_poc_app.bridge.AiTone.toNative() = when (this) {
    com.example.translation_poc_app.bridge.AiTone.STANDARD -> AiTone.STANDARD
    com.example.translation_poc_app.bridge.AiTone.FORMAL -> AiTone.FORMAL
    com.example.translation_poc_app.bridge.AiTone.INFORMAL -> AiTone.INFORMAL
}

fun com.example.translation_poc_app.data.history.TranslationRecord.toPigeon() = TranslationRecord(
    id = id,
    original = original,
    translated = translated,
    sourceLanguage = sourceLanguage,
    targetLanguage = targetLanguage,
    engine = runCatching { Engine.valueOf(engine) }.getOrDefault(Engine.ML_KIT).toPigeon(),
    createdAtMs = createdAt,
)

fun Engine.toPigeon() = when (this) {
    Engine.ML_KIT -> EngineType.ML_KIT
    Engine.GEMINI -> EngineType.GEMINI
}

fun EngineType.toNative() = when (this) {
    EngineType.ML_KIT -> Engine.ML_KIT
    EngineType.GEMINI -> Engine.GEMINI
}

fun CaptureRange.toPigeon() = when (this) {
    CaptureRange.FULL_SCREEN -> CaptureMode.FULL_SCREEN
    CaptureRange.DRAG_REGION -> CaptureMode.DRAG_REGION
    CaptureRange.FIXED_REGION -> CaptureMode.FIXED_REGION
}

fun CaptureMode.toNative() = when (this) {
    CaptureMode.FULL_SCREEN -> CaptureRange.FULL_SCREEN
    CaptureMode.DRAG_REGION -> CaptureRange.DRAG_REGION
    CaptureMode.FIXED_REGION -> CaptureRange.FIXED_REGION
}

fun ResultDisplay.toPigeon() = when (this) {
    ResultDisplay.LIST -> DisplayMode.LIST
    ResultDisplay.PARAGRAPH -> DisplayMode.PARAGRAPH
    ResultDisplay.OVERLAY -> DisplayMode.OVERLAY
}

fun DisplayMode.toNative() = when (this) {
    DisplayMode.LIST -> ResultDisplay.LIST
    DisplayMode.PARAGRAPH -> ResultDisplay.PARAGRAPH
    DisplayMode.OVERLAY -> ResultDisplay.OVERLAY
}

fun RunState.toPigeon() = when (this) {
    RunState.STOPPED -> ServiceState.STOPPED
    RunState.STARTING -> ServiceState.STARTING
    RunState.RUNNING -> ServiceState.RUNNING
    RunState.ERROR -> ServiceState.ERROR
}

fun com.example.translation_poc_app.data.vocabulary.WordbookRow.toPigeon() = Wordbook(
    id = id,
    name = name,
    wordCount = wordCount.toLong(),
    memorizedCount = memorizedCount.toLong(),
    createdAtMs = createdAt,
)

fun com.example.translation_poc_app.data.vocabulary.WordEntity.toPigeon() = VocabWord(
    id = id,
    wordbookId = wordbookId,
    word = word,
    meaning = meaning,
    pronunciation = pronunciation,
    partOfSpeech = partOfSpeech,
    contextMeaning = contextMeaning,
    sentence = sentence,
    sourceApp = sourceApp,
    sourceLanguage = sourceLanguage,
    targetLanguage = targetLanguage,
    memorized = memorized,
    createdAtMs = createdAt,
)

fun VocabSort.toNative() = when (this) {
    VocabSort.NEWEST -> com.example.translation_poc_app.data.vocabulary.WordSort.NEWEST
    VocabSort.OLDEST -> com.example.translation_poc_app.data.vocabulary.WordSort.OLDEST
    VocabSort.ALPHABETICAL -> com.example.translation_poc_app.data.vocabulary.WordSort.ALPHABETICAL
}
