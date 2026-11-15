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
/// [editingId]를 주면 저장된 그 단어를 고치는 모드다: 단어장 선택 없이, 정답률 등 기록은 유지한 채 내용만 바꾼다.
/// [meaningOfWordId]를 주면 그 단어에 뜻을 더하는 모드, [editingMeaningId]를 주면 그 뜻 하나를 고치는 모드다
/// (단어 · 발음 · 품사 없이 뜻 · 문맥 뜻 · 예문만 다룬다).
Future<String?> showWordEditSheet(
  BuildContext context, {
  required String title,
  required WordDraft initial,
  int? wordbookId,
  int? editingId,
  int? meaningOfWordId,
  int? editingMeaningId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => WordEditSheet(
      title: title,
      initial: initial,
      wordbookId: wordbookId,
      editingId: editingId,
      meaningOfWordId: meaningOfWordId,
      editingMeaningId: editingMeaningId,
    ),
  );
}

/// 눌러야 나타나는 부가 항목.
enum _Option {
  pronunciation,
  partOfSpeech,
  contextMeaning,
  sentence;

  String label(AppLocalizations l10n) => switch (this) {
    pronunciation => l10n.vocabOptPronunciation,
    partOfSpeech => l10n.vocabOptPartOfSpeech,
    contextMeaning => l10n.vocabOptContextMeaning,
    sentence => l10n.vocabOptSentence,
  };

  String hint(AppLocalizations l10n) => switch (this) {
    pronunciation => l10n.vocabPronunciationHint,
    partOfSpeech => l10n.vocabPartOfSpeechHint,
    contextMeaning => l10n.vocabContextMeaningHint,
    sentence => l10n.vocabSentenceHint,
  };
}

class WordEditSheet extends ConsumerStatefulWidget {
  const WordEditSheet({
    super.key,
    required this.title,
    required this.initial,
    this.wordbookId,
    this.editingId,
    this.meaningOfWordId,
    this.editingMeaningId,
  });

  final String title;
  final WordDraft initial;
  final int? wordbookId;

  /// 저장된 단어를 고칠 때 그 단어 id.
  final int? editingId;

  /// 단어에 뜻을 더할 때 그 단어 id.
  final int? meaningOfWordId;

  /// 뜻 하나를 고칠 때 그 뜻 id.
  final int? editingMeaningId;

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

  /// 이 단어장에 같은 단어 · 같은 뜻이 이미 있어 저장하지 않았다.
  bool _alreadySaved = false;
  String? _savedBookName;

  /// 펼쳐진 부가 항목. 값이 이미 있는 항목은 처음부터 보인다.
  late final Set<_Option> _shown = {
    for (final o in _Option.values)
      if (_controllerOf(o).text.trim().isNotEmpty) o,
  };

  @override
  void initState() {
    super.initState();
    _bookId = widget.wordbookId;
  }

  TextEditingController _controllerOf(_Option option) => switch (option) {
    _Option.pronunciation => _pronunciation,
    _Option.partOfSpeech => _partOfSpeech,
    _Option.contextMeaning => _contextMeaning,
    _Option.sentence => _sentence,
  };

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

  bool get _meaningOnly =>
      widget.meaningOfWordId != null || widget.editingMeaningId != null;

  /// 단어장 선택 없이 이미 있는 단어를 고치거나 뜻을 더하는 모드.
  bool get _editing => widget.editingId != null || _meaningOnly;

  /// 이 모드에서 보여 줄 부가 항목.
  List<_Option> get _options => _meaningOnly
      ? const [_Option.contextMeaning, _Option.sentence]
      : _Option.values;

  bool _canSave(List<Wordbook> books) {
    if (_word.text.trim().isEmpty || _meaning.text.trim().isEmpty) return false;
    if (_editing) return !_busy;
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

  WordDraft _draft() => WordDraft(
    word: _word.text.trim(),
    meaning: _meaning.text.trim(),
    pronunciation: _blankToNull(_pronunciation),
    partOfSpeech: _blankToNull(_partOfSpeech),
    contextMeaning: _blankToNull(_contextMeaning),
    sentence: _blankToNull(_sentence),
    sourceLanguage: widget.initial.sourceLanguage,
    targetLanguage: widget.initial.targetLanguage,
  );

  Future<void> _save(List<Wordbook> books) async {
    if (!_canSave(books)) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    if (_editing) {
      final model = ref.read(wordEditViewModelProvider.notifier);
      final ok = widget.meaningOfWordId != null
          ? await model.addMeaning(widget.meaningOfWordId!, _draft())
          : widget.editingMeaningId != null
          ? await model.updateMeaning(widget.editingMeaningId!, _draft())
          : await model.update(widget.editingId!, _draft());
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _busy = false;
          _failed = true;
        });
        return;
      }
      setState(() => _savedBookName = '');
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) Navigator.of(context).pop('');
      return;
    }
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
    if (bookId != null && !await _confirmSameWord(bookId)) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    if (!mounted) return;
    final saved =
        bookId != null &&
        await ref
            .read(wordEditViewModelProvider.notifier)
            .save(bookId, _draft());
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

  /// 같은 단어가 이미 저장돼 있으면 저장 전에 알린다. 새 뜻이면 뜻을 더할지 묻고, 이 단어장에 같은 뜻까지 있으면 막는다.
  /// 계속 저장해도 되면 true.
  Future<bool> _confirmSameWord(int bookId) async {
    final l10n = AppLocalizations.of(context);
    final model = ref.read(wordEditViewModelProvider.notifier);
    final draft = _draft();
    final same = await model.findSame(draft);
    if (same == null || !mounted) return true;
    final meanings = same.meanings.isEmpty
        ? [same.meaning]
        : [for (final m in same.meanings) m.meaning];
    final sameMeaning = meanings.any(
      (m) => m.trim().toLowerCase() == draft.meaning.trim().toLowerCase(),
    );
    final inBook = (await model.wordbookIds(same.id)).contains(bookId);
    if (!mounted) return false;
    if (sameMeaning) {
      if (!inBook) return true;
      setState(() => _alreadySaved = true);
      return false;
    }
    final add = await showAppConfirm(
      context,
      title: l10n.vocabSameWordTitle,
      message: l10n.vocabSameWordMessage(draft.word, meanings.join(' · ')),
      confirmLabel: l10n.vocabSameWordAdd,
      cancelLabel: l10n.vocabCancel,
    );
    return add;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final books = ref.watch(wordbooksViewModelProvider).value ?? const [];
    // 단어장이 하나도 없으면 바로 새로 만든다.
    final creating = _creating(books);
    final selectedId = _effectiveBookId(books);

    Widget field(
      TextEditingController c,
      String hint, {
      int lines = 1,
      _Option? option,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 선택 항목은 위에 이름 줄을 두고 오른쪽 끝에 × (비우고 접어 추가하기 전으로).
          if (option != null)
            Padding(
              padding: const EdgeInsets.only(
                left: AppTokens.sectionTitleIndent,
                bottom: AppTokens.space4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option.label(l10n),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  AppIconButton(
                    icon: Symbols.close_rounded,
                    tooltip: l10n.vocabOptRemove,
                    plain: true,
                    size: 32,
                    onPressed: () => setState(() {
                      c.clear();
                      _shown.remove(option);
                    }),
                  ),
                ],
              ),
            ),
          AppTextField(
            controller: c,
            hint: hint,
            maxLines: lines,
            onChanged: (_) => setState(() {
              _failed = false;
              _alreadySaved = false;
            }),
          ),
        ],
      ),
    );

    final saved = _savedBookName;
    final media = MediaQuery.of(context);
    // 내용 길이에 따라 시트 높이가 들쭉날쭉하지 않게 화면 높이의 0.85로 고정한다 (키보드가 올라오면 그만큼 줄인다).
    final sheetHeight = (media.size.height * 0.85 - media.viewInsets.bottom)
        .clamp(280.0, media.size.height);
    return SafeArea(
      top: false,
      child: Padding(
        // 키보드가 올라오면 그만큼 시트를 밀어 올린다.
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: SizedBox(
          height: sheetHeight,
          child: saved != null
              ? Center(
                  child: Padding(
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
                          _editing
                              ? l10n.vocabEdited
                              : l10n.vocabSavedTo(saved),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppTokens.space4),
                        Text(
                          _word.text.trim(),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
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
                      if (!_meaningOnly) field(_word, l10n.vocabWordHint),
                      field(_meaning, l10n.vocabMeaningHint, lines: 3),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        alignment: Alignment.topCenter,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final o in _options)
                              if (_shown.contains(o))
                                field(
                                  _controllerOf(o),
                                  o.hint(l10n),
                                  lines: o == _Option.sentence ? 3 : 1,
                                  option: o,
                                ),
                            if (_options.any((o) => !_shown.contains(o)))
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppTokens.space12,
                                ),
                                child: Wrap(
                                  spacing: AppTokens.space8,
                                  runSpacing: AppTokens.space8,
                                  children: [
                                    for (final o in _options)
                                      if (!_shown.contains(o))
                                        AppAddChip(
                                          label: o.label(l10n),
                                          onTap: () =>
                                              setState(() => _shown.add(o)),
                                        ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!_editing) ...[
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
                      ],
                      if (_alreadySaved) ...[
                        const SizedBox(height: AppTokens.space12),
                        Text(
                          l10n.vocabAlreadyInBook,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                      if (_failed) ...[
                        const SizedBox(height: AppTokens.space12),
                        Text(
                          _editing
                              ? l10n.vocabEditFailed
                              : l10n.vocabSaveFailed,
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
      ),
    );
  }
}
