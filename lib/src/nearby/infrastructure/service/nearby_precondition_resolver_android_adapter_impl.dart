import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poc/src/nearby/application/service/nearby_precondition_resolver.dart';

class NearbyPreconditionResolverAndroidAdapterImpl
    implements NearbyPreconditionResolver {
  NearbyPreconditionResolverAndroidAdapterImpl(this._deviceInfo) {
    _initializePermissions();
  }

  static const kAndroid12MinVersion = 31;
  static const kAndroid13Version = 33;

  final DeviceInfoPlugin _deviceInfo;

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

  Future<List<Permission>> _initializePermissions() async {
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
}
