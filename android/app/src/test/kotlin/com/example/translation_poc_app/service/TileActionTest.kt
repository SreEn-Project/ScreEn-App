package com.example.translation_poc_app.service

import org.junit.Assert.assertEquals
import org.junit.Test

class TileActionTest {
    @Test
    fun running_stops_regardless_of_overlay_permission() {
        assertEquals(TileAction.STOP, decideTileAction(RunState.RUNNING, true))
        assertEquals(TileAction.STOP, decideTileAction(RunState.RUNNING, false))
    }

    @Test
    fun stopped_with_overlay_permission_requests_consent() {
        assertEquals(TileAction.REQUEST_CONSENT, decideTileAction(RunState.STOPPED, true))
        assertEquals(TileAction.REQUEST_CONSENT, decideTileAction(RunState.ERROR, true))
    }

    @Test
    fun waiting_for_consent_reopens_consent() {
        assertEquals(TileAction.REQUEST_CONSENT, decideTileAction(RunState.STARTING, true))
    }

    @Test
    fun missing_overlay_permission_opens_app() {
        assertEquals(TileAction.OPEN_APP, decideTileAction(RunState.STOPPED, false))
        assertEquals(TileAction.OPEN_APP, decideTileAction(RunState.STARTING, false))
    }
}
