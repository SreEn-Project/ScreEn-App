import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/accent_title.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../core/widgets/section_title.dart';
import '../../../l10n/app_localizations.dart';
import '../../language/domain/supported_language.dart';

/// 언어 모델 관리 (S-05, FL-05).
/// UI 퍼블리싱 단계: 설치 상태 · 진행률은 가짜 값이다. 받기를 누르면 진행률이 흉내로 올라간다.
/// 실제 다운로드 · 삭제 · 진행률 이벤트는 NA-12와 함께 연결한다.
class LanguageModelsScreen extends StatefulWidget {
  const LanguageModelsScreen({super.key});

  @override
  State<LanguageModelsScreen> createState() => _LanguageModelsScreenState();
}

class _LanguageModelsScreenState extends State<LanguageModelsScreen> {
  static const _modelSizeMb = 30;

  bool _wifiOnly = true;

  /// 언어 코드 → 진행률. 1 = 설치됨, 0~1 = 받는 중, 없음 = 받지 않음.
  final Map<String, double> _progress = {'ko': 1, 'en': 1, 'ja': 0.42};
  final Map<String, Timer> _timers = {};

  @override
  void initState() {
    super.initState();
    _simulateDownload('ja');
  }

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _simulateDownload(String code) {
    _progress[code] ??= 0;
    _timers[code]?.cancel();
    _timers[code] = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        final next = (_progress[code]! + 0.08).clamp(0.0, 1.0);
        _progress[code] = next;
        if (next >= 1) {
          timer.cancel();
          _timers.remove(code);
        }
      });
    });
  }

  void _cancelOrDelete(String code) {
    _timers.remove(code)?.cancel();
    setState(() => _progress.remove(code));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);

    final installed = SupportedLanguage.all
        .where((l) => _progress.containsKey(l.code))
        .toList();
    final available = SupportedLanguage.all
        .where((l) => !_progress.containsKey(l.code))
        .toList();

    Widget tile(SupportedLanguage language) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _ModelTile(
        name: language.displayName(locale),
        language: language,
        progress: _progress[language.code],
        sizeMb: _modelSizeMb,
        onDownload: () => setState(() => _simulateDownload(language.code)),
        onRemove: () => _cancelOrDelete(language.code),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.modelsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.pagePadding,
          8,
          AppTokens.pagePadding,
          32,
        ),
        children: [
          AccentTitle(
            text: l10n.modelsHeadline,
            highlight: l10n.modelsHighlight,
          ),
          const SizedBox(height: 8),
          Text(l10n.modelsBody, style: theme.textTheme.bodySmall),
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SwitchListTile(
              value: _wifiOnly,
              onChanged: (v) => setState(() => _wifiOnly = v),
              secondary: const IconBadge(icon: Symbols.wifi_rounded),
              title: Text(
                l10n.modelsWifiOnly,
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                l10n.modelsWifiOnlyDetail,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 28),
          SectionTitle(l10n.modelsSectionInstalled),
          const SizedBox(height: 12),
          ...installed.map(tile),
          const SizedBox(height: 20),
          SectionTitle(l10n.modelsSectionAvailable),
          const SizedBox(height: 12),
          ...available.map(tile),
        ],
      ),
    );
  }
}

class _ModelTile extends StatelessWidget {
  const _ModelTile({
    required this.name,
    required this.language,
    required this.progress,
    required this.sizeMb,
    required this.onDownload,
    required this.onRemove,
  });

  final String name;
  final SupportedLanguage language;
  final double? progress;
  final int sizeMb;
  final VoidCallback onDownload;
  final VoidCallback onRemove;

  bool get _installed => progress != null && progress! >= 1;
  bool get _downloading => progress != null && progress! < 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final status = _installed
        ? l10n.modelsInstalled
        : _downloading
        ? l10n.modelsDownloading((progress! * 100).round())
        : l10n.modelsSize(sizeMb);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(name, style: theme.textTheme.titleMedium),
                        if (!language.ocrSupported)
                          _Badge(label: l10n.modelsTargetOnly),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${language.nativeName} · $status',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _installed ? colors.primary : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (_installed)
                IconButton(
                  tooltip: l10n.modelsDelete,
                  onPressed: onRemove,
                  icon: Icon(
                    Symbols.delete_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                )
              else if (_downloading)
                IconButton(
                  tooltip: l10n.modelsCancel,
                  onPressed: onRemove,
                  icon: Icon(
                    Symbols.close_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                )
              else
                IconButton.filledTonal(
                  tooltip: l10n.modelsDownload,
                  onPressed: onDownload,
                  icon: const Icon(Symbols.download_rounded),
                ),
            ],
          ),
          if (_downloading) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: colors.primaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 작은 배지 (secondaryContainer).
class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: colors.secondaryContainer,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.onSecondaryContainer,
        ),
      ),
    );
  }
}
