// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_options_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AI 번역 옵션 (FL-09 연령 확인, FL-11 말투 · 용어집). 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.

@ProviderFor(AiOptionsViewModel)
final aiOptionsViewModelProvider = AiOptionsViewModelProvider._();

/// AI 번역 옵션 (FL-09 연령 확인, FL-11 말투 · 용어집). 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
final class AiOptionsViewModelProvider
    extends $StreamNotifierProvider<AiOptionsViewModel, AiOptions> {
  /// AI 번역 옵션 (FL-09 연령 확인, FL-11 말투 · 용어집). 네이티브 설정(DataStore)이 원본이라
  /// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
  AiOptionsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiOptionsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiOptionsViewModelHash();

  @$internal
  @override
  AiOptionsViewModel create() => AiOptionsViewModel();
}

String _$aiOptionsViewModelHash() =>
    r'1d89b6187cf416242dec220020997fda5fee0d51';

/// AI 번역 옵션 (FL-09 연령 확인, FL-11 말투 · 용어집). 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.

abstract class _$AiOptionsViewModel extends $StreamNotifier<AiOptions> {
  Stream<AiOptions> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AiOptions>, AiOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AiOptions>, AiOptions>,
              AsyncValue<AiOptions>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
