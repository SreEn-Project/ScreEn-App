// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 정보 화면의 앱 버전 (FL-14).

@ProviderFor(appInfo)
final appInfoProvider = AppInfoProvider._();

/// 정보 화면의 앱 버전 (FL-14).

final class AppInfoProvider
    extends $FunctionalProvider<AsyncValue<AppInfo>, AppInfo, FutureOr<AppInfo>>
    with $FutureModifier<AppInfo>, $FutureProvider<AppInfo> {
  /// 정보 화면의 앱 버전 (FL-14).
  AppInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInfoHash();

  @$internal
  @override
  $FutureProviderElement<AppInfo> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppInfo> create(Ref ref) {
    return appInfo(ref);
  }
}

String _$appInfoHash() => r'd426b8a33aa63c82e200106c821543ce9c86a0d2';
