import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/l10n/labels.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/translator_settings.dart';
import '../view_models/ai_options_view_model.dart';
import '../view_models/api_key_pin_view_model.dart';
import '../view_models/api_key_view_model.dart';
import '../widgets/ai_options_section.dart';
import '../widgets/pin_sheets.dart';

/// AI 번역 설정 (S-06): 만 18세 확인(FL-09), 본인 Gemini · Groq API 키(NA-13), 말투 · 용어집(FL-11), 데이터 전송 고지.
/// 연령 확인 전에는 키 입력 · 옵션을 보여 주지 않는다.
/// 등록된 키가 있으면 입력창에 가려서 채워 두고, 보기 · 수정 · 삭제를 할 수 있다.
/// 키 접근 PIN을 켜 두면(NA-13) PIN을 넣기 전에는 키 영역 대신 잠금 카드만 보인다.
class AiSetupScreen extends ConsumerStatefulWidget {
  const AiSetupScreen({super.key});

  @override
  ConsumerState<AiSetupScreen> createState() => _AiSetupScreenState();
}

/// 엔진별 키 발급 페이지.
final _keyUrls = {
  EngineType.gemini: Uri.parse('https://aistudio.google.com/apikey'),
  EngineType.groq: Uri.parse('https://console.groq.com/keys'),
};

class _AiSetupScreenState extends ConsumerState<AiSetupScreen> {
  final _controller = TextEditingController();

  /// 지금 키를 다루는 AI 엔진 (Gemini · Groq 탭).
  EngineType _engine = EngineType.gemini;
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
    await ref
        .read(apiKeyViewModelProvider(_engine).notifier)
        .save(_controller.text);
    if (!mounted) return;
    setState(() {});
    AppToast.show(context, AppLocalizations.of(context).apiKeySavedToast);
  }

  Future<void> _remove() async {
    await ref.read(apiKeyViewModelProvider(_engine).notifier).clear();
    _controller.clear();
    if (!mounted) return;
    setState(() => _revealed = false);
    AppToast.show(context, AppLocalizations.of(context).apiKeyRemovedToast);
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _testMessage = null;
    });
    final l10n = AppLocalizations.of(context);
    final reason = await ref
        .read(apiKeyViewModelProvider(_engine).notifier)
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

  ApiKeyPinViewModel get _pin => ref.read(apiKeyPinViewModelProvider.notifier);

  Future<void> _unlock() {
    final l10n = AppLocalizations.of(context);
    return showPinSheet(
      context,
      title: l10n.pinEnterTitle,
      body: l10n.pinEnterBody,
      validate: (pin) async => await _pin.unlock(pin) ? null : l10n.pinWrong,
    );
  }

  /// 새 PIN을 두 번 받아 돌려준다. 취소하면 null.
  Future<String?> _askNewPin() async {
    final l10n = AppLocalizations.of(context);
    final first = await showPinSheet(
      context,
      title: l10n.pinNewTitle,
      body: l10n.pinNewBody,
    );
    if (first == null || !mounted) return null;
    return showPinSheet(
      context,
      title: l10n.pinConfirmTitle,
      validate: (pin) async => pin == first ? null : l10n.pinMismatch,
    );
  }

  Future<void> _enablePin() async {
    final pin = await _askNewPin();
    if (pin != null) await _pin.enable(pin);
  }

  Future<void> _disablePin() {
    final l10n = AppLocalizations.of(context);
    return showPinSheet(
      context,
      title: l10n.pinCurrentTitle,
      body: l10n.pinEnterBody,
      validate: (pin) async => await _pin.disable(pin) ? null : l10n.pinWrong,
    );
  }

  Future<void> _changePin() async {
    final l10n = AppLocalizations.of(context);
    final current = await showPinSheet(
      context,
      title: l10n.pinCurrentTitle,
      body: l10n.pinEnterBody,
      validate: (pin) async => await _pin.verify(pin) ? null : l10n.pinWrong,
    );
    if (current == null || !mounted) return;
    final next = await _askNewPin();
    if (next != null) await _pin.change(current, next);
  }

  Future<void> _forgotPin() async {
    if (!await showPinResetSheet(context)) return;
    await _pin.reset();
    _controller.clear();
    if (mounted) setState(() => _filled = false);
  }

  Future<void> _openKeyPage() =>
      launchUrl(_keyUrls[_engine]!, mode: LaunchMode.externalApplication);

  void _selectEngine(EngineType engine) {
    if (engine == _engine) return;
    setState(() {
      _engine = engine;
      _controller.clear();
      _filled = false;
      _revealed = false;
      _testMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final options = ref.watch(aiOptionsViewModelProvider).value;
    final ageConfirmed = options?.ageConfirmed ?? false;
    final saved = ref.watch(apiKeyViewModelProvider(_engine)).value;
    final pinState = ref.watch(apiKeyPinViewModelProvider).value;
    final pinEnabled = pinState?.enabled ?? false;
    // PIN 상태를 읽기 전에도 잠긴 것처럼 둬서 키가 잠깐 비치지 않게 한다.
    final locked = pinState == null || (pinState.enabled && !pinState.unlocked);
    if (!_filled && !locked && saved != null) {
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
                  Text(
                    l10n.apiKeyIntroFor(_engine),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  AiAgeCard(confirmed: ageConfirmed),
                  const SizedBox(height: 12),
                  const AiNoticeCard(),
                  const SizedBox(height: 24),
                  if (ageConfirmed && locked)
                    _LockedCard(onUnlock: _unlock, onForgot: _forgotPin)
                  else if (ageConfirmed) ...[
                    AppSegmented<EngineType>(
                      values: const [EngineType.gemini, EngineType.groq],
                      selected: _engine,
                      label: l10n.engineBrand,
                      onChanged: _selectEngine,
                    ),
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
                      hint: l10n.apiKeyHintFor(_engine),
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
                      AppNotice(
                        _testMessage!,
                        kind: _testOk
                            ? AppMessageKind.success
                            : AppMessageKind.error,
                      ),
                    ],
                    const SizedBox(height: 8),
                    AppButton(
                      label: l10n.apiKeySave,
                      expand: true,
                      onPressed: text.isEmpty || text == saved ? null : _save,
                    ),
                    AppButton.text(
                      label: l10n.apiKeyGetFor(_engine),
                      onPressed: _openKeyPage,
                    ),
                    if (saved != null) ...[
                      const SizedBox(height: 8),
                      AppButton.secondary(
                        label: l10n.apiKeyRemove,
                        expand: true,
                        onPressed: _remove,
                      ),
                    ],
                    const SizedBox(height: 24),
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTokens.cardListPaddingV,
                      ),
                      child: Column(
                        children: [
                          AppListTile(
                            icon: Symbols.lock_rounded,
                            title: l10n.apiKeyPinTitle,
                            subtitle: l10n.apiKeyPinDetail,
                            trailing: AppSwitch(
                              value: pinEnabled,
                              onChanged: (on) =>
                                  on ? _enablePin() : _disablePin(),
                            ),
                          ),
                          if (pinEnabled)
                            AppListTile(
                              title: l10n.apiKeyPinChange,
                              onTap: _changePin,
                            ),
                        ],
                      ),
                    ),
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

/// PIN이 켜져 있고 아직 풀지 않았을 때 키 영역 대신 보이는 카드.
class _LockedCard extends StatelessWidget {
  const _LockedCard({required this.onUnlock, required this.onForgot});

  final VoidCallback onUnlock;
  final VoidCallback onForgot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.lock_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.apiKeyLockedTitle,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.apiKeyLockedBody,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: l10n.apiKeyUnlock,
            expand: true,
            onPressed: onUnlock,
          ),
          Align(
            alignment: Alignment.center,
            child: AppButton.text(
              label: l10n.apiKeyPinForgot,
              onPressed: onForgot,
            ),
          ),
        ],
      ),
    );
  }
}
