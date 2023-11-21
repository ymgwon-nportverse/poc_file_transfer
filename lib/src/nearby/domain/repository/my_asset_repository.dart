import 'dart:async';

/// 가지고 있는 asset 을 조회하는 interface
///
/// asset 이라는 이름을 사용한 이유는
/// - 내 자산(asset) 이라는 의미로 추후 프로젝트 성격이 변경되면 특별한 이름 변경 없이
///   그대로 code 를 가져갈 수 있기 때문이고
/// - 일회용으로 사용되더라도, flutter 를 사용하는 사람에게 `file = asset`
///   이라는 의미는 보편적이기 때문
abstract interface class MyAssetRepository {
  /// detail 을 추후 고려하기 위해 우선 String type 으로 생각함
  FutureOr<List<String>> getAssets();
}
