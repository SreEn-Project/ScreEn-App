import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/vocabulary.dart';
import '../view_models/word_edit_view_model.dart';
import '../view_models/wordbooks_view_model.dart';
import 'vocabulary_sheets.dart';
import 'wordbook_selector.dart';

/// 단어 편집 시트 (AD-03): 단어장에 저장하기 전에 단어 · 뜻 · 발음 등을 고친다.
/// 직접 추가 · 번역 기록에서 추가가 같이 쓴다. 저장하면 단어장 이름을 돌려주고, 닫으면 null.
/// [wordbookId]를 주면 그 단어장이 미리 골라진다.
Future<String?> showWordEditSheet(
  BuildContext context, {
  required String title,
  required WordDraft initial,
  int? wordbookId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        WordEditSheet(title: title, initial: initial, wordbookId: wordbookId),
  );
}

class WordEditSheet extends ConsumerStatefulWidget {
  const WordEditSheet({
    super.key,
    required this.title,
    required this.initial,
    this.wordbookId,
  });

  final String title;
  final WordDraft initial;
  final int? wordbookId;

  @override
  ConsumerState<WordEditSheet> createState() => _WordEditSheetState();
}

class _WordEditSheetState extends ConsumerState<WordEditSheet> {
  late final _word = TextEditingController(text: widget.initial.word);
  late final _meaning = TextEditingController(text: widget.initial.meaning);
  late final _pronunciation = TextEditingController(
    text: widget.initial.pronunciation ?? '',
  );
  late final _partOfSpeech = TextEditingController(
    text: widget.initial.partOfSpeech ?? '',
  );
  late final _contextMeaning = TextEditingController(
    text: widget.initial.contextMeaning ?? '',
  );
  late final _sentence = TextEditingController(
    text: widget.initial.sentence ?? '',
  );
  final _newBookName = TextEditingController();

  int? _bookId;
  bool _wantsNewBook = false;
  bool _busy = false;
  bool _failed = false;
  String? _savedBookName;

  @override
  void initState() {
    super.initState();
    _bookId = widget.wordbookId;
  }

  @override
  void dispose() {
    for (final c in [
      _word,
      _meaning,
      _pronunciation,
      _partOfSpeech,
      _contextMeaning,
      _sentence,
      _newBookName,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// 저장할 단어장을 목록 시트에서 고른다 (가로로 넘기는 칩은 단어장이 늘면 불편해서).
  Future<void> _pickBook(
    List<Wordbook> books,
    bool creating,
    int? selectedId,
  ) async {
    FocusScope.of(context).unfocus();
    final picked = await showWordbookPickerSheet(
      context,
      books: books,
      selectedId: creating ? pickNewWordbook : selectedId,
      title: AppLocalizations.of(context).vocabSaveTo,
      allowCreate: true,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _wantsNewBook = picked == pickNewWordbook;
      if (!_wantsNewBook) _bookId = picked;
    });
  }

  bool _canSave(List<Wordbook> books) {
    if (_word.text.trim().isEmpty || _meaning.text.trim().isEmpty) return false;
    final hasBook = _creating(books)
        ? _newBookName.text.trim().isNotEmpty
        : books.any((b) => b.id == _effectiveBookId(books));
    return hasBook && !_busy;
  }

  bool _creating(List<Wordbook> books) => _wantsNewBook || books.isEmpty;

  /// 고른 단어장이 없으면(처음 열렸을 때) 첫 단어장.
  int? _effectiveBookId(List<Wordbook> books) {
    if (_bookId != null && books.any((b) => b.id == _bookId)) return _bookId;
    return books.firstOrNull?.id;
  }

  String? _blankToNull(TextEditingController c) {
    final text = c.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save(List<Wordbook> books) async {
    if (!_canSave(books)) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    final booksModel = ref.read(wordbooksViewModelProvider.notifier);
    int? bookId;
    String? bookName;
    if (_creating(books)) {
      final created = await booksModel.create(_newBookName.text.trim());
      bookId = created?.id;
      bookName = created?.name;
    } else {
      bookId = _effectiveBookId(books);
      bookName = books.where((b) => b.id == bookId).firstOrNull?.name;
    }
    final saved =
        bookId != null &&
        await ref
            .read(wordEditViewModelProvider.notifier)
            .save(
              bookId,
              WordDraft(
                word: _word.text.trim(),
                meaning: _meaning.text.trim(),
                pronunciation: _blankToNull(_pronunciation),
                partOfSpeech: _blankToNull(_partOfSpeech),
                contextMeaning: _blankToNull(_contextMeaning),
                sentence: _blankToNull(_sentence),
                sourceLanguage: widget.initial.sourceLanguage,
                targetLanguage: widget.initial.targetLanguage,
              ),
            );
    if (!mounted) return;
    if (!saved) {
      setState(() {
        _busy = false;
        _failed = true;
      });
      return;
    }
    await booksModel.refresh();
    if (!mounted) return;
    setState(() => _savedBookName = bookName ?? '');
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (mounted) Navigator.of(context).pop(bookName ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final books = ref.watch(wordbooksViewModelProvider).value ?? const [];
    // 단어장이 하나도 없으면 바로 새로 만든다.
    final creating = _creating(books);
    final selectedId = _effectiveBookId(books);

    Widget field(TextEditingController c, String hint, {int lines = 1}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.space12),
          child: AppTextField(
            controller: c,
            hint: hint,
            maxLines: lines,
            onChanged: (_) => setState(() => _failed = false),
          ),
        );

    final saved = _savedBookName;
    return SafeArea(
      top: false,
      child: Padding(
        // 키보드가 올라오면 그만큼 시트를 밀어 올린다.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: saved != null
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTokens.sectionGap,
                  horizontal: AppTokens.pagePadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const IconBadge(icon: Symbols.check_rounded, size: 56),
                    const SizedBox(height: AppTokens.space16),
                    Text(
                      l10n.vocabSavedTo(saved),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(_word.text.trim(), style: theme.textTheme.bodySmall),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.pagePadding,
                  0,
                  AppTokens.pagePadding,
                  AppTokens.sectionGap,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppTokens.space16),
                    field(_word, l10n.vocabWordHint),
                    field(_meaning, l10n.vocabMeaningHint, lines: 3),
                    field(_pronunciation, l10n.vocabPronunciationHint),
                    field(_partOfSpeech, l10n.vocabPartOfSpeechHint),
                    field(_contextMeaning, l10n.vocabContextMeaningHint),
                    field(_sentence, l10n.vocabSentenceHint, lines: 3),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      l10n.vocabSaveTo,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    WordbookSelector(
                      label: creating
                          ? l10n.vocabNewBook
                          : books
                                    .where((b) => b.id == selectedId)
                                    .firstOrNull
                                    ?.name ??
                                '',
                      count: creating
                          ? null
                          : books
                                .where((b) => b.id == selectedId)
                                .firstOrNull
                                ?.wordCount,
                      onTap: () => _pickBook(books, creating, selectedId),
                    ),
                    if (creating) ...[
                      const SizedBox(height: AppTokens.space12),
                      AppTextField(
                        controller: _newBookName,
                        hint: l10n.vocabNameHint,
                        maxLength: 30,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                    if (_failed) ...[
                      const SizedBox(height: AppTokens.space12),
                      Text(
                        l10n.vocabSaveFailed,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppTokens.sectionGap),
                    AppButton(
                      label: l10n.vocabSave,
                      onPressed: _canSave(books) ? () => _save(books) : null,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
