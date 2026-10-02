import '../entities/history_entry.dart';

/// 번역 기록. 저장은 네이티브가 번역할 때 알아서 하고, 앱은 조회 · 삭제만 한다 (원본은 네이티브 Room).
abstract interface class HistoryRepository {
  /// 최신순. [query]는 원문 · 번역에서 찾을 글자(빈 문자열 = 전부), [since] 이후만(null = 전체).
  Future<List<HistoryEntry>> search({
    String query = '',
    DateTime? since,
    required int limit,
  });

  Future<void> delete(int id);

  Future<void> clear();
}
