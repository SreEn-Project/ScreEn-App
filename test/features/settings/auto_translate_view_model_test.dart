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
    when(() => repository.setAutoHideMs(any())).thenAnswer((_) async {});
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
    expect(s.speed, AutoSpeed.normal);
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
    expect(s.speed, AutoSpeed.batterySaver);
  });

  test('켜고 끄기는 저장소로 전달된다', () async {
    await ready();

    await container
        .read(autoTranslateViewModelProvider.notifier)
        .setEnabled(true);

    verify(() => repository.setAutoTranslate(true)).called(1);
  });

  test('속도 한 단계가 확인 간격과 대기 시간을 함께 저장한다 · 숨김은 가장 가까운 선택지로', () async {
    await ready();
    final viewModel = container.read(autoTranslateViewModelProvider.notifier);

    await viewModel.setSpeed(AutoSpeed.saver);
    await viewModel.setHide(-5);
    await viewModel.setHide(700);

    verify(() => repository.setAutoCheckIntervalMs(2000)).called(1);
    verify(() => repository.setAutoSettleMs(1000)).called(1);
    verify(() => repository.setAutoHideMs(autoHideNever)).called(1);
    verify(() => repository.setAutoHideMs(500)).called(1);
  });

  test('저장된 확인 간격은 가장 가까운 속도 단계로 보인다', () {
    expect(AutoSpeed.fromCheckInterval(500), AutoSpeed.fast);
    expect(AutoSpeed.fromCheckInterval(1400), AutoSpeed.normal);
    expect(AutoSpeed.fromCheckInterval(3000), AutoSpeed.saver);
    expect(AutoSpeed.fromCheckInterval(4000), AutoSpeed.batterySaver);
  });

  test('nearestChoice는 가까운 값을 고르고 같은 거리면 앞쪽을 고른다', () {
    expect(nearestChoice(autoHideChoicesMs.sublist(0, 4), 700), 500);
    expect(nearestChoice(autoHideChoicesMs.sublist(0, 4), 750), 500);
  });
}
