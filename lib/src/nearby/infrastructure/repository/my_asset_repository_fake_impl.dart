import 'package:poc/src/nearby/domain/repository/my_asset_repository.dart';

/// implementation 을 우선 생각하지 않고 로직 처리를 위해 Fake implementation 생성
class MyAssetRepositoryFakeImpl implements MyAssetRepository {
  @override
  Future<List<String>> getAssets() {
    return Future.delayed(const Duration(seconds: 1), () {
      return [
        'Hello',
        'world',
        'nportverse',
      ];
    });
  }
}
