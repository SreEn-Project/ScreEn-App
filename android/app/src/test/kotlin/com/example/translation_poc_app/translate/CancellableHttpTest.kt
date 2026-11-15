package com.example.translation_poc_app.translate

import java.net.HttpURLConnection
import java.net.ServerSocket
import java.net.URL
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import org.junit.Assert.assertTrue
import org.junit.Test

class CancellableHttpTest {
    /** 응답을 주지 않는 서버에 걸린 호출도, 취소하면 타임아웃(여기선 30초)을 기다리지 않고 바로 끝나야 한다. */
    @Test
    fun `취소하면 막힌 HTTP 호출이 바로 끝난다`() {
        ServerSocket(0).use { server ->
            val conn = URL("http://127.0.0.1:${server.localPort}/").openConnection() as HttpURLConnection
            conn.readTimeout = 30_000
            val start = System.currentTimeMillis()
            var cancelled = false
            runBlocking {
                val job = async(Dispatchers.Default) {
                    try {
                        runCancellableHttp(conn) { conn.responseCode }
                    } catch (e: CancellationException) {
                        cancelled = true
                        throw e
                    }
                }
                delay(300)
                job.cancel()
                withTimeout(5_000) { job.join() }
            }
            assertTrue(cancelled)
            assertTrue(System.currentTimeMillis() - start < 5_000)
        }
    }
}
