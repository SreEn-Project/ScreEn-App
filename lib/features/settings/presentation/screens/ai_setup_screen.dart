import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_models/ai_options_view_model.dart';
import '../view_models/api_key_view_model.dart';
import '../widgets/ai_options_section.dart';

/// AI 번역 설정 (S-06): 만 18세 확인(FL-09), 본인 Gemini API 키(NA-13), 말투 · 용어집(FL-11), 데이터 전송 고지.
/// 연령 확인 전에는 키 입력 · 옵션을 보여 주지 않는다.
/// 등록된 키가 있으면 입력창에 가려서 채워 두고, 보기 · 수정 · 삭제를 할 수 있다.
class AiSetupScreen extends ConsumerStatefulWidget {
  const AiSetupScreen({super.key});

  @override
  ConsumerState<AiSetupScreen> createState() => _AiSetupScreenState();
}

final _studioUrl = Uri.parse('https://aistudio.google.com/apikey');

class _AiSetupScreenState extends ConsumerState<AiSetupScreen> {
  final _controller = TextEditingController();
  bool _revealed = false;
  bool _filled = false;
  bool _testing = false;
  String? _testMessage;
  bool _testOk = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(apiKeyViewModelProvider.notifier).save(_controller.text);
    if (mounted) setState(() {});
  }

  Future<void> _remove() async {
    await ref.read(apiKeyViewModelProvider.notifier).clear();
    _controller.clear();
    if (mounted) setState(() => _revealed = false);
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _testMessage = null;
    });
    final l10n = AppLocalizations.of(context);
    final reason = await ref
        .read(apiKeyViewModelProvider.notifier)
        .test(_controller.text);
    if (!mounted) return;
    setState(() {
      _testing = false;
      _testOk = reason == null;
      _testMessage = reason == null
          ? l10n.apiKeyTestOk
          : l10n.apiKeyTestFailed(reason);
    });
  }

  Future<void> _openStudio() =>
      launchUrl(_studioUrl, mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final options = ref.watch(aiOptionsViewModelProvider).value;
    final ageConfirmed = options?.ageConfirmed ?? false;
    final saved = ref.watch(apiKeyViewModelProvider).value;
    if (!_filled && saved != null) {
      _controller.text = saved;
      _filled = true;
    }
    final text = _controller.text.trim();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: l10n.apiKeyTitle),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppTokens.pagePadding),
                children: [
                  Text(l10n.apiKeyIntro, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  AiAgeCard(confirmed: ageConfirmed),
                  const SizedBox(height: 12),
                  const AiNoticeCard(),
                  const SizedBox(height: 24),
                  if (ageConfirmed) ...[
                    if (saved != null) ...[
                      Text(
                        l10n.apiKeyRegistered,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    AppTextField(
                      controller: _controller,
                      hint: l10n.apiKeyHint,
                      obscure: !_revealed,
                      onChanged: (_) => setState(() {}),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppButton.text(
                        label: _revealed ? l10n.apiKeyHide : l10n.apiKeyShow,
                        onPressed: () => setState(() => _revealed = !_revealed),
                      ),
                    ),
                    AppButton.secondary(
                      label: l10n.apiKeyTest,
                      expand: true,
                      onPressed: text.isEmpty || _testing ? null : _test,
                    ),
                    if (_testMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _testMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _testOk
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    AppButton(
                      label: l10n.apiKeySave,
                      expand: true,
                      onPressed: text.isEmpty || text == saved ? null : _save,
                    ),
                    AppButton.text(
                      label: l10n.apiKeyGet,
                      onPressed: _openStudio,
                    ),
                    if (saved != null) ...[
                      const SizedBox(height: 8),
                      AppButton.secondary(
                        label: l10n.apiKeyRemove,
                        expand: true,
                        onPressed: _remove,
                      ),
                    ],
                    const SizedBox(height: 32),
                    AiOptionsSection(options: options!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
