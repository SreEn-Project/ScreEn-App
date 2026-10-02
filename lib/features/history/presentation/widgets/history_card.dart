import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/ui.dart';
import '../../../language/domain/entities/supported_language.dart';
import '../../domain/entities/history_entry.dart';

/// 기록 한 줄 카드 (FL-13): 번역 · 원문 · 언어 쌍 · 시각. [onDelete]를 주면 삭제 버튼이 붙는다.
class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.entry,
    this.onDelete,
    this.deleteTooltip = '',
  });

  final HistoryEntry entry;
  final VoidCallback? onDelete;
  final String deleteTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = Localizations.localeOf(context);
    final time = DateFormat.MMMd(locale.toString())
        .add_Hm()
        .format(entry.translatedAt);
    final meta =
        '${_languageName(entry.sourceLanguage, locale.languageCode)} → '
        '${_languageName(entry.targetLanguage, locale.languageCode)} · $time';

    return AppCard(
      padding: EdgeInsets.fromLTRB(20, 16, onDelete == null ? 20 : 8, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.translated, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  entry.original,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(meta, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (onDelete != null)
            AppIconButton(
              icon: Symbols.delete_rounded,
              tooltip: deleteTooltip,
              plain: true,
              size: 40,
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

String _languageName(String code, String uiLanguageCode) {
  for (final language in SupportedLanguage.all) {
    if (language.code == code) return language.displayName(uiLanguageCode);
  }
  return code;
}
