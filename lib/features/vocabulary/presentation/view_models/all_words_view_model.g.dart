// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_words_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AllWordsViewModel)
final allWordsViewModelProvider = AllWordsViewModelProvider._();

final class AllWordsViewModelProvider
    extends $AsyncNotifierProvider<AllWordsViewModel, AllWordsState> {
  AllWordsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allWordsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allWordsViewModelHash();

  @$internal
  @override
  AllWordsViewModel create() => AllWordsViewModel();
}

String _$allWordsViewModelHash() => r'd31170db0fac7efe5b4e7be8d8256e1b33550e7a';

abstract class _$AllWordsViewModel extends $AsyncNotifier<AllWordsState> {
  FutureOr<AllWordsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AllWordsState>, AllWordsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AllWordsState>, AllWordsState>,
              AsyncValue<AllWordsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
