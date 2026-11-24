import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/vocabulary.dart';
import '../view_models/word_detail_view_model.dart';
import '../view_models/wordbooks_view_model.dart';
import '../widgets/vocabulary_sheets.dart';
import '../widgets/word_edit_sheet.dart';

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
      ..._meaningBlocks(context, ref, w),
      const SizedBox(height: AppTokens.space12),
      AppButton.secondary(
        label: l10n.vocabAddMeaning,
        leading: const Icon(LucideIcons.plus, size: 20),
        onPressed: () async {
          final added = await showWordEditSheet(
            context,
            title: l10n.vocabAddMeaningTitle,
            initial: WordDraft(
              word: w.word,
              meaning: '',
              sourceLanguage: w.sourceLanguage,
              targetLanguage: w.targetLanguage,
            ),
            meaningOfWordId: w.id,
          );
          if (added != null) await model.reload();
        },
      ),
      ..._progressBlock(context, ref),
      block(l10n.vocabSavedAt, saved),
      const SizedBox(height: AppTokens.sectionGap + AppTokens.space8),
      AppButton.secondary(
        label: l10n.vocabEditWord,
        leading: const Icon(LucideIcons.pencil, size: 20),
        onPressed: () async {
          final edited = await showWordEditSheet(
            context,
            title: l10n.vocabEditWord,
            initial: w.toDraft(),
            editingId: w.id,
          );
          if (edited != null) await model.reload();
        },
      ),
      const SizedBox(height: AppTokens.space8),
      AppButton.secondary(
        label: l10n.vocabAddTo,
        leading: const Icon(LucideIcons.libraryBig, size: 20),
        onPressed: () => _addTo(context, ref, w),
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

  /// 뜻마다 한 덩어리: 뜻 · 문맥 뜻 · 예문, 고치기 · 지우기 (마지막 뜻은 지울 수 없다).
  List<Widget> _meaningBlocks(
    BuildContext context,
    WidgetRef ref,
    VocabularyWord w,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final model = ref.read(wordDetailViewModelProvider(wordId).notifier);
    final meanings = w.meanings.isEmpty
        ? [
            WordMeaning(
              id: -w.id,
              meaning: w.meaning,
              contextMeaning: w.contextMeaning,
              sentence: w.sentence,
              sourceApp: w.sourceApp,
            ),
          ]
        : w.meanings;
    return [
      for (var i = 0; i < meanings.length; i++)
        Padding(
          padding: const EdgeInsets.only(top: AppTokens.sectionGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SectionTitle(
                      meanings.length == 1
                          ? l10n.vocabMeaning
                          : l10n.vocabMeaningN(i + 1),
                    ),
                  ),
                  AppIconButton(
                    icon: LucideIcons.pencil,
                    tooltip: l10n.vocabEditWord,
                    plain: true,
                    size: 32,
                    onPressed: () async {
                      final m = meanings[i];
                      final edited = await showWordEditSheet(
                        context,
                        title: l10n.vocabEditMeaningTitle,
                        initial: WordDraft(
                          word: w.word,
                          meaning: m.meaning,
                          contextMeaning: m.contextMeaning,
                          sentence: m.sentence,
                          sourceLanguage: w.sourceLanguage,
                          targetLanguage: w.targetLanguage,
                        ),
                        editingMeaningId: m.id,
                      );
                      if (edited != null) await model.reload();
                    },
                  ),
                  if (meanings.length > 1)
                    AppIconButton(
                      icon: LucideIcons.trash2,
                      tooltip: l10n.vocabDeleteWord,
                      plain: true,
                      size: 32,
                      onPressed: () async {
                        final confirmed = await showDeleteConfirmSheet(
                          context,
                          title: l10n.vocabMeaningDeleteTitle,
                          body: meanings[i].meaning,
                        );
                        if (confirmed) {
                          await model.deleteMeaning(meanings[i].id);
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppTokens.space4),
              SelectableText(
                meanings[i].meaning,
                style: theme.textTheme.titleLarge,
              ),
              if (meanings[i].contextMeaning != null) ...[
                const SizedBox(height: AppTokens.space8),
                SelectableText(
                  meanings[i].contextMeaning!,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
              if (meanings[i].sentence != null) ...[
                const SizedBox(height: AppTokens.space8),
                SelectableText(
                  meanings[i].sentence!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
              if (meanings[i].sourceApp != null) ...[
                const SizedBox(height: AppTokens.space4),
                Text(
                  meanings[i].sourceApp!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
    ];
  }

  /// 들어 있는 단어장마다의 진도 (외움 · 정답률).
  List<Widget> _progressBlock(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final progress = ref.watch(wordProgressProvider(wordId)).value ?? const [];
    final books = ref.watch(wordbooksViewModelProvider).value ?? const [];
    if (progress.isEmpty) return const [];
    return [
      const SizedBox(height: AppTokens.sectionGap),
      SectionTitle(l10n.vocabProgressByBook),
      const SizedBox(height: AppTokens.space8),
      if (progress.length > 1 && progress.any((p) => p.attemptCount > 0))
        Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.space8),
          child: Text(() {
            final correct = progress.fold(0, (a, p) => a + p.correctCount);
            final attempt = progress.fold(0, (a, p) => a + p.attemptCount);
            return l10n.vocabOverallAccuracy(
              (correct * 100 / attempt).round(),
              correct,
              attempt,
            );
          }(), style: theme.textTheme.bodySmall),
        ),
      for (final p in progress)
        Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.space8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  books.where((b) => b.id == p.wordbookId).firstOrNull?.name ??
                      '',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              if (p.accuracy != null) ...[
                Text(
                  l10n.vocabAccuracy((p.accuracy! * 100).round()),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: AppTokens.space8),
              ],
              AppBadge(
                label: p.memorized
                    ? l10n.vocabMemorizedShort
                    : l10n.vocabNotMemorizedShort,
              ),
            ],
          ),
        ),
    ];
  }

  Future<void> _addTo(
    BuildContext context,
    WidgetRef ref,
    VocabularyWord word,
  ) async {
    final l10n = AppLocalizations.of(context);
    final model = ref.read(wordDetailViewModelProvider(wordId).notifier);
    final members = await model.wordbookIds();
    final books = await ref.read(wordbooksViewModelProvider.future);
    if (!context.mounted) return;
    final target = await showWordbookPickerSheet(
      context,
      books: [
        for (final book in books)
          if (!members.contains(book.id)) book,
      ],
      title: l10n.vocabAddToTitle,
    );
    if (target == null || !context.mounted) return;
    final added = await model.addTo(target);
    if (!context.mounted) return;
    AppToast.show(
      context,
      added ? l10n.vocabAddedToast : l10n.vocabAddDuplicate,
    );
  }
}
