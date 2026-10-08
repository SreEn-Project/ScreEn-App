import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/vocabulary.dart';

/// 단어장 상세의 단어 한 줄 (AD-05): 단어 · 뜻, 외운 표시 토글, 이동 · 삭제 메뉴.
class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.word,
    required this.onTap,
    required this.onToggleMemorized,
    required this.onMore,
  });

  final VocabularyWord word;
  final VoidCallback onTap;
  final VoidCallback onToggleMemorized;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppTokens.pagePadding,
        AppTokens.space12,
        AppTokens.space8,
        AppTokens.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.word,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      word.meaning,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AppIconButton(
                icon: Symbols.more_vert_rounded,
                tooltip: l10n.vocabMove,
                plain: true,
                size: 40,
                onPressed: onMore,
              ),
            ],
          ),
          Row(
            children: [
              if (word.accuracy case final accuracy?) ...[
                AppBadge(label: l10n.vocabAccuracy((accuracy * 100).round())),
                const SizedBox(width: AppTokens.space8),
                Flexible(
                  child: Text(
                    l10n.vocabAccuracyDetail(
                      word.correctCount,
                      word.attemptCount,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
              const Spacer(),
              AppIconButton(
                icon: word.memorized
                    ? Symbols.check_circle_rounded
                    : Symbols.radio_button_unchecked_rounded,
                tooltip: l10n.vocabMemorizedLabel,
                plain: true,
                size: 40,
                onPressed: onToggleMemorized,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
