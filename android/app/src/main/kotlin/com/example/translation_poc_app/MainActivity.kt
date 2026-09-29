package com.example.translation_poc_app

import com.example.translation_poc_app.bridge.EventsStreamHandler
import com.example.translation_poc_app.bridge.ServiceHostApi
import com.example.translation_poc_app.bridge.ServiceHostApiImpl
import com.example.translation_poc_app.bridge.SettingsHostApi
import com.example.translation_poc_app.bridge.SettingsHostApiImpl
import com.example.translation_poc_app.bridge.TranslatorEventHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var eventHandler: TranslatorEventHandler? = null

    // Pigeon 브리지 연결 (NA-01). 번역 서비스는 이 엔진과 무관하게 돈다.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        val settingsRepository = AppGraph.settingsRepository(this)

        SettingsHostApi.setUp(messenger, SettingsHostApiImpl(settingsRepository))
        ServiceHostApi.setUp(messenger, ServiceHostApiImpl(applicationContext))
        eventHandler = TranslatorEventHandler(settingsRepository).also {
            EventsStreamHandler.register(messenger, it)
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        SettingsHostApi.setUp(messenger, null)
        ServiceHostApi.setUp(messenger, null)
        eventHandler?.dispose()
        eventHandler = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
