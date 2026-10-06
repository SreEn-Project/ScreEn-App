import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/history_entry.dart';
import '../../../vocabulary/domain/entities/vocabulary.dart';
import '../../../vocabulary/presentation/widgets/word_edit_sheet.dart';
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

// 긴 글은 예문으로 넣지 않는다.
const _maxSentenceLength = 200;

class _HistoryDetailSheetState extends State<HistoryDetailSheet> {
  _Copied? _copied;

  // 원문 · 번역에서 드래그로 고른 글. 단어 추가 시 단어 · 뜻 칸을 미리 채운다.
  String _pickedOriginal = '';
  String _pickedTranslated = '';

  Future<void> _addWord() async {
    final l10n = AppLocalizations.of(context);
    final entry = widget.entry;
    final saved = await showWordEditSheet(
      context,
      title: l10n.vocabHistoryAddTitle,
      initial: WordDraft(
        word: _pickedOriginal.trim(),
        meaning: _pickedTranslated.trim(),
        sentence: entry.original.length <= _maxSentenceLength
            ? entry.original
            : null,
        sourceLanguage: entry.sourceLanguage,
        targetLanguage: entry.targetLanguage,
      ),
    );
    if (saved != null && mounted) Navigator.of(context).pop();
  }

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

    Widget block(
      String title,
      String text,
      TextStyle? style,
      _Copied target,
      ValueChanged<String> onPicked,
    ) {
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
          SelectableText(
            text,
            style: style,
            onSelectionChanged: (selection, _) => onPicked(
              selection.isCollapsed ? '' : selection.textInside(text),
            ),
          ),
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
              (text) => _pickedTranslated = text,
            ),
            const SizedBox(height: AppTokens.sectionGap),
            block(
              l10n.historyDetailOriginal,
              entry.original,
              theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              _Copied.original,
              (text) => _pickedOriginal = text,
            ),
            const SizedBox(height: AppTokens.sectionGap),
            AppButton.secondary(
              label: l10n.vocabAddToBook,
              leading: const Icon(Symbols.menu_book_rounded, size: 20),
              onPressed: _addWord,
            ),
          ],
        ),
      ),
    );
  }
}
