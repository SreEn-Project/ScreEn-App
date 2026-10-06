// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_of_the_day_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 오늘의 단어 (AD-14).

@ProviderFor(WordOfTheDayViewModel)
final wordOfTheDayViewModelProvider = WordOfTheDayViewModelProvider._();

/// 오늘의 단어 (AD-14).
final class WordOfTheDayViewModelProvider
    extends $AsyncNotifierProvider<WordOfTheDayViewModel, WordOfTheDayState> {
  /// 오늘의 단어 (AD-14).
  WordOfTheDayViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordOfTheDayViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordOfTheDayViewModelHash();

  @$internal
  @override
  WordOfTheDayViewModel create() => WordOfTheDayViewModel();
}

String _$wordOfTheDayViewModelHash() =>
    r'd1a5bfa1460e01798f40b1b9c8fe6ddf15c4392e';

/// 오늘의 단어 (AD-14).

abstract class _$WordOfTheDayViewModel
    extends $AsyncNotifier<WordOfTheDayState> {
  FutureOr<WordOfTheDayState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<WordOfTheDayState>, WordOfTheDayState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WordOfTheDayState>, WordOfTheDayState>,
              AsyncValue<WordOfTheDayState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
