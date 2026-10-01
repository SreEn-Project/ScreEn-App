package com.example.translation_poc_app.autotranslate

/**
 * 자동 번역 · 이전 번역 숨김이 쓰는 시간 설정 (ms). 사용자 설정은 [showDelayMs] · [hideMs] 둘뿐이고, 나머지는
 * 열 · 배터리를 위한 고정값이다.
 */
data class AutoTranslateConfig(
    /**
     * 새 번역을 보여 줄 시점: 조작이 끝난 뒤 이 시간이 지나기 전에는 새 번역을 올리지 않는다. 0 = 번역이 되는 대로 바로.
     * 번역 작업 자체는 화면이 멈추면 바로 시작하므로 그동안 미리 해 둔다.
     */
    val showDelayMs: Long = 0L,
    /** 화면이 바뀐 걸 안 뒤 이전 결과를 숨기기까지의 시간. 음수 = 숨기지 않는다. */
    val hideMs: Long = HIDE_NEVER,
    /** false면 다시 번역하지 않고 낡은 결과 숨김만 한다 (자동 번역이 꺼진 채 덮어쓰기 결과가 떠 있을 때). */
    val retranslate: Boolean = true,
    /** 화면 확인 간격. 번역이 연달아 도는 것은 [minTranslateGapMs]로 막는다. */
    val checkIntervalMs: Long = CHECK_INTERVAL_MS,
    /** 번역과 번역 사이 최소 간격. 계속 바뀌는 화면에서 번역이 연달아 도는 것을 막는다. */
    val minTranslateGapMs: Long = MIN_TRANSLATE_GAP_MS,
) {
    companion object {
        const val CHECK_INTERVAL_MS = 500L
        const val MIN_TRANSLATE_GAP_MS = 1_000L
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
 * 2. 이후 지문이 기준과 뚜렷이 다르면 "바뀜"이다. 바뀐 화면이 멈추고(연속된 두 지문이 같음) 마지막 번역으로부터
 *    [AutoTranslateConfig.minTranslateGapMs] 지났을 때 번역을 시작한다. 조작이 끝난 시각은 [interactionEndedAt]이고,
 *    새 번역은 그로부터 [AutoTranslateConfig.showDelayMs] 뒤에 올린다 ([showNotBefore]).
 * 3. 변화가 없을수록 확인 간격을 늘린다 ([nextDelayMs]).
 * 4. 바뀐 걸 안 뒤 [AutoTranslateConfig.hideMs]가 지나면 낡은 결과를 숨겨야 한다 ([isStale]).
 * 5. 번역 중 화면이 또 바뀌어 번역을 취소했다면 [onCanceled]. 조작이 끝난 시각을 그 시점부터 다시 센다.
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
            // 새로 바뀌었거나 아직 움직이는 중이다: 마지막으로 움직인 시각을 갱신한다.
            pending = true
            changedAt = nowMs
        }
        // 움직이는 중에는 번역하지 않는다: 조작이 끝난 걸(두 지문이 같음) 보고 바로 번역을 시작한다.
        val settled = !moving
        val gapOk = nowMs - lastTranslatedAt >= config().minTranslateGapMs
        return if (settled && gapOk) Decision.TRANSLATE else Decision.WAIT
    }

    /** 번역 중에 본 지문. 판단은 하지 않고 "직전 지문"만 갱신해, 번역이 끝난 뒤 움직임 여부를 바로 가린다. */
    fun observe(signature: IntArray) {
        previous = signature
    }

    /** 번역 중 화면이 또 바뀌어 번역을 취소했다. 바뀐 상태는 그대로 두고 마지막으로 움직인 시각을 지금으로 한다. */
    fun onCanceled(nowMs: Long) {
        pending = true
        changedAt = nowMs
        idleChecks = 0
    }

    /** 사용자 조작이 끝난 시각(마지막으로 화면이 움직인 때). */
    val interactionEndedAt: Long get() = changedAt

    /** 지금 시작하는 번역의 결과를 올릴 수 있는 가장 이른 시각: 조작이 끝난 뒤 [AutoTranslateConfig.showDelayMs]. */
    fun showNotBefore(): Long = changedAt + config().showDelayMs

    /** 바뀐 걸 안 뒤 숨김 시간이 지났다: 번역한 화면이 더는 아니라서 낡은 결과를 숨겨야 한다. 기준으로 돌아오면 다시 false. */
    fun isStale(nowMs: Long): Boolean {
        val hide = config().hideMs
        return pending && hide >= 0 && nowMs - changeStartedAt >= hide
    }

    /**
     * 다음 확인까지의 시간. 바뀜을 기다리는 중이면 설정 간격 그대로, 변화 없이 오래 지나면 간격을 조금씩 늘려
     * 정지한 화면을 지켜보는 비용을 줄인다 (최대 [MAX_IDLE_DELAY_MS]: 다시 움직였을 때 숨김이 너무 늦지 않게).
     */
    fun nextDelayMs(): Long {
        val interval = config().checkIntervalMs
        if (pending) return interval
        val factor = when {
            idleChecks >= IDLE_LONG -> 3
            idleChecks >= IDLE_SHORT -> 2
            else -> 1
        }
        return (interval * factor).coerceAtMost(maxOf(MAX_IDLE_DELAY_MS, interval))
    }

    companion object {
        const val IDLE_SHORT = 20
        const val IDLE_LONG = 60
        const val MAX_IDLE_DELAY_MS = 1_500L
    }
}
