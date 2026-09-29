import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/supported_language.dart';

/// 검색 가능한 대상 언어 목록 (FL-04). 온보딩 · 설정에서 같이 쓴다.
class LanguageList extends StatefulWidget {
  const LanguageList({
    super.key,
    required this.selectedCode,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppTokens.pagePadding,
    ),
  });

  final String selectedCode;
  final ValueChanged<SupportedLanguage> onSelected;
  final EdgeInsets padding;

  @override
  State<LanguageList> createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final languages = SupportedLanguage.all
        .where((l) => l.matches(_query))
        .toList();

    return Column(
      children: [
        Padding(
          padding: widget.padding,
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: l10n.languageSearchHint,
              prefixIcon: const Icon(Symbols.search_rounded),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: languages.isEmpty
              ? Center(
                  child: Text(
                    l10n.languageEmpty,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              : ListView.separated(
                  padding: widget.padding.copyWith(top: 4, bottom: 24),
                  itemCount: languages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    return _LanguageTile(
                      language: language,
                      name: language.displayName(locale),
                      selected: language.code == widget.selectedCode,
                      onTap: () => widget.onSelected(language),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final SupportedLanguage language;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard(
      onTap: onTap,
      color: selected ? colors.primaryContainer : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  language.ocrSupported
                      ? language.nativeName
                      : '${language.nativeName} · ${l10n.languageOcrUnsupported}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (selected)
            Icon(Symbols.check_circle_rounded, color: colors.primary),
        ],
      ),
    );
  }
}
