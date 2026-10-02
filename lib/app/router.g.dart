// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 첫 실행이면 온보딩, 이미 마쳤으면 홈에서 시작한다 (FL-01). 저장된 설정을 한 번 읽는다.

@ProviderFor(startLocation)
final startLocationProvider = StartLocationProvider._();

/// 첫 실행이면 온보딩, 이미 마쳤으면 홈에서 시작한다 (FL-01). 저장된 설정을 한 번 읽는다.

final class StartLocationProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// 첫 실행이면 온보딩, 이미 마쳤으면 홈에서 시작한다 (FL-01). 저장된 설정을 한 번 읽는다.
  StartLocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startLocationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startLocationHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return startLocation(ref);
  }
}

String _$startLocationHash() => r'b463f811cdeb5987b4fd5f0d403eb827e151350c';

/// [startLocationProvider]가 정해진 뒤에만 읽는다 (앱이 그때까지 기다린다).

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// [startLocationProvider]가 정해진 뒤에만 읽는다 (앱이 그때까지 기다린다).

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// [startLocationProvider]가 정해진 뒤에만 읽는다 (앱이 그때까지 기다린다).
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'd41f8fc0600d70a358f6e23566baaaf84bd0e8d2';
