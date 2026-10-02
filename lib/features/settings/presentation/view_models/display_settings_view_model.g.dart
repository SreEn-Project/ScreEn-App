// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_settings_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 표시 설정 (FL-07): 결과 표시 방식 · 플로팅 버튼 크기 · 투명도. 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 실행 중인 플로팅 버튼에 바로 반영되고, 이벤트로 다시 돌아와 화면이 갱신된다.

@ProviderFor(DisplaySettingsViewModel)
final displaySettingsViewModelProvider = DisplaySettingsViewModelProvider._();

/// 표시 설정 (FL-07): 결과 표시 방식 · 플로팅 버튼 크기 · 투명도. 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 실행 중인 플로팅 버튼에 바로 반영되고, 이벤트로 다시 돌아와 화면이 갱신된다.
final class DisplaySettingsViewModelProvider
    extends $StreamNotifierProvider<DisplaySettingsViewModel, DisplaySettings> {
  /// 표시 설정 (FL-07): 결과 표시 방식 · 플로팅 버튼 크기 · 투명도. 네이티브 설정(DataStore)이 원본이라
  /// 바꾸면 실행 중인 플로팅 버튼에 바로 반영되고, 이벤트로 다시 돌아와 화면이 갱신된다.
  DisplaySettingsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displaySettingsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displaySettingsViewModelHash();

  @$internal
  @override
  DisplaySettingsViewModel create() => DisplaySettingsViewModel();
}

String _$displaySettingsViewModelHash() =>
    r'dcacddd3e73e507ccafe4a05e6f11b76b00f9228';

/// 표시 설정 (FL-07): 결과 표시 방식 · 플로팅 버튼 크기 · 투명도. 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 실행 중인 플로팅 버튼에 바로 반영되고, 이벤트로 다시 돌아와 화면이 갱신된다.

abstract class _$DisplaySettingsViewModel
    extends $StreamNotifier<DisplaySettings> {
  Stream<DisplaySettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DisplaySettings>, DisplaySettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DisplaySettings>, DisplaySettings>,
              AsyncValue<DisplaySettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
