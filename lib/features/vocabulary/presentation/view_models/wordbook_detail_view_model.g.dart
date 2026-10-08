// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wordbook_detail_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WordbookDetailViewModel)
final wordbookDetailViewModelProvider = WordbookDetailViewModelFamily._();

final class WordbookDetailViewModelProvider
    extends
        $AsyncNotifierProvider<WordbookDetailViewModel, WordbookDetailState> {
  WordbookDetailViewModelProvider._({
    required WordbookDetailViewModelFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'wordbookDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wordbookDetailViewModelHash();

  @override
  String toString() {
    return r'wordbookDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WordbookDetailViewModel create() => WordbookDetailViewModel();

  @override
  bool operator ==(Object other) {
    return other is WordbookDetailViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wordbookDetailViewModelHash() =>
    r'51c121ce7ae971b15195006f9ab1a1000e4731d3';

final class WordbookDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          WordbookDetailViewModel,
          AsyncValue<WordbookDetailState>,
          WordbookDetailState,
          FutureOr<WordbookDetailState>,
          int
        > {
  WordbookDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'wordbookDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WordbookDetailViewModelProvider call(int wordbookId) =>
      WordbookDetailViewModelProvider._(argument: wordbookId, from: this);

  @override
  String toString() => r'wordbookDetailViewModelProvider';
}

abstract class _$WordbookDetailViewModel
    extends $AsyncNotifier<WordbookDetailState> {
  late final _$args = ref.$arg as int;
  int get wordbookId => _$args;

  FutureOr<WordbookDetailState> build(int wordbookId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<WordbookDetailState>, WordbookDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WordbookDetailState>, WordbookDetailState>,
              AsyncValue<WordbookDetailState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
