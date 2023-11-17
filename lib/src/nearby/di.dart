import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_bloc.dart';
import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_state.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_bloc.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_state.dart';
import 'package:poc/src/nearby/application/service/nearby.dart';
import 'package:poc/src/nearby/application/service/nearby_precondition_checker.dart';
import 'package:poc/src/nearby/application/service/user_info_fetcher.dart';
import 'package:poc/src/nearby/domain/repository/my_asset_repository.dart';
import 'package:poc/src/nearby/infrastructure/repository/my_asset_repository_fake_impl.dart';
import 'package:poc/src/nearby/infrastructure/service/nearby_impl.dart';
import 'package:poc/src/nearby/infrastructure/service/nearby_precondition_checker_impl.dart';
import 'package:poc/src/nearby/infrastructure/service/user_info_fetcher_impl.dart';

final nearbySenderBlocProvider =
    StateNotifierProvider<NearbySenderBloc, NearbySenderState>(
  (ref) => NearbySenderBloc(
    ref.watch(nearbyProvider),
    ref.watch(nearbyConditionCheckerProvider),
    ref.watch(infoFetcherProvider),
  ),
);

final nearbyReceiverBlocProvider =
    StateNotifierProvider<NearbyReceiverBloc, NearbyReceiverState>(
  (ref) => NearbyReceiverBloc(
    ref.watch(nearbyProvider),
    ref.watch(nearbyConditionCheckerProvider),
    ref.watch(infoFetcherProvider),
  ),
);

final nearbyProvider = Provider<Nearby>(
  (ref) => NearbyImpl(),
);

final nearbyConditionCheckerProvider = Provider<NearbyPreconditionChecker>(
  (ref) => NearbyPreconditionCheckerImpl(
    ref.watch(deviceInfoProvider),
  ),
);

final infoFetcherProvider = Provider<UserInfoFetcher>(
  (ref) => UserInfoFetcherImpl(
    ref.watch(deviceInfoProvider),
  ),
);

final deviceInfoProvider = Provider((ref) => DeviceInfoPlugin());

/// 현재 fake implementation 으로 할당되어 있는 것에 주의.
///
/// fake implementation 이 아니라면 주석 삭제 해야함.
final myAssetsRepositoryProvider =
    Provider<MyAssetRepository>((ref) => MyAssetRepositoryFakeImpl());
