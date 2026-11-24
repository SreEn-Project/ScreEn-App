import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';

/// 고른 단어장을 보여 주는 칸 (AD-03, AD-07): 누르면 단어장 고르기 시트가 뜬다.
class WordbookSelector extends StatelessWidget {
  const WordbookSelector({
    super.key,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final String label;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space12,
      ),
      child: Row(
        children: [
          const IconBadge(icon: Symbols.menu_book_rounded, size: 36),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
          ),
          if (count != null)
            Text(l10n.vocabWordCount(count!), style: theme.textTheme.bodySmall),
          const SizedBox(width: AppTokens.space4),
          Icon(
            Symbols.unfold_more_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ],
      ),
    );
  }
}
