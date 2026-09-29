package com.example.translation_poc_app.bridge

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
)

fun Engine.toPigeon() = when (this) {
    Engine.ML_KIT -> EngineType.ML_KIT
    Engine.GEMINI -> EngineType.GEMINI
    Engine.FIREBASE_AI -> EngineType.FIREBASE_AI
}

fun EngineType.toNative() = when (this) {
    EngineType.ML_KIT -> Engine.ML_KIT
    EngineType.GEMINI -> Engine.GEMINI
    EngineType.FIREBASE_AI -> Engine.FIREBASE_AI
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
    ResultDisplay.OVERLAY -> DisplayMode.OVERLAY
}

fun DisplayMode.toNative() = when (this) {
    DisplayMode.LIST -> ResultDisplay.LIST
    DisplayMode.OVERLAY -> ResultDisplay.OVERLAY
}

fun RunState.toPigeon() = when (this) {
    RunState.STOPPED -> ServiceState.STOPPED
    RunState.STARTING -> ServiceState.STARTING
    RunState.RUNNING -> ServiceState.RUNNING
    RunState.ERROR -> ServiceState.ERROR
}
