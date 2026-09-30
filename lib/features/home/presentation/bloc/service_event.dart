part of 'service_bloc.dart';

sealed class ServiceEvent {
  const ServiceEvent();
}

/// 처음 한 번: 현재 상태를 읽고 네이티브 상태 변화를 구독한다.
final class ServiceSubscriptionRequested extends ServiceEvent {
  const ServiceSubscriptionRequested();
}

/// 시작/중지 버튼.
final class ServiceToggled extends ServiceEvent {
  const ServiceToggled();
}
