import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/app_info.dart';

part 'app_info_view_model.g.dart';

/// 정보 화면의 앱 버전 (FL-14).
@riverpod
Future<AppInfo> appInfo(Ref ref) => ref.watch(getAppInfoProvider)();
