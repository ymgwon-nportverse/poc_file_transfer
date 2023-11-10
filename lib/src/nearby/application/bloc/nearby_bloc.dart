import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/nearby/application/bloc/nearby_event.dart';
import 'package:poc/src/nearby/application/bloc/nearby_state.dart';
import 'package:poc/src/nearby/application/service/nearby.dart';
import 'package:poc/src/nearby/application/service/nearby_precondition_checker.dart';
import 'package:poc/src/nearby/application/service/user_info_fetcher.dart';

class NearbyBloc extends StateNotifier<NearbyState> {
  NearbyBloc(
    this._nearby,
    this._checker,
    this._infoFetcher,
  ) : super(const NearbyState.none()) {
    _loadUserName();
  }

  final Nearby _nearby;
  final NearbyPreconditionChecker _checker;
  final UserInfoFetcher _infoFetcher;

  late String _userName = 'unidentified';

  void mapEventToState(NearbyEvent event) {
    event.handle(this);
  }

  Future<void> discover(Strategy strategy) async {
    // step 1: 사전 조건(e.g. bluetooth 켜져있는지, 권한 설정 되어 있는지) 확인
    final isPreconditionSatisfied = await _checker.isSatisfied();
    if (!isPreconditionSatisfied) {
      // result 1: 조건 만족하지 않을 때는 그에 맞게 상태 변경
      state = const NearbyState.failed('precondition unsatisfied');
      _checker.satisfy();
      return;
    }

    _nearby
        .startDiscovery(
      _userName,
      strategy,
      onEndpointFound: _onEndpointFound,
      onEndpointLost: _onEndpointLost,
    )
        .onError(
      (_, __) {
        state = const NearbyState.failed('already discovering');
      },
    );
    // result 2: 찾고 있는 것으로 상태 변경
    state = NearbyState.discovering(_userName, []);
  }

  Future<void> advertise(Strategy strategy) async {
    // step 1: 사전 조건(e.g. bluetooth 켜져있는지, 권한 설정 되어 있는지) 확인
    final isPreconditionSatisfied = await _checker.isSatisfied();
    if (!isPreconditionSatisfied) {
      // result 1: 조건 만족하지 않을 때는 그에 맞게 상태 변경
      state = const NearbyState.failed('precondition unsatisfied');
      _checker.satisfy();
      return;
    }

    _nearby
        .startAdvertising(
      _userName,
      strategy,
      onBandwidthChanged: _onBandwidthChanged,
      onConnectionInitiated: _onConnectionInitiatedAdvertiser,
      onConnectionResult: _onConnectionResult,
      onDisconnected: _onDisconnected,
    )
        .onError(
      (_, __) {
        state = const NearbyState.failed('already advertising');
      },
    );
    // result 2: 홍보 중으로 상태 변경
    state = NearbyState.advertising(_userName);
  }

  Future<void> requestConnection(String endpointId, String userName) async {
    _nearby.requestConnection(
      userName,
      endpointId,
      onBandwidthChanged: _onBandwidthChanged,
      onConnectionInitiated: _onConnectionInitiatedDiscoverer,
      onConnectionResult: _onConnectionResult,
      onDisconnected: _onDisconnected,
    );
    state = const NearbyState.connecting();
  }

  Future<void> rejectConnection(String endpointId) async {
    _nearby.rejectConnection(endpointId);
  }

  void end() {
    _nearby.stopAllEndpoints();
    _nearby.stopAdvertising();
    _nearby.stopDiscovery();

    state = NearbyState.none(_userName);
  }

  /// User 정보를 이후에 계속 사용하기 위해 받아옴
  Future<void> _loadUserName() async {
    _userName = await _infoFetcher.info;
    state = NearbyState.none(_userName);
  }

  /// 연결 요청을 받은 기기에서 연결 시작 로직
  void _onConnectionInitiatedAdvertiser(
    String endpointId,
    ConnectionInfo connectionInfo,
  ) {
    state = const NearbyState.connecting();
  }

  /// 연결 요청을 보낸 기기에서 연결 시작 로직
  ///
  /// 연결 요청을 보낸 입장에서 두 번 확인하게 할 필요 없으므로 따로 처리함
  void _onConnectionInitiatedDiscoverer(
      String endpointId, ConnectionInfo info) {
    _nearby.acceptConnection(
      endpointId,
      onPayloadReceived: _onPayloadReceived,
      onPayloadTransferUpdate: _onPayloadTransferUpdate,
    );

    state = const NearbyState.connected();
  }

  void _onConnectionResult(
    String endpointId,
    ConnectionStatus status,
  ) {
    switch (status) {
      case ConnectionStatus.connected:
        _nearby.stopAdvertising();
        _nearby.stopDiscovery();
        state = const NearbyState.connected();
      case ConnectionStatus.rejected:
        state = const NearbyState.failed('connection rejected');
      case ConnectionStatus.error:
        state = const NearbyState.failed('connection error');
    }
  }

  void _onDisconnected(
    String endpointId,
  ) {
    _nearby.disconnectFromEndpoint(endpointId);
    _nearby.stopAdvertising();
    _nearby.stopDiscovery();
    state = NearbyState.none(_userName);
  }

  void _onEndpointFound(
    String endpointId,
    String endpointName,
    String serviceId,
  ) {
    switch (state) {
      case NearbyStateDiscovering(devices: var devices):
        final newDevice = NearbyDevice(id: endpointId, name: endpointName);
        if (!devices.contains(newDevice)) {
          state = NearbyState.discovering(_userName,
              [...devices, NearbyDevice(id: endpointId, name: endpointName)]);
        }
      default:
        break;
    }
  }

  void _onEndpointLost(
    String? endpointId,
  ) {
    switch (state) {
      case NearbyStateDiscovering(devices: var devices):
        state = NearbyState.discovering(_userName,
            devices.where((element) => element.id != endpointId).toList());
      default:
        break;
    }
  }

  void _onPayloadReceived(String endpointId, Payload payload) {
    // TODO: 데이터 받았을 때 처리
  }

  void _onPayloadTransferUpdate(
    String endpointId,
    PayloadTransferUpdate payloadTransferUpdate,
  ) {
    // TODO: 데이터 업데이트 될 때 처리
  }

  void _onBandwidthChanged(
    String endpointId,
    BandwidthQuality quality,
  ) {
    // TODO: what should I do here...?
  }
}
