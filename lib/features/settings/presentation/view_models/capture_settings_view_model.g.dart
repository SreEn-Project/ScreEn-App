// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_settings_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 캡처 모드 설정 (FL-08): 기본 캡처 모드 · 고정 영역 초기화. 네이티브 설정(DataStore)이 원본이라
/// 플로팅 버튼 메뉴에서 바꾼 모드도 이벤트로 돌아와 화면에 반영된다.

@ProviderFor(CaptureSettingsViewModel)
final captureSettingsViewModelProvider = CaptureSettingsViewModelProvider._();

/// 캡처 모드 설정 (FL-08): 기본 캡처 모드 · 고정 영역 초기화. 네이티브 설정(DataStore)이 원본이라
/// 플로팅 버튼 메뉴에서 바꾼 모드도 이벤트로 돌아와 화면에 반영된다.
final class CaptureSettingsViewModelProvider
    extends $StreamNotifierProvider<CaptureSettingsViewModel, CaptureSettings> {
  /// 캡처 모드 설정 (FL-08): 기본 캡처 모드 · 고정 영역 초기화. 네이티브 설정(DataStore)이 원본이라
  /// 플로팅 버튼 메뉴에서 바꾼 모드도 이벤트로 돌아와 화면에 반영된다.
  CaptureSettingsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captureSettingsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captureSettingsViewModelHash();

  @$internal
  @override
  CaptureSettingsViewModel create() => CaptureSettingsViewModel();
}

String _$captureSettingsViewModelHash() =>
    r'a113a8075b6e8f83c29915f85c52ea144a114b36';

/// 캡처 모드 설정 (FL-08): 기본 캡처 모드 · 고정 영역 초기화. 네이티브 설정(DataStore)이 원본이라
/// 플로팅 버튼 메뉴에서 바꾼 모드도 이벤트로 돌아와 화면에 반영된다.

abstract class _$CaptureSettingsViewModel
    extends $StreamNotifier<CaptureSettings> {
  Stream<CaptureSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CaptureSettings>, CaptureSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CaptureSettings>, CaptureSettings>,
              AsyncValue<CaptureSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
