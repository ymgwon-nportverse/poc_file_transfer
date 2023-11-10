import 'dart:typed_data';

/// [ConnectionClient API](https://developers.google.com/android/reference/com/google/android/gms/nearby/connection/ConnectionsClient)
/// 에 따라 비슷하게 만든 interface.
///
/// [flutter: nearby_connections](https://www.github.com:mannprerak2/nearby_connections) 를 reference 로 삼아 만듬.
abstract interface class Nearby {
  /// [startAdvertising] 을 통해 스스롤 광고 하고 있는 기기를 찾는 명령
  Future<void> startDiscovery(
    String userName,
    Strategy strategy, {
    String serviceId = 'com.nportverse.poc',
    required OnEndpointFound onEndpointFound,
    required OnEndpointLost onEndpointLost,
  });

  /// [startDiscovery] 를 통해 주변기기를 listening 하고 있는 기기들에게 자신을 알리는 명령
  Future<void> startAdvertising(
    String userName,
    Strategy strategy, {
    String serviceId = 'com.nportverse.poc',
    required OnBandwidthChanged onBandwidthChanged,
    required OnConnectionInitiated onConnectionInitiated,
    required OnConnectionResult onConnectionResult,
    required OnDisconnected onDisconnected,
  });

  /// [startDiscovery] 를 종료하는 명령
  void stopDiscovery();

  /// [startAdvertising] 를 종료하는 명령
  void stopAdvertising();

  /// 연결된 모든 기기를 해제하는 명령
  void stopAllEndpoints();

  /// 연결된 특정 기기를 해제하는 명령
  void disconnectFromEndpoint(String endpointId);

  /// 외부 기기 [requestConnection] 을 받았을 때, 연결을 승락하는 명령
  Future<void> acceptConnection(
    String endpointId, {
    required OnPayloadReceived onPayloadReceived,
    required OnPayloadTransferUpdate onPayloadTransferUpdate,
  });

  /// 외부 기기 [requestConnection] 을 받았을 때, 연결을 거절하는 명령
  Future<void> rejectConnection(String endpointId);

  /// 외부 기기에 연결을 요청하는 명령
  Future<void> requestConnection(
    String userName,
    String endpointId, {
    required OnBandwidthChanged onBandwidthChanged,
    required OnConnectionInitiated onConnectionInitiated,
    required OnConnectionResult onConnectionResult,
    required OnDisconnected onDisconnected,
  });

  /// 연결된 이후 데이터를 전송하는 명령
  Future<void> sendPayload(Payload payload, String endpointId);

  /// 데이터 전송을 취소하는 명령
  Future<void> cancelPayload(int payloadId);
}

// callbacks
// ==================
typedef OnBandwidthChanged = void Function(
  String endpointId,
  BandwidthQuality quality,
);

typedef OnConnectionInitiated = void Function(
  String endpointId,
  ConnectionInfo connectionInfo,
);

typedef OnConnectionResult = void Function(
  String endpointId,
  ConnectionStatus status,
);

typedef OnDisconnected = void Function(
  String endpointId,
);

typedef OnEndpointFound = void Function(
  String endpointId,
  String endpointName,
  String serviceId,
);

typedef OnEndpointLost = void Function(
  String? endpointId,
);

typedef OnPayloadReceived = void Function(
  String endpointId,
  Payload payload,
);

/// byte 전송은 한번, file 전송은 file 전송이 완료될때까지 지속적으로 호출
typedef OnPayloadTransferUpdate = void Function(
  String endpointId,
  PayloadTransferUpdate payloadTransferUpdate,
);
// ==================

/// 연결 방식
///
/// - **cluster** - 작은 payload를 전달하기 적절함. 멀티플레이어 게임.
///
/// - **star** - 중간 payload를 전달하기 적절함. cluster 보다 bandwidth 가 큼.
///
/// - **pointToPoint** - 단일 연결만 가능. 가장 큰 bandwidth를 가짐.
enum Strategy {
  cluster,
  star,
  pointToPoint,
}

/// 네트워크 대역폭을 나타내어, 파일을 보낼 수 있는 상태인지 확인할 수 있는 듯함
enum BandwidthQuality {
  /// 찾을 수 없음
  unknown,

  /// (~5KBps) 파일을 보내기에 적절하지 않음
  low,

  /// (60~200KBps) 작은 파일을 보낼 수 있을 만큼 좋음
  medium,

  /// (6MBps ~ 60MBps) 파일을 언제나 보낼 수 있을 만큼 좋음
  high,
}

enum ConnectionStatus {
  connected,
  rejected,
  error,
}

enum PayloadStatus {
  none,
  success,
  failure,
  inProgress,
  canceled,
}

enum PayloadType {
  none,
  bytes,
  file,
  // TODO: stream 은 현재 제대로 구현이 되어 있지 않기 때문에 처리가 필요함
  stream,
}

/// [OnConnectionInitiated] 의 파라미터.
///
/// [endPointName] 는 요청자의 userName.
///
/// [authenticationDigits] 는 연결 보안을 체크하기 위해 사용할 수 있 수 있고, 연결하는 두 기기의
/// token 값이 동일해야함.
class ConnectionInfo {
  const ConnectionInfo(
    this.endpointName,
    this.authenticationDigits,
    this.isIncomingConnection,
  );

  final String endpointName, authenticationDigits;
  final bool isIncomingConnection;
}

/// Payload 변경사항을 알려주는 클래스
///
/// [OnPayloadTransferUpdate] 에서 사용됨.
///
/// file 전송일 때는 지속적으로 호출되므로 로직 처리 필요함.
class PayloadTransferUpdate {
  const PayloadTransferUpdate({
    required this.id,
    required this.bytesTransferred,
    required this.totalBytes,
    this.status = PayloadStatus.none,
  });

  final int id, bytesTransferred, totalBytes;
  final PayloadStatus status;
}

/// file로 보낼때는 filePath에만 값이 있어야하고,
/// bytes로 보낼때는 bytes에만 값이 있어야함.
///
/// assert 문 혹은
/// [test](test/src/nearby/application/nearby_communication_test.dart)
/// 참고
class Payload {
  const Payload({
    required this.id,
    this.bytes,
    this.type = PayloadType.none,
    this.filePath,
  }) : assert(
          (bytes == null && filePath != null) ||
              (filePath == null && bytes != null),
          'Payload must have either bytes or filePath, not both or neither',
        );

  final int id;
  final PayloadType type;
  final Uint8List? bytes;
  final String? filePath;
}
