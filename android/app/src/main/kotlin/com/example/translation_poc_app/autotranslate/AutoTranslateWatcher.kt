package com.example.translation_poc_app.autotranslate

import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

/**
 * 자동 번역 감시 루프 (#23). [arm]하면 [sample]로 화면 지문을 주기적으로 읽어 [AutoTranslateTracker]에 넘기고,
 * 다시 번역할 때가 되면 [translate]를 부른다. [stop]하면 즉시 멈춘다 (오버레이를 닫음 · 화면 꺼짐 · 서비스 종료).
 *
 * 비용을 줄이는 점: 지문은 프레임 버퍼에서 바로 뽑은 격자 표본이고, 화면이 안 바뀌면 확인 간격이 늘어나며,
 * 번역(OCR)은 화면이 뚜렷이 바뀌고 안정된 뒤에만 돈다. 정지한 화면에서 하는 일은 지문 읽기뿐이다.
 */
class AutoTranslateWatcher(
    private val scope: CoroutineScope,
    /** 화면 지문. 프레임이 아직 없으면 null. */
    private val sample: suspend () -> IntArray?,
    private val config: () -> AutoTranslateConfig,
    /** 다시 번역한다. 지금 할 수 없으면(번역 중 · 메뉴 열림 등) false — 다음 확인에서 다시 시도한다. */
    private val translate: suspend () -> Boolean,
    private val clock: () -> Long = { System.nanoTime() / 1_000_000 },
) {
    private val tracker = AutoTranslateTracker(config)
    private var job: Job? = null

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

    private suspend fun loop() {
        // 결과 시트가 자리 잡을 시간. 이 뒤의 첫 지문이 기준이 된다.
        delay(FIRST_SAMPLE_DELAY_MS)
        while (scope.isActive) {
            try {
                val signature = sample()
                if (signature != null &&
                    tracker.onSample(signature, clock()) == AutoTranslateTracker.Decision.TRANSLATE &&
                    translate()
                ) {
                    tracker.onTranslated(clock())
                    delay(FIRST_SAMPLE_DELAY_MS)
                    continue
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
