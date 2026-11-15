package com.example.translation_poc_app.translate

import java.net.HttpURLConnection
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.withContext

/**
 * 막히는 HTTP 호출을 코루틴 취소와 함께 끊는다.
 * [HttpURLConnection]은 취소를 모르기 때문에, 그냥 withContext(IO)로 감싸면 취소해도 응답이 올 때까지(최대 타임아웃)
 * 기다린다. 취소되면 연결을 닫아 막힌 읽기 · 쓰기가 바로 예외로 끝나게 한다.
 */
internal suspend fun <T> runCancellableHttp(conn: HttpURLConnection, block: () -> T): T =
    withContext(Dispatchers.IO) {
        coroutineScope {
            val call = async(Dispatchers.IO) { block() }
            try {
                call.await()
            } catch (e: CancellationException) {
                conn.disconnect()
                throw e
            }
        }
    }
