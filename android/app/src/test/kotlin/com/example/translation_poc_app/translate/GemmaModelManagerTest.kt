package com.example.translation_poc_app.translate

import com.sun.net.httpserver.HttpServer
import java.io.File
import java.net.InetSocketAddress
import java.nio.file.Files
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class GemmaModelManagerTest {
    private lateinit var server: HttpServer
    private lateinit var dir: File
    private val payload = ByteArray(300_000) { (it % 251).toByte() }
    private var seenAuth: String? = null
    private var status = 200

    @Before
    fun setUp() {
        dir = Files.createTempDirectory("gemma").toFile()
        server = HttpServer.create(InetSocketAddress("127.0.0.1", 0), 0)
        server.createContext("/model") { ex ->
            seenAuth = ex.requestHeaders.getFirst("Authorization")
            if (status != 200) {
                ex.sendResponseHeaders(status, -1)
            } else {
                val range = ex.requestHeaders.getFirst("Range")?.removePrefix("bytes=")?.removeSuffix("-")?.toIntOrNull()
                if (range != null) {
                    ex.responseHeaders.add("Content-Range", "bytes $range-${payload.size - 1}/${payload.size}")
                    ex.sendResponseHeaders(206, (payload.size - range).toLong())
                    ex.responseBody.use { it.write(payload, range, payload.size - range) }
                } else {
                    ex.sendResponseHeaders(200, payload.size.toLong())
                    ex.responseBody.use { it.write(payload) }
                }
            }
            ex.close()
        }
        server.start()
    }

    @After
    fun tearDown() {
        server.stop(0)
        dir.deleteRecursively()
    }

    private fun downloader(token: String? = null) =
        GemmaDownloader("http://127.0.0.1:${server.address.port}/model", { token }, { Long.MAX_VALUE })

    private val part get() = File(dir, "m.part")
    private val target get() = File(dir, "m")

    @Test
    fun `처음부터 받아 완성 파일로 바꾼다`() {
        val done = downloader().download(part, target, { _, _ -> }, { false })
        assertTrue(done)
        assertTrue(target.readBytes().contentEquals(payload))
        assertFalse(part.exists())
    }

    @Test
    fun `받던 파일이 있으면 이어받는다`() {
        part.writeBytes(payload.copyOfRange(0, 1000))
        assertTrue(downloader().download(part, target, { _, _ -> }, { false }))
        assertTrue(target.readBytes().contentEquals(payload))
    }

    @Test
    fun `취소하면 받던 파일을 남기고 false`() {
        var calls = 0
        val done = downloader().download(part, target, { _, _ -> }, { ++calls > 2 })
        assertFalse(done)
        assertTrue(part.exists())
        assertFalse(target.exists())
    }

    @Test
    fun `401은 토큰 필요, 403은 토큰 유무로 나뉜다`() {
        status = 401
        var e = runCatching { downloader().download(part, target, { _, _ -> }, { false }) }.exceptionOrNull() as GemmaDownloadException
        assertEquals(GemmaFailure.TOKEN_REQUIRED, e.failure)
        status = 403
        e = runCatching { downloader().download(part, target, { _, _ -> }, { false }) }.exceptionOrNull() as GemmaDownloadException
        assertEquals(GemmaFailure.TOKEN_REQUIRED, e.failure)
        e = runCatching { downloader("hf_x").download(part, target, { _, _ -> }, { false }) }.exceptionOrNull() as GemmaDownloadException
        assertEquals(GemmaFailure.LICENSE_NOT_ACCEPTED, e.failure)
    }

    @Test
    fun `토큰은 huggingface 외 주소에는 보내지 않는다`() {
        downloader("hf_secret").download(part, target, { _, _ -> }, { false })
        assertEquals(null, seenAuth) // 127.0.0.1은 huggingface.co가 아니다
    }

    @Test
    fun `저장 공간이 모자라면 NOT_ENOUGH_SPACE`() {
        val d = GemmaDownloader("http://127.0.0.1:${server.address.port}/model", { null }, { 10L })
        val e = runCatching { d.download(part, target, { _, _ -> }, { false }) }.exceptionOrNull() as GemmaDownloadException
        assertEquals(GemmaFailure.NOT_ENOUGH_SPACE, e.failure)
    }
}
