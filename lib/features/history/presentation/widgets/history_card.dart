import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/ui/ui.dart';
import '../../../language/domain/entities/supported_language.dart';
import '../../domain/entities/history_entry.dart';
import 'history_detail_sheet.dart';

// 목록에서 보이는 최대 줄 수. 넘치는 글은 상세 시트에서 본다.
const _translatedMaxLines = 3;
const _originalMaxLines = 2;

/// 기록 한 줄 카드 (FL-13): 번역 · 원문 · 언어 쌍 · 시각. 긴 글은 줄여 보이고, 탭하면 상세 시트로 전체를 본다.
/// [onDelete]를 주면 삭제 버튼이 붙는다.
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
        '${historyLanguageName(entry.sourceLanguage, locale.languageCode)} → '
        '${historyLanguageName(entry.targetLanguage, locale.languageCode)} · $time';

    return AppCard(
      onTap: () => HistoryDetailSheet.show(context, entry),
      padding: EdgeInsets.fromLTRB(20, 16, onDelete == null ? 20 : 8, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.translated,
                  maxLines: _translatedMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  entry.original,
                  maxLines: _originalMaxLines,
                  overflow: TextOverflow.ellipsis,
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

/// 언어 코드의 화면 표시 이름. 모르는 코드는 코드 그대로.
String historyLanguageName(String code, String uiLanguageCode) {
  for (final language in SupportedLanguage.all) {
    if (language.code == code) return language.displayName(uiLanguageCode);
  }
  return code;
}
