package com.example.translation_poc_app.translate

import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.common.model.RemoteModelManager
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.TranslateRemoteModel

/**
 * 언어 모델 관리 (FL-05). 앱의 언어 모델 화면이 쓴다: 받아 둔 목록 · 받기 · 삭제.
 * 번역 중 자동으로 받는 것은 [MlKitTranslationEngine]이 맡고, 둘은 같은 ML Kit 저장소를 본다.
 * ML Kit은 진행률을 주지 않는다: 받기는 끝나면 돌아오고, 실패는 예외로 던진다.
 */
class LanguageModelManager(private val modelManager: RemoteModelManager = RemoteModelManager.getInstance()) {

    suspend fun downloaded(): Set<String> =
        modelManager.getDownloadedModels(TranslateRemoteModel::class.java).await().map { it.language }.toSet()

    suspend fun download(language: String, wifiOnly: Boolean) {
        val code = checked(language)
        val conditions = DownloadConditions.Builder().apply { if (wifiOnly) requireWifi() }.build()
        modelManager.download(model(code), conditions).await()
    }

    suspend fun delete(language: String) {
        modelManager.deleteDownloadedModel(model(checked(language))).await()
    }

    private fun checked(language: String): String {
        val code = LanguagePlan.normalize(language)
        require(code in TranslateLanguage.getAllLanguages()) { "지원하지 않는 언어: $language" }
        return code
    }

    private fun model(code: String) = TranslateRemoteModel.Builder(code).build()
}
