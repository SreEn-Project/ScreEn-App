import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../language/presentation/language_list.dart';

/// 온보딩 (S-01, FL-01): 소개 3장 + 대상 언어 선택 → 권한 안내.
/// UI 퍼블리싱 단계라 선택한 언어 · 완료 여부는 아직 저장하지 않는다.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 4;

  final _controller = PageController();
  int _page = 0;
  String _targetLanguage = 'ko';

  bool get _isLanguagePage => _page == _pageCount - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLanguagePage) {
      context.go(AppRoutes.permission);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _skipToLanguage() => _controller.animateToPage(
    _pageCount - 1,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Align(
                alignment: Alignment.centerRight,
                child: _isLanguagePage
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppButton.text(
                          onPressed: _skipToLanguage,
                          label: l10n.commonSkip,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  _IntroPage(
                    icon: Symbols.translate_rounded,
                    title: l10n.onboardingIntro1Title,
                    highlight: l10n.onboardingIntro1Highlight,
                    body: l10n.onboardingIntro1Body,
                  ),
                  _IntroPage(
                    icon: Symbols.touch_app_rounded,
                    title: l10n.onboardingIntro2Title,
                    highlight: l10n.onboardingIntro2Highlight,
                    body: l10n.onboardingIntro2Body,
                  ),
                  _IntroPage(
                    icon: Symbols.shield_lock_rounded,
                    title: l10n.onboardingIntro3Title,
                    highlight: l10n.onboardingIntro3Highlight,
                    body: l10n.onboardingIntro3Body,
                  ),
                  _LanguagePage(
                    selectedCode: _targetLanguage,
                    onSelected: (code) =>
                        setState(() => _targetLanguage = code),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.pagePadding,
                16,
                AppTokens.pagePadding,
                24,
              ),
              child: Column(
                children: [
                  _PageDots(count: _pageCount, current: _page),
                  const SizedBox(height: 20),
                  AppButton.secondary(
                    label: _isLanguagePage
                        ? l10n.onboardingStart
                        : l10n.commonNext,
                    trailingIcon: Symbols.arrow_forward_rounded,
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.icon,
    required this.title,
    required this.highlight,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String highlight;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          IconBadge(icon: icon, size: 88),
          const SizedBox(height: 32),
          AccentTitle(
            text: title,
            highlight: highlight,
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _LanguagePage extends StatelessWidget {
  const _LanguagePage({required this.selectedCode, required this.onSelected});

  final String selectedCode;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.pagePadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccentTitle(
                text: l10n.onboardingLanguageTitle,
                highlight: l10n.onboardingLanguageHighlight,
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.onboardingLanguageBody,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LanguageList(
            selectedCode: selectedCode,
            onSelected: (language) => onSelected(language.code),
          ),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 20 : 6,
            height: 6,
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: i == current ? colors.primary : colors.outline,
            ),
          ),
      ],
    );
  }
}
