import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/l10n/labels.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/translator_settings.dart';
import '../view_models/ai_options_view_model.dart';

/// 만 18세 이상 확인 (FL-09). 확인해야 AI 번역 설정과 AI 엔진을 쓸 수 있다.
class AiAgeCard extends ConsumerWidget {
  const AiAgeCard({super.key, required this.confirmed});

  final bool confirmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.cardListPaddingV),
      child: AppListTile(
        icon: Symbols.verified_user_rounded,
        title: l10n.aiAgeTitle,
        subtitle: l10n.aiAgeDetail,
        trailing: AppSwitch(
          value: confirmed,
          onChanged: (value) => ref
              .read(aiOptionsViewModelProvider.notifier)
              .setAgeConfirmed(value),
        ),
      ),
    );
  }
}

/// 데이터 전송 고지 (FL-11): 화면 글자가 AI 제공자로 가고, 무료 등급은 구글이 검토에 쓸 수 있다.
class AiNoticeCard extends StatelessWidget {
  const AiNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AppCard(
      color: theme.colorScheme.surfaceContainer,
      shadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Symbols.info_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.aiNoticeTitle, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  l10n.aiNoticeBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 말투 · 용어집 (FL-11).
class AiOptionsSection extends ConsumerStatefulWidget {
  const AiOptionsSection({super.key, required this.options});

  final AiOptions options;

  @override
  ConsumerState<AiOptionsSection> createState() => _AiOptionsSectionState();
}

class _AiOptionsSectionState extends ConsumerState<AiOptionsSection> {
  final _source = TextEditingController();
  final _target = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _source.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(aiOptionsViewModelProvider.notifier)
        .addEntry(_source.text, _target.text);
    if (!mounted) return;
    setState(() {
      switch (result) {
        case AddGlossaryResult.added:
          _source.clear();
          _target.clear();
          _message = null;
        case AddGlossaryResult.empty:
          _message = null;
        case AddGlossaryResult.full:
          _message = l10n.aiGlossaryFull(maxGlossaryEntries);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final viewModel = ref.read(aiOptionsViewModelProvider.notifier);
    final options = widget.options;
    final canAdd =
        _source.text.trim().isNotEmpty && _target.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.aiOptionsTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        Text(l10n.aiToneTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        AppSegmented<AiTone>(
          values: AiTone.values,
          selected: options.tone,
          label: l10n.aiToneName,
          onChanged: viewModel.setTone,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.aiToneHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Text(l10n.aiGlossaryTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          l10n.aiGlossaryDetail,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (options.glossary.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.aiGlossaryEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          AppCard(
            padding: const EdgeInsets.symmetric(
              vertical: AppTokens.cardListPaddingV,
            ),
            child: Column(
              children: [
                for (var i = 0; i < options.glossary.length; i++) ...[
                  if (i > 0) const AppDivider(),
                  _GlossaryRow(
                    entry: options.glossary[i],
                    onRemove: () => viewModel.removeEntry(options.glossary[i]),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _source,
          hint: l10n.aiGlossarySourceHint,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: _target,
          hint: l10n.aiGlossaryTargetHint,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        AppButton.secondary(
          label: l10n.aiGlossaryAdd,
          onPressed: canAdd ? _add : null,
        ),
        if (_message != null) ...[
          const SizedBox(height: 8),
          Text(
            _message!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _GlossaryRow extends StatelessWidget {
  const _GlossaryRow({required this.entry, required this.onRemove});

  final GlossaryEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.rowPaddingH,
        vertical: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: entry.source),
                  TextSpan(
                    text: '  →  ',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  TextSpan(
                    text: entry.target,
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ],
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),
          AppIconButton(
            icon: Symbols.close_rounded,
            tooltip: l10n.aiGlossaryRemove,
            plain: true,
            size: 40,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
