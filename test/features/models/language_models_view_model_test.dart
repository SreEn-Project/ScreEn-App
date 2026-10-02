import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/features/models/di.dart';
import 'package:translation_poc_app/features/models/domain/repositories/model_repository.dart';
import 'package:translation_poc_app/features/models/presentation/view_models/language_models_view_model.dart';
import 'package:translation_poc_app/features/settings/di.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/settings/domain/repositories/settings_repository.dart';

class _MockModelRepository extends Mock implements ModelRepository {}

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockModelRepository models;
  late _MockSettingsRepository settings;
  late ProviderContainer container;

  setUp(() {
    models = _MockModelRepository();
    settings = _MockSettingsRepository();
    when(() => models.downloaded()).thenAnswer((_) async => {'ko', 'en'});
    when(() => models.delete(any())).thenAnswer((_) async {});
    when(() => settings.load()).thenAnswer(
      (_) async => const TranslatorSettings(wifiOnlyModelDownload: false),
    );
    container = ProviderContainer(
      overrides: [
        modelRepositoryProvider.overrideWithValue(models),
        settingsRepositoryProvider.overrideWithValue(settings),
      ],
    );
    container.listen(languageModelsViewModelProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  Future<LanguageModelsState> ready() =>
      container.read(languageModelsViewModelProvider.future);

  LanguageModelsState now() =>
      container.read(languageModelsViewModelProvider).requireValue;

  LanguageModelsViewModel viewModel() =>
      container.read(languageModelsViewModelProvider.notifier);

  test('처음에는 기기에 받아 둔 모델을 보여 준다', () async {
    expect((await ready()).installed, {'ko', 'en'});
  });

  test('받기: 받는 중으로 바뀌었다가 끝나면 받은 목록에 들어간다', () async {
    final done = Completer<void>();
    when(() => models.download('ja', wifiOnly: any(named: 'wifiOnly')))
        .thenAnswer((_) => done.future);
    await ready();

    final future = viewModel().download('ja');
    await pumpEventQueue();
    expect(now().downloading, {'ja'});

    done.complete();
    await future;
    expect(now().downloading, isEmpty);
    expect(now().installed, {'ko', 'en', 'ja'});
  });

  test('받기는 설정의 Wi-Fi 전용 값을 따른다', () async {
    when(() => models.download(any(), wifiOnly: any(named: 'wifiOnly')))
        .thenAnswer((_) async {});
    await ready();

    await viewModel().download('ja');

    verify(() => models.download('ja', wifiOnly: false)).called(1);
  });

  test('받기가 실패하면 실패로 표시하고 받은 목록에는 넣지 않는다', () async {
    when(() => models.download(any(), wifiOnly: any(named: 'wifiOnly')))
        .thenThrow(Exception('network'));
    await ready();

    await viewModel().download('ja');

    expect(now().failed, {'ja'});
    expect(now().downloading, isEmpty);
    expect(now().installed, {'ko', 'en'});
  });

  test('이미 받은 언어나 받는 중인 언어는 다시 받지 않는다', () async {
    final done = Completer<void>();
    when(() => models.download(any(), wifiOnly: any(named: 'wifiOnly')))
        .thenAnswer((_) => done.future);
    await ready();

    await viewModel().download('ko');
    final first = viewModel().download('ja');
    await pumpEventQueue();
    await viewModel().download('ja');
    done.complete();
    await first;

    verify(() => models.download('ja', wifiOnly: false)).called(1);
    verifyNever(() => models.download('ko', wifiOnly: any(named: 'wifiOnly')));
  });

  test('삭제하면 받은 목록에서 빠진다', () async {
    await ready();

    await viewModel().delete('en');

    verify(() => models.delete('en')).called(1);
    expect(now().installed, {'ko'});
  });
}
