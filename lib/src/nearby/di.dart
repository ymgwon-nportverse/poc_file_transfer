import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_bloc.dart';
import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_state.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_bloc.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_state.dart';
import 'package:poc/src/nearby/application/service/nearby.dart';
import 'package:poc/src/nearby/application/service/nearby_precondition_resolver.dart';
import 'package:poc/src/nearby/application/service/user_info_fetcher.dart';
import 'package:poc/src/nearby/domain/repository/my_asset_repository.dart';
import 'package:poc/src/nearby/infrastructure/repository/my_asset_repository_fake_impl.dart';
import 'package:poc/src/nearby/infrastructure/service/nearby_impl.dart';
import 'package:poc/src/nearby/infrastructure/service/nearby_precondition_resolver_impl.dart';
import 'package:poc/src/nearby/infrastructure/service/user_info_fetcher_impl.dart';

final nearbySenderBlocProvider =
    NotifierProvider.autoDispose<NearbySenderBloc, NearbySenderState>(
  NearbySenderBloc.new,
);

final nearbyReceiverBlocProvider =
    NotifierProvider.autoDispose<NearbyReceiverBloc, NearbyReceiverState>(
  NearbyReceiverBloc.new,
);

final nearbyProvider = Provider<Nearby>(
  (_) => NearbyImpl(),
);

final nearbyPreconditionResolverProvider = Provider<NearbyPreconditionResolver>(
  (ref) {
    if (Platform.isAndroid) {
      return NearbyPreconditionResolverConcreteImplAndroid(
          ref.watch(deviceInfoProvider));
    }

    if (Platform.isIOS) {
      return const NearbyPreconditionResolverConcreteImplIos();
    }

    throw UnimplementedError();
  },
);

final infoFetcherProvider = Provider<UserInfoFetcher>(
  (ref) => UserInfoFetcherImpl(
    ref.watch(deviceInfoProvider),
  ),
);

final deviceInfoProvider = Provider((_) => DeviceInfoPlugin());

/// 현재 fake implementation 으로 할당되어 있는 것에 주의.
///
/// fake implementation 이 아니라면 주석 삭제 해야함.
final myAssetsRepositoryProvider =
    Provider<MyAssetRepository>((_) => MyAssetRepositoryFakeImpl());
