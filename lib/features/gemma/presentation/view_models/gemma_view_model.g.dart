// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemma_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Gemma 온디바이스 모델 화면 상태 (#174). 원본은 네이티브라 받는 중에는 [pollInterval]마다 다시 읽어 진행률을 갱신한다.

@ProviderFor(GemmaViewModel)
final gemmaViewModelProvider = GemmaViewModelProvider._();

/// Gemma 온디바이스 모델 화면 상태 (#174). 원본은 네이티브라 받는 중에는 [pollInterval]마다 다시 읽어 진행률을 갱신한다.
final class GemmaViewModelProvider
    extends $AsyncNotifierProvider<GemmaViewModel, GemmaStatus> {
  /// Gemma 온디바이스 모델 화면 상태 (#174). 원본은 네이티브라 받는 중에는 [pollInterval]마다 다시 읽어 진행률을 갱신한다.
  GemmaViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemmaViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemmaViewModelHash();

  @$internal
  @override
  GemmaViewModel create() => GemmaViewModel();
}

String _$gemmaViewModelHash() => r'fb53001184234ae4dcec840f90b236e7303db3eb';

/// Gemma 온디바이스 모델 화면 상태 (#174). 원본은 네이티브라 받는 중에는 [pollInterval]마다 다시 읽어 진행률을 갱신한다.

abstract class _$GemmaViewModel extends $AsyncNotifier<GemmaStatus> {
  FutureOr<GemmaStatus> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<GemmaStatus>, GemmaStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GemmaStatus>, GemmaStatus>,
              AsyncValue<GemmaStatus>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
