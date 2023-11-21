import 'package:flutter/services.dart';
import 'package:poc/src/nearby/application/service/nearby.dart';
import 'package:poc/src/nearby/application/service/exceptions.dart';

/// [Nearby] 의 구현
///
/// **한계점**
/// - Clean Architecture 를 표방한다면, 어떤 구현을 의도하는지 인터페이스에서 알 수 없어야 하나
///   이 프로젝트는 해당 기술에 상당히 의존적임을 interface에서 이미 나타내고 있음.
class NearbyImpl implements Nearby {
  /// constructor 에서 [MethodChannel] 을 선택적으로 주입할 수 있도록 처리한 이유는
  /// 테스트 코드를 작성할 때 사용하기 위해서임.
  NearbyImpl({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('nearby_connections') {
    _initializeMethodCallHandler();
  }

  /// Platform (Android/iOS) 에 구현된 코드와 통신하는 방법을 채택하기로 합의됨.
  final MethodChannel _channel;

  /// [startAdvertising] 혹은 [requestConnection] 하는 경우의 callback 들
  OnConnectionInitiated? _advertiseConnectionInitiated,
      _discoverConnectionInitiated;
  OnConnectionResult? _advertiseConnectionResult, _discoverConnectionResult;
  OnDisconnected? _advertiseDisconnected, _discoverDisconnected;

  /// [startDiscovery] 하는 경우의 callback 들
  OnEndpointFound? _onEndpointFound;
  OnEndpointLost? _onEndpointLost;

  /// [acceptConnection] 하는 경우 callback 들
  OnPayloadReceived? _onPayloadReceived;
  OnPayloadTransferUpdate? _onPayloadTransferUpdate;

  /// native -> flutter 로 호출되는 callback 함수 처리
  void _initializeMethodCallHandler() {
    return _channel.setMethodCallHandler(
      (MethodCall call) async {
        final Map<dynamic, dynamic> args = call.arguments!;

        // step 1)
        // method 이름에 따라 enum으로 변환
        // enum으로 변환한 이유?
        // - String과 달리 compiler 에서 빠진 경우가 있으면 잡아주기 때문
        final methodEvent = MethodEvent.values.byName(call.method);

        // step 2)
        // 각 state에 맞게 호출해야할 함수 처리
        switch (methodEvent) {
          case MethodEvent.onAdvertiseConnectionInitiated:
            _handleOnAdvertiseConnectionInitiated(args);
          case MethodEvent.onAdvertiseConnectionResult:
            _handleOnAdvertiseConnectionResult(args);
          case MethodEvent.onAdvertiseDisconnected:
            _handleOnAdvertiseDisconnected(args);
          case MethodEvent.onDiscoveryConnectionInitiated:
            _handleOnDiscoveryConnectionInitiated(args);
          case MethodEvent.onDiscoveryConnectionResult:
            _handleOnDiscoveryConnectionResult(args);
          case MethodEvent.onDiscoveryDisconnected:
            _handleOnDiscoveryDisconnected(args);
          case MethodEvent.onEndpointFound:
            _handleOnEndpointFound(args);
          case MethodEvent.onEndpointLost:
            _handleOnEndpointLost(args);
          case MethodEvent.onPayloadReceived:
            _handleOnPayloadReceived(args);
          case MethodEvent.onPayloadTransferUpdate:
            _handleOnPayloadTransferUpdate(args);
        }
      },
    );
  }

  @override
  Future<void> startDiscovery(
    String userName,
    Strategy strategy, {
    String serviceId = 'com.nportverse.poc',
    required OnEndpointFound onEndpointFound,
    required OnEndpointLost onEndpointLost,
  }) async {
    _onEndpointFound = onEndpointFound;
    _onEndpointLost = onEndpointLost;

    try {
      await _channel.invokeMethod(
        'startDiscovery',
        <String, dynamic>{
          'userName': userName,
          'strategy': strategy.index,
          'serviceId': serviceId,
        },
      );
    } on PlatformException {
      throw AlreadyInUseException();
    }
  }

  @override
  Future<void> startAdvertising(
    String userName,
    Strategy strategy, {
    String serviceId = 'com.nportverse.poc',
    required OnBandwidthChanged onBandwidthChanged,
    required OnConnectionInitiated onConnectionInitiated,
    required OnConnectionResult onConnectionResult,
    required OnDisconnected onDisconnected,
  }) async {
    _advertiseConnectionInitiated = onConnectionInitiated;
    _advertiseConnectionResult = onConnectionResult;
    _advertiseDisconnected = onDisconnected;
    try {
      await _channel.invokeMethod(
        'startAdvertising',
        <String, dynamic>{
          'userName': userName,
          'strategy': strategy.index,
          'serviceId': serviceId,
        },
      );
    } on PlatformException {
      throw AlreadyInUseException();
    }
  }

  @override
  void stopDiscovery() {
    _channel.invokeMethod('stopDiscovery');
  }

  @override
  void stopAdvertising() {
    _channel.invokeMethod('stopAdvertising');
  }

  @override
  void stopAllEndpoints() {
    _channel.invokeMethod('stopAllEndpoints');
  }

  @override
  void disconnectFromEndpoint(String endpointId) {
    _channel.invokeMethod(
      'disconnectFromEndpoint',
      <String, dynamic>{'endpointId': endpointId},
    );
  }

  @override
  Future<void> acceptConnection(
    String endpointId, {
    required OnPayloadReceived onPayloadReceived,
    required OnPayloadTransferUpdate onPayloadTransferUpdate,
  }) {
    _onPayloadReceived = onPayloadReceived;
    _onPayloadTransferUpdate = onPayloadTransferUpdate;

    return _channel.invokeMethod(
      'acceptConnection',
      <String, dynamic>{'endpointId': endpointId},
    );
  }

  @override
  Future<void> requestConnection(
    String userName,
    String endpointId, {
    required OnBandwidthChanged onBandwidthChanged,
    required OnConnectionInitiated onConnectionInitiated,
    required OnConnectionResult onConnectionResult,
    required OnDisconnected onDisconnected,
  }) {
    _discoverConnectionInitiated = onConnectionInitiated;
    _discoverConnectionResult = onConnectionResult;
    _discoverDisconnected = onDisconnected;

    return _channel.invokeMethod(
      'requestConnection',
      <String, dynamic>{
        'userName': userName,
        'endpointId': endpointId,
      },
    );
  }

  @override
  Future<void> rejectConnection(String endpointId) {
    return _channel.invokeMethod(
      'rejectConnection',
      <String, dynamic>{
        'endpointId': endpointId,
      },
    );
  }

  /// bytes에 데이터 넣어보낼때 주의할 사항
  ///
  /// - 6940316 bytes ~= 6.619 MB 까지 bytes 로 전송 가능하니 주의
  @override
  Future<void> sendPayload(
    Payload payload,
    String endpointId,
  ) async {
    return _channel.invokeMethod(
      'sendPayload',
      <String, dynamic>{
        'endpointId': endpointId,
        'payload': {
          'bytes': payload.bytes,
          'filePath': payload.filePath,
        },
      },
    );
  }

  @override
  Future<void> cancelPayload(int payloadId) {
    return _channel.invokeMethod(
      'cancelPayload',
      <String, dynamic>{
        'payloadId': payloadId.toString(),
      },
    );
  }

  void _handleOnAdvertiseConnectionInitiated(Map<dynamic, dynamic> args) {
    String endpointId = args['endpointId'] ?? '-1';
    String endpointName = args['endpointName'] ?? '-1';
    String authenticationDigits = args['authenticationDigits'] ?? '-1';
    bool isIncomingConnection = args['isIncomingConnection'] ?? false;

    _advertiseConnectionInitiated?.call(
      endpointId,
      ConnectionInfo(
        endpointName,
        authenticationDigits,
        isIncomingConnection,
      ),
    );
  }

  void _handleOnAdvertiseConnectionResult(Map<dynamic, dynamic> args) {
    String endpointId = args['endpointId'] ?? '-1';
    ConnectionStatus statusCode = ConnectionStatus
        .values[args['statusCode'] ?? ConnectionStatus.error.index];

    _advertiseConnectionResult?.call(endpointId, statusCode);
  }

  void _handleOnAdvertiseDisconnected(Map<dynamic, dynamic> args) {
    String endpointId = args['endpointId'] ?? '-1';

    _advertiseDisconnected?.call(endpointId);
  }

  void _handleOnDiscoveryConnectionInitiated(Map<dynamic, dynamic> args) {
    String endpointId = args['endpointId'] ?? '-1';
    String endpointName = args['endpointName'] ?? '-1';
    String authenticationDigits = args['authenticationDigits'] ?? '-1';
    bool isIncomingConnection = args['isIncomingConnection'] ?? false;

    _discoverConnectionInitiated?.call(
      endpointId,
      ConnectionInfo(
        endpointName,
        authenticationDigits,
        isIncomingConnection,
      ),
    );
  }

  void _handleOnDiscoveryConnectionResult(Map<dynamic, dynamic> args) {
    String endpointId = args['endpointId'] ?? '-1';
    ConnectionStatus statusCode = ConnectionStatus
        .values[args['statusCode'] ?? ConnectionStatus.error.index];

    _discoverConnectionResult?.call(endpointId, statusCode);
  }

  void _handleOnDiscoveryDisconnected(Map<dynamic, dynamic> args) {
    String endpointId = args['endpointId'] ?? '-1';
    _discoverDisconnected?.call(endpointId);
  }

  void _handleOnEndpointFound(Map<dynamic, dynamic> args) {
    String endpointId = args['endpointId'] ?? '-1';
    String endpointName = args['endpointName'] ?? '-1';
    String serviceId = args['serviceId'] ?? '-1';

    _onEndpointFound?.call(endpointId, endpointName, serviceId);
  }

  void _handleOnEndpointLost(Map<dynamic, dynamic> args) {
    String endpointId = args['endpointId'] ?? '-1';

    _onEndpointLost?.call(endpointId);
  }

  void _handleOnPayloadReceived(Map<dynamic, dynamic> args) {
    String endpointId = args['endpointId'] ?? '-1';
    int type = args['type'] ?? PayloadType.none.index;
    Uint8List bytes = args['bytes'] ?? Uint8List(0);
    int payloadId = args['payloadId'] ?? -1;
    String? filePath = args['filePath'];

    Payload payload = Payload(
      id: payloadId,
      type: PayloadType.values[type],
      bytes: bytes,
      filePath: filePath,
    );

    _onPayloadReceived?.call(endpointId, payload);
  }

  void _handleOnPayloadTransferUpdate(Map<dynamic, dynamic> args) {
    String endpointId = args['endpointId'] ?? '-1';
    int payloadId = args['payloadId'] ?? -1;
    int status = args['status'] ?? ConnectionStatus.error.index;
    int bytesTransferred = args['bytesTransferred'] ?? 0;
    int totalBytes = args['totalBytes'] ?? 0;

    PayloadTransferUpdate payloadTransferUpdate = PayloadTransferUpdate(
      id: payloadId,
      status: PayloadStatus.values[status],
      bytesTransferred: bytesTransferred,
      totalBytes: totalBytes,
    );

    _onPayloadTransferUpdate?.call(endpointId, payloadTransferUpdate);
  }
}

enum MethodEvent {
  onAdvertiseConnectionInitiated,
  onAdvertiseConnectionResult,
  onAdvertiseDisconnected,
  onDiscoveryConnectionInitiated,
  onDiscoveryConnectionResult,
  onDiscoveryDisconnected,
  onEndpointFound,
  onEndpointLost,
  onPayloadReceived,
  onPayloadTransferUpdate,
  ;
}
