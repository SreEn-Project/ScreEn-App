import '../../../../core/bridge/translator_api.g.dart' as pigeon;

/// 네이티브 언어 모델 API(Pigeon, ML Kit)를 감싼다.
class ModelNativeDataSource {
  const ModelNativeDataSource(this._api);

  final pigeon.ModelHostApi _api;

  Future<List<String>> getDownloadedLanguages() =>
      _api.getDownloadedLanguages();

  Future<void> downloadLanguage(String code, bool wifiOnly) =>
      _api.downloadLanguage(code, wifiOnly);

  Future<void> deleteLanguage(String code) => _api.deleteLanguage(code);
}
