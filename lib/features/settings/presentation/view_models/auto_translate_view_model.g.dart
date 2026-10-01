// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_translate_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 자동 번역 설정 (#23): 켜짐 · 화면 확인 간격 · 안정 대기. 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.

@ProviderFor(AutoTranslateViewModel)
final autoTranslateViewModelProvider = AutoTranslateViewModelProvider._();

/// 자동 번역 설정 (#23): 켜짐 · 화면 확인 간격 · 안정 대기. 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
final class AutoTranslateViewModelProvider
    extends
        $StreamNotifierProvider<AutoTranslateViewModel, AutoTranslateSettings> {
  /// 자동 번역 설정 (#23): 켜짐 · 화면 확인 간격 · 안정 대기. 네이티브 설정(DataStore)이 원본이라
  /// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
  AutoTranslateViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoTranslateViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoTranslateViewModelHash();

  @$internal
  @override
  AutoTranslateViewModel create() => AutoTranslateViewModel();
}

String _$autoTranslateViewModelHash() =>
    r'587785b878e10e1da7a73cfdfb13e58cd46a6682';

/// 자동 번역 설정 (#23): 켜짐 · 화면 확인 간격 · 안정 대기. 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.

abstract class _$AutoTranslateViewModel
    extends $StreamNotifier<AutoTranslateSettings> {
  Stream<AutoTranslateSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<AutoTranslateSettings>, AutoTranslateSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AutoTranslateSettings>,
                AutoTranslateSettings
              >,
              AsyncValue<AutoTranslateSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
