// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(serviceRepository)
final serviceRepositoryProvider = ServiceRepositoryProvider._();

final class ServiceRepositoryProvider
    extends
        $FunctionalProvider<
          ServiceRepository,
          ServiceRepository,
          ServiceRepository
        >
    with $Provider<ServiceRepository> {
  ServiceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServiceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServiceRepository create(Ref ref) {
    return serviceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceRepository>(value),
    );
  }
}

String _$serviceRepositoryHash() => r'9cffd1177fbb4a4ebd72c263907898b7c667e7f0';

@ProviderFor(getServiceStatus)
final getServiceStatusProvider = GetServiceStatusProvider._();

final class GetServiceStatusProvider
    extends
        $FunctionalProvider<
          GetServiceStatus,
          GetServiceStatus,
          GetServiceStatus
        >
    with $Provider<GetServiceStatus> {
  GetServiceStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getServiceStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getServiceStatusHash();

  @$internal
  @override
  $ProviderElement<GetServiceStatus> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetServiceStatus create(Ref ref) {
    return getServiceStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetServiceStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetServiceStatus>(value),
    );
  }
}

String _$getServiceStatusHash() => r'0763d51b43d4219abcfbc0e18dd5969c4808b588';

@ProviderFor(watchServiceStatus)
final watchServiceStatusProvider = WatchServiceStatusProvider._();

final class WatchServiceStatusProvider
    extends
        $FunctionalProvider<
          WatchServiceStatus,
          WatchServiceStatus,
          WatchServiceStatus
        >
    with $Provider<WatchServiceStatus> {
  WatchServiceStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchServiceStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchServiceStatusHash();

  @$internal
  @override
  $ProviderElement<WatchServiceStatus> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchServiceStatus create(Ref ref) {
    return watchServiceStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchServiceStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchServiceStatus>(value),
    );
  }
}

String _$watchServiceStatusHash() =>
    r'c81a227add7a08a7a749cb85c7ae7a34a25450ba';

@ProviderFor(startTranslationService)
final startTranslationServiceProvider = StartTranslationServiceProvider._();

final class StartTranslationServiceProvider
    extends
        $FunctionalProvider<
          StartTranslationService,
          StartTranslationService,
          StartTranslationService
        >
    with $Provider<StartTranslationService> {
  StartTranslationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startTranslationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startTranslationServiceHash();

  @$internal
  @override
  $ProviderElement<StartTranslationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StartTranslationService create(Ref ref) {
    return startTranslationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StartTranslationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StartTranslationService>(value),
    );
  }
}

String _$startTranslationServiceHash() =>
    r'5da3d7201d02838eec5f3df074ad53eaa2b96d02';

@ProviderFor(stopTranslationService)
final stopTranslationServiceProvider = StopTranslationServiceProvider._();

final class StopTranslationServiceProvider
    extends
        $FunctionalProvider<
          StopTranslationService,
          StopTranslationService,
          StopTranslationService
        >
    with $Provider<StopTranslationService> {
  StopTranslationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stopTranslationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stopTranslationServiceHash();

  @$internal
  @override
  $ProviderElement<StopTranslationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StopTranslationService create(Ref ref) {
    return stopTranslationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StopTranslationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StopTranslationService>(value),
    );
  }
}

String _$stopTranslationServiceHash() =>
    r'61cb15b1f6395a77be1fe02834fa341988bf0299';
