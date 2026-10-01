import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/router.dart';
import '../../../language/domain/entities/supported_language.dart';
import '../../domain/entities/translator_settings.dart';
import '../view_models/auto_translate_view_model.dart';
import '../view_models/hide_after_interaction_view_model.dart';
import '../view_models/quick_languages_view_model.dart';
import '../../../../core/l10n/labels.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';

/// 설정 탭 (S-04, FL-06). FL-07 표시, FL-08 캡처 모드 항목도 여기 있다.
/// 대상 언어 · 언어 모델은 "언어" 탭으로 옮겼다 (D-016).
/// UI 퍼블리싱 단계: 값은 화면 안에서만 바뀐다. 저장은 SettingsRepository + ViewModel로 연결한다.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  EngineType _engine = EngineType.mlKit;
  CaptureMode _captureMode = CaptureMode.fullScreen;
  DisplayMode _displayMode = DisplayMode.list;
  double _buttonSize = 56;
  double _buttonOpacity = 0.9;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppPage(
      title: l10n.settingsTitle,
      withBottomNav: true,
      children: [
        AppSection(
          title: l10n.settingsSectionEngine,
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (final engine in EngineType.values) ...[
                  _EngineTile(
                    engine: engine,
                    selected: engine == _engine,
                    // AI 엔진은 3단계. 조건(키 · 로그인 · 연령)이 없으면 비활성.
                    disabledReason: switch (engine) {
                      EngineType.mlKit => null,
                      EngineType.gemini => l10n.engineNeedsKey,
                      EngineType.firebaseAi => l10n.engineNeedsLogin,
                    },
                    onTap: () => setState(() => _engine = engine),
                  ),
                  const AppDivider(),
                ],
                AppListTile(
                  icon: Symbols.tune_rounded,
                  title: l10n.settingsAiSetup,
                  subtitle: l10n.settingsAiSetupDetail,
                  enabled: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        AppSection(
          title: l10n.settingsSectionCapture,
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Labeled(
                  label: l10n.settingsDefaultCaptureMode,
                  child: AppSegmented<CaptureMode>(
                    values: CaptureMode.values,
                    selected: _captureMode,
                    label: l10n.captureModeName,
                    onChanged: (mode) => setState(() => _captureMode = mode),
                  ),
                ),
                const AppDivider(),
                AppListTile(
                  icon: Symbols.restart_alt_rounded,
                  title: l10n.settingsResetFixedRegion,
                  enabled: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        AppSection(
          title: l10n.settingsSectionDisplay,
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Labeled(
                  label: l10n.settingsDisplayMode,
                  child: AppSegmented<DisplayMode>(
                    values: DisplayMode.values,
                    selected: _displayMode,
                    label: l10n.displayModeName,
                    onChanged: (mode) => setState(() => _displayMode = mode),
                  ),
                ),
                const AppDivider(),
                const _HideAfterInteraction(),
                const AppDivider(),
                _Labeled(
                  label: l10n.settingsButtonSize,
                  value: '${_buttonSize.round()}dp',
                  child: AppSlider(
                    value: _buttonSize,
                    min: 40,
                    max: 72,
                    divisions: 8,
                    onChanged: (v) => setState(() => _buttonSize = v),
                  ),
                ),
                const AppDivider(),
                _Labeled(
                  label: l10n.settingsButtonOpacity,
                  value: '${(_buttonOpacity * 100).round()}%',
                  child: AppSlider(
                    value: _buttonOpacity,
                    min: 0.3,
                    max: 1,
                    divisions: 7,
                    onChanged: (v) => setState(() => _buttonOpacity = v),
                  ),
                ),
              ],
            ),
          ),
        ),
        const _QuickLanguagesSection(),
        const _AutoTranslateSection(),
        AppSection(
          title: l10n.settingsSectionEtc,
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: AppListTile(
              icon: Symbols.info_rounded,
              title: l10n.settingsAbout,
              onTap: () => context.push(AppRoutes.about),
            ),
          ),
        ),
      ],
    );
  }
}

class _EngineTile extends StatelessWidget {
  const _EngineTile({
    required this.engine,
    required this.selected,
    required this.disabledReason,
    required this.onTap,
  });

  final EngineType engine;
  final bool selected;
  final String? disabledReason;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return AppListTile(
      icon: engineIcon(engine),
      title: l10n.engineName(engine),
      subtitle: disabledReason ?? l10n.engineDetail(engine),
      enabled: disabledReason == null,
      onTap: onTap,
      trailing: _RadioMark(selected: selected, color: colors.primary),
    );
  }
}

/// 원형 선택 표시 (Radio 대신).
class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? color : outline,
          width: selected ? 6 : 2,
        ),
      ),
    );
  }
}

/// 제목(+ 오른쪽 값) 아래에 조절 요소를 두는 항목.
class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child, this.value});

  final String label;
  final String? value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
              if (value != null)
                Text(
                  value!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// 빠른 언어 (FL-04): 플로팅 버튼 "빠른 언어" 버블에 나올 언어. 눌러서 편집 화면으로.
class _QuickLanguagesSection extends ConsumerWidget {
  const _QuickLanguagesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uiLanguage = Localizations.localeOf(context).languageCode;
    final codes =
        ref.watch(quickLanguagesViewModelProvider).value ??
        defaultQuickLanguages;

    return AppSection(
      title: l10n.settingsQuickLanguages,
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AppListTile(
          icon: Symbols.translate_rounded,
          title: l10n.settingsQuickLanguagesDetail,
          subtitle: codes
              .map(
                (code) =>
                    SupportedLanguage.byCode(code).displayName(uiLanguage),
              )
              .join(' · '),
          onTap: () => context.push(AppRoutes.quickLanguages),
        ),
      ),
    );
  }
}

/// 사용자가 화면을 조작한 뒤 이전 번역(덮어쓰기)을 숨기기까지의 시간 (#35). 자동 번역을 켜지 않아도 적용된다.
class _HideAfterInteraction extends ConsumerWidget {
  const _HideAfterInteraction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hideMs =
        ref.watch(hideAfterInteractionViewModelProvider).value ??
        defaultHideAfterInteractionMs;
    final viewModel = ref.read(hideAfterInteractionViewModelProvider.notifier);
    String label(int ms) => ms == hideNever
        ? l10n.settingsAutoNever
        : ms == 0
        ? l10n.settingsAutoInstant
        : l10n.secondsShort(
            (ms / 1000).toStringAsFixed(ms % 1000 == 0 ? 0 : 1),
          );

    return _Labeled(
      label: l10n.settingsHideAfterInteraction,
      value: label(hideMs),
      child: AppSegmented<int>(
        values: hideAfterInteractionChoicesMs,
        selected: hideMs < 0
            ? hideNever
            : nearestChoice(
                hideAfterInteractionChoicesMs.sublist(0, 4),
                hideMs,
              ),
        label: label,
        onChanged: viewModel.setHide,
      ),
    );
  }
}

/// 자동 번역 (#23): 켜기 · 새 번역을 보여 줄 시점 (#35). 값은 네이티브 설정에 바로 저장된다.
class _AutoTranslateSection extends ConsumerWidget {
  const _AutoTranslateSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings =
        ref.watch(autoTranslateViewModelProvider).value ??
        const AutoTranslateSettings();
    final viewModel = ref.read(autoTranslateViewModelProvider.notifier);
    String delayLabel(int ms) => ms == 0
        ? l10n.settingsAutoInstant
        : l10n.secondsShort(
            (ms / 1000).toStringAsFixed(ms % 1000 == 0 ? 0 : 1),
          );

    return AppSection(
      title: l10n.settingsSectionAuto,
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppListTile(
              icon: Symbols.autorenew_rounded,
              title: l10n.settingsAutoTranslate,
              subtitle: l10n.settingsAutoTranslateDetail,
              onTap: () => viewModel.setEnabled(!settings.enabled),
              trailing: AppSwitch(
                value: settings.enabled,
                onChanged: viewModel.setEnabled,
              ),
            ),
            if (settings.enabled) ...[
              const AppDivider(),
              _Labeled(
                label: l10n.settingsAutoShowDelay,
                value: delayLabel(settings.showDelayMs),
                child: AppSegmented<int>(
                  values: autoShowDelayChoicesMs,
                  selected: nearestChoice(
                    autoShowDelayChoicesMs,
                    settings.showDelayMs,
                  ),
                  label: delayLabel,
                  onChanged: viewModel.setShowDelay,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
