import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/vocabulary.dart';
import '../view_models/word_detail_view_model.dart';
import '../view_models/wordbooks_view_model.dart';
import '../widgets/vocabulary_sheets.dart';

/// 단어 상세 (X-05, AD-06): 뜻 · 발음 · 품사 · 문맥 뜻 · 문맥 예문 · 저장 날짜, 이동 · 삭제.
class WordDetailScreen extends ConsumerWidget {
  const WordDetailScreen({super.key, required this.wordId});

  final int wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(wordDetailViewModelProvider(wordId));

    return AppPage(
      title: l10n.vocabWordDetailTitle,
      children: switch (state) {
        AsyncData(:final value) when value != null => _content(
          context,
          ref,
          value,
        ),
        AsyncData() => [
          const SizedBox(height: AppTokens.sectionGap),
          Center(
            child: Text(l10n.vocabWordGone, style: theme.textTheme.bodySmall),
          ),
        ],
        _ => const [],
      },
    );
  }

  List<Widget> _content(BuildContext context, WidgetRef ref, VocabularyWord w) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final saved = DateFormat.yMMMd(locale).add_Hm().format(w.savedAt);
    final model = ref.read(wordDetailViewModelProvider(wordId).notifier);

    Widget block(String title, String text, {TextStyle? style}) => Padding(
      padding: const EdgeInsets.only(top: AppTokens.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title),
          const SizedBox(height: AppTokens.space4),
          SelectableText(text, style: style ?? theme.textTheme.bodyLarge),
        ],
      ),
    );

    return [
      const SizedBox(height: AppTokens.space8),
      SelectableText(w.word, style: theme.textTheme.headlineMedium),
      if (w.pronunciation != null || w.partOfSpeech != null) ...[
        const SizedBox(height: AppTokens.space8),
        Wrap(
          spacing: AppTokens.space8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (w.pronunciation != null)
              Text(
                w.pronunciation!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            if (w.partOfSpeech != null) AppBadge(label: w.partOfSpeech!),
          ],
        ),
      ],
      block(l10n.vocabMeaning, w.meaning, style: theme.textTheme.titleLarge),
      if (w.contextMeaning != null)
        block(l10n.vocabContextMeaning, w.contextMeaning!),
      if (w.sentence != null)
        block(
          l10n.vocabSentence,
          w.sentence!,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      if (w.sourceApp != null) block(l10n.vocabSourceApp, w.sourceApp!),
      block(l10n.vocabSavedAt, saved),
      const SizedBox(height: AppTokens.sectionGap + AppTokens.space8),
      AppButton.secondary(
        label: l10n.vocabMove,
        leading: const Icon(Symbols.drive_file_move_rounded, size: 20),
        onPressed: () => _move(context, ref, w),
      ),
      const SizedBox(height: AppTokens.space8),
      Center(
        child: AppButton.text(
          label: l10n.vocabDeleteWord,
          onPressed: () async {
            final confirmed = await showDeleteConfirmSheet(
              context,
              title: l10n.vocabDeleteWordTitle,
              body: w.word,
            );
            if (!confirmed) return;
            await model.delete();
            if (context.mounted) context.pop();
          },
        ),
      ),
    ];
  }

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    VocabularyWord word,
  ) async {
    final books = await ref.read(wordbooksViewModelProvider.future);
    if (!context.mounted) return;
    final target = await showWordbookPickerSheet(
      context,
      books: books,
      exceptId: word.wordbookId,
    );
    if (target == null) return;
    final model = ref.read(wordDetailViewModelProvider(wordId).notifier);
    await model.move(target);
    // 옮길 단어장에 같은 단어가 있어 합쳐졌으면 이 단어는 사라진다.
    if (context.mounted &&
        ref.read(wordDetailViewModelProvider(wordId)).value == null) {
      context.pop();
    }
  }
}
