package com.example.translation_poc_app.service

/** 빠른 설정 타일을 눌렀을 때 할 일 (NA-25). */
enum class TileAction { STOP, REQUEST_CONSENT, OPEN_APP }

/**
 * 타일 탭 동작을 정한다 (안드로이드 무관).
 * 실행 중이면 끈다. 꺼져 있으면 캡처 동의를 받아 시작하되, 오버레이 권한이 없으면 앱을 열어 권한 안내 흐름으로 보낸다.
 * 동의 대기(STARTING) 중에 다시 누르면 동의 창을 되찾는다.
 */
fun decideTileAction(state: RunState, canDrawOverlays: Boolean): TileAction = when {
    state == RunState.RUNNING -> TileAction.STOP
    !canDrawOverlays -> TileAction.OPEN_APP
    else -> TileAction.REQUEST_CONSENT
}
