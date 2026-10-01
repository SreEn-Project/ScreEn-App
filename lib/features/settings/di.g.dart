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

@ProviderFor(changeAutoCheckInterval)
final changeAutoCheckIntervalProvider = ChangeAutoCheckIntervalProvider._();

final class ChangeAutoCheckIntervalProvider
    extends
        $FunctionalProvider<
          ChangeAutoCheckInterval,
          ChangeAutoCheckInterval,
          ChangeAutoCheckInterval
        >
    with $Provider<ChangeAutoCheckInterval> {
  ChangeAutoCheckIntervalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeAutoCheckIntervalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeAutoCheckIntervalHash();

  @$internal
  @override
  $ProviderElement<ChangeAutoCheckInterval> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangeAutoCheckInterval create(Ref ref) {
    return changeAutoCheckInterval(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeAutoCheckInterval value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeAutoCheckInterval>(value),
    );
  }
}

String _$changeAutoCheckIntervalHash() =>
    r'4b37af5cdab8637723222dfdc3324f4b8719f5cd';

@ProviderFor(changeAutoSettle)
final changeAutoSettleProvider = ChangeAutoSettleProvider._();

final class ChangeAutoSettleProvider
    extends
        $FunctionalProvider<
          ChangeAutoSettle,
          ChangeAutoSettle,
          ChangeAutoSettle
        >
    with $Provider<ChangeAutoSettle> {
  ChangeAutoSettleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeAutoSettleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeAutoSettleHash();

  @$internal
  @override
  $ProviderElement<ChangeAutoSettle> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChangeAutoSettle create(Ref ref) {
    return changeAutoSettle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeAutoSettle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeAutoSettle>(value),
    );
  }
}

String _$changeAutoSettleHash() => r'0d271e76ad8aa7626f071e2dca7cd73ed88e662e';

@ProviderFor(changeAutoHide)
final changeAutoHideProvider = ChangeAutoHideProvider._();

final class ChangeAutoHideProvider
    extends $FunctionalProvider<ChangeAutoHide, ChangeAutoHide, ChangeAutoHide>
    with $Provider<ChangeAutoHide> {
  ChangeAutoHideProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeAutoHideProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeAutoHideHash();

  @$internal
  @override
  $ProviderElement<ChangeAutoHide> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChangeAutoHide create(Ref ref) {
    return changeAutoHide(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeAutoHide value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeAutoHide>(value),
    );
  }
}

String _$changeAutoHideHash() => r'26bc7bd4a3bb912dcb4636013855c63d364e62bd';

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
