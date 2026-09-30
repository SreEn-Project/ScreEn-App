// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(permissionRepository)
final permissionRepositoryProvider = PermissionRepositoryProvider._();

final class PermissionRepositoryProvider
    extends
        $FunctionalProvider<
          PermissionRepository,
          PermissionRepository,
          PermissionRepository
        >
    with $Provider<PermissionRepository> {
  PermissionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionRepositoryHash();

  @$internal
  @override
  $ProviderElement<PermissionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PermissionRepository create(Ref ref) {
    return permissionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PermissionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PermissionRepository>(value),
    );
  }
}

String _$permissionRepositoryHash() =>
    r'efa1a0bbf33eaa9de4a8a324c4edd2a84545794c';

@ProviderFor(checkPermissions)
final checkPermissionsProvider = CheckPermissionsProvider._();

final class CheckPermissionsProvider
    extends
        $FunctionalProvider<
          CheckPermissions,
          CheckPermissions,
          CheckPermissions
        >
    with $Provider<CheckPermissions> {
  CheckPermissionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkPermissionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkPermissionsHash();

  @$internal
  @override
  $ProviderElement<CheckPermissions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CheckPermissions create(Ref ref) {
    return checkPermissions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckPermissions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckPermissions>(value),
    );
  }
}

String _$checkPermissionsHash() => r'8943082ace2cef62bde64293a4a9f744a9bd9d1b';

@ProviderFor(requestNotificationPermission)
final requestNotificationPermissionProvider =
    RequestNotificationPermissionProvider._();

final class RequestNotificationPermissionProvider
    extends
        $FunctionalProvider<
          RequestNotificationPermission,
          RequestNotificationPermission,
          RequestNotificationPermission
        >
    with $Provider<RequestNotificationPermission> {
  RequestNotificationPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestNotificationPermissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requestNotificationPermissionHash();

  @$internal
  @override
  $ProviderElement<RequestNotificationPermission> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RequestNotificationPermission create(Ref ref) {
    return requestNotificationPermission(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RequestNotificationPermission value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RequestNotificationPermission>(
        value,
      ),
    );
  }
}

String _$requestNotificationPermissionHash() =>
    r'1f46673d6c709bd9b9e98d03815b75c9f8f65476';

@ProviderFor(requestOverlayPermission)
final requestOverlayPermissionProvider = RequestOverlayPermissionProvider._();

final class RequestOverlayPermissionProvider
    extends
        $FunctionalProvider<
          RequestOverlayPermission,
          RequestOverlayPermission,
          RequestOverlayPermission
        >
    with $Provider<RequestOverlayPermission> {
  RequestOverlayPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestOverlayPermissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requestOverlayPermissionHash();

  @$internal
  @override
  $ProviderElement<RequestOverlayPermission> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RequestOverlayPermission create(Ref ref) {
    return requestOverlayPermission(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RequestOverlayPermission value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RequestOverlayPermission>(value),
    );
  }
}

String _$requestOverlayPermissionHash() =>
    r'191729c9d50a84684ad935cd235eb87822acf203';
