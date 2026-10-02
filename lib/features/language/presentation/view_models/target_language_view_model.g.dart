// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_language_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 대상 언어 (FL-04). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
/// 홈 · 언어 탭 · 선택 화면이 함께 쓴다.

@ProviderFor(TargetLanguageViewModel)
final targetLanguageViewModelProvider = TargetLanguageViewModelProvider._();

/// 대상 언어 (FL-04). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
/// 홈 · 언어 탭 · 선택 화면이 함께 쓴다.
final class TargetLanguageViewModelProvider
    extends $StreamNotifierProvider<TargetLanguageViewModel, String> {
  /// 대상 언어 (FL-04). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
  /// 홈 · 언어 탭 · 선택 화면이 함께 쓴다.
  TargetLanguageViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'targetLanguageViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$targetLanguageViewModelHash();

  @$internal
  @override
  TargetLanguageViewModel create() => TargetLanguageViewModel();
}

String _$targetLanguageViewModelHash() =>
    r'51ffe6091778e1b77deaa75634762349fbda3e31';

/// 대상 언어 (FL-04). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
/// 홈 · 언어 탭 · 선택 화면이 함께 쓴다.

abstract class _$TargetLanguageViewModel extends $StreamNotifier<String> {
  Stream<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 언어 모델 화면의 Wi-Fi 전용 받기 스위치 (FL-05).

@ProviderFor(WifiOnlyDownloadViewModel)
final wifiOnlyDownloadViewModelProvider = WifiOnlyDownloadViewModelProvider._();

/// 언어 모델 화면의 Wi-Fi 전용 받기 스위치 (FL-05).
final class WifiOnlyDownloadViewModelProvider
    extends $StreamNotifierProvider<WifiOnlyDownloadViewModel, bool> {
  /// 언어 모델 화면의 Wi-Fi 전용 받기 스위치 (FL-05).
  WifiOnlyDownloadViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wifiOnlyDownloadViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wifiOnlyDownloadViewModelHash();

  @$internal
  @override
  WifiOnlyDownloadViewModel create() => WifiOnlyDownloadViewModel();
}

String _$wifiOnlyDownloadViewModelHash() =>
    r'16aaca677a78d3863cef0f96bc21a1adbf300f1b';

/// 언어 모델 화면의 Wi-Fi 전용 받기 스위치 (FL-05).

abstract class _$WifiOnlyDownloadViewModel extends $StreamNotifier<bool> {
  Stream<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
