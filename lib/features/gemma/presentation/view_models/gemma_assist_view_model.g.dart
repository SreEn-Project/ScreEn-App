// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemma_assist_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Gemma 도우미 설정 (#176): 번역 전 OCR 보정 · 번역 후 다듬기. 원본은 네이티브 설정이라
/// 바꾸면 이벤트로 돌아와 화면이 갱신된다.

@ProviderFor(GemmaAssistViewModel)
final gemmaAssistViewModelProvider = GemmaAssistViewModelProvider._();

/// Gemma 도우미 설정 (#176): 번역 전 OCR 보정 · 번역 후 다듬기. 원본은 네이티브 설정이라
/// 바꾸면 이벤트로 돌아와 화면이 갱신된다.
final class GemmaAssistViewModelProvider
    extends $StreamNotifierProvider<GemmaAssistViewModel, GemmaAssistOptions> {
  /// Gemma 도우미 설정 (#176): 번역 전 OCR 보정 · 번역 후 다듬기. 원본은 네이티브 설정이라
  /// 바꾸면 이벤트로 돌아와 화면이 갱신된다.
  GemmaAssistViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemmaAssistViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemmaAssistViewModelHash();

  @$internal
  @override
  GemmaAssistViewModel create() => GemmaAssistViewModel();
}

String _$gemmaAssistViewModelHash() =>
    r'0de7b78aaef42ae3eec8d51fdd4f551054dad625';

/// Gemma 도우미 설정 (#176): 번역 전 OCR 보정 · 번역 후 다듬기. 원본은 네이티브 설정이라
/// 바꾸면 이벤트로 돌아와 화면이 갱신된다.

abstract class _$GemmaAssistViewModel
    extends $StreamNotifier<GemmaAssistOptions> {
  Stream<GemmaAssistOptions> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<GemmaAssistOptions>, GemmaAssistOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GemmaAssistOptions>, GemmaAssistOptions>,
              AsyncValue<GemmaAssistOptions>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
