import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/router.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../language/domain/entities/supported_language.dart';
import '../../../language/presentation/view_models/target_language_view_model.dart';
import '../view_models/language_models_view_model.dart';

/// 언어 탭: 대상 언어(FL-04) + 언어 모델 관리(S-05, FL-05).
/// 받은 모델은 ML Kit이 기기에 둔 것을 그대로 보여 주고, 받기 · 삭제는 바로 ML Kit에 요청한다.
/// ML Kit이 진행률을 주지 않아 받는 중에는 진행 중 표시만 나온다 (취소도 못 한다).
class LanguageModelsScreen extends ConsumerWidget {
  const LanguageModelsScreen({super.key});

  static const _modelSizeMb = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final target = ref.watch(targetLanguageViewModelProvider).value ?? 'ko';
    final wifiOnly = ref.watch(wifiOnlyDownloadViewModelProvider).value ?? true;
    final models =
        ref.watch(languageModelsViewModelProvider).value ??
        const LanguageModelsState();
    final viewModel = ref.read(languageModelsViewModelProvider.notifier);
    ref.listen(languageModelsViewModelProvider, (previous, next) {
      final before = previous?.value?.failed ?? const <String>{};
      final now = next.value?.failed ?? const <String>{};
      if (now.difference(before).isNotEmpty) {
        AppToast.show(
          context,
          l10n.modelsDownloadFailed,
          kind: AppMessageKind.error,
        );
      }
    });

    final installed = SupportedLanguage.all
        .where((l) => models.installed.contains(l.code))
        .toList();
    final available = SupportedLanguage.all
        .where((l) => !models.installed.contains(l.code))
        .toList();

    Widget group(List<SupportedLanguage> languages) => AppCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < languages.length; i++) ...[
            if (i > 0) const AppDivider(),
            _ModelRow(
              name: languages[i].displayName(locale.languageCode),
              language: languages[i],
              installed: models.installed.contains(languages[i].code),
              downloading: models.downloading.contains(languages[i].code),
              failed: models.failed.contains(languages[i].code),
              sizeMb: _modelSizeMb,
              onDownload: () => viewModel.download(languages[i].code),
              onRemove: () => viewModel.delete(languages[i].code),
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
              value: SupportedLanguage.byCode(target)
                  .displayName(locale.languageCode),
              onTap: () => context.push(AppRoutes.targetLanguage),
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
                    value: wifiOnly,
                    onChanged: (v) => ref
                        .read(wifiOnlyDownloadViewModelProvider.notifier)
                        .setEnabled(v),
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
    required this.installed,
    required this.downloading,
    required this.failed,
    required this.sizeMb,
    required this.onDownload,
    required this.onRemove,
  });

  final String name;
  final SupportedLanguage language;
  final bool installed;
  final bool downloading;
  final bool failed;
  final int sizeMb;
  final VoidCallback onDownload;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final status = installed
        ? l10n.modelsInstalled
        : downloading
        ? l10n.modelsDownloading
        : failed
        ? l10n.modelsDownloadFailed
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
                        color: installed
                            ? colors.primary
                            : failed
                            ? colors.error
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (installed)
                AppIconButton(
                  icon: Symbols.delete_rounded,
                  tooltip: l10n.modelsDelete,
                  plain: true,
                  size: 40,
                  onPressed: onRemove,
                )
              else if (!downloading)
                AppIconButton(
                  icon: Symbols.download_rounded,
                  tooltip: l10n.modelsDownload,
                  size: 40,
                  onPressed: onDownload,
                ),
            ],
          ),
          if (downloading) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppProgressBar(),
            ),
          ],
        ],
      ),
    );
  }
}
