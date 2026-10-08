// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_edit_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 단어 편집 시트(AD-03)의 저장 동작. 직접 추가 · 기록에서 추가가 같이 쓴다.

@ProviderFor(WordEditViewModel)
final wordEditViewModelProvider = WordEditViewModelProvider._();

/// 단어 편집 시트(AD-03)의 저장 동작. 직접 추가 · 기록에서 추가가 같이 쓴다.
final class WordEditViewModelProvider
    extends $NotifierProvider<WordEditViewModel, void> {
  /// 단어 편집 시트(AD-03)의 저장 동작. 직접 추가 · 기록에서 추가가 같이 쓴다.
  WordEditViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordEditViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordEditViewModelHash();

  @$internal
  @override
  WordEditViewModel create() => WordEditViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$wordEditViewModelHash() => r'e2f76621d7e4edc602a2f832d38189d51716043d';

/// 단어 편집 시트(AD-03)의 저장 동작. 직접 추가 · 기록에서 추가가 같이 쓴다.

abstract class _$WordEditViewModel extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
