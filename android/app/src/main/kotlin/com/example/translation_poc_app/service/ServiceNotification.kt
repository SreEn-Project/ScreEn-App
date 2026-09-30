package com.example.translation_poc_app.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.example.translation_poc_app.MainActivity
import com.example.translation_poc_app.R
import com.example.translation_poc_app.service.TranslatorService.Companion.isDebuggable

/**
 * 번역 서비스 알림 (NA-03). 실행 중임을 알리고, 누르면 앱을 열고, "중지"로 서비스를 끈다.
 * 알림 권한(Android 13+)이 없어도 서비스는 돈다. 알림만 보이지 않는다.
 */
object ServiceNotification {
    const val ID = 1
    private const val CHANNEL_ID = "translator_service"

    fun ensureChannel(context: Context) {
        val manager = context.getSystemService(NotificationManager::class.java)
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            context.getString(R.string.notification_channel_name),
            // 계속 떠 있는 알림이라 소리 · 진동 없이 조용하게.
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = context.getString(R.string.notification_channel_description)
            setShowBadge(false)
        }
        manager.createNotificationChannel(channel)
    }

    fun build(context: Context): Notification {
        val openApp = PendingIntent.getActivity(
            context,
            0,
            context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?: android.content.Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val stop = PendingIntent.getService(
            context,
            1,
            TranslatorService.stopIntent(context),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setColor(ContextCompat.getColor(context, R.color.brand_primary))
            .setContentTitle(context.getString(R.string.notification_title))
            .setContentText(context.getString(R.string.notification_text))
            .setContentIntent(openApp)
            .addAction(0, context.getString(R.string.notification_action_stop), stop)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)

        // 디버그 빌드 전용: 플로팅 버튼(NA-18) 전까지 캡처를 시험하는 동작.
        if (context.isDebuggable()) {
            val debugCapture = PendingIntent.getService(
                context,
                2,
                TranslatorService.debugCaptureIntent(context),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            builder.addAction(0, context.getString(R.string.notification_action_debug_capture), debugCapture)
        }
        return builder.build()
    }
}
