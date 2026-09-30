import '../../domain/entities/service_status.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_native_data_source.dart';
import '../mappers/service_status_mapper.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  const ServiceRepositoryImpl(this._dataSource);

  final ServiceNativeDataSource _dataSource;

  @override
  Future<ServiceStatus> currentStatus() async =>
      (await _dataSource.getState()).toEntity();

  @override
  Stream<ServiceStatus> watchStatus() =>
      _dataSource.watchState().map((state) => state.toEntity());

  @override
  Future<void> start() => _dataSource.start();

  @override
  Future<void> stop() => _dataSource.stop();
}
