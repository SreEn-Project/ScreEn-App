import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_models/api_key_view_model.dart';

/// AI 번역 설정 (NA-13): 본인 Gemini API 키를 붙여 넣는다. 키는 기기에만 저장되고 화면에 다시 나오지 않는다.
class AiSetupScreen extends ConsumerStatefulWidget {
  const AiSetupScreen({super.key});

  @override
  ConsumerState<AiSetupScreen> createState() => _AiSetupScreenState();
}

class _AiSetupScreenState extends ConsumerState<AiSetupScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await ref
        .read(apiKeyViewModelProvider.notifier)
        .save(_controller.text);
    if (saved) _controller.clear();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasKey = ref.watch(apiKeyViewModelProvider).value ?? false;
    final viewModel = ref.read(apiKeyViewModelProvider.notifier);

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
                  if (hasKey) ...[
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
                    obscure: true,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: l10n.apiKeySave,
                    expand: true,
                    onPressed: _controller.text.trim().isEmpty ? null : _save,
                  ),
                  if (hasKey) ...[
                    const SizedBox(height: 8),
                    AppButton.secondary(
                      label: l10n.apiKeyRemove,
                      expand: true,
                      onPressed: viewModel.clear,
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
