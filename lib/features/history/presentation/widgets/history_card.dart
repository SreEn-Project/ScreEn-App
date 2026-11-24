import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    this.flat = false,
  });

  final HistoryEntry entry;
  final VoidCallback? onDelete;
  final String deleteTooltip;

  /// true면 카드로 감싸지 않고 평면 행으로 그린다 (그룹 카드 안이나 평면 목록에서 쓴다).
  final bool flat;

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

    final padding = EdgeInsets.fromLTRB(
      flat ? 4 : 20,
      flat ? 14 : 16,
      onDelete == null ? (flat ? 4 : 20) : 8,
      flat ? 14 : 16,
    );
    final row = Row(
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
            icon: LucideIcons.trash2,
            tooltip: deleteTooltip,
            plain: true,
            size: 40,
            onPressed: onDelete,
          ),
      ],
    );
    final body = Padding(padding: padding, child: row);
    if (flat) {
      return Pressable(
        onTap: () => HistoryDetailSheet.show(context, entry),
        scale: 0.99,
        child: body,
      );
    }
    return AppCard(
      onTap: () => HistoryDetailSheet.show(context, entry),
      padding: padding,
      child: row,
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
