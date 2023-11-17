import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/nearby/application/bloc/nearby_bloc.dart';
import 'package:poc/src/nearby/application/bloc/nearby_state.dart';
import 'package:poc/src/nearby/application/service/nearby.dart';
import 'package:poc/src/nearby/application/service/nearby_precondition_checker.dart';
import 'package:poc/src/nearby/application/service/user_info_fetcher.dart';
import 'package:poc/src/nearby/infrastructure/service/nearby_impl.dart';
import 'package:poc/src/nearby/infrastructure/service/nearby_precondition_checker_impl.dart';
import 'package:poc/src/nearby/infrastructure/service/user_info_fetcher_impl.dart';

final nearbyBlocProvider = StateNotifierProvider<NearbyBloc, NearbyState>(
  (ref) => NearbyBloc(
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
