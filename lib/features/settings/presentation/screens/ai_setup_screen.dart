import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_models/api_key_view_model.dart';

/// AI 번역 설정 (NA-13): 본인 Gemini API 키를 붙여 넣는다.
/// 등록된 키가 있으면 입력창에 가려서 채워 두고, 보기 · 수정 · 삭제를 할 수 있다.
class AiSetupScreen extends ConsumerStatefulWidget {
  const AiSetupScreen({super.key});

  @override
  ConsumerState<AiSetupScreen> createState() => _AiSetupScreenState();
}

class _AiSetupScreenState extends ConsumerState<AiSetupScreen> {
  final _controller = TextEditingController();
  bool _revealed = false;
  bool _filled = false;

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
                  const SizedBox(height: 8),
                  AppButton(
                    label: l10n.apiKeySave,
                    expand: true,
                    onPressed: text.isEmpty || text == saved ? null : _save,
                  ),
                  if (saved != null) ...[
                    const SizedBox(height: 8),
                    AppButton.secondary(
                      label: l10n.apiKeyRemove,
                      expand: true,
                      onPressed: _remove,
                    ),
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
