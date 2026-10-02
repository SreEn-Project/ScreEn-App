import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/features/settings/di.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:translation_poc_app/features/settings/presentation/view_models/capture_settings_view_model.dart';
import 'package:translation_poc_app/features/settings/presentation/view_models/display_settings_view_model.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(CaptureMode.fullScreen);
    registerFallbackValue(DisplayMode.list);
  });

  setUp(() {
    repository = _MockSettingsRepository();
    when(() => repository.watch()).thenAnswer((_) => const Stream.empty());
    when(() => repository.load()).thenAnswer(
      (_) async => const TranslatorSettings(
        captureMode: CaptureMode.fixedRegion,
        displayMode: DisplayMode.overlay,
        buttonSizeDp: 60,
        buttonOpacityPercent: 70,
        hasFixedRegion: true,
      ),
    );
    when(() => repository.setCaptureMode(any())).thenAnswer((_) async {});
    when(() => repository.setDisplayMode(any())).thenAnswer((_) async {});
    when(() => repository.setButtonSizeDp(any())).thenAnswer((_) async {});
    when(() => repository.setButtonOpacityPercent(any()))
        .thenAnswer((_) async {});
    when(() => repository.resetFixedRegion()).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  test('캡처 설정: 저장된 모드와 고정 영역 유무를 보여 주고 바꾼다', () async {
    container.listen(captureSettingsViewModelProvider, (_, _) {});
    final settings = await container.read(
      captureSettingsViewModelProvider.future,
    );
    expect(settings.mode, CaptureMode.fixedRegion);
    expect(settings.hasFixedRegion, isTrue);

    final viewModel = container.read(captureSettingsViewModelProvider.notifier);
    await viewModel.setMode(CaptureMode.dragRegion);
    await viewModel.resetFixedRegion();
    verify(() => repository.setCaptureMode(CaptureMode.dragRegion)).called(1);
    verify(() => repository.resetFixedRegion()).called(1);
  });

  test('표시 설정: 저장된 값을 보여 주고 바꾼다', () async {
    container.listen(displaySettingsViewModelProvider, (_, _) {});
    final settings = await container.read(
      displaySettingsViewModelProvider.future,
    );
    expect(settings.mode, DisplayMode.overlay);
    expect(settings.buttonSizeDp, 60);
    expect(settings.buttonOpacityPercent, 70);

    final viewModel = container.read(displaySettingsViewModelProvider.notifier);
    await viewModel.setMode(DisplayMode.paragraph);
    verify(() => repository.setDisplayMode(DisplayMode.paragraph)).called(1);
  });

  test('버튼 크기 · 투명도는 범위 안 단위값으로 맞춰 저장한다', () async {
    final viewModel = container.read(displaySettingsViewModelProvider.notifier);

    await viewModel.setButtonSize(100);
    await viewModel.setButtonSize(53);
    await viewModel.setButtonOpacity(5);
    await viewModel.setButtonOpacity(74);

    verify(() => repository.setButtonSizeDp(maxButtonSizeDp)).called(1);
    verify(() => repository.setButtonSizeDp(52)).called(1);
    verify(() => repository.setButtonOpacityPercent(minButtonOpacityPercent))
        .called(1);
    verify(() => repository.setButtonOpacityPercent(70)).called(1);
  });
}
