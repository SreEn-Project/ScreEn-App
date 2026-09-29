import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/bridge/bridge_providers.dart';
import '../../../core/l10n/labels.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../language/domain/supported_language.dart';

/// 설정 (S-04, FL-06). FL-04 대상 언어, FL-07 표시, FL-08 캡처 모드 항목도 여기 있다.
/// UI 퍼블리싱 단계: 값은 화면 안에서만 바뀐다. 저장은 SettingsRepository + ViewModel로 연결한다.
/// 2단계 이후 항목(덮어쓰기, 고정 영역, 버튼 크기 · 투명도)도 화면 확인을 위해 미리 둔다.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _targetLanguage = 'ko';
  EngineType _engine = EngineType.mlKit;
  CaptureMode _captureMode = CaptureMode.fullScreen;
  DisplayMode _displayMode = DisplayMode.list;
  double _buttonSize = 56;
  double _buttonOpacity = 0.9;

  Future<void> _pickLanguage() async {
    final code = await context.push<String>(AppRoutes.targetLanguage);
    if (code != null) setState(() => _targetLanguage = code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.pagePadding,
          8,
          AppTokens.pagePadding,
          32,
        ),
        children: [
          _Group(
            title: l10n.settingsSectionTranslation,
            children: [
              _NavTile(
                icon: Symbols.translate_rounded,
                title: l10n.settingsTargetLanguage,
                value: SupportedLanguage.byCode(_targetLanguage)
                    .displayName(locale),
                onTap: _pickLanguage,
              ),
              _NavTile(
                icon: Symbols.download_rounded,
                title: l10n.settingsLanguageModels,
                subtitle: l10n.settingsLanguageModelsDetail,
                onTap: () => context.push(AppRoutes.languageModels),
              ),
            ],
          ),
          _Group(
            title: l10n.settingsSectionEngine,
            children: [
              for (final engine in EngineType.values)
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
              _NavTile(
                icon: Symbols.tune_rounded,
                title: l10n.settingsAiSetup,
                subtitle: l10n.settingsAiSetupDetail,
                onTap: null,
              ),
            ],
          ),
          _Group(
            title: l10n.settingsSectionCapture,
            children: [
              _ChipsTile<CaptureMode>(
                title: l10n.settingsDefaultCaptureMode,
                values: CaptureMode.values,
                selected: _captureMode,
                label: l10n.captureModeName,
                onSelected: (mode) => setState(() => _captureMode = mode),
              ),
              _NavTile(
                icon: Symbols.restart_alt_rounded,
                title: l10n.settingsResetFixedRegion,
                onTap: null,
              ),
            ],
          ),
          _Group(
            title: l10n.settingsSectionDisplay,
            children: [
              _ChipsTile<DisplayMode>(
                title: l10n.settingsDisplayMode,
                values: DisplayMode.values,
                selected: _displayMode,
                label: l10n.displayModeName,
                onSelected: (mode) => setState(() => _displayMode = mode),
              ),
              _SliderTile(
                title: l10n.settingsButtonSize,
                value: _buttonSize,
                min: 40,
                max: 72,
                divisions: 8,
                valueLabel: '${_buttonSize.round()}dp',
                onChanged: (v) => setState(() => _buttonSize = v),
              ),
              _SliderTile(
                title: l10n.settingsButtonOpacity,
                value: _buttonOpacity,
                min: 0.3,
                max: 1,
                divisions: 7,
                valueLabel: '${(_buttonOpacity * 100).round()}%',
                onChanged: (v) => setState(() => _buttonOpacity = v),
              ),
            ],
          ),
          _Group(
            title: l10n.settingsSectionEtc,
            children: [
              _NavTile(
                icon: Symbols.info_rounded,
                title: l10n.settingsAbout,
                onTap: () => context.push(AppRoutes.about),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 쓸 수 없는 항목을 흐리게 보인다. ListTile 기본 비활성 색은 직접 준 글자 스타일에 가려지기 때문.
class _Dimmed extends StatelessWidget {
  const _Dimmed({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      enabled ? child : Opacity(opacity: 0.45, child: child);
}

/// 섹션 제목 + 흰 카드 안에 항목들을 구분선으로 묶는다.
class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    const Divider(indent: 20, endIndent: 20, height: 1),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.value,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Dimmed(enabled: onTap != null, child: _navTile(theme));
  }

  Widget _navTile(ThemeData theme) {
    return ListTile(
      enabled: onTap != null,
      onTap: onTap,
      leading: IconBadge(icon: icon),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: theme.textTheme.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(width: 4),
          Icon(
            Symbols.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = disabledReason == null;

    return _Dimmed(
      enabled: enabled,
      child: _tile(l10n, theme, colors, enabled),
    );
  }

  Widget _tile(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colors,
    bool enabled,
  ) {
    return ListTile(
      enabled: enabled,
      onTap: enabled ? onTap : null,
      leading: IconBadge(icon: engineIcon(engine)),
      title: Text(l10n.engineName(engine), style: theme.textTheme.titleMedium),
      subtitle: Text(
        disabledReason ?? l10n.engineDetail(engine),
        style: theme.textTheme.bodySmall,
      ),
      trailing: Icon(
        selected
            ? Symbols.radio_button_checked_rounded
            : Symbols.radio_button_unchecked_rounded,
        color: selected ? colors.primary : colors.outline,
      ),
    );
  }
}

class _ChipsTile<T> extends StatelessWidget {
  const _ChipsTile({
    required this.title,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final String title;
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in values)
                ChoiceChip(
                  label: Text(label(value)),
                  selected: value == selected,
                  backgroundColor: colors.surfaceContainer,
                  onSelected: (_) => onSelected(value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(valueLabel, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
