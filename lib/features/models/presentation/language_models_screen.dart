import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/router.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../language/domain/supported_language.dart';

/// 언어 탭: 대상 언어(FL-04) + 언어 모델 관리(S-05, FL-05).
/// UI 퍼블리싱 단계: 설치 상태 · 진행률은 가짜 값이다. 받기를 누르면 진행률이 흉내로 올라간다.
/// 실제 다운로드 · 삭제 · 진행률 이벤트는 NA-12와 함께 연결한다.
class LanguageModelsScreen extends StatefulWidget {
  const LanguageModelsScreen({super.key});

  @override
  State<LanguageModelsScreen> createState() => _LanguageModelsScreenState();
}

class _LanguageModelsScreenState extends State<LanguageModelsScreen> {
  static const _modelSizeMb = 30;

  String _targetLanguage = 'ko';
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

  void _remove(String code) {
    _timers.remove(code)?.cancel();
    setState(() => _progress.remove(code));
  }

  Future<void> _pickLanguage() async {
    final code = await context.push<String>(
      AppRoutes.targetLanguage,
      extra: _targetLanguage,
    );
    if (code != null) setState(() => _targetLanguage = code);
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

    Widget group(List<SupportedLanguage> languages) => AppCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < languages.length; i++) ...[
            if (i > 0) const AppDivider(),
            _ModelRow(
              name: languages[i].displayName(locale),
              language: languages[i],
              progress: _progress[languages[i].code],
              sizeMb: _modelSizeMb,
              onDownload: () =>
                  setState(() => _simulateDownload(languages[i].code)),
              onRemove: () => _remove(languages[i].code),
            ),
          ],
        ],
      ),
    );

    return AppPage(
      title: l10n.languagesTitle,
      withBottomNav: true,
      children: [
        AppSection(
          title: l10n.languagesSectionTarget,
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: AppListTile(
              icon: Symbols.translate_rounded,
              title: l10n.homeTargetLanguage,
              value: SupportedLanguage.byCode(_targetLanguage)
                  .displayName(locale),
              onTap: _pickLanguage,
            ),
          ),
        ),
        AppSection(
          title: l10n.languagesSectionDownload,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: AppListTile(
                  icon: Symbols.wifi_rounded,
                  title: l10n.modelsWifiOnly,
                  subtitle: l10n.modelsWifiOnlyDetail,
                  trailing: AppSwitch(
                    value: _wifiOnly,
                    onChanged: (v) => setState(() => _wifiOnly = v),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(l10n.modelsBody, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        ),
        AppSection(title: l10n.modelsSectionInstalled, child: group(installed)),
        AppSection(title: l10n.modelsSectionAvailable, child: group(available)),
      ],
    );
  }
}

class _ModelRow extends StatelessWidget {
  const _ModelRow({
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
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
                          AppBadge(label: l10n.modelsTargetOnly),
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
                AppIconButton(
                  icon: Symbols.delete_rounded,
                  tooltip: l10n.modelsDelete,
                  plain: true,
                  size: 40,
                  onPressed: onRemove,
                )
              else if (_downloading)
                AppIconButton(
                  icon: Symbols.close_rounded,
                  tooltip: l10n.modelsCancel,
                  plain: true,
                  size: 40,
                  onPressed: onRemove,
                )
              else
                AppIconButton(
                  icon: Symbols.download_rounded,
                  tooltip: l10n.modelsDownload,
                  size: 40,
                  onPressed: onDownload,
                ),
            ],
          ),
          if (_downloading) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppProgressBar(value: progress!),
            ),
          ],
        ],
      ),
    );
  }
}
