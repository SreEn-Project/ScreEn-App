package com.example.translation_poc_app.translate

import java.io.Closeable

/** 번역 엔진 종류. 엔진이 늘면 여기에 추가한다 (NA-11). */
enum class EngineId { ML_KIT, GEMINI }

/** 원문 언어를 엔진이 알아서 고르게 할 때 쓰는 값. */
const val AUTO_LANGUAGE = "auto"

/** @param source 언어 코드(ko, en …) 또는 [AUTO_LANGUAGE]. target은 항상 언어 코드. */
data class TranslationRequest(val text: String, val source: String, val target: String)

data class TranslationResult(
    val text: String,
    /** 실제로 쓴 원문 언어 (auto였다면 감지한 언어). */
    val sourceLanguage: String,
    val targetLanguage: String,
    val engine: EngineId,
)

/** 번역 · 모델 관리 실패 이유. 엔진 구현이 무엇이든 같은 종류로 돌려준다. */
sealed interface TranslationError {
    /** 엔진이 이 언어를 지원하지 않는다. */
    data class UnsupportedLanguage(val language: String) : TranslationError

    /** auto인데 원문 언어를 알아내지 못했다. */
    data object LanguageUndetermined : TranslationError

    /** 번역에 필요한 언어 모델이 기기에 없고, 자동 내려받기도 꺼져 있다. */
    data class ModelNotDownloaded(val languages: List<String>) : TranslationError

    /** 모델 내려받기 조건(Wi-Fi 등)이 안 맞거나 네트워크 문제. */
    data object Network : TranslationError

    data object NotEnoughSpace : TranslationError

    /** 엔진 자체를 쓸 수 없다 (예: 서비스 미지원 기기). */
    /** AI 엔진인데 API 키가 없다. */
    data object NoApiKey : TranslationError

    /** API 키가 거부됐다 (잘못된 키 · 권한 없음). */
    data object InvalidApiKey : TranslationError

    /** 키는 유효하지만 이 계정 · 지역 · 연령으로는 쓸 수 없다 (403). */
    data object AccessDenied : TranslationError

    /** 사용 한도 초과 또는 서버 오류. */
    data object ServiceBusy : TranslationError

    data class Unavailable(val message: String?) : TranslationError

    data class Unknown(val message: String?) : TranslationError
}

sealed interface EngineResult<out T> {
    data class Ok<T>(val value: T) : EngineResult<T>
    data class Err(val error: TranslationError) : EngineResult<Nothing>
}

/** 언어 모델 내려받기 조건. */
data class ModelDownloadPolicy(val wifiOnly: Boolean = true)

/**
 * 번역 엔진 공통 규약 (NA-11). 서비스는 이 인터페이스만 본다.
 * 메서드는 예외 대신 [EngineResult]로 실패를 돌려준다 (취소 예외는 그대로 던진다).
 * ML Kit 구현은 [MlKitTranslationEngine] (NA-12). 실패 시 ML Kit으로 대체하는 것은 호출 쪽 책임.
 */
interface TranslationEngine : Closeable {
    val id: EngineId

    /** 엔진이 이 언어를 (원문 · 대상으로) 다룰 수 있는가. 순수 조회, 모델 유무와 무관. */
    fun supports(language: String): Boolean

    suspend fun translate(request: TranslationRequest): EngineResult<TranslationResult>

    /** 번역에 필요한 모델이 모두 기기에 있는가. 모델이 없는 엔진(클라우드)은 항상 true. */
    suspend fun isLanguageAvailable(language: String): EngineResult<Boolean>

    /** 언어 모델 내려받기. 이미 있으면 바로 Ok. 모델이 없는 엔진은 바로 Ok. */
    suspend fun downloadLanguage(language: String, policy: ModelDownloadPolicy): EngineResult<Unit>

    suspend fun deleteLanguage(language: String): EngineResult<Unit>
}
