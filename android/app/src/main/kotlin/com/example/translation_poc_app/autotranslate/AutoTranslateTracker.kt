package com.example.translation_poc_app.autotranslate

/**
 * 자동 번역이 쓰는 시간 설정 (ms). 확인 간격 · 안정 대기 · 숨김 시간은 사용자 설정, 나머지는 열 · 배터리를 위한 고정값.
 * [settleMs]가 0이면 "조작이 끝나면 바로" — 화면이 멈춘 걸 본 즉시 번역한다 (번역 중 또 바뀌면 취소되므로 간격 제한도 둔다).
 */
data class AutoTranslateConfig(
    val checkIntervalMs: Long,
    val settleMs: Long,
    /** 화면이 바뀐 걸 안 뒤 이전 결과를 숨기기까지의 시간. 음수 = 숨기지 않는다. */
    val hideMs: Long = HIDE_NEVER,
    /** 번역과 번역 사이 최소 간격. 계속 바뀌는 화면에서 번역이 연달아 도는 것을 막는다. 바로 번역(0)이면 두지 않는다. */
    val minTranslateGapMs: Long = if (settleMs == 0L) 0L else MIN_TRANSLATE_GAP_MS,
) {
    companion object {
        const val MIN_TRANSLATE_GAP_MS = 3_000L
        const val HIDE_NEVER = -1L
    }
}

/**
 * 자동 번역의 판단 (#23). 지문([FrameSignature])을 하나씩 받아 "지금 다시 번역할지"와 "다음 확인까지 얼마나 쉴지"를
 * 정한다. 시간은 밖에서 넣어 주므로 시험이 쉽다.
 *
 * 흐름
 * 1. 번역이 끝나면 [onTranslated]. 첫 확인의 지문이 **기준**이 된다 (결과 시트가 막 뜨며 화면이 바뀌는 것을
 *    "변화"로 오해하지 않도록 번역 직후가 아니라 한 박자 뒤 화면을 기준으로 삼는다).
 * 2. 이후 지문이 기준과 뚜렷이 다르면 "바뀜"이다. 바뀐 상태가 [AutoTranslateConfig.settleMs] 동안 더 변하지 않고
 *    (스크롤이 멈추고) 마지막 번역으로부터 [AutoTranslateConfig.minTranslateGapMs] 지났을 때만 번역한다.
 * 3. 변화가 없을수록 확인 간격을 늘린다 ([nextDelayMs]).
 * 4. 바뀐 걸 안 뒤 [AutoTranslateConfig.hideMs]가 지나면 낡은 결과를 숨겨야 한다 ([isStale]).
 * 5. 번역 중 화면이 또 바뀌어 번역을 취소했다면 [onCanceled]. 안정 대기를 그 시점부터 다시 센다.
 */
class AutoTranslateTracker(private val config: () -> AutoTranslateConfig) {

    enum class Decision { WAIT, TRANSLATE }

    private var reference: IntArray? = null
    private var previous: IntArray? = null
    private var pending = false
    private var changedAt = 0L
    private var changeStartedAt = 0L
    private var lastTranslatedAt = Long.MIN_VALUE / 2
    private var idleChecks = 0

    /** 번역을 마쳤다. 다음 지문부터 기준을 새로 잡는다. */
    fun onTranslated(nowMs: Long) {
        reference = null
        previous = null
        pending = false
        idleChecks = 0
        lastTranslatedAt = nowMs
    }

    fun onSample(signature: IntArray, nowMs: Long): Decision {
        val base = reference
        if (base == null) {
            reference = signature
            previous = signature
            return Decision.WAIT
        }
        val moving = previous?.let { FrameSignature.isChanged(it, signature) } ?: false
        previous = signature

        if (!FrameSignature.isChanged(base, signature)) {
            // 번역한 화면과 같다 (바뀌었다 돌아온 경우 포함).
            pending = false
            idleChecks++
            return Decision.WAIT
        }
        idleChecks = 0
        if (!pending) changeStartedAt = nowMs
        if (!pending || moving) {
            // 새로 바뀌었거나 아직 움직이는 중이다: 안정 대기를 다시 센다.
            pending = true
            changedAt = nowMs
        }
        // 움직이는 중에는 대기 시간이 0이어도 번역하지 않는다: 조작이 끝난 걸(두 지문이 같음) 보고 바로 번역한다.
        val settled = !moving && nowMs - changedAt >= config().settleMs
        val gapOk = nowMs - lastTranslatedAt >= config().minTranslateGapMs
        return if (settled && gapOk) Decision.TRANSLATE else Decision.WAIT
    }

    /** 번역 중에 본 지문. 판단은 하지 않고 "직전 지문"만 갱신해, 번역이 끝난 뒤 움직임 여부를 바로 가린다. */
    fun observe(signature: IntArray) {
        previous = signature
    }

    /** 번역 중 화면이 또 바뀌어 번역을 취소했다. 바뀐 상태는 그대로 두고 안정 대기를 지금부터 다시 센다. */
    fun onCanceled(nowMs: Long) {
        pending = true
        changedAt = nowMs
        idleChecks = 0
    }

    /** 바뀐 걸 안 뒤 숨김 시간이 지났다: 번역한 화면이 더는 아니라서 낡은 결과를 숨겨야 한다. 기준으로 돌아오면 다시 false. */
    fun isStale(nowMs: Long): Boolean {
        val hide = config().hideMs
        return pending && hide >= 0 && nowMs - changeStartedAt >= hide
    }

    /**
     * 다음 확인까지의 시간. 바뀜을 기다리는 중이면 설정 간격 그대로, 변화 없이 오래 지나면 간격을 2배 · 4배로 늘려
     * 정지한 화면을 지켜보는 비용을 줄인다 (최대 [MAX_BACKOFF_MS]).
     */
    fun nextDelayMs(): Long {
        val interval = config().checkIntervalMs
        if (pending) return interval
        val factor = when {
            idleChecks >= IDLE_LONG -> 4
            idleChecks >= IDLE_SHORT -> 2
            else -> 1
        }
        return (interval * factor).coerceAtMost(maxOf(MAX_BACKOFF_MS, interval))
    }

    companion object {
        const val IDLE_SHORT = 15
        const val IDLE_LONG = 40
        const val MAX_BACKOFF_MS = 8_000L
    }
}
