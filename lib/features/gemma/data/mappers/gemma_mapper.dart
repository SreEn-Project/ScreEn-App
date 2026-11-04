import '../../../../core/bridge/translator_api.g.dart' as pigeon;
import '../../domain/entities/gemma_status.dart';

extension GemmaStatusMapper on pigeon.GemmaStatus {
  GemmaStatus toEntity() => GemmaStatus(
    state: switch (state) {
      pigeon.GemmaState.notDownloaded => GemmaModelState.notDownloaded,
      pigeon.GemmaState.downloading => GemmaModelState.downloading,
      pigeon.GemmaState.ready => GemmaModelState.ready,
    },
    downloadedBytes: downloadedBytes,
    totalBytes: totalBytes,
    failure: switch (error) {
      pigeon.GemmaError.none => GemmaFailure.none,
      pigeon.GemmaError.tokenRequired => GemmaFailure.tokenRequired,
      pigeon.GemmaError.licenseNotAccepted => GemmaFailure.licenseNotAccepted,
      pigeon.GemmaError.network => GemmaFailure.network,
      pigeon.GemmaError.notEnoughSpace => GemmaFailure.notEnoughSpace,
      pigeon.GemmaError.unknown => GemmaFailure.unknown,
    },
    hasToken: hasToken,
    deviceRamMb: deviceRamMb,
    minRamMb: minRamMb,
  );
}
