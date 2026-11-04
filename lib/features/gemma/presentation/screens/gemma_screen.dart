import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/domain/entities/translator_settings.dart';
import '../../../settings/presentation/view_models/engine_view_model.dart';
import '../../domain/entities/gemma_status.dart';
import '../view_models/gemma_assist_view_model.dart';
import '../view_models/gemma_view_model.dart';

final _licenseUrl = Uri.parse(
  'https://huggingface.co/litert-community/Gemma3-1B-IT',
);
final _tokenUrl = Uri.parse('https://huggingface.co/settings/tokens');

/// 기기 안 AI 번역 Gemma (#174): 모델 받기 · 진행률 · 취소 · 삭제, Hugging Face 토큰, 기기 메모리 안내, 번역 엔진으로 쓰기.
class GemmaScreen extends ConsumerStatefulWidget {
  const GemmaScreen({super.key});

  @override
  ConsumerState<GemmaScreen> createState() => _GemmaScreenState();
}

class _GemmaScreenState extends ConsumerState<GemmaScreen> {
  final _token = TextEditingController();
  bool _revealed = false;

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  Future<void> _saveToken() async {
    await ref.read(gemmaViewModelProvider.notifier).saveToken(_token.text);
    if (!mounted) return;
    _token.clear();
    setState(() {});
    AppToast.show(context, AppLocalizations.of(context).gemmaTokenSaved);
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showAppConfirm(
      context,
      title: l10n.gemmaDeleteTitle,
      message: l10n.gemmaDeleteBody,
      confirmLabel: l10n.modelsDelete,
      cancelLabel: l10n.modelsCancel,
    );
    if (ok) await ref.read(gemmaViewModelProvider.notifier).delete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status =
        ref.watch(gemmaViewModelProvider).value ?? const GemmaStatus();
    final viewModel = ref.read(gemmaViewModelProvider.notifier);
    final engine = ref.watch(engineViewModelProvider).value ?? EngineType.mlKit;
    final assist =
        ref.watch(gemmaAssistViewModelProvider).value ??
        const GemmaAssistOptions();
    final assistViewModel = ref.read(gemmaAssistViewModelProvider.notifier);
    final sizeMb = (status.totalBytes / (1024 * 1024)).round();

    final String stateText;
    if (status.isReady) {
      stateText = l10n.gemmaStateReady;
    } else if (status.isDownloading) {
      final percent = ((status.progress ?? 0) * 100).round();
      stateText = l10n.gemmaStateDownloading(percent, sizeMb);
    } else {
      stateText = l10n.gemmaStateNotDownloaded(sizeMb);
    }

    final failureText = switch (status.failure) {
      GemmaFailure.none => null,
      GemmaFailure.tokenRequired => l10n.gemmaErrorToken,
      GemmaFailure.licenseNotAccepted => l10n.gemmaErrorLicense,
      GemmaFailure.network => l10n.gemmaErrorNetwork,
      GemmaFailure.notEnoughSpace => l10n.gemmaErrorSpace,
      GemmaFailure.unknown => l10n.gemmaErrorUnknown,
    };
    final tokenText = _token.text.trim();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: l10n.gemmaTitle),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppTokens.pagePadding),
                children: [
                  Text(l10n.gemmaIntro, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  if (!status.ramSufficient) ...[
                    AppNotice.error(
                      l10n.gemmaRamLow(
                        (status.deviceRamMb / 1024).toStringAsFixed(1),
                        (status.minRamMb / 1024).toStringAsFixed(1),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.gemmaModelName,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    stateText,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: status.isReady
                                          ? theme.colorScheme.primary
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (status.isReady)
                              AppIconButton(
                                icon: Symbols.delete_rounded,
                                tooltip: l10n.modelsDelete,
                                plain: true,
                                size: 40,
                                onPressed: _confirmDelete,
                              ),
                          ],
                        ),
                        if (status.isDownloading) ...[
                          const SizedBox(height: 12),
                          AppProgressBar(value: status.progress),
                        ],
                        if (failureText != null && !status.isDownloading) ...[
                          const SizedBox(height: 12),
                          AppNotice.error(failureText),
                        ],
                        const SizedBox(height: 12),
                        if (status.isDownloading)
                          AppButton.secondary(
                            label: l10n.gemmaCancel,
                            onPressed: viewModel.cancel,
                          )
                        else if (!status.isReady)
                          AppButton(
                            label: status.downloadedBytes > 0
                                ? l10n.gemmaResume
                                : l10n.modelsDownload,
                            onPressed: status.ramSufficient
                                ? viewModel.download
                                : null,
                          ),
                      ],
                    ),
                  ),
                  if (status.isReady) ...[
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: AppListTile(
                        icon: Symbols.memory_rounded,
                        title: l10n.gemmaUse,
                        subtitle: l10n.gemmaUseDetail,
                        trailing: AppSwitch(
                          value: engine == EngineType.gemma,
                          onChanged: (on) => ref
                              .read(engineViewModelProvider.notifier)
                              .select(on ? EngineType.gemma : EngineType.mlKit),
                        ),
                      ),
                    ),
                  ],
                  if (status.isReady) ...[
                    const SizedBox(height: 20),
                    Text(
                      l10n.gemmaAssistTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.gemmaAssistIntro,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        children: [
                          AppListTile(
                            icon: Symbols.spellcheck_rounded,
                            title: l10n.gemmaAssistFixOcr,
                            subtitle: l10n.gemmaAssistFixOcrDetail,
                            trailing: AppSwitch(
                              value: assist.fixOcr,
                              onChanged: assistViewModel.setFixOcr,
                            ),
                          ),
                          AppListTile(
                            icon: Symbols.edit_note_rounded,
                            title: l10n.gemmaAssistPolish,
                            subtitle: l10n.gemmaAssistPolishDetail,
                            trailing: AppSwitch(
                              value: assist.polish,
                              onChanged: assistViewModel.setPolish,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!status.isReady) ...[
                    const SizedBox(height: 20),
                    Text(
                      l10n.gemmaTokenTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.gemmaTokenIntro,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _token,
                      hint: status.hasToken
                          ? l10n.gemmaTokenSavedHint
                          : l10n.gemmaTokenHint,
                      obscure: !_revealed,
                      onChanged: (_) => setState(() {}),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppButton.text(
                        label: _revealed ? l10n.apiKeyHide : l10n.apiKeyShow,
                        onPressed: () => setState(() => _revealed = !_revealed),
                      ),
                    ),
                    AppButton(
                      label: l10n.apiKeySave,
                      onPressed: tokenText.isEmpty ? null : _saveToken,
                    ),
                    if (status.hasToken)
                      AppButton.text(
                        label: l10n.gemmaTokenRemove,
                        onPressed: () => viewModel.saveToken(''),
                      ),
                    AppButton.text(
                      label: l10n.gemmaLicenseLink,
                      onPressed: () => launchUrl(
                        _licenseUrl,
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    AppButton.text(
                      label: l10n.gemmaTokenLink,
                      onPressed: () => launchUrl(
                        _tokenUrl,
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(l10n.gemmaFootnote, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
