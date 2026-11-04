package com.example.translation_poc_app.translate

import android.app.ActivityManager
import android.content.Context
import android.net.ConnectivityManager
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/** Gemma 모델 받기 실패 이유 (#174). Pigeon `GemmaError`와 1:1. */
enum class GemmaFailure { NONE, TOKEN_REQUIRED, LICENSE_NOT_ACCEPTED, NETWORK, NOT_ENOUGH_SPACE, UNKNOWN }

enum class GemmaModelState { NOT_DOWNLOADED, DOWNLOADING, READY }

data class GemmaSnapshot(
    val state: GemmaModelState,
    val downloadedBytes: Long,
    val totalBytes: Long,
    val failure: GemmaFailure,
)

/** 받을 모델 정보. 모델을 바꾸려면 여기만 고친다. */
data class GemmaModelSpec(
    val url: String,
    val fileName: String,
    /** 화면에 먼저 보여 주는 대략의 크기. 받기 시작하면 서버가 알려 준 크기로 바뀐다. */
    val approxBytes: Long,
    /** 이 값보다 전체 메모리가 작은 기기는 받기를 막는다 (MB). */
    val minRamMb: Int,
) {
    companion object {
        /** Gemma 3 1B IT, int4 (MediaPipe `.task`). Hugging Face에서 사용 조건 동의 + 토큰이 필요하다. */
        val DEFAULT = GemmaModelSpec(
            url = "https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/gemma3-1b-it-int4.task",
            fileName = "gemma3-1b-it-int4.task",
            approxBytes = 555_000_000L,
            minRamMb = 3_500,
        )
    }
}

internal class GemmaDownloadException(val failure: GemmaFailure, message: String? = null) : IOException(message)

/**
 * 모델 파일을 이어받는 한 번의 받기. 리다이렉트는 직접 따라가며, Authorization은 huggingface.co에만 보낸다
 * (CDN 서명 주소로 토큰이 새지 않게). 끝나면 [part]를 [target]으로 바꾼다.
 */
internal class GemmaDownloader(
    private val url: String,
    private val token: () -> String?,
    private val freeSpace: () -> Long,
    private val timeoutMs: Int = 20_000,
) {
    /** @return 받기를 끝냈으면 true, [isCancelled]로 멈췄으면 false. 실패는 [GemmaDownloadException]. */
    fun download(
        part: File,
        target: File,
        onProgress: (downloaded: Long, total: Long) -> Unit,
        isCancelled: () -> Boolean,
    ): Boolean {
        part.parentFile?.mkdirs()
        var resumeFrom = if (part.exists()) part.length() else 0L
        val conn = open(resumeFrom)
        try {
            val code = conn.responseCode
            when {
                code == 200 -> if (resumeFrom > 0) { part.delete(); resumeFrom = 0 } // 서버가 이어받기를 무시함
                code == 206 -> Unit
                code == 416 -> { part.delete(); throw GemmaDownloadException(FAILURE_RETRY, "range") }
                code == 401 -> throw GemmaDownloadException(GemmaFailure.TOKEN_REQUIRED, "HTTP 401")
                code == 403 -> throw GemmaDownloadException(
                    if (token().isNullOrBlank()) GemmaFailure.TOKEN_REQUIRED else GemmaFailure.LICENSE_NOT_ACCEPTED,
                    "HTTP 403",
                )
                code >= 500 || code == 429 -> throw GemmaDownloadException(GemmaFailure.NETWORK, "HTTP $code")
                else -> throw GemmaDownloadException(GemmaFailure.UNKNOWN, "HTTP $code")
            }
            val total = totalSize(conn, code, resumeFrom)
            if (total > 0 && freeSpace() < total - resumeFrom + SPACE_MARGIN_BYTES) {
                throw GemmaDownloadException(GemmaFailure.NOT_ENOUGH_SPACE)
            }
            var done = resumeFrom
            onProgress(done, total)
            conn.inputStream.use { input ->
                FileOutputStream(part, resumeFrom > 0).use { out ->
                    val buffer = ByteArray(64 * 1024)
                    var lastReport = 0L
                    while (true) {
                        if (isCancelled()) return false
                        val n = input.read(buffer)
                        if (n < 0) break
                        out.write(buffer, 0, n)
                        done += n
                        if (done - lastReport >= PROGRESS_STEP_BYTES) {
                            lastReport = done
                            onProgress(done, total)
                        }
                    }
                }
            }
            if (total > 0 && part.length() != total) {
                throw GemmaDownloadException(GemmaFailure.NETWORK, "incomplete ${part.length()}/$total")
            }
            onProgress(done, if (total > 0) total else done)
            target.delete()
            if (!part.renameTo(target)) throw GemmaDownloadException(GemmaFailure.UNKNOWN, "rename failed")
            return true
        } catch (e: GemmaDownloadException) {
            throw e
        } catch (e: IOException) {
            // 디스크가 꽉 찬 경우도 IOException이다.
            val full = e.message?.contains("ENOSPC", ignoreCase = true) == true || e.message?.contains("space", ignoreCase = true) == true
            throw GemmaDownloadException(if (full) GemmaFailure.NOT_ENOUGH_SPACE else GemmaFailure.NETWORK, e.message)
        } finally {
            conn.disconnect()
        }
    }

    private fun open(resumeFrom: Long): HttpURLConnection {
        var current = URL(url)
        repeat(MAX_REDIRECTS + 1) {
            val conn = current.openConnection() as HttpURLConnection
            conn.instanceFollowRedirects = false
            conn.connectTimeout = timeoutMs
            conn.readTimeout = timeoutMs
            token()?.takeIf { it.isNotBlank() && isHuggingFace(current) }
                ?.let { conn.setRequestProperty("Authorization", "Bearer $it") }
            if (resumeFrom > 0) conn.setRequestProperty("Range", "bytes=$resumeFrom-")
            val code = conn.responseCode
            if (code in REDIRECT_CODES) {
                val location = conn.getHeaderField("Location")
                conn.disconnect()
                if (location.isNullOrBlank()) throw GemmaDownloadException(GemmaFailure.UNKNOWN, "redirect without Location")
                current = URL(current, location)
                return@repeat
            }
            return conn
        }
        throw GemmaDownloadException(GemmaFailure.UNKNOWN, "too many redirects")
    }

    private fun isHuggingFace(u: URL) = u.host == "huggingface.co" || u.host.endsWith(".huggingface.co")

    private fun totalSize(conn: HttpURLConnection, code: Int, resumeFrom: Long): Long {
        if (code == 206) {
            // Content-Range: bytes 100-999/1000
            conn.getHeaderField("Content-Range")?.substringAfter('/', "")?.toLongOrNull()?.let { return it }
            val len = conn.getHeaderField("Content-Length")?.toLongOrNull() ?: return -1
            return resumeFrom + len
        }
        return conn.getHeaderField("Content-Length")?.toLongOrNull() ?: -1
    }

    companion object {
        private val REDIRECT_CODES = setOf(301, 302, 303, 307, 308)
        private const val MAX_REDIRECTS = 5
        private const val SPACE_MARGIN_BYTES = 200L * 1024 * 1024
        private const val PROGRESS_STEP_BYTES = 512L * 1024

        /** 416: 받던 파일이 서버와 맞지 않아 지웠다. 처음부터 다시 받게 한다. */
        private val FAILURE_RETRY = GemmaFailure.NETWORK
    }
}

/**
 * Gemma 모델 파일 관리 (#174): 위치 · 상태 · 받기 · 취소 · 삭제 · 기기 메모리 확인.
 * 받기는 앱 프로세스의 코루틴에서 돌아 화면을 떠나도 이어진다 (프로세스가 죽으면 이어받기로 재개).
 */
class GemmaModelManager internal constructor(
    private val modelDir: File,
    private val spec: GemmaModelSpec,
    private val tokenProvider: () -> String?,
    private val isUnmetered: () -> Boolean,
    private val totalRamMb: () -> Int,
    private val freeSpace: () -> Long,
    private val scope: CoroutineScope,
) {
    constructor(context: Context, tokenProvider: () -> String?, spec: GemmaModelSpec = GemmaModelSpec.DEFAULT) : this(
        modelDir = File(context.applicationContext.filesDir, "models"),
        spec = spec,
        tokenProvider = tokenProvider,
        isUnmetered = {
            val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            cm.activeNetwork != null && !cm.isActiveNetworkMetered
        },
        totalRamMb = {
            val info = ActivityManager.MemoryInfo()
            (context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager).getMemoryInfo(info)
            (info.totalMem / (1024 * 1024)).toInt()
        },
        freeSpace = { context.applicationContext.filesDir.usableSpace },
        scope = CoroutineScope(SupervisorJob() + Dispatchers.IO),
    )

    val minRamMb: Int get() = spec.minRamMb
    fun deviceRamMb(): Int = totalRamMb()
    fun ramSufficient(): Boolean = totalRamMb() >= spec.minRamMb

    val modelFile: File get() = File(modelDir, spec.fileName)
    private val partFile: File get() = File(modelDir, spec.fileName + ".part")

    @Volatile private var job: Job? = null
    @Volatile private var downloaded = 0L
    @Volatile private var total = 0L
    @Volatile private var failure = GemmaFailure.NONE
    @Volatile private var cancelRequested = false

    fun isReady(): Boolean = modelFile.exists() && modelFile.length() > 0

    fun snapshot(): GemmaSnapshot {
        val downloading = job?.isActive == true
        return when {
            downloading -> GemmaSnapshot(
                GemmaModelState.DOWNLOADING, downloaded, total.takeIf { it > 0 } ?: spec.approxBytes, failure,
            )
            isReady() -> GemmaSnapshot(GemmaModelState.READY, modelFile.length(), modelFile.length(), GemmaFailure.NONE)
            else -> GemmaSnapshot(
                GemmaModelState.NOT_DOWNLOADED,
                if (partFile.exists()) partFile.length() else 0L,
                spec.approxBytes,
                failure,
            )
        }
    }

    /** 받기를 시작하고 바로 돌아온다. 이미 받는 중이거나 받았으면 무시. 메모리가 모자라면 실패로 기록한다. */
    @Synchronized
    fun startDownload(wifiOnly: Boolean) {
        if (job?.isActive == true || isReady()) return
        failure = GemmaFailure.NONE
        if (!ramSufficient()) {
            failure = GemmaFailure.UNKNOWN
            return
        }
        if (wifiOnly && !isUnmetered()) {
            failure = GemmaFailure.NETWORK
            return
        }
        cancelRequested = false
        downloaded = partFile.takeIf { it.exists() }?.length() ?: 0L
        total = 0L
        val downloader = GemmaDownloader(spec.url, tokenProvider, freeSpace)
        job = scope.launch {
            try {
                // 416 등으로 받던 파일을 지웠으면 한 번만 처음부터 다시 받는다.
                var attempt = 0
                while (true) {
                    try {
                        downloader.download(
                            part = partFile,
                            target = modelFile,
                            onProgress = { d, t -> downloaded = d; total = t },
                            isCancelled = { cancelRequested },
                        )
                        break
                    } catch (e: GemmaDownloadException) {
                        if (e.message == "range" && attempt++ == 0) continue
                        throw e
                    }
                }
            } catch (e: GemmaDownloadException) {
                failure = e.failure
            } catch (e: Exception) {
                failure = GemmaFailure.UNKNOWN
            }
        }
    }

    /** 받기를 멈춘다. 받던 파일은 이어받기용으로 남긴다. */
    fun cancelDownload() {
        cancelRequested = true
    }

    /** 받은 모델 · 받던 파일을 지운다. 받는 중이면 먼저 멈춘다. */
    fun delete() {
        cancelRequested = true
        job?.let { j -> kotlinx.coroutines.runBlocking { j.join() } }
        modelFile.delete()
        partFile.delete()
        downloaded = 0
        failure = GemmaFailure.NONE
    }
}
