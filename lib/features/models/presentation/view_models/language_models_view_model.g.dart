// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_models_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LanguageModelsViewModel)
final languageModelsViewModelProvider = LanguageModelsViewModelProvider._();

final class LanguageModelsViewModelProvider
    extends
        $AsyncNotifierProvider<LanguageModelsViewModel, LanguageModelsState> {
  LanguageModelsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languageModelsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languageModelsViewModelHash();

  @$internal
  @override
  LanguageModelsViewModel create() => LanguageModelsViewModel();
}

String _$languageModelsViewModelHash() =>
    r'851d7961d25ef857cbc74c30857e11931661471d';

abstract class _$LanguageModelsViewModel
    extends $AsyncNotifier<LanguageModelsState> {
  FutureOr<LanguageModelsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<LanguageModelsState>, LanguageModelsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LanguageModelsState>, LanguageModelsState>,
              AsyncValue<LanguageModelsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
