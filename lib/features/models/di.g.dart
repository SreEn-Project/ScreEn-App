// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(modelRepository)
final modelRepositoryProvider = ModelRepositoryProvider._();

final class ModelRepositoryProvider
    extends
        $FunctionalProvider<ModelRepository, ModelRepository, ModelRepository>
    with $Provider<ModelRepository> {
  ModelRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modelRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modelRepositoryHash();

  @$internal
  @override
  $ProviderElement<ModelRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ModelRepository create(Ref ref) {
    return modelRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModelRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModelRepository>(value),
    );
  }
}

String _$modelRepositoryHash() => r'22cd007e1deae8da1505ebc8982354e64f100184';

@ProviderFor(getDownloadedModels)
final getDownloadedModelsProvider = GetDownloadedModelsProvider._();

final class GetDownloadedModelsProvider
    extends
        $FunctionalProvider<
          GetDownloadedModels,
          GetDownloadedModels,
          GetDownloadedModels
        >
    with $Provider<GetDownloadedModels> {
  GetDownloadedModelsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getDownloadedModelsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getDownloadedModelsHash();

  @$internal
  @override
  $ProviderElement<GetDownloadedModels> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetDownloadedModels create(Ref ref) {
    return getDownloadedModels(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetDownloadedModels value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetDownloadedModels>(value),
    );
  }
}

String _$getDownloadedModelsHash() =>
    r'3da53deb58f081018aab8db7aa23fa9634c58f6a';

@ProviderFor(downloadModel)
final downloadModelProvider = DownloadModelProvider._();

final class DownloadModelProvider
    extends $FunctionalProvider<DownloadModel, DownloadModel, DownloadModel>
    with $Provider<DownloadModel> {
  DownloadModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadModelHash();

  @$internal
  @override
  $ProviderElement<DownloadModel> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DownloadModel create(Ref ref) {
    return downloadModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DownloadModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DownloadModel>(value),
    );
  }
}

String _$downloadModelHash() => r'65397451ae7b58316ea2188dc0556a38fc893bf5';

@ProviderFor(deleteModel)
final deleteModelProvider = DeleteModelProvider._();

final class DeleteModelProvider
    extends $FunctionalProvider<DeleteModel, DeleteModel, DeleteModel>
    with $Provider<DeleteModel> {
  DeleteModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteModelHash();

  @$internal
  @override
  $ProviderElement<DeleteModel> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteModel create(Ref ref) {
    return deleteModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteModel>(value),
    );
  }
}

String _$deleteModelHash() => r'fc2b97dd747d19523c6dc376914bc204466625b7';
