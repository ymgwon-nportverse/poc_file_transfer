import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:poc/src/nearby/application/service/user_info_fetcher.dart';

/// Device 정보 받아와서 Model명(iPhone/Galaxy) 등을 받아와서 반환하도록 구현함
///
/// BLoC 클래스에 InMemory Caching 을 적용할까, 여기 적용할까 하다 여기 적용함.
///
/// 즉, 언제든 위치를 바꿔도 무관하다는 의미.
class UserInfoFetcherImpl implements UserInfoFetcher {
  UserInfoFetcherImpl(this._infoFetcher) {
    info;
  }

  final DeviceInfoPlugin _infoFetcher;

  String? _info;

  @override
  Future<String> get info async {
    if (_info != null) {
      return _info!;
    }

    final info = (await _infoFetcher.deviceInfo).data;
    if (Platform.isAndroid) {
      return _info = info['model'] ?? 'unidentified';
    } else if (Platform.isIOS) {
      return _info = info['utsname']['machine'] ?? 'unidentified';
    } else {
      throw UnimplementedError();
    }
  }
}
