import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/features/gemma/di.dart';
import 'package:translation_poc_app/features/gemma/domain/entities/gemma_status.dart';
import 'package:translation_poc_app/features/gemma/domain/repositories/gemma_repository.dart';
import 'package:translation_poc_app/features/gemma/presentation/view_models/gemma_view_model.dart';
import 'package:translation_poc_app/features/settings/di.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:translation_poc_app/features/settings/presentation/view_models/engine_view_model.dart';

class _MockGemma extends Mock implements GemmaRepository {}

class _MockSettings extends Mock implements SettingsRepository {}

void main() {
  late _MockGemma gemma;
  late _MockSettings settings;
  late ProviderContainer container;

  const ram = GemmaStatus(deviceRamMb: 8000, minRamMb: 3500);

  setUpAll(() => registerFallbackValue(EngineType.mlKit));

  setUp(() {
    gemma = _MockGemma();
    settings = _MockSettings();
    when(() => settings.watch()).thenAnswer((_) => const Stream.empty());
    when(() => settings.setEngine(any())).thenAnswer((_) async {});
    when(() => settings.load()).thenAnswer(
      (_) async => const TranslatorSettings(wifiOnlyModelDownload: true),
    );
    when(() => gemma.status()).thenAnswer((_) async => ram);
    when(() => gemma.startDownload(wifiOnly: any(named: 'wifiOnly')))
        .thenAnswer((_) async {});
    when(() => gemma.deleteModel()).thenAnswer((_) async {});
    when(() => gemma.setToken(any())).thenAnswer((_) async {});
    when(() => gemma.clearToken()).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [
        gemmaRepositoryProvider.overrideWithValue(gemma),
        settingsRepositoryProvider.overrideWithValue(settings),
      ],
    );
    container.listen(gemmaViewModelProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  test('상태는 progress와 메모리 충분 여부를 계산한다', () {
    const status = GemmaStatus(
      state: GemmaModelState.downloading,
      downloadedBytes: 250,
      totalBytes: 1000,
      deviceRamMb: 2000,
      minRamMb: 3500,
    );
    expect(status.progress, 0.25);
    expect(status.ramSufficient, isFalse);
    expect(const GemmaStatus().progress, isNull);
    expect(const GemmaStatus().ramSufficient, isTrue);
  });

  test('받기는 Wi-Fi 전용 설정을 그대로 넘긴다', () async {
    await container.read(gemmaViewModelProvider.future);
    await container.read(gemmaViewModelProvider.notifier).download();
    verify(() => gemma.startDownload(wifiOnly: true)).called(1);
  });

  test('메모리가 모자라면 받기를 시작하지 않는다', () async {
    when(() => gemma.status()).thenAnswer(
      (_) async => const GemmaStatus(deviceRamMb: 2000, minRamMb: 3500),
    );
    container.invalidate(gemmaViewModelProvider);
    await container.read(gemmaViewModelProvider.future);
    await container.read(gemmaViewModelProvider.notifier).download();
    verifyNever(() => gemma.startDownload(wifiOnly: any(named: 'wifiOnly')));
  });

  test('토큰 저장은 공백을 다듬고, 빈 값이면 지운다', () async {
    await container.read(gemmaViewModelProvider.future);
    final vm = container.read(gemmaViewModelProvider.notifier);
    await vm.saveToken('  hf_abc ');
    verify(() => gemma.setToken('hf_abc')).called(1);
    await vm.saveToken('   ');
    verify(() => gemma.clearToken()).called(1);
  });

  test('모델을 지울 때 Gemma가 선택돼 있었으면 ML Kit으로 돌린다', () async {
    when(() => settings.load()).thenAnswer(
      (_) async => const TranslatorSettings(engine: EngineType.gemma),
    );
    await container.read(gemmaViewModelProvider.future);
    await container.read(gemmaViewModelProvider.notifier).delete();
    verify(() => gemma.deleteModel()).called(1);
    verify(() => settings.setEngine(EngineType.mlKit)).called(1);
  });

  group('엔진 선택', () {
    test('모델을 받기 전에는 Gemma를 고를 수 없다', () async {
      container.listen(engineViewModelProvider, (_, _) {});
      await container.read(engineViewModelProvider.future);
      await container
          .read(engineViewModelProvider.notifier)
          .select(EngineType.gemma);
      verifyNever(() => settings.setEngine(any()));
    });

    test('모델이 있으면 연령 확인 · 키 없이도 Gemma를 고를 수 있다', () async {
      when(() => gemma.status()).thenAnswer(
        (_) async => const GemmaStatus(state: GemmaModelState.ready),
      );
      container.listen(engineViewModelProvider, (_, _) {});
      await container.read(engineViewModelProvider.future);
      await container
          .read(engineViewModelProvider.notifier)
          .select(EngineType.gemma);
      verify(() => settings.setEngine(EngineType.gemma)).called(1);
    });
  });
}
