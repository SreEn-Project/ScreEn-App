import '../../domain/repositories/model_repository.dart';
import '../datasources/model_native_data_source.dart';

class ModelRepositoryImpl implements ModelRepository {
  const ModelRepositoryImpl(this._dataSource);

  final ModelNativeDataSource _dataSource;

  @override
  Future<Set<String>> downloaded() async =>
      (await _dataSource.getDownloadedLanguages()).toSet();

  @override
  Future<void> download(String languageCode, {required bool wifiOnly}) =>
      _dataSource.downloadLanguage(languageCode, wifiOnly);

  @override
  Future<void> delete(String languageCode) =>
      _dataSource.deleteLanguage(languageCode);
}
