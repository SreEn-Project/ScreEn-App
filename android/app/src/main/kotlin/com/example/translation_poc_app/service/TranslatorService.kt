package com.example.translation_poc_app.service

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.ServiceCompat
import androidx.core.content.IntentCompat
import androidx.lifecycle.LifecycleService

/**
 * 번역 포그라운드 서비스 (NA-02). Flutter 엔진 없이 독립적으로 돈다.
 * 화면 캡처 동의 결과로만 시작하며([CaptureConsentActivity]), MediaProjection 세션을 가진다.
 * 캡처(NA-05) · 오버레이(NA-18)는 이 서비스 안에 붙인다.
 */
class TranslatorService : LifecycleService() {

    private var projection: MediaProjection? = null

    private val projectionCallback = object : MediaProjection.Callback() {
        // 사용자가 시스템 UI(상태 표시줄 칩 등)에서 공유를 끄면 서비스도 멈춘다.
        override fun onStop() {
            stopSelf()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        when (intent?.action) {
            ACTION_START -> handleStart(intent)
            ACTION_STOP -> stopSelf()
            // 시스템이 다시 살린 경우(동의 토큰 없음)는 이어갈 수 없으니 멈춘다.
            else -> stopSelf()
        }
        // 동의 토큰은 한 번만 쓸 수 있어 재시작해도 이어갈 수 없다.
        return START_NOT_STICKY
    }

    private fun handleStart(intent: Intent) {
        val resultCode = intent.getIntExtra(EXTRA_RESULT_CODE, Activity.RESULT_CANCELED)
        val data = IntentCompat.getParcelableExtra(intent, EXTRA_DATA, Intent::class.java)
        if (data == null) {
            fail("캡처 동의 데이터 없음")
            return
        }

        ServiceNotification.ensureChannel(this)
        // mediaProjection 유형으로 먼저 포그라운드가 된 뒤에 MediaProjection을 얻어야 한다 (Android 14+).
        try {
            ServiceCompat.startForeground(
                this,
                ServiceNotification.ID,
                ServiceNotification.build(this),
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
                } else {
                    0
                },
            )
        } catch (e: Exception) {
            fail("포그라운드 시작 실패", e)
            return
        }

        val manager = getSystemService(MediaProjectionManager::class.java)
        projection?.unregisterCallback(projectionCallback)
        projection?.stop()
        projection = manager.getMediaProjection(resultCode, data)?.also {
            it.registerCallback(projectionCallback, Handler(Looper.getMainLooper()))
        }
        if (projection == null) {
            fail("MediaProjection을 얻지 못함")
            return
        }

        TranslatorServiceState.update(RunState.RUNNING)
    }

    private fun fail(reason: String, error: Throwable? = null) {
        Log.e(TAG, reason, error)
        TranslatorServiceState.update(RunState.ERROR)
        stopForegroundCompat()
        stopSelf()
    }

    private fun stopForegroundCompat() {
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
    }

    override fun onDestroy() {
        projection?.unregisterCallback(projectionCallback)
        projection?.stop()
        projection = null
        if (TranslatorServiceState.state.value != RunState.ERROR) {
            TranslatorServiceState.update(RunState.STOPPED)
        }
        super.onDestroy()
    }

    companion object {
        private const val TAG = "TranslatorService"
        private const val ACTION_START = "com.example.translation_poc_app.action.START"
        const val ACTION_STOP = "com.example.translation_poc_app.action.STOP"
        private const val EXTRA_RESULT_CODE = "result_code"
        private const val EXTRA_DATA = "data"

        /** 캡처 동의 결과로 서비스를 시작한다. [CaptureConsentActivity]에서만 부른다. */
        fun start(context: Context, resultCode: Int, data: Intent) {
            val intent = Intent(context, TranslatorService::class.java)
                .setAction(ACTION_START)
                .putExtra(EXTRA_RESULT_CODE, resultCode)
                .putExtra(EXTRA_DATA, data)
            context.startForegroundService(intent)
        }

        fun stop(context: Context) {
            // 실행 중이 아니면 startService가 서비스를 새로 만들지 않도록 stopService를 쓴다.
            context.stopService(Intent(context, TranslatorService::class.java))
        }

        fun stopIntent(context: Context): Intent =
            Intent(context, TranslatorService::class.java).setAction(ACTION_STOP)
    }
}
