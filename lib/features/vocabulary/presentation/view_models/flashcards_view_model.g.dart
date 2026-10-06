// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcards_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 카드 학습 (AD-08): 카드를 한 장씩 넘기며 외움 · 못 외움을 기록하고, 결과에서 못 외운 단어만 다시 본다.

@ProviderFor(FlashcardsViewModel)
final flashcardsViewModelProvider = FlashcardsViewModelFamily._();

/// 카드 학습 (AD-08): 카드를 한 장씩 넘기며 외움 · 못 외움을 기록하고, 결과에서 못 외운 단어만 다시 본다.
final class FlashcardsViewModelProvider
    extends $AsyncNotifierProvider<FlashcardsViewModel, FlashcardsState> {
  /// 카드 학습 (AD-08): 카드를 한 장씩 넘기며 외움 · 못 외움을 기록하고, 결과에서 못 외운 단어만 다시 본다.
  FlashcardsViewModelProvider._({
    required FlashcardsViewModelFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'flashcardsViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flashcardsViewModelHash();

  @override
  String toString() {
    return r'flashcardsViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FlashcardsViewModel create() => FlashcardsViewModel();

  @override
  bool operator ==(Object other) {
    return other is FlashcardsViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flashcardsViewModelHash() =>
    r'080d2a2bd7968f3146027f99f6d67714826f3ac4';

/// 카드 학습 (AD-08): 카드를 한 장씩 넘기며 외움 · 못 외움을 기록하고, 결과에서 못 외운 단어만 다시 본다.

final class FlashcardsViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          FlashcardsViewModel,
          AsyncValue<FlashcardsState>,
          FlashcardsState,
          FutureOr<FlashcardsState>,
          int
        > {
  FlashcardsViewModelFamily._()
    : super(
        retry: null,
        name: r'flashcardsViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 카드 학습 (AD-08): 카드를 한 장씩 넘기며 외움 · 못 외움을 기록하고, 결과에서 못 외운 단어만 다시 본다.

  FlashcardsViewModelProvider call(int wordbookId) =>
      FlashcardsViewModelProvider._(argument: wordbookId, from: this);

  @override
  String toString() => r'flashcardsViewModelProvider';
}

/// 카드 학습 (AD-08): 카드를 한 장씩 넘기며 외움 · 못 외움을 기록하고, 결과에서 못 외운 단어만 다시 본다.

abstract class _$FlashcardsViewModel extends $AsyncNotifier<FlashcardsState> {
  late final _$args = ref.$arg as int;
  int get wordbookId => _$args;

  FutureOr<FlashcardsState> build(int wordbookId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FlashcardsState>, FlashcardsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FlashcardsState>, FlashcardsState>,
              AsyncValue<FlashcardsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
