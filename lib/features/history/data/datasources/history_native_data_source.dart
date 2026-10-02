import '../../../../core/bridge/translator_api.g.dart' as pigeon;

/// 네이티브 번역 기록 API(Pigeon, Room)를 감싼다.
class HistoryNativeDataSource {
  const HistoryNativeDataSource(this._api);

  final pigeon.HistoryHostApi _api;

  Future<List<pigeon.TranslationRecord>> getHistory(
    String query,
    int sinceMs,
    int limit,
  ) => _api.getHistory(query, sinceMs, limit);

  Future<void> deleteHistory(int id) => _api.deleteHistory(id);

  Future<void> clearHistory() => _api.clearHistory();
}
