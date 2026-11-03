// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gemmaRepository)
final gemmaRepositoryProvider = GemmaRepositoryProvider._();

final class GemmaRepositoryProvider
    extends
        $FunctionalProvider<GemmaRepository, GemmaRepository, GemmaRepository>
    with $Provider<GemmaRepository> {
  GemmaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemmaRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemmaRepositoryHash();

  @$internal
  @override
  $ProviderElement<GemmaRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GemmaRepository create(Ref ref) {
    return gemmaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GemmaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GemmaRepository>(value),
    );
  }
}

String _$gemmaRepositoryHash() => r'947324812d8d9780b55b208fd17807d6cfab66d6';

@ProviderFor(getGemmaStatus)
final getGemmaStatusProvider = GetGemmaStatusProvider._();

final class GetGemmaStatusProvider
    extends $FunctionalProvider<GetGemmaStatus, GetGemmaStatus, GetGemmaStatus>
    with $Provider<GetGemmaStatus> {
  GetGemmaStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getGemmaStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getGemmaStatusHash();

  @$internal
  @override
  $ProviderElement<GetGemmaStatus> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetGemmaStatus create(Ref ref) {
    return getGemmaStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetGemmaStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetGemmaStatus>(value),
    );
  }
}

String _$getGemmaStatusHash() => r'e2ba3dd2d3df0c084d4d6da06bf26fa7fa58dd75';

@ProviderFor(startGemmaDownload)
final startGemmaDownloadProvider = StartGemmaDownloadProvider._();

final class StartGemmaDownloadProvider
    extends
        $FunctionalProvider<
          StartGemmaDownload,
          StartGemmaDownload,
          StartGemmaDownload
        >
    with $Provider<StartGemmaDownload> {
  StartGemmaDownloadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startGemmaDownloadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startGemmaDownloadHash();

  @$internal
  @override
  $ProviderElement<StartGemmaDownload> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StartGemmaDownload create(Ref ref) {
    return startGemmaDownload(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StartGemmaDownload value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StartGemmaDownload>(value),
    );
  }
}

String _$startGemmaDownloadHash() =>
    r'3dfaef009d6178fa48640510ac90f2a6f819a2cc';

@ProviderFor(cancelGemmaDownload)
final cancelGemmaDownloadProvider = CancelGemmaDownloadProvider._();

final class CancelGemmaDownloadProvider
    extends
        $FunctionalProvider<
          CancelGemmaDownload,
          CancelGemmaDownload,
          CancelGemmaDownload
        >
    with $Provider<CancelGemmaDownload> {
  CancelGemmaDownloadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cancelGemmaDownloadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cancelGemmaDownloadHash();

  @$internal
  @override
  $ProviderElement<CancelGemmaDownload> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CancelGemmaDownload create(Ref ref) {
    return cancelGemmaDownload(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CancelGemmaDownload value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CancelGemmaDownload>(value),
    );
  }
}

String _$cancelGemmaDownloadHash() =>
    r'ed98f081039d2051b8a968c8e6b9552458609056';

@ProviderFor(deleteGemmaModel)
final deleteGemmaModelProvider = DeleteGemmaModelProvider._();

final class DeleteGemmaModelProvider
    extends
        $FunctionalProvider<
          DeleteGemmaModel,
          DeleteGemmaModel,
          DeleteGemmaModel
        >
    with $Provider<DeleteGemmaModel> {
  DeleteGemmaModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteGemmaModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteGemmaModelHash();

  @$internal
  @override
  $ProviderElement<DeleteGemmaModel> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteGemmaModel create(Ref ref) {
    return deleteGemmaModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteGemmaModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteGemmaModel>(value),
    );
  }
}

String _$deleteGemmaModelHash() => r'1bd2f77222c65f2282bd9e699518f79ad23df01a';

@ProviderFor(saveHuggingFaceToken)
final saveHuggingFaceTokenProvider = SaveHuggingFaceTokenProvider._();

final class SaveHuggingFaceTokenProvider
    extends
        $FunctionalProvider<
          SaveHuggingFaceToken,
          SaveHuggingFaceToken,
          SaveHuggingFaceToken
        >
    with $Provider<SaveHuggingFaceToken> {
  SaveHuggingFaceTokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveHuggingFaceTokenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveHuggingFaceTokenHash();

  @$internal
  @override
  $ProviderElement<SaveHuggingFaceToken> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveHuggingFaceToken create(Ref ref) {
    return saveHuggingFaceToken(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveHuggingFaceToken value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveHuggingFaceToken>(value),
    );
  }
}

String _$saveHuggingFaceTokenHash() =>
    r'a29f66278921f201e37aa5c24f0d5896b1a2efeb';
