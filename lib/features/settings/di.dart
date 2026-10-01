import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/bridge/bridge_providers.dart';
import 'data/datasources/settings_native_data_source.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/settings_usecases.dart';

part 'di.g.dart';

// 설정 기능의 의존성 연결 (D-018). 테스트는 settingsRepositoryProvider를 바꿔 끼운다.

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) => SettingsRepositoryImpl(
  SettingsNativeDataSource(
    ref.watch(settingsHostApiProvider),
    ref.watch(translatorEventBusProvider).stream,
  ),
);

@riverpod
GetSettings getSettings(Ref ref) =>
    GetSettings(ref.watch(settingsRepositoryProvider));

@riverpod
WatchSettings watchSettings(Ref ref) =>
    WatchSettings(ref.watch(settingsRepositoryProvider));

@riverpod
ChangeTargetLanguage changeTargetLanguage(Ref ref) =>
    ChangeTargetLanguage(ref.watch(settingsRepositoryProvider));

@riverpod
ChangeEngine changeEngine(Ref ref) =>
    ChangeEngine(ref.watch(settingsRepositoryProvider));

@riverpod
ChangeCaptureMode changeCaptureMode(Ref ref) =>
    ChangeCaptureMode(ref.watch(settingsRepositoryProvider));

@riverpod
ChangeDisplayMode changeDisplayMode(Ref ref) =>
    ChangeDisplayMode(ref.watch(settingsRepositoryProvider));

@riverpod
ChangeQuickLanguages changeQuickLanguages(Ref ref) =>
    ChangeQuickLanguages(ref.watch(settingsRepositoryProvider));

@riverpod
ChangeAutoTranslate changeAutoTranslate(Ref ref) =>
    ChangeAutoTranslate(ref.watch(settingsRepositoryProvider));

@riverpod
ChangeAutoShowDelay changeAutoShowDelay(Ref ref) =>
    ChangeAutoShowDelay(ref.watch(settingsRepositoryProvider));

@riverpod
ChangeHideAfterInteraction changeHideAfterInteraction(Ref ref) =>
    ChangeHideAfterInteraction(ref.watch(settingsRepositoryProvider));

@riverpod
CompleteOnboarding completeOnboarding(Ref ref) =>
    CompleteOnboarding(ref.watch(settingsRepositoryProvider));
