package com.example.translation_poc_app.translate

/**
 * 블록(원문 글자) 단위 결과 캐시 (#35). 같은 글자가 다시 읽히면 언어 감지와 번역을 건너뛴다.
 * 스크롤해도 화면에 남아 있는 글자, 반복되는 UI 문구, 같은 화면을 다시 번역하는 자동 모드가 대상이다.
 *
 * 크기는 자동으로 관리한다 (가장 오래 안 쓴 것부터 버리는 LRU, 상한 [capacity]). 항목이 글자 몇십~몇백 자라
 * 상한에 닿아도 메모리는 작고, 사용자가 정할 이유가 없어 설정은 두지 않는다.
 * 키에 대상 언어 · 엔진을 넣어 바뀌면 자연스럽게 안 맞고 밀려난다. 스레드 안전.
 */
class BlockCache<K : Any, V : Any>(private val capacity: Int = DEFAULT_CAPACITY) {

    private val map = object : LinkedHashMap<K, V>(16, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<K, V>?) = size > capacity
    }

    operator fun get(key: K): V? = synchronized(map) { map[key] }

    operator fun set(key: K, value: V) {
        synchronized(map) { map[key] = value }
    }

    val size: Int get() = synchronized(map) { map.size }

    companion object {
        const val DEFAULT_CAPACITY = 512
    }
}

/** 언어 감지 캐시 키: 감지에 쓰는 글자 + OCR이 추정한 언어 + 대상 언어. */
data class DecisionKey(val text: String, val ocrLanguage: String, val target: String)

/** 번역 캐시 키: 엔진 + 원문 + 원문 언어 + 대상 언어. 성공한 번역만 넣는다. */
data class TranslationKey(val engine: EngineId, val text: String, val source: String, val target: String)
