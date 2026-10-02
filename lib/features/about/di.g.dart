// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appInfoRepository)
final appInfoRepositoryProvider = AppInfoRepositoryProvider._();

final class AppInfoRepositoryProvider
    extends
        $FunctionalProvider<
          AppInfoRepository,
          AppInfoRepository,
          AppInfoRepository
        >
    with $Provider<AppInfoRepository> {
  AppInfoRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInfoRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInfoRepositoryHash();

  @$internal
  @override
  $ProviderElement<AppInfoRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppInfoRepository create(Ref ref) {
    return appInfoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppInfoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppInfoRepository>(value),
    );
  }
}

String _$appInfoRepositoryHash() => r'64e24ec645279d383734b7fdeb4be393df01d20d';

@ProviderFor(getAppInfo)
final getAppInfoProvider = GetAppInfoProvider._();

final class GetAppInfoProvider
    extends $FunctionalProvider<GetAppInfo, GetAppInfo, GetAppInfo>
    with $Provider<GetAppInfo> {
  GetAppInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAppInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAppInfoHash();

  @$internal
  @override
  $ProviderElement<GetAppInfo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetAppInfo create(Ref ref) {
    return getAppInfo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAppInfo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAppInfo>(value),
    );
  }
}

String _$getAppInfoHash() => r'07edb322cd80ea5fd93b4de8757ec3d5358efe0f';
