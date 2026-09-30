import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injector.dart';
import '../features/home/presentation/bloc/service_bloc.dart';
import '../features/permission/presentation/bloc/permission_cubit.dart';

/// 여러 화면이 함께 보거나 탭을 오가도 유지해야 하는 Bloc · Cubit (D-023).
/// 처음 읽힐 때 만들어진다 (lazy). 권한: 권한 안내 · 홈 시작 버튼. 서비스: 홈.
class AppBlocProviders extends StatelessWidget {
  const AppBlocProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<PermissionCubit>()..refresh()),
        BlocProvider(
          create: (_) =>
              getIt<ServiceBloc>()..add(const ServiceSubscriptionRequested()),
        ),
      ],
      child: child,
    );
  }
}
