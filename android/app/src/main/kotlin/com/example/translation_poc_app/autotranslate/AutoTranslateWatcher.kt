package com.example.translation_poc_app.autotranslate

import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

/**
 * 자동 번역 감시 루프 (#23). [arm]하면 [sample]로 화면 지문을 주기적으로 읽어 [AutoTranslateTracker]에 넘기고,
 * 다시 번역할 때가 되면 [translate]를 부른다. [stop]하면 즉시 멈춘다 (오버레이를 닫음 · 화면 꺼짐 · 서비스 종료).
 *
 * 비용을 줄이는 점: 지문은 프레임 버퍼에서 바로 뽑은 격자 표본이고, 화면이 안 바뀌면 확인 간격이 늘어나며,
 * 번역(OCR)은 화면이 뚜렷이 바뀌고 안정된 뒤에만 돈다. 정지한 화면에서 하는 일은 지문 읽기뿐이다.
 *
 * 번역은 감시 루프와 따로 돌아서(자식 작업), 번역하는 동안에도 지문을 계속 읽는다. 번역할 화면을 캡처한 뒤
 * ([markCaptured]) 화면이 또 바뀌면 사용자가 다시 조작한 것이므로 그 번역을 취소하고 조작이 끝나길 다시 기다린다.
 * 화면이 바뀐 걸 안 뒤 숨김 시간이 지나면 [setStale]로 낡은 결과를 숨기게 한다.
 */
class AutoTranslateWatcher(
    private val scope: CoroutineScope,
    /** 화면 지문. 프레임이 아직 없으면 null. */
    private val sample: suspend () -> IntArray?,
    private val config: () -> AutoTranslateConfig,
    /**
     * 다시 번역한다. 지금 할 수 없으면(번역 중 · 메뉴 열림 등) false — 다음 확인에서 다시 시도한다.
     * 번역할 화면을 캡처하면 [markCaptured]를 불러야 한다 (그 뒤에 화면이 바뀌어야 취소로 본다).
     */
    private val translate: suspend () -> Boolean,
    /** 낡은 결과를 숨기거나(true) 다시 보이게(false) 한다. 새 번역이 끝나면 호출하지 않는다 (결과를 새로 그리므로). */
    private val setStale: (Boolean) -> Unit = {},
    private val clock: () -> Long = { System.nanoTime() / 1_000_000 },
) {
    private val tracker = AutoTranslateTracker(config)
    private var job: Job? = null

    /** 번역 작업이 캡처를 마쳤는지. 그 뒤 첫 지문이 "번역한 화면"의 기준이 된다. */
    @Volatile
    private var captured = false

    val isWatching: Boolean get() = job?.isActive == true

    /** 번역 결과가 막 화면에 올랐다: 지금부터 감시한다 (이미 감시 중이면 기준을 새로 잡는다). */
    fun arm() {
        stop()
        tracker.onTranslated(clock())
        job = scope.launch { loop() }
    }

    fun stop() {
        job?.cancel()
        job = null
    }

    /** 번역할 화면을 캡처했다 (다시 번역하는 중에 부른다). */
    fun markCaptured() {
        captured = true
    }

    private suspend fun loop() = coroutineScope {
        // 결과 시트가 자리 잡을 시간. 이 뒤의 첫 지문이 기준이 된다.
        delay(FIRST_SAMPLE_DELAY_MS)
        var running: Job? = null
        var runningBase: IntArray? = null
        var quietUntil = Long.MIN_VALUE
        var stale = false
        while (isActive) {
            try {
                val signature = sample()
                val now = clock()
                if (signature != null && now >= quietUntil) {
                    val current = running
                    if (current != null && current.isActive) {
                        // 번역 중: 캡처한 뒤 화면이 또 바뀌었으면 사용자가 다시 조작한 것이다 → 번역을 취소한다.
                        val base = runningBase
                        if (captured && base == null) {
                            runningBase = signature
                        } else if (captured && base != null && FrameSignature.isChanged(base, signature)) {
                            current.cancelAndJoin()
                            running = null
                            tracker.onCanceled(now)
                        }
                        tracker.observe(signature)
                    } else {
                        val decision = tracker.onSample(signature, now)
                        val nowStale = tracker.isStale(now)
                        if (nowStale != stale) {
                            stale = nowStale
                            setStale(nowStale)
                        }
                        if (decision == AutoTranslateTracker.Decision.TRANSLATE) {
                            captured = false
                            runningBase = null
                            running = launch {
                                val done = try {
                                    translate()
                                } catch (e: CancellationException) {
                                    throw e
                                } catch (e: Exception) {
                                    false // 한 번 실패해도 감시는 이어간다. 다음 확인 때 다시 시도.
                                }
                                if (done) {
                                    tracker.onTranslated(clock())
                                    // 새 결과가 막 올랐다: 한 박자 뒤 화면을 기준으로 삼는다.
                                    quietUntil = clock() + FIRST_SAMPLE_DELAY_MS
                                    stale = false
                                }
                            }
                        }
                    }
                }
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                // 한 번 실패해도 감시는 이어간다. 다음 확인 때 다시 시도.
            }
            delay(tracker.nextDelayMs())
        }
    }

    companion object {
        const val FIRST_SAMPLE_DELAY_MS = 700L
    }
}
