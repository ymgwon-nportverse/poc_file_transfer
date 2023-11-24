import 'dart:async';
import 'dart:typed_data';

import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_bloc.dart';
import 'package:poc/src/nearby/application/service/nearby.dart';

/// 송신자 입장에서의 이벤트들
sealed class NearbySenderEvent {
  /// 수신자 검색 이벤트
  const factory NearbySenderEvent.search([Strategy strategy]) =
      NearbySenderEventDiscover;

  /// 수신자 검색 중단 이벤트
  const factory NearbySenderEvent.stopSearching() =
      NearbySenderEventDiscoverStop;

  /// 수신자에게 연결 의사 물어보는 이벤트
  const factory NearbySenderEvent.requestConnection(
          String endpointId, String name, String dataName) =
      NearbySenderEventConnect;

  /// 수신자에게 거절당했을 때 원래 상태로 되돌리는 이벤트
  const factory NearbySenderEvent.recoverFromRejection([Strategy strategy]) =
      NearbySenderEventRejectRecover;

  /// 수신자에게 데이터 전달하는 이벤트
  const factory NearbySenderEvent.sendPayload(
      [Uint8List data, String filePath]) = NearbySenderEventSend;

  /// 모든 연결 해제 이벤트
  const factory NearbySenderEvent.stopAll() = NearbySenderEventStopAll;

  const NearbySenderEvent();

  FutureOr<void> handle(NearbySenderBloc bloc);
}

class NearbySenderEventDiscover extends NearbySenderEvent {
  const NearbySenderEventDiscover([this.strategy]);

  final Strategy? strategy;

  @override
  FutureOr<void> handle(NearbySenderBloc bloc) {
    bloc.discover(strategy ?? Strategy.pointToPoint);
  }
}

class NearbySenderEventDiscoverStop extends NearbySenderEvent {
  const NearbySenderEventDiscoverStop();

  @override
  FutureOr<void> handle(NearbySenderBloc bloc) {
    bloc.stopDiscovery();
  }
}

class NearbySenderEventConnect extends NearbySenderEvent {
  const NearbySenderEventConnect(this.endpointId, this.userName, this.dataName);

  final String endpointId;
  final String userName;
  // 다음 데이터 타입은 바뀔 가능성이 높음
  final String dataName;

  @override
  FutureOr<void> handle(NearbySenderBloc bloc) {
    bloc.requestConnection(endpointId, userName, dataName);
  }
}

class NearbySenderEventRejectRecover extends NearbySenderEvent {
  const NearbySenderEventRejectRecover([this.strategy]);

  final Strategy? strategy;

  @override
  FutureOr<void> handle(NearbySenderBloc bloc) {
    bloc.stopDiscovery();
    bloc.discover(strategy ?? Strategy.pointToPoint);
  }
}

class NearbySenderEventSend extends NearbySenderEvent {
  const NearbySenderEventSend([this.bytes, this.filePath]);

  final Uint8List? bytes;
  final String? filePath;

  @override
  FutureOr<void> handle(NearbySenderBloc bloc) {
    bloc.send(bytes, filePath);
  }
}

class NearbySenderEventStopAll extends NearbySenderEvent {
  const NearbySenderEventStopAll();

  @override
  FutureOr<void> handle(NearbySenderBloc bloc) {
    bloc.stopAll();
  }
}
