// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 권한 안내 · 홈 시작 버튼이 함께 보는 권한 상태 (FL-02).
/// 시스템 설정에서 돌아오면 화면이 [refresh]를 불러 다시 확인한다.

@ProviderFor(PermissionViewModel)
final permissionViewModelProvider = PermissionViewModelProvider._();

/// 권한 안내 · 홈 시작 버튼이 함께 보는 권한 상태 (FL-02).
/// 시스템 설정에서 돌아오면 화면이 [refresh]를 불러 다시 확인한다.
final class PermissionViewModelProvider
    extends $AsyncNotifierProvider<PermissionViewModel, AppPermissions> {
  /// 권한 안내 · 홈 시작 버튼이 함께 보는 권한 상태 (FL-02).
  /// 시스템 설정에서 돌아오면 화면이 [refresh]를 불러 다시 확인한다.
  PermissionViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionViewModelHash();

  @$internal
  @override
  PermissionViewModel create() => PermissionViewModel();
}

String _$permissionViewModelHash() =>
    r'1d326416461c17c3eebbdad1faaa75abf179c477';

/// 권한 안내 · 홈 시작 버튼이 함께 보는 권한 상태 (FL-02).
/// 시스템 설정에서 돌아오면 화면이 [refresh]를 불러 다시 확인한다.

abstract class _$PermissionViewModel extends $AsyncNotifier<AppPermissions> {
  FutureOr<AppPermissions> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppPermissions>, AppPermissions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppPermissions>, AppPermissions>,
              AsyncValue<AppPermissions>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
