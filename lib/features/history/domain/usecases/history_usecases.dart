import '../../../../core/domain/use_case.dart';
import '../entities/history_entry.dart';
import '../repositories/history_repository.dart';

class SearchHistoryParams {
  const SearchHistoryParams({
    this.query = '',
    this.period = HistoryPeriod.all,
    this.limit = 200,
  });

  final String query;
  final HistoryPeriod period;
  final int limit;
}

/// 번역 기록 조회 · 검색 (FL-13).
final class SearchHistory
    implements UseCase<List<HistoryEntry>, SearchHistoryParams> {
  const SearchHistory(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final HistoryRepository _repository;
  final DateTime Function() _clock;

  @override
  Future<List<HistoryEntry>> call(SearchHistoryParams params) =>
      _repository.search(
        query: params.query.trim(),
        since: params.period.start(_clock()),
        limit: params.limit,
      );
}

/// 기록 한 줄 삭제 (FL-13).
final class DeleteHistoryEntry implements UseCase<void, int> {
  const DeleteHistoryEntry(this._repository);

  final HistoryRepository _repository;

  @override
  Future<void> call(int id) => _repository.delete(id);
}

/// 기록 전체 삭제 (FL-13).
final class ClearHistory implements NoParamsUseCase<void> {
  const ClearHistory(this._repository);

  final HistoryRepository _repository;

  @override
  Future<void> call() => _repository.clear();
}
