import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/di.dart';
import '../../di.dart';
import '../../domain/usecases/model_usecases.dart';

part 'language_models_view_model.g.dart';

/// 언어 모델 화면 상태 (FL-05). 받은 모델은 네이티브(ML Kit)가 원본이고, 받는 중 · 실패는 화면이 기억한다.
/// ML Kit이 진행률을 주지 않아 받는 중은 "진행 중" 여부만 있다.
class LanguageModelsState {
  const LanguageModelsState({
    this.installed = const {},
    this.downloading = const {},
    this.failed = const {},
  });

  final Set<String> installed;
  final Set<String> downloading;

  /// 마지막 받기가 실패한 언어. 다시 받기를 시작하면 지워진다.
  final Set<String> failed;

  LanguageModelsState copyWith({
    Set<String>? installed,
    Set<String>? downloading,
    Set<String>? failed,
  }) => LanguageModelsState(
    installed: installed ?? this.installed,
    downloading: downloading ?? this.downloading,
    failed: failed ?? this.failed,
  );
}

@riverpod
class LanguageModelsViewModel extends _$LanguageModelsViewModel {
  @override
  Future<LanguageModelsState> build() async => LanguageModelsState(
    installed: await ref.watch(getDownloadedModelsProvider)(),
  );

  LanguageModelsState get _current =>
      state.value ?? const LanguageModelsState();

  /// 모델을 받는다. 이미 받는 중이거나 받은 언어면 무시한다.
  Future<void> download(String code) async {
    final now = _current;
    if (now.downloading.contains(code) || now.installed.contains(code)) return;
    state = AsyncData(
      now.copyWith(
        downloading: {...now.downloading, code},
        failed: {...now.failed}..remove(code),
      ),
    );

    var ok = true;
    try {
      final settings = await ref.read(getSettingsProvider)();
      await ref.read(downloadModelProvider)(
        DownloadModelParams(code, wifiOnly: settings.wifiOnlyModelDownload),
      );
    } catch (_) {
      ok = false;
    }

    final after = _current;
    state = AsyncData(
      after.copyWith(
        downloading: {...after.downloading}..remove(code),
        installed: ok ? {...after.installed, code} : null,
        failed: ok ? null : {...after.failed, code},
      ),
    );
  }

  Future<void> delete(String code) async {
    await ref.read(deleteModelProvider)(code);
    final now = _current;
    state = AsyncData(
      now.copyWith(installed: {...now.installed}..remove(code)),
    );
  }
}
