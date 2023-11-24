sealed class NearbyPreconditionState {
  const NearbyPreconditionState();

  const factory NearbyPreconditionState.none() = NearbyPreconditionStateNone;
  const factory NearbyPreconditionState.satisfied() =
      NearbyPreconditionStateSatisfied;
  const factory NearbyPreconditionState.unsatisfied() =
      NearbyPreconditionStateUnsatisfied;
}

class NearbyPreconditionStateNone extends NearbyPreconditionState {
  const NearbyPreconditionStateNone();
}

class NearbyPreconditionStateSatisfied extends NearbyPreconditionState {
  const NearbyPreconditionStateSatisfied();
}

class NearbyPreconditionStateUnsatisfied extends NearbyPreconditionState {
  const NearbyPreconditionStateUnsatisfied();
}
