import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poc/src/nearby/application/service/nearby_precondition_checker.dart';

/// [NearbyPreconditionChecker] 의 구현 클래스
///
/// - 설명은 [NearbyPreconditionChecker] 을 참고.
/// - Layering Architecture 의 원칙에 따라, 애플리케이션의 로직(e.g. 데이터를 가져와라)은
///   application layer 에 정의하고, 실제 구현을 infrastructure layer 에서 정의.
/// - 개발자에 따라 이 layer를 `data layer` 라고 하는 경우도 있으니 참고.
class NearbyPreconditionCheckerImpl implements NearbyPreconditionChecker {
  NearbyPreconditionCheckerImpl(this._deviceInfo);

  static const kAndroid12MinVersion = 31;
  static const kAndroid13Version = 33;

  final DeviceInfoPlugin _deviceInfo;

  // Android 기기 정보 caching 을 위한 객체
  AndroidDeviceInfo? _androidDeviceInfo;

  /// Nearby Connections를 사용하기 위해 필요한 권한들
  List<Permission>? _permissions;

  /// Android/iOS 에서 공통적으로 필요한 권한임
  // TODO: iOS 에서 bluetooth 를 정말로 사용하는지 확인이 필요함
  final _commonPermissions = <Permission>[
    // 위치 관련
    Permission.location,
    // bluetooth 관련
    Permission.bluetooth,
  ];

  /// Android12 버전 부터 필요한 권한들
  final _androidFrom12Permissions = <Permission>[
    /// bluetooth 관련
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
  ];

  /// Android13 버전 부터 필요한 권한들
  final _androidFrom13Permissions = <Permission>[
    /// Nearby Wifi 관련 (Android에만 해당하는 것으로 추론)
    Permission.nearbyWifiDevices,
  ];

  Future<List<Permission>> _initializePermissions() async {
    // iOS 인경우
    if (Platform.isIOS) {
      return [..._commonPermissions];
    }

    if (!Platform.isAndroid) {
      throw UnimplementedError();
    }

    _androidDeviceInfo ??= await _deviceInfo.androidInfo;

    final permissions = <Permission>[
      ..._commonPermissions,
    ];

    if (_androidDeviceInfo!.version.sdkInt >= kAndroid12MinVersion) {
      permissions.addAll(_androidFrom12Permissions);
    }

    if (_androidDeviceInfo!.version.sdkInt >= kAndroid13Version) {
      permissions.addAll(_androidFrom13Permissions);
    }

    return permissions;
  }

  /// [NearbyImpl] 을 사용하기 위한 조건을 만족하는지 확인.
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
    // step 0. permission 초기화 되어있지 않으면 초기화
    _permissions ??= await _initializePermissions();

    // step 1. 필요 권한 여부 확인
    for (final permission in _permissions!) {
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
    // step 0. permission 초기화 되어있지 않으면 초기화
    _permissions ??= await _initializePermissions();

    for (final permission in _permissions!) {
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
