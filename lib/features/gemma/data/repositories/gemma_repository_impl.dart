import '../../domain/entities/gemma_status.dart';
import '../../domain/repositories/gemma_repository.dart';
import '../datasources/gemma_native_data_source.dart';
import '../mappers/gemma_mapper.dart';

class GemmaRepositoryImpl implements GemmaRepository {
  const GemmaRepositoryImpl(this._dataSource);

  final GemmaNativeDataSource _dataSource;

  @override
  Future<GemmaStatus> status() async =>
      (await _dataSource.getStatus()).toEntity();

  @override
  Future<void> startDownload({required bool wifiOnly}) =>
      _dataSource.startDownload(wifiOnly);

  @override
  Future<void> cancelDownload() => _dataSource.cancelDownload();

  @override
  Future<void> deleteModel() => _dataSource.deleteModel();

  @override
  Future<void> setToken(String token) => _dataSource.setToken(token);

  @override
  Future<void> clearToken() => _dataSource.clearToken();
}
