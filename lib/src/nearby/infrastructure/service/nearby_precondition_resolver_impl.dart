import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poc/src/nearby/application/service/nearby_precondition_resolver.dart';

/// [NearbyPreconditionResolver] 의 구현 클래스
///
/// - 설명은 [NearbyPreconditionResolver] 을 참고.
/// - Layering Architecture 의 원칙에 따라, 애플리케이션의 로직(e.g. 데이터를 가져와라)은
///   application layer 에 정의하고, 실제 구현을 infrastructure layer 에서 정의.
/// - 개발자에 따라 이 layer를 `data layer` 라고 하는 경우도 있으니 참고.
class NearbyPreconditionResolverImpl implements NearbyPreconditionResolver {
  NearbyPreconditionResolverImpl(this._deviceInfo, {MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('wifi_enabled_check');

  static const kAndroid12MinVersion = 31;
  static const kAndroid13Version = 33;

  final DeviceInfoPlugin _deviceInfo;
  final MethodChannel _channel;

  // Android 기기 정보 caching 을 위한 객체
  AndroidDeviceInfo? _androidDeviceInfo;

  /// Nearby Connections를 사용하기 위해 필요한 권한들
  List<Permission>? _permissions;

  /// Android/iOS 에서 공통적으로 필요한 권한임
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
    // step 0: android/ios 가 아닌 경우 지원하지 않기 때문에 exception 처리
    //
    // REF: android/ios 만 빌드할 수 있도록 프로젝트 설정이 되어 있어서 확인하지 않아도 되지만,
    //      추후 지원 플랫폼을 추가하는 경우(e.g. macOS), 추가 작업을 해야한다는 의미에서 추가
    if (!(Platform.isAndroid || Platform.isIOS)) {
      throw UnimplementedError();
    }

    // step 1: iOS 인 경우, 공통으로 사용할 권한만 확인하면 됨
    if (Platform.isIOS) {
      return [..._commonPermissions];
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

    // step 2. android 인 경우 검증 종료
    //
    // REF: 안드로이드에서는 서비스를 시작하기 전에 wifi/bluetooth가 켜져있지 않다면
    //      자동으로 켜기 때문에 더이상 검증할 필요없음.
    if (Platform.isAndroid) {
      return true;
    }

    // step 3. ios wifi/bluetooth 확인
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
    // step 0. permission 초기화 되어있지 않으면 초기화
    _permissions ??= await _initializePermissions();

    for (final permission in _permissions!) {
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
  // TODO: implement this
  Future<bool> _isWifiEnabled() async {
    final result = await _channel.invokeMethod('checkWifiEnabled');
    log(result.toString());
    return true;
  }
}
