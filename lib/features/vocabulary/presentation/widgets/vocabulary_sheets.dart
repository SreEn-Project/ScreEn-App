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

/// [showWordbookPickerSheet]에서 "새 단어장"을 골랐을 때 돌려주는 값.
const pickNewWordbook = -1;

/// 단어장 고르기 (AD-03, AD-05, AD-06, AD-07). [books]에서 [exceptId]는 뺀다.
/// 고르면 그 id를, [allowCreate]에서 "새 단어장"을 고르면 [pickNewWordbook]을 돌려준다.
/// [selectedId]인 줄에는 체크 표시를 한다. 단어장이 늘어나도 세로로 훑어 고를 수 있다.
Future<int?> showWordbookPickerSheet(
  BuildContext context, {
  required List<Wordbook> books,
  int? exceptId,
  int? selectedId,
  String? title,
  bool allowCreate = false,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      final theme = Theme.of(sheetContext);
      final colors = theme.colorScheme;
      final others = [
        for (final book in books)
          if (book.id != exceptId) book,
      ];

      Widget row({
        required IconData icon,
        required String name,
        String? count,
        bool selected = false,
        required VoidCallback onTap,
      }) {
        return AppCard(
          onTap: onTap,
          color: selected ? colors.primaryContainer : null,
          shadow: !selected,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.rowPaddingH,
            vertical: AppTokens.space12,
          ),
          child: Row(
            children: [
              IconBadge(icon: icon, size: 40),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (count != null) Text(count, style: theme.textTheme.bodySmall),
              if (selected) ...[
                const SizedBox(width: AppTokens.space8),
                Icon(Symbols.check_rounded, color: colors.primary, size: 22),
              ],
            ],
          ),
        );
      }

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
              Text(
                title ?? l10n.vocabMoveTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppTokens.space16),
              if (others.isEmpty && !allowCreate)
                Text(l10n.vocabMoveNoOther, style: theme.textTheme.bodySmall)
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final book in others) ...[
                        row(
                          icon: Symbols.menu_book_rounded,
                          name: book.name,
                          count: l10n.vocabWordCount(book.wordCount),
                          selected: book.id == selectedId,
                          onTap: () => Navigator.of(sheetContext).pop(book.id),
                        ),
                        const SizedBox(height: AppTokens.space8),
                      ],
                      if (allowCreate)
                        row(
                          icon: Symbols.add_rounded,
                          name: l10n.vocabNewBook,
                          selected: selectedId == pickNewWordbook,
                          onTap: () =>
                              Navigator.of(sheetContext).pop(pickNewWordbook),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// 학습할 단어장을 여러 개 고르기 (AD-07). 적어도 하나는 골라야 한다.
/// 확인을 누르면 고른 id들을, 그냥 닫으면 null을 돌려준다.
Future<List<int>?> showWordbookMultiPickerSheet(
  BuildContext context, {
  required List<Wordbook> books,
  required Set<int> selectedIds,
  required String title,
}) {
  return showModalBottomSheet<List<int>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) =>
        _WordbookMultiPicker(books: books, initial: selectedIds, title: title),
  );
}

class _WordbookMultiPicker extends StatefulWidget {
  const _WordbookMultiPicker({
    required this.books,
    required this.initial,
    required this.title,
  });

  final List<Wordbook> books;
  final Set<int> initial;
  final String title;

  @override
  State<_WordbookMultiPicker> createState() => _WordbookMultiPickerState();
}

class _WordbookMultiPickerState extends State<_WordbookMultiPicker> {
  late final Set<int> _picked = {...widget.initial};

  void _toggle(int id) {
    setState(() {
      if (!_picked.remove(id)) _picked.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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
            Text(widget.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppTokens.space4),
            Text(l10n.learnPickBookHint, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppTokens.space16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final book in widget.books) ...[
                    AppCard(
                      onTap: () => _toggle(book.id),
                      color: _picked.contains(book.id)
                          ? colors.primaryContainer
                          : null,
                      shadow: !_picked.contains(book.id),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.rowPaddingH,
                        vertical: AppTokens.space12,
                      ),
                      child: Row(
                        children: [
                          const IconBadge(
                            icon: Symbols.menu_book_rounded,
                            size: 40,
                          ),
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
                          if (_picked.contains(book.id)) ...[
                            const SizedBox(width: AppTokens.space8),
                            Icon(
                              Symbols.check_rounded,
                              color: colors.primary,
                              size: 22,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space8),
            AppButton(
              label: l10n.learnPickBookDone(_picked.length),
              onPressed: _picked.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(_picked.toList()),
            ),
          ],
        ),
      ),
    );
  }
}

/// 지우기 전 확인 시트. 지우겠다고 하면 true.
Future<bool> showDeleteConfirmSheet(
  BuildContext context, {
  required String title,
  String? body,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppConfirm(
    context,
    title: title,
    message: body,
    confirmLabel: l10n.vocabDelete,
    cancelLabel: l10n.vocabCancel,
  );
}

enum WordAction { edit, move, addTo, delete }

/// 단어 하나에 할 동작 고르기 (AD-05): 수정 · 다른 단어장으로 이동 · 다른 단어장에도 넣기 · 이 단어장에서 빼기.
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
                  icon: Symbols.edit_rounded,
                  title: l10n.vocabEditWord,
                  onTap: () => Navigator.of(sheetContext).pop(WordAction.edit),
                ),
                const AppDivider(),
                AppListTile(
                  icon: Symbols.drive_file_move_rounded,
                  title: l10n.vocabMove,
                  onTap: () => Navigator.of(sheetContext).pop(WordAction.move),
                ),
                const AppDivider(),
                AppListTile(
                  icon: Symbols.library_add_rounded,
                  title: l10n.vocabAddTo,
                  onTap: () => Navigator.of(sheetContext).pop(WordAction.addTo),
                ),
                const AppDivider(),
                AppListTile(
                  icon: Symbols.delete_rounded,
                  title: l10n.vocabRemoveFromBook,
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
