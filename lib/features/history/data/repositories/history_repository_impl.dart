import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_native_data_source.dart';
import '../mappers/history_mapper.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._dataSource);

  final HistoryNativeDataSource _dataSource;

  @override
  Future<List<HistoryEntry>> search({
    String query = '',
    DateTime? since,
    required int limit,
  }) async {
    final records = await _dataSource.getHistory(
      query,
      since?.millisecondsSinceEpoch ?? 0,
      limit,
    );
    return [for (final record in records) record.toEntity()];
  }

  @override
  Future<void> delete(int id) => _dataSource.deleteHistory(id);

  @override
  Future<void> clear() => _dataSource.clearHistory();
}
