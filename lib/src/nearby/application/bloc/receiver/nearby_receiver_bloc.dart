import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_event.dart';
import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_state.dart';
import 'package:poc/src/nearby/application/service/exceptions.dart';
import 'package:poc/src/nearby/application/service/nearby.dart';
import 'package:poc/src/nearby/application/service/user_info_fetcher.dart';

class NearbyReceiverBloc extends StateNotifier<NearbyReceiverState> {
  NearbyReceiverBloc(
    this._nearby,
    this._infoFetcher,
  ) : super(const NearbyReceiverState.none()) {
    // User 정보를 이후에 계속 사용하기 위해 initializer에서 받아옴
    _loadUserName();
  }

  final Nearby _nearby;
  final UserInfoFetcher _infoFetcher;

  /// [advertise] 할 때, 상대에게 누군지 알려주기 위한 값.
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

  /// REF: 임시 저장을 위한 변수
  /// 추후 API 수정되며 사라질 것임
  /// TODO: 현재는 bytes 단위만 확인했으므로 file 도 확인해보고 이 TODO 삭제하기
  String? _transferredData;

  /// Event를 받으면 State 로 전환하는 함수
  ///
  /// 여러가지 Event를 가질 때, switch 문이 길어져, 거대한 함수가 되기 때문에
  /// 이를 줄이고자, event 에서 bloc 에 있는 public method 들을 호출하는 방식으로
  /// 구현함.
  ///
  /// 각 Event sealed class의 [handle] method 참고.
  void mapEventToState(NearbyReceiverEvent event) {
    event.handle(this);
  }

  /// `수신자(receiver)` 가
  /// `전송자(sender)` 에게 자신을 찾을 수 있도록 알리는 함수
  Future<void> advertise(Strategy strategy) async {
    try {
      // step 2: advertising
      await _nearby.startAdvertising(
        _userName,
        strategy,
        onBandwidthChanged: _onBandwidthChanged,
        onConnectionInitiated: _onConnectionInitiatedAdvertiser,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );

      // result 2: 홍보 중으로 상태 변경
      state = NearbyReceiverState.advertising(_userName);
    } on AlreadyInUseException {
      // 에러 발생시 failed 상태로 만들기
      state = const NearbyReceiverState.failed('already advertising');
    }
  }

  void stopAdvertising() {
    _nearby.stopAdvertising();
    state = NearbyReceiverState.none(_userName);
  }

  Future<void> acceptConnection(String endpointId) async {
    await _nearby.acceptConnection(
      endpointId,
      onPayloadReceived: _onPayloadReceived,
      onPayloadTransferUpdate: _onPayloadTransferUpdate,
    );

    state = const NearbyReceiverState.connected();
  }

  Future<void> rejectConnection(String endpointId) async {
    await _nearby.rejectConnection(endpointId);
    state = NearbyReceiverState.advertising(_userName);
  }

  void stopAll() {
    _nearby.stopAllEndpoints();
    _nearby.stopDiscovery();

    state = NearbyReceiverState.none(_userName);
  }

  /// [_userName] 을 이후에 사용할 수 있도록 적제해놓고, 상태 초기에 부족했던 사용자 이름을
  /// state 에 반영함
  Future<void> _loadUserName() async {
    _userName = await _infoFetcher.info;
    state = NearbyReceiverState.none(_userName);
  }

  /// 연결 요청을 받은 기기에서 연결 시작 로직
  ///
  /// callback parameter 중 [ConnectionInfo] 의 `endpointName` 은
  /// `사용자이름|데이터이름` 형태로 되어있고, 이를 사용할 때, presentation layer 에서
  /// 풀어서 사용해야함을 주의.
  ///
  /// 추가 내용은 [NearbySenderBloc] 의 `requestConnection` 을 참고
  void _onConnectionInitiatedAdvertiser(
    String endpointId,
    ConnectionInfo connectionInfo,
  ) {
    // step 1: 화면에서 상태를 처리할 수 있도록 응답 중으로 변경
    state = NearbyReceiverState.responding(endpointId, connectionInfo);
  }

  void _onConnectionResult(
    String endpointId,
    ConnectionStatus status,
  ) {
    switch (status) {
      case ConnectionStatus.connected:
        _nearby.stopAdvertising();
        state = const NearbyReceiverState.connected();
      case ConnectionStatus.error:
        state = const NearbyReceiverState.failed('connection error');
      case ConnectionStatus.rejected:
        break;
    }
  }

  void _onDisconnected(
    String endpointId,
  ) {
    _nearby.disconnectFromEndpoint(endpointId);
    state = NearbyReceiverState.none(_userName);
  }

  /// 현재는 bytes 만 보내는 것을 상정하고 있음에 주의
  ///
  /// TODO: 현재는 bytes 단위만 확인했으므로 file 도 확인해보고 이 TODO 삭제하기
  void _onPayloadReceived(String endpointId, Payload payload) {
    _transferredData = String.fromCharCodes(payload.bytes!);

    _nearby.sendPayload(
      Payload.forSend(
        bytes: Uint8List.fromList(json.encode({'isSuccess': true}).codeUnits),
      ),
      endpointId,
    );

    state = NearbyReceiverState.success(_transferredData!);
  }

  /// [PayloadTransferUpdate.status] 는 inProgress -> success 로
  /// 횟수 n >= 2 로 들어오게 되니 주의
  ///
  /// TODO: 현재는 bytes 단위만 확인했으므로 file 도 확인해보고 이 TODO 삭제하기
  void _onPayloadTransferUpdate(
    String endpointId,
    PayloadTransferUpdate payloadTransferUpdate,
  ) {
    switch (payloadTransferUpdate.status) {
      case PayloadStatus.none:
        break;
      case PayloadStatus.success:
        break;
      case PayloadStatus.failure:
        // TODO: 다음 프로토콜 리팩토링 하기
        _nearby.sendPayload(
          Payload.forSend(
              bytes: Uint8List.fromList(
                  json.encode({'isSuccess': false}).codeUnits)),
          endpointId,
        );

        state = const NearbyReceiverState.failed(
            'something went wrong while receiving data');
      case PayloadStatus.inProgress:
        break;
      case PayloadStatus.canceled:
        state = const NearbyReceiverState.failed('canceled');
    }
  }

  /// API에는 존재하나, 현재는 크게 필요성을 못느껴서 없애도 될거 같다는 생각이 듬
  void _onBandwidthChanged(
    String endpointId,
    BandwidthQuality quality,
  ) {}
}
