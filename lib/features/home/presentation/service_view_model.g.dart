// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 홈의 번역 시작/중지 (FL-03). 네이티브 서비스 상태를 그대로 따라간다.
/// 알림의 "중지"나 시스템에서 공유를 끈 경우에도 이벤트로 상태가 맞춰진다.

@ProviderFor(ServiceViewModel)
final serviceViewModelProvider = ServiceViewModelProvider._();

/// 홈의 번역 시작/중지 (FL-03). 네이티브 서비스 상태를 그대로 따라간다.
/// 알림의 "중지"나 시스템에서 공유를 끈 경우에도 이벤트로 상태가 맞춰진다.
final class ServiceViewModelProvider
    extends $StreamNotifierProvider<ServiceViewModel, ServiceState> {
  /// 홈의 번역 시작/중지 (FL-03). 네이티브 서비스 상태를 그대로 따라간다.
  /// 알림의 "중지"나 시스템에서 공유를 끈 경우에도 이벤트로 상태가 맞춰진다.
  ServiceViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceViewModelHash();

  @$internal
  @override
  ServiceViewModel create() => ServiceViewModel();
}

String _$serviceViewModelHash() => r'5476d6af5316fa2fad3bc6beef64f622b0e38a23';

/// 홈의 번역 시작/중지 (FL-03). 네이티브 서비스 상태를 그대로 따라간다.
/// 알림의 "중지"나 시스템에서 공유를 끈 경우에도 이벤트로 상태가 맞춰진다.

abstract class _$ServiceViewModel extends $StreamNotifier<ServiceState> {
  Stream<ServiceState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ServiceState>, ServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ServiceState>, ServiceState>,
              AsyncValue<ServiceState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
