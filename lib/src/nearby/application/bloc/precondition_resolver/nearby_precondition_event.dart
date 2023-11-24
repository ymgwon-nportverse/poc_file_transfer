import 'dart:async';

import 'package:poc/src/nearby/application/bloc/precondition_resolver/nearby_precondition_bloc.dart';

sealed class NearbyPreconditionEvent {
  const factory NearbyPreconditionEvent.check() = NearbyPreconditionEventCheck;
  const factory NearbyPreconditionEvent.resolve() =
      NearbyPreconditionEventCheck;

  const NearbyPreconditionEvent();

  FutureOr<void> handle(NearbyPreconditionBloc bloc);
}

class NearbyPreconditionEventCheck extends NearbyPreconditionEvent {
  const NearbyPreconditionEventCheck();

  @override
  FutureOr<void> handle(NearbyPreconditionBloc bloc) {
    return bloc.checkPrecondition();
  }
}

class NearbyPreconditionEventResolve extends NearbyPreconditionEvent {
  const NearbyPreconditionEventResolve();

  @override
  FutureOr<void> handle(NearbyPreconditionBloc bloc) {
    return bloc.resolve();
  }
}
