import 'dart:async';

import 'package:poc/src/nearby/application/bloc/nearby_bloc.dart';
import 'package:poc/src/nearby/application/service/nearby.dart';

sealed class NearbyEvent {
  const NearbyEvent();

  const factory NearbyEvent.discover([Strategy strategy]) = NearbyEventDiscover;
  const factory NearbyEvent.advertise([Strategy strategy]) =
      NearbyEventAdvertise;
  const factory NearbyEvent.connect(String endpointId, String name) =
      NearbyEventConnect;
  const factory NearbyEvent.reject(String endpointId) = NearbyEventReject;
  const factory NearbyEvent.end() = NearbyEventEnd;

  FutureOr<void> handle(NearbyBloc bloc);
}

class NearbyEventDiscover extends NearbyEvent {
  const NearbyEventDiscover([this.strategy]);

  final Strategy? strategy;

  @override
  FutureOr<void> handle(NearbyBloc bloc) {
    bloc.discover(strategy ?? Strategy.pointToPoint);
  }
}

class NearbyEventAdvertise extends NearbyEvent {
  const NearbyEventAdvertise([this.strategy]);

  final Strategy? strategy;

  @override
  FutureOr<void> handle(NearbyBloc bloc) {
    bloc.advertise(strategy ?? Strategy.pointToPoint);
  }
}

class NearbyEventConnect extends NearbyEvent {
  const NearbyEventConnect(this.endpointId, this.userName);

  final String endpointId;
  final String userName;

  @override
  FutureOr<void> handle(NearbyBloc bloc) {
    bloc.requestConnection(endpointId, userName);
  }
}

class NearbyEventReject extends NearbyEvent {
  const NearbyEventReject(this.endpointId);

  final String endpointId;

  @override
  FutureOr<void> handle(NearbyBloc bloc) {
    bloc.rejectConnection(endpointId);
  }
}

class NearbyEventEnd extends NearbyEvent {
  const NearbyEventEnd();

  @override
  FutureOr<void> handle(NearbyBloc bloc) {
    bloc.end();
  }
}
