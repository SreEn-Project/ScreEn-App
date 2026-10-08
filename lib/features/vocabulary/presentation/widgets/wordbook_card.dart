import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/vocabulary.dart';

/// 단어장 한 장 카드 (AD-04): 이름 · 단어 수 · 외운 수, 오른쪽에 이름 변경 · 삭제.
class WordbookCard extends StatelessWidget {
  const WordbookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  final Wordbook book;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final counts = [
      l10n.vocabWordCount(book.wordCount),
      if (book.accuracy case final accuracy?)
        l10n.vocabAccuracy((accuracy * 100).round()),
      if (book.memorizedCount > 0)
        l10n.vocabMemorizedCount(book.memorizedCount),
    ].join(' · ');

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppTokens.pagePadding,
        AppTokens.space12,
        AppTokens.space8,
        AppTokens.space12,
      ),
      child: Row(
        children: [
          const IconBadge(icon: Symbols.menu_book_rounded, size: 44),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppTokens.space4),
                Text(counts, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          AppIconButton(
            icon: Symbols.edit_rounded,
            tooltip: l10n.vocabRename,
            plain: true,
            size: 40,
            onPressed: onRename,
          ),
          AppIconButton(
            icon: Symbols.delete_rounded,
            tooltip: l10n.vocabDelete,
            plain: true,
            size: 40,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
