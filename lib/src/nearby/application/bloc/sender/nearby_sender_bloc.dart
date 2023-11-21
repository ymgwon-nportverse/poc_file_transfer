import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_event.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_state.dart';
import 'package:poc/src/nearby/application/service/nearby.dart';
import 'package:poc/src/nearby/application/service/nearby_precondition_checker.dart';
import 'package:poc/src/nearby/application/service/user_info_fetcher.dart';
import 'package:poc/src/nearby/application/service/exceptions.dart';

class NearbySenderBloc extends StateNotifier<NearbySenderState> {
  NearbySenderBloc(
    this._nearby,
    this._checker,
    this._infoFetcher,
  ) : super(const NearbySenderState.none()) {
    // User 정보를 이후에 계속 사용하기 위해 initializer에서 받아옴
    _loadUserName();
  }

  final Nearby _nearby;
  final NearbyPreconditionChecker _checker;
  final UserInfoFetcher _infoFetcher;

  /// 데이터 보낼 endpoint id
  ///
  /// 다른 상태를 가지고 싶게 하지 않았으나,
  /// 전송을 위한 event 의 발현 시점이 다르기 때문에
  /// 상태를 가질 수 밖에 없었음
  ///
  /// connected 될 때, 값이 할당되고, disconnected 될 때, 값이 초기화 되어야하니
  /// 이것이 잘 구현되어 있는지 확인 필요
  String? _targetEndpointId;

  /// REF: 임시 저장을 위한 변수
  /// 추후 API 수정되며 사라질 것임
  /// TODO: 현재는 bytes 단위만 확인했으므로 file 도 확인해보고 이 TODO 삭제하기
  // String? _transferredData;

  /// [advertise] / [discover] 할 때, 상대에게 누군지 알려주기 위한 값.
  ///
  /// 이 BLoC 클래스 생성하며, initializer 에서 이름을 업데이트하게 되어있음.
  ///
  /// c.f.)
  ///
  /// - `unidentified` 라는 이름은 부적절함. 추후 수정하는게 좋을 것으로 보임.
  ///   - 이는 정보를 불러오는 함수가 [FutureOr], 즉 비동기일 가능성이 큰 함수이기 때문에
  /// 불러오기 전까진 [_userName]이 null 값 일 수 밖에 없고, 이는 다른 메소드에서 사용될 때
  /// nullable 확인을 해야하는 귀찮은 상황이 발생할 수 있기 때문에 default 값을 선정함.
  String _userName = 'unidentified';

  /// Event를 받으면 State 로 전환하는 함수
  ///
  /// 여러가지 Event를 가질 때, switch 문이 길어져, 거대한 함수가 되기 때문에
  /// 이를 줄이고자, event 에서 bloc 에 있는 public method 들을 호출하는 방식으로
  /// 구현함.
  ///
  /// 각 Event sealed class의 [handle] method 참고.
  void mapEventToState(NearbySenderEvent event) {
    event.handle(this);
  }

  /// `송신자(sender)` 가
  /// `수신자(receiver)` 를 찾기 위한 함수
  Future<void> discover(Strategy strategy) async {
    // step 1: 사전 조건(e.g. bluetooth 켜져있는지, 권한 설정 되어 있는지) 확인
    final isPreconditionSatisfied = await _checker.isSatisfied();
    if (!isPreconditionSatisfied) {
      // result 1: 조건 만족하지 않을 때는 그에 맞게 상태 변경
      state = const NearbySenderState.failed('precondition unsatisfied');
      _checker.makeItSatisfied();
      return;
    }

    try {
      await _nearby.startDiscovery(
        _userName,
        strategy,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
      );
      // result 2: 찾고 있는 것으로 상태 변경
      state = NearbySenderState.discovering(_userName, []);
    } on AlreadyInUseException {
      state = const NearbySenderState.failed('already discovering');
    }
  }

  void stopDiscovery() {
    _nearby.stopDiscovery();
    state = NearbySenderState.none(_userName);
  }

  /// 연결 요청 보내기
  ///
  /// 애플리케이션 요구사항이 연결을 시도할 때, 연결 후 보낼 데이터가 무엇인지 확인하는 것이기 때문에
  /// 이를 위해 우회방법을 사용함.
  /// - [userName]과 [dataName] 을 '|'(pipe) 로 합친 후 보냄.
  ///
  /// 수신자에서도 [onConnectionInitiated] 에서 이를 처리해줘야하는 것 잊지 않아야 함
  Future<void> requestConnection(
    String endpointId,
    String userName,
    String dataName,
  ) async {
    final concatenatedName = "$userName|$dataName";

    _nearby.requestConnection(
      concatenatedName,
      endpointId,
      onBandwidthChanged: _onBandwidthChanged,
      onConnectionInitiated: _onConnectionInitiatedDiscoverer,
      onConnectionResult: _onConnectionResult,
      onDisconnected: _onDisconnected,
    );
    state = const NearbySenderState.requesting();
  }

  // TODO: 현재는 bytes 보내는 것만 가정하고 있으므로, 수정후 이 TODO 지우기
  Future<void> send([Uint8List? bytes, String? filePath]) async {
    if (_targetEndpointId == null) {
      state = const NearbySenderState.failed('endpoint is null!');
      return;
    }

    // _transferredData = String.fromCharCodes(bytes!);

    _nearby.sendPayload(
      Payload.forSend(
        bytes: bytes,
        filePath: filePath,
      ),
      _targetEndpointId!,
    );
  }

  void stopAll() {
    _nearby.stopAllEndpoints();
    _nearby.stopDiscovery();

    state = NearbySenderState.none(_userName);
  }

  /// [_userName] 을 이후에 사용할 수 있도록 적제해놓고, 상태 초기에 부족했던 사용자 이름을
  /// state 에 반영함
  Future<void> _loadUserName() async {
    _userName = await _infoFetcher.info;
    state = NearbySenderState.none(_userName);
  }

  /// 연결 요청을 보낸 기기(=discoverer) 에서 연결 시작 로직
  ///
  /// 연결 요청을 보낸 입장에서 두 번 확인하게 할 필요 없으므로 따로 처리함
  ///
  /// 여기서는 상태를 처리하지 않고 [_onConnectionResult] 에서 상태를 처리함
  Future<void> _onConnectionInitiatedDiscoverer(
      String endpointId, ConnectionInfo connectionInfo) async {
    await _nearby.acceptConnection(
      endpointId,
      onPayloadReceived: _onPayloadReceived,
      onPayloadTransferUpdate: _onPayloadTransferUpdate,
    );
  }

  void _onConnectionResult(
    String endpointId,
    ConnectionStatus status,
  ) {
    switch (status) {
      case ConnectionStatus.connected:
        _targetEndpointId = endpointId;
        _nearby.stopDiscovery();
        state = const NearbySenderState.connected();
      case ConnectionStatus.rejected:
        state = const NearbySenderState.rejected();
      case ConnectionStatus.error:
        state = const NearbySenderState.failed('connection error');
    }
  }

  void _onDisconnected(
    String endpointId,
  ) {
    _targetEndpointId = null;
    _nearby.disconnectFromEndpoint(endpointId);
    state = NearbySenderState.none(_userName);
  }

  void _onEndpointFound(
    String endpointId,
    String endpointName,
    String serviceId,
  ) {
    switch (state) {
      case NearbySenderStateDiscovering(devices: var devices):
        final newDevice = NearbyDevice(id: endpointId, name: endpointName);
        if (!devices.contains(newDevice)) {
          state = NearbySenderState.discovering(_userName,
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
      case NearbySenderStateDiscovering(devices: var devices):
        state = NearbySenderState.discovering(_userName,
            devices.where((element) => element.id != endpointId).toList());
      default:
        break;
    }
  }

  /// sender은 검증 데이터가 맞는지 확인해야 하므로 receiver 로 부터 응답을 받아서 확인함
  void _onPayloadReceived(String endpointId, Payload payload) {}

  /// sender은 검증 데이터가 맞는지 확인해야 하므로 receiver 로 부터 응답을 받아서 확인함
  void _onPayloadTransferUpdate(
    String endpointId,
    PayloadTransferUpdate payloadTransferUpdate,
  ) {}

  /// API에는 존재하나, 현재는 크게 필요성을 못느껴서 없애도 될거 같다는 생각이 듬
  void _onBandwidthChanged(
    String endpointId,
    BandwidthQuality quality,
  ) {}
}
