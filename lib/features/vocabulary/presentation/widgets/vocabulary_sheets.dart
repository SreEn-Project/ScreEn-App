import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/vocabulary.dart';

/// 단어장 이름 입력 시트 (AD-04): 만들기와 이름 변경에 같이 쓴다.
/// [onSubmit]이 false를 돌려주면(이름이 겹침 · 비어 있음) 시트를 닫지 않고 안내한다.
Future<void> showWordbookNameSheet(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String initialName = '',
  required Future<bool> Function(String name) onSubmit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _WordbookNameSheet(
      title: title,
      confirmLabel: confirmLabel,
      initialName: initialName,
      onSubmit: onSubmit,
    ),
  );
}

class _WordbookNameSheet extends StatefulWidget {
  const _WordbookNameSheet({
    required this.title,
    required this.confirmLabel,
    required this.initialName,
    required this.onSubmit,
  });

  final String title;
  final String confirmLabel;
  final String initialName;
  final Future<bool> Function(String name) onSubmit;

  @override
  State<_WordbookNameSheet> createState() => _WordbookNameSheetState();
}

class _WordbookNameSheetState extends State<_WordbookNameSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );
  bool _taken = false;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _busy) return;
    setState(() => _busy = true);
    final done = await widget.onSubmit(name);
    if (!mounted) return;
    if (done) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _busy = false;
        _taken = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        // 키보드가 올라오면 그만큼 시트를 밀어 올린다.
        padding: EdgeInsets.fromLTRB(
          AppTokens.pagePadding,
          0,
          AppTokens.pagePadding,
          AppTokens.sectionGap + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppTokens.space16),
            AppTextField(
              controller: _controller,
              hint: l10n.vocabNameHint,
              onChanged: (_) {
                if (_taken) setState(() => _taken = false);
              },
            ),
            if (_taken) ...[
              const SizedBox(height: AppTokens.space8),
              Padding(
                padding: const EdgeInsets.only(left: AppTokens.space8),
                child: Text(
                  l10n.vocabNameTaken,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppTokens.space16),
            AppButton(
              label: widget.confirmLabel,
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// 이동할 단어장 고르기 (AD-05, AD-06). [books]에서 [exceptId]는 뺀다. 고르면 그 id를 돌려준다.
Future<int?> showWordbookPickerSheet(
  BuildContext context, {
  required List<Wordbook> books,
  required int exceptId,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      final theme = Theme.of(sheetContext);
      final others = [
        for (final book in books)
          if (book.id != exceptId) book,
      ];
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.pagePadding,
            0,
            AppTokens.pagePadding,
            AppTokens.sectionGap,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.vocabMoveTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppTokens.space16),
              if (others.isEmpty)
                Text(l10n.vocabMoveNoOther, style: theme.textTheme.bodySmall)
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: others.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppTokens.space8),
                    itemBuilder: (_, index) {
                      final book = others[index];
                      return AppCard(
                        onTap: () => Navigator.of(sheetContext).pop(book.id),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.rowPaddingH,
                          vertical: AppTokens.space16,
                        ),
                        child: Row(
                          children: [
                            const IconBadge(icon: Symbols.menu_book_rounded),
                            const SizedBox(width: AppTokens.space12),
                            Expanded(
                              child: Text(
                                book.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              l10n.vocabWordCount(book.wordCount),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// 지우기 전 확인 시트. 지우겠다고 하면 true.
Future<bool> showDeleteConfirmSheet(
  BuildContext context, {
  required String title,
  String? body,
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      final theme = Theme.of(sheetContext);
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.pagePadding,
            0,
            AppTokens.pagePadding,
            AppTokens.sectionGap,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              if (body != null) ...[
                const SizedBox(height: AppTokens.space8),
                Text(body, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: AppTokens.sectionGap),
              AppButton(
                label: l10n.vocabDelete,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
              const SizedBox(height: AppTokens.space8),
              AppButton.secondary(
                label: l10n.vocabCancel,
                onPressed: () => Navigator.of(sheetContext).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );
  return confirmed ?? false;
}

enum WordAction { move, delete }

/// 단어 하나에 할 동작 고르기 (AD-05): 다른 단어장으로 이동 · 삭제.
Future<WordAction?> showWordActionsSheet(BuildContext context) {
  return showModalBottomSheet<WordAction>(
    context: context,
    useSafeArea: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.pagePadding,
            0,
            AppTokens.pagePadding,
            AppTokens.sectionGap,
          ),
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppListTile(
                  icon: Symbols.drive_file_move_rounded,
                  title: l10n.vocabMove,
                  onTap: () => Navigator.of(sheetContext).pop(WordAction.move),
                ),
                const AppDivider(),
                AppListTile(
                  icon: Symbols.delete_rounded,
                  title: l10n.vocabDeleteWord,
                  onTap: () =>
                      Navigator.of(sheetContext).pop(WordAction.delete),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
