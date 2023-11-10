import 'dart:async';

abstract interface class UserInfoFetcher {
  FutureOr<String> get info;
}
