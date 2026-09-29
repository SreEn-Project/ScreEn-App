package com.example.translation_poc_app.service

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjectionConfig
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Bundle

/**
 * 화면 캡처 동의 화면만 띄우는 투명 Activity (NA-04).
 * Android 14+는 캡처 세션마다 동의가 필요하고, mediaProjection 포그라운드 서비스는 동의 뒤에만 시작할 수 있다.
 * 앱 화면 · 알림 · 빠른 설정 타일(NA-25) 어디서 시작하든 이 Activity를 거친다.
 */
class CaptureConsentActivity : Activity() {

    private var resultHandled = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (savedInstanceState != null) return // 회전 등으로 다시 만들어졌으면 결과만 기다린다.

        TranslatorServiceState.update(RunState.STARTING)
        val manager = getSystemService(MediaProjectionManager::class.java)
        // Android 14+ 동의 창은 기본이 "앱 하나 공유"다. 번역은 어떤 앱 위에서든 써야 하므로 전체 화면으로 요청한다.
        val consent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            manager.createScreenCaptureIntent(MediaProjectionConfig.createConfigForDefaultDisplay())
        } else {
            manager.createScreenCaptureIntent()
        }
        @Suppress("DEPRECATION") // ActivityResult API는 ComponentActivity가 필요하다.
        startActivityForResult(consent, REQUEST_CAPTURE)
    }

    @Deprecated("Activity 기본 결과 콜백")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_CAPTURE) return
        resultHandled = true

        if (resultCode == RESULT_OK && data != null) {
            TranslatorService.start(this, resultCode, data)
        } else {
            TranslatorServiceState.update(RunState.STOPPED)
        }
        finish()
        overrideActivityTransitionCompat()
    }

    override fun onDestroy() {
        // 결과 없이 사라지면(작업 목록에서 지움 등) "동의 대기"에 멈추지 않게 되돌린다.
        if (!resultHandled && !isChangingConfigurations &&
            TranslatorServiceState.state.value == RunState.STARTING
        ) {
            TranslatorServiceState.update(RunState.STOPPED)
        }
        super.onDestroy()
    }

    private fun overrideActivityTransitionCompat() {
        @Suppress("DEPRECATION")
        overridePendingTransition(0, 0)
    }

    companion object {
        private const val REQUEST_CAPTURE = 1001

        /**
         * 동의 화면을 띄운다. singleInstance라 이미 기다리는 중이면 그 화면을 앞으로 가져온다
         * (사용자가 다른 앱으로 갔다가 돌아와 다시 누른 경우 결과가 이어서 전달된다).
         */
        fun launch(context: Context) {
            val intent = Intent(context, CaptureConsentActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_NO_ANIMATION)
            context.startActivity(intent)
        }
    }
}
