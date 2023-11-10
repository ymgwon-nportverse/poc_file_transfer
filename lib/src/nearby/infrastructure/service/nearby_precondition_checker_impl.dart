import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:poc/src/nearby/application/service/nearby_precondition_checker.dart';

class NearbyPreconditionCheckerImpl implements NearbyPreconditionChecker {
  /// Nearby Connections를 사용하기 위해 필요한 권한들
  ///
  /// 플랫폼 마다 Permission 설정값이 달라 이를 처리해주기 위한 getter
  List<Permission> get _permissions {
    if (Platform.isAndroid) {
      return [..._commonPermission, ..._androidPermissions];
    } else if (Platform.isIOS) {
      return _commonPermission;
    } else {
      throw UnimplementedError();
    }
  }

  /// Nearby Connections를 사용하기 위해 공통적으로 필요한 권한들
  // TODO: iOS 에서 bluetooth 를 정말로 사용하는지 확인이 필요함
  final _commonPermission = <Permission>[
    // bluetooth 관련
    Permission.bluetooth,

    // 위치 관련
    Permission.location,
  ];

  /// Nearby Connections를 사용하기 위해 안드로이드에서만 필요한 권한들
  final _androidPermissions = <Permission>[
    // bluetooth 관련
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,

    // Nearby Wifi 관련 (Android에만 해당하는 것으로 추론)
    Permission.nearbyWifiDevices,
  ];

  /// [NearbyCommunicationImpl] 을 사용하기 위한 조건을 만족하는지 확인.
  ///
  /// **REF**
  ///
  /// - WiFi 설정이 켜져있는지 켜져있지 않은지 확인하는 기능을 넣으려고 하였으나, 반쪽짜리 패키지 밖에
  /// 없음. [참고 링크](https://pub.dev/packages/wifi_iot).
  ///
  /// - 직접 `MethodChannel` 로 확인하려 하였으나,
  /// [iOS 에서는 WiFi on/off 체크할 수 없음](https://stackoverflow.com/a/43832758)
  /// 을 확인함.
  ///
  ///
  /// 대안으로 사용자에게 wifi 연결 확인하라고 알려주는 것이 좋을듯 함.
  @override
  Future<bool> isSatisfied() async {
    // step 1. 필요 권한 여부 확인
    for (final permission in _permissions) {
      final isGranted = await permission.isGranted;
      if (!isGranted) {
        return false;
      }
    }

    // step 2. bluetooth 켜져있는지 확인
    if (!(await _isBluetoothEnabled())) {
      return false;
    }

    return true;
  }

  @override
  Future<void> satisfy() async {
    for (final permission in _permissions) {
      await permission.request();
    }
  }

  /// step 1: bluetooth 켜져있는지 확인
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
}
