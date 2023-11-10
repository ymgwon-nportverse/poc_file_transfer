sealed class NearbyState {
  const NearbyState();

  const factory NearbyState.none([String userName]) = NearbyStateNone;
  const factory NearbyState.advertising(String userName) =
      NearbyStateAdvertising;
  const factory NearbyState.discovering(
      String userName, List<NearbyDevice> devices) = NearbyStateDiscovering;
  const factory NearbyState.connecting() = NearbyStateConnecting;
  const factory NearbyState.connected() = NearbyStateConnected;
  const factory NearbyState.failed(String message) = NearbyStateFailed;
}

class NearbyStateNone extends NearbyState {
  const NearbyStateNone([this.userName]);

  final String? userName;
}

class NearbyStateAdvertising extends NearbyState {
  const NearbyStateAdvertising(this.userName);

  final String userName;
}

class NearbyStateDiscovering extends NearbyState {
  const NearbyStateDiscovering(this.userName, this.devices);

  final String userName;
  final List<NearbyDevice> devices;
}

class NearbyStateConnecting extends NearbyState {
  const NearbyStateConnecting();
}

class NearbyStateConnected extends NearbyState {
  const NearbyStateConnected();
}

class NearbyStateFailed extends NearbyState {
  const NearbyStateFailed(this.message);

  final String message;
}

class NearbyDevice {
  const NearbyDevice({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  bool operator ==(covariant NearbyDevice other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
