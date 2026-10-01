import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/features/settings/di.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:translation_poc_app/features/settings/presentation/view_models/auto_translate_view_model.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockSettingsRepository();
    when(() => repository.watch()).thenAnswer((_) => const Stream.empty());
    when(() => repository.setAutoTranslate(any())).thenAnswer((_) async {});
    when(() => repository.setAutoCheckIntervalMs(any()))
        .thenAnswer((_) async {});
    when(() => repository.setAutoSettleMs(any())).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  Future<AutoTranslateSettings> ready([
    TranslatorSettings saved = const TranslatorSettings(),
  ]) {
    when(() => repository.load()).thenAnswer((_) async => saved);
    container.listen(autoTranslateViewModelProvider, (_, _) {});
    return container.read(autoTranslateViewModelProvider.future);
  }

  test('기본값은 꺼짐, 간격 2초, 안정 대기 1초', () async {
    final s = await ready();

    expect(s.enabled, isFalse);
    expect(s.checkIntervalMs, 2000);
    expect(s.settleMs, 1000);
  });

  test('저장된 값을 보여 준다', () async {
    final s = await ready(
      const TranslatorSettings(
        autoTranslate: true,
        autoCheckIntervalMs: 5000,
        autoSettleMs: 500,
      ),
    );

    expect(s.enabled, isTrue);
    expect(s.checkIntervalMs, 5000);
    expect(s.settleMs, 500);
  });

  test('켜고 끄기는 저장소로 전달된다', () async {
    await ready();

    await container
        .read(autoTranslateViewModelProvider.notifier)
        .setEnabled(true);

    verify(() => repository.setAutoTranslate(true)).called(1);
  });

  test('선택지 밖의 간격은 가장 가까운 선택지로 맞춰 저장한다', () async {
    await ready();
    final viewModel = container.read(autoTranslateViewModelProvider.notifier);

    await viewModel.setCheckInterval(2400);
    await viewModel.setSettle(10000);

    verify(() => repository.setAutoCheckIntervalMs(2000)).called(1);
    verify(() => repository.setAutoSettleMs(2000)).called(1);
  });

  test('nearestChoice는 가까운 값을 고르고 같은 거리면 앞쪽을 고른다', () {
    expect(nearestChoice(autoCheckIntervalChoicesMs, 1400), 1000);
    expect(nearestChoice(autoCheckIntervalChoicesMs, 4000), 3000);
    expect(nearestChoice(autoSettleChoicesMs, 1250), 1000);
  });
}
