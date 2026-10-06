import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/history_entry.dart';
import 'history_card.dart' show historyLanguageName;

/// 기록 상세 바텀시트 (FL-13): 목록에서 줄여 보인 번역 · 원문을 전체로 보여 주고 복사한다.
class HistoryDetailSheet extends StatefulWidget {
  const HistoryDetailSheet({super.key, required this.entry});

  final HistoryEntry entry;

  static Future<void> show(BuildContext context, HistoryEntry entry) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => HistoryDetailSheet(entry: entry),
    );
  }

  @override
  State<HistoryDetailSheet> createState() => _HistoryDetailSheetState();
}

enum _Copied { translated, original }

class _HistoryDetailSheetState extends State<HistoryDetailSheet> {
  _Copied? _copied;

  Future<void> _copy(_Copied target, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) setState(() => _copied = target);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = Localizations.localeOf(context);
    final entry = widget.entry;
    final time = DateFormat.yMMMd(locale.toString())
        .add_Hm()
        .format(entry.translatedAt);
    final meta =
        '${historyLanguageName(entry.sourceLanguage, locale.languageCode)} → '
        '${historyLanguageName(entry.targetLanguage, locale.languageCode)} · $time';

    Widget block(String title, String text, TextStyle? style, _Copied target) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: SectionTitle(title)),
              AppButton.text(
                label: _copied == target
                    ? l10n.historyCopied
                    : l10n.historyCopy,
                leading: Icon(
                  _copied == target
                      ? Symbols.check_rounded
                      : Symbols.content_copy_rounded,
                  size: 18,
                ),
                onPressed: () => _copy(target, text),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space4),
          SelectableText(text, style: style),
        ],
      );
    }

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.pagePadding,
          0,
          AppTokens.pagePadding,
          AppTokens.sectionGap,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meta, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppTokens.space16),
            block(
              l10n.historyDetailTranslated,
              entry.translated,
              theme.textTheme.titleMedium,
              _Copied.translated,
            ),
            const SizedBox(height: AppTokens.sectionGap),
            block(
              l10n.historyDetailOriginal,
              entry.original,
              theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              _Copied.original,
            ),
          ],
        ),
      ),
    );
  }
}
