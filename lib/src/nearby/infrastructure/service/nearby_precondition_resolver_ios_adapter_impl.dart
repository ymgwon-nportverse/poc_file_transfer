import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poc/src/nearby/application/service/nearby_precondition_resolver.dart';

class NearbyPreconditionResolverIosAdapterImpl
    implements NearbyPreconditionResolver {
  const NearbyPreconditionResolverIosAdapterImpl({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('wifi_check');

  final MethodChannel _channel;

  /// iOS 필요 권한
  static final _permissions = <Permission>[
    // 위치 관련
    Permission.location,
    // bluetooth 관련
    Permission.bluetooth,
  ];

  @override
  Future<bool> isSatisfied() async {
    // step 1. 필요 권한 여부 확인
    for (final permission in _permissions) {
      final isGranted = await permission.isGranted;
      if (!isGranted) {
        return false;
      }
    }

    // step 2. wifi/bluetooth 확인
    //
    // REF: build 단계에서
    if (!(await _isWifiEnabled())) {
      return false;
    }

    if (!(await _isBluetoothEnabled())) {
      return false;
    }

    return true;
  }

  @override
  Future<void> resolve() async {
    // 권한 수정
    for (final permission in _permissions) {
      await permission.request();
    }
  }

  /// bluetooth 켜져있는지 확인
  ///
  /// - `permission_handler` 패키지에서 확인할 수 있음.
  ///   이 [issue](https://github.com/Baseflow/flutter-permission-handler/issues/773) 참고
  Future<bool> _isBluetoothEnabled() async {
    final bluetoothStatus = await Permission.bluetooth.serviceStatus;
    return switch (bluetoothStatus) {
      ServiceStatus.enabled => true,
      ServiceStatus.disabled || ServiceStatus.notApplicable => false,
    };
  }

  /// wifi 켜져있는지 확인
  /// TODO: 검증하기
  Future<bool> _isWifiEnabled() async {
    final result = await _channel.invokeMethod('checkWifiEnabled');
    log(result.toString());
    return true;
  }
}
