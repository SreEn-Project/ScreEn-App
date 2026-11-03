import '../../../../core/bridge/translator_api.g.dart' as pigeon;

/// 네이티브 Gemma API(Pigeon)를 감싼다.
class GemmaNativeDataSource {
  const GemmaNativeDataSource(this._api);

  final pigeon.GemmaHostApi _api;

  Future<pigeon.GemmaStatus> getStatus() => _api.getStatus();

  Future<void> startDownload(bool wifiOnly) => _api.startDownload(wifiOnly);

  Future<void> cancelDownload() => _api.cancelDownload();

  Future<void> deleteModel() => _api.deleteModel();

  Future<void> setToken(String token) => _api.setHuggingFaceToken(token);

  Future<void> clearToken() => _api.clearHuggingFaceToken();
}
