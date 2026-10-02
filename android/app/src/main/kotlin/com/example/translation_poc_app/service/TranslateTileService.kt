package com.example.translation_poc_app.service

import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import com.example.translation_poc_app.MainActivity
import com.example.translation_poc_app.R
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

/**
 * 알림 패널의 번역 켜기/끄기 타일 (NA-25).
 * 켜기는 앱 화면과 같은 경로(캡처 동의 → 서비스 시작)를 거치고, 서비스 상태를 타일에 반영한다.
 */
class TranslateTileService : TileService() {

    private var scope: CoroutineScope? = null

    override fun onStartListening() {
        super.onStartListening()
        val listening = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
        scope = listening
        listening.launch {
            TranslatorServiceState.state.collect { render(it) }
        }
    }

    override fun onStopListening() {
        scope?.cancel()
        scope = null
        super.onStopListening()
    }

    override fun onClick() {
        super.onClick()
        val action = decideTileAction(
            TranslatorServiceState.state.value,
            Settings.canDrawOverlays(this),
        )
        when (action) {
            TileAction.STOP -> TranslatorService.stop(this)
            TileAction.REQUEST_CONSENT -> launchActivity(
                Intent(this, CaptureConsentActivity::class.java)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_NO_ANIMATION),
            )
            TileAction.OPEN_APP -> launchActivity(
                packageManager.getLaunchIntentForPackage(packageName)
                    ?: Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
        }
    }

    private fun render(state: RunState) {
        val tile = qsTile ?: return
        tile.state = if (state == RunState.RUNNING) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            tile.subtitle = getString(
                when (state) {
                    RunState.RUNNING -> R.string.tile_on
                    RunState.STARTING -> R.string.tile_starting
                    else -> R.string.tile_off
                },
            )
        }
        tile.updateTile()
    }

    /** 잠금 화면이면 잠금 해제 뒤에 띄우고, 알림 패널을 접는다. Android 14부터는 PendingIntent만 받는다. */
    private fun launchActivity(intent: Intent) {
        // 앱 화면은 새 작업으로 열어야 하므로 플래그를 보장한다.
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val pending = PendingIntent.getActivity(
                this,
                0,
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            startActivityAndCollapse(pending)
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(intent)
        }
    }
}
