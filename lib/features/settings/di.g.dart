// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'f03c71b2908406000a06d82382b6ca2cd990c261';

@ProviderFor(getSettings)
final getSettingsProvider = GetSettingsProvider._();

final class GetSettingsProvider
    extends $FunctionalProvider<GetSettings, GetSettings, GetSettings>
    with $Provider<GetSettings> {
  GetSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSettingsHash();

  @$internal
  @override
  $ProviderElement<GetSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetSettings create(Ref ref) {
    return getSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSettings>(value),
    );
  }
}

String _$getSettingsHash() => r'd4d992c7e1e4fe9f455f5521a11659e65b1049d0';

@ProviderFor(watchSettings)
final watchSettingsProvider = WatchSettingsProvider._();

final class WatchSettingsProvider
    extends $FunctionalProvider<WatchSettings, WatchSettings, WatchSettings>
    with $Provider<WatchSettings> {
  WatchSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchSettingsHash();

  @$internal
  @override
  $ProviderElement<WatchSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WatchSettings create(Ref ref) {
    return watchSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchSettings>(value),
    );
  }
}

String _$watchSettingsHash() => r'3287ecd7fd32b46e2552b2321a960e19a6e055d5';

@ProviderFor(changeTargetLanguage)
final changeTargetLanguageProvider = ChangeTargetLanguageProvider._();

final class ChangeTargetLanguageProvider
    extends
        $FunctionalProvider<
          ChangeTargetLanguage,
          ChangeTargetLanguage,
          ChangeTargetLanguage
        >
    with $Provider<ChangeTargetLanguage> {
  ChangeTargetLanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeTargetLanguageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeTargetLanguageHash();

  @$internal
  @override
  $ProviderElement<ChangeTargetLanguage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangeTargetLanguage create(Ref ref) {
    return changeTargetLanguage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeTargetLanguage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeTargetLanguage>(value),
    );
  }
}

String _$changeTargetLanguageHash() =>
    r'650c27fe23e25662f66d5ba205ec7f869eb60517';

@ProviderFor(changeEngine)
final changeEngineProvider = ChangeEngineProvider._();

final class ChangeEngineProvider
    extends $FunctionalProvider<ChangeEngine, ChangeEngine, ChangeEngine>
    with $Provider<ChangeEngine> {
  ChangeEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeEngineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeEngineHash();

  @$internal
  @override
  $ProviderElement<ChangeEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChangeEngine create(Ref ref) {
    return changeEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeEngine>(value),
    );
  }
}

String _$changeEngineHash() => r'89c65625f44008c0b622a7201fbe13bca7e54937';

@ProviderFor(changeCaptureMode)
final changeCaptureModeProvider = ChangeCaptureModeProvider._();

final class ChangeCaptureModeProvider
    extends
        $FunctionalProvider<
          ChangeCaptureMode,
          ChangeCaptureMode,
          ChangeCaptureMode
        >
    with $Provider<ChangeCaptureMode> {
  ChangeCaptureModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeCaptureModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeCaptureModeHash();

  @$internal
  @override
  $ProviderElement<ChangeCaptureMode> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangeCaptureMode create(Ref ref) {
    return changeCaptureMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeCaptureMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeCaptureMode>(value),
    );
  }
}

String _$changeCaptureModeHash() => r'17f2063b1786fc79f09c86578fba69ad10f1fa05';

@ProviderFor(changeDisplayMode)
final changeDisplayModeProvider = ChangeDisplayModeProvider._();

final class ChangeDisplayModeProvider
    extends
        $FunctionalProvider<
          ChangeDisplayMode,
          ChangeDisplayMode,
          ChangeDisplayMode
        >
    with $Provider<ChangeDisplayMode> {
  ChangeDisplayModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeDisplayModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeDisplayModeHash();

  @$internal
  @override
  $ProviderElement<ChangeDisplayMode> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangeDisplayMode create(Ref ref) {
    return changeDisplayMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeDisplayMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeDisplayMode>(value),
    );
  }
}

String _$changeDisplayModeHash() => r'7c08b997249b45a869d90a0e85d1ef0dc02bb047';

@ProviderFor(changeQuickLanguages)
final changeQuickLanguagesProvider = ChangeQuickLanguagesProvider._();

final class ChangeQuickLanguagesProvider
    extends
        $FunctionalProvider<
          ChangeQuickLanguages,
          ChangeQuickLanguages,
          ChangeQuickLanguages
        >
    with $Provider<ChangeQuickLanguages> {
  ChangeQuickLanguagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeQuickLanguagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeQuickLanguagesHash();

  @$internal
  @override
  $ProviderElement<ChangeQuickLanguages> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangeQuickLanguages create(Ref ref) {
    return changeQuickLanguages(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeQuickLanguages value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeQuickLanguages>(value),
    );
  }
}

String _$changeQuickLanguagesHash() =>
    r'a4e5afa9e6c08f9a671e9148cb3134d6a50deb5f';

@ProviderFor(changeAutoTranslate)
final changeAutoTranslateProvider = ChangeAutoTranslateProvider._();

final class ChangeAutoTranslateProvider
    extends
        $FunctionalProvider<
          ChangeAutoTranslate,
          ChangeAutoTranslate,
          ChangeAutoTranslate
        >
    with $Provider<ChangeAutoTranslate> {
  ChangeAutoTranslateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeAutoTranslateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeAutoTranslateHash();

  @$internal
  @override
  $ProviderElement<ChangeAutoTranslate> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangeAutoTranslate create(Ref ref) {
    return changeAutoTranslate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeAutoTranslate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeAutoTranslate>(value),
    );
  }
}

String _$changeAutoTranslateHash() =>
    r'4de9cc03ef32ef9ed3677ad8f5465829134fe13c';

@ProviderFor(changeAutoShowDelay)
final changeAutoShowDelayProvider = ChangeAutoShowDelayProvider._();

final class ChangeAutoShowDelayProvider
    extends
        $FunctionalProvider<
          ChangeAutoShowDelay,
          ChangeAutoShowDelay,
          ChangeAutoShowDelay
        >
    with $Provider<ChangeAutoShowDelay> {
  ChangeAutoShowDelayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeAutoShowDelayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeAutoShowDelayHash();

  @$internal
  @override
  $ProviderElement<ChangeAutoShowDelay> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangeAutoShowDelay create(Ref ref) {
    return changeAutoShowDelay(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeAutoShowDelay value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeAutoShowDelay>(value),
    );
  }
}

String _$changeAutoShowDelayHash() =>
    r'194fbd87c4a01785b6c51d7b360504d206b47cf5';

@ProviderFor(changeHideAfterInteraction)
final changeHideAfterInteractionProvider =
    ChangeHideAfterInteractionProvider._();

final class ChangeHideAfterInteractionProvider
    extends
        $FunctionalProvider<
          ChangeHideAfterInteraction,
          ChangeHideAfterInteraction,
          ChangeHideAfterInteraction
        >
    with $Provider<ChangeHideAfterInteraction> {
  ChangeHideAfterInteractionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeHideAfterInteractionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeHideAfterInteractionHash();

  @$internal
  @override
  $ProviderElement<ChangeHideAfterInteraction> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangeHideAfterInteraction create(Ref ref) {
    return changeHideAfterInteraction(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeHideAfterInteraction value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeHideAfterInteraction>(value),
    );
  }
}

String _$changeHideAfterInteractionHash() =>
    r'3dc75206567d2be8ac5ea28c83f15df369c83f47';

@ProviderFor(changeWifiOnlyModelDownload)
final changeWifiOnlyModelDownloadProvider =
    ChangeWifiOnlyModelDownloadProvider._();

final class ChangeWifiOnlyModelDownloadProvider
    extends
        $FunctionalProvider<
          ChangeWifiOnlyModelDownload,
          ChangeWifiOnlyModelDownload,
          ChangeWifiOnlyModelDownload
        >
    with $Provider<ChangeWifiOnlyModelDownload> {
  ChangeWifiOnlyModelDownloadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeWifiOnlyModelDownloadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeWifiOnlyModelDownloadHash();

  @$internal
  @override
  $ProviderElement<ChangeWifiOnlyModelDownload> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangeWifiOnlyModelDownload create(Ref ref) {
    return changeWifiOnlyModelDownload(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeWifiOnlyModelDownload value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeWifiOnlyModelDownload>(value),
    );
  }
}

String _$changeWifiOnlyModelDownloadHash() =>
    r'45061ee76189705e10557806ddfe4968d843ca89';

@ProviderFor(changeButtonSize)
final changeButtonSizeProvider = ChangeButtonSizeProvider._();

final class ChangeButtonSizeProvider
    extends
        $FunctionalProvider<
          ChangeButtonSize,
          ChangeButtonSize,
          ChangeButtonSize
        >
    with $Provider<ChangeButtonSize> {
  ChangeButtonSizeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeButtonSizeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeButtonSizeHash();

  @$internal
  @override
  $ProviderElement<ChangeButtonSize> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChangeButtonSize create(Ref ref) {
    return changeButtonSize(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeButtonSize value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeButtonSize>(value),
    );
  }
}

String _$changeButtonSizeHash() => r'f69779f5aaa4ff0c642e75671dde45c0830b130f';

@ProviderFor(changeButtonOpacity)
final changeButtonOpacityProvider = ChangeButtonOpacityProvider._();

final class ChangeButtonOpacityProvider
    extends
        $FunctionalProvider<
          ChangeButtonOpacity,
          ChangeButtonOpacity,
          ChangeButtonOpacity
        >
    with $Provider<ChangeButtonOpacity> {
  ChangeButtonOpacityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeButtonOpacityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeButtonOpacityHash();

  @$internal
  @override
  $ProviderElement<ChangeButtonOpacity> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangeButtonOpacity create(Ref ref) {
    return changeButtonOpacity(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeButtonOpacity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeButtonOpacity>(value),
    );
  }
}

String _$changeButtonOpacityHash() =>
    r'c705b5824b4cd57596331908a92f6fa7e6182b5d';

@ProviderFor(resetFixedRegion)
final resetFixedRegionProvider = ResetFixedRegionProvider._();

final class ResetFixedRegionProvider
    extends
        $FunctionalProvider<
          ResetFixedRegion,
          ResetFixedRegion,
          ResetFixedRegion
        >
    with $Provider<ResetFixedRegion> {
  ResetFixedRegionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetFixedRegionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetFixedRegionHash();

  @$internal
  @override
  $ProviderElement<ResetFixedRegion> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ResetFixedRegion create(Ref ref) {
    return resetFixedRegion(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResetFixedRegion value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResetFixedRegion>(value),
    );
  }
}

String _$resetFixedRegionHash() => r'760edf4187d76541bb648465dd3763e5d5f28992';

@ProviderFor(completeOnboarding)
final completeOnboardingProvider = CompleteOnboardingProvider._();

final class CompleteOnboardingProvider
    extends
        $FunctionalProvider<
          CompleteOnboarding,
          CompleteOnboarding,
          CompleteOnboarding
        >
    with $Provider<CompleteOnboarding> {
  CompleteOnboardingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completeOnboardingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completeOnboardingHash();

  @$internal
  @override
  $ProviderElement<CompleteOnboarding> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CompleteOnboarding create(Ref ref) {
    return completeOnboarding(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompleteOnboarding value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompleteOnboarding>(value),
    );
  }
}

String _$completeOnboardingHash() =>
    r'7a8d915553a3367122f68b7538ecac8b8f77e58d';

@ProviderFor(getApiKey)
final getApiKeyProvider = GetApiKeyProvider._();

final class GetApiKeyProvider
    extends $FunctionalProvider<GetApiKey, GetApiKey, GetApiKey>
    with $Provider<GetApiKey> {
  GetApiKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getApiKeyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getApiKeyHash();

  @$internal
  @override
  $ProviderElement<GetApiKey> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetApiKey create(Ref ref) {
    return getApiKey(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetApiKey value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetApiKey>(value),
    );
  }
}

String _$getApiKeyHash() => r'44271899c1303a075405ec754a451eb409f46c31';

@ProviderFor(saveApiKey)
final saveApiKeyProvider = SaveApiKeyProvider._();

final class SaveApiKeyProvider
    extends $FunctionalProvider<SaveApiKey, SaveApiKey, SaveApiKey>
    with $Provider<SaveApiKey> {
  SaveApiKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveApiKeyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveApiKeyHash();

  @$internal
  @override
  $ProviderElement<SaveApiKey> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SaveApiKey create(Ref ref) {
    return saveApiKey(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveApiKey value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveApiKey>(value),
    );
  }
}

String _$saveApiKeyHash() => r'340e44a8a2f98d01e9eb440cc302980eb1f7a64a';

@ProviderFor(clearApiKey)
final clearApiKeyProvider = ClearApiKeyProvider._();

final class ClearApiKeyProvider
    extends $FunctionalProvider<ClearApiKey, ClearApiKey, ClearApiKey>
    with $Provider<ClearApiKey> {
  ClearApiKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearApiKeyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearApiKeyHash();

  @$internal
  @override
  $ProviderElement<ClearApiKey> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ClearApiKey create(Ref ref) {
    return clearApiKey(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClearApiKey value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClearApiKey>(value),
    );
  }
}

String _$clearApiKeyHash() => r'43276c5c97ef3c2839c5ce5c440db5c4a1723cef';

@ProviderFor(testApiKey)
final testApiKeyProvider = TestApiKeyProvider._();

final class TestApiKeyProvider
    extends $FunctionalProvider<TestApiKey, TestApiKey, TestApiKey>
    with $Provider<TestApiKey> {
  TestApiKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'testApiKeyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$testApiKeyHash();

  @$internal
  @override
  $ProviderElement<TestApiKey> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TestApiKey create(Ref ref) {
    return testApiKey(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TestApiKey value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TestApiKey>(value),
    );
  }
}

String _$testApiKeyHash() => r'a1a176b88b94790b83824267ed2566ce95ef6b7f';
