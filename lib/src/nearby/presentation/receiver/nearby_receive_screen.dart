import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_event.dart';
import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_state.dart';
import 'package:poc/src/nearby/di.dart';

/// 데이터 전송 받기 화면
class NearbyReceiveScreen extends ConsumerWidget {
  const NearbyReceiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _reserveRouteInEachNearbyState(context, ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('데이터 전송 받기'),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator.adaptive(),
            SizedBox(height: 18),
            Text('상대방의 신호를 탐색 중입니다.')
          ],
        ),
      ),
    );
  }

  /// [NearbyReceiverState.responding] 즉, 송신자 에서 전송 지정할 때
  /// 상태가 되었을 때만, ModalBottomSheet 을 보여주도록 되어있음에 주의.
  void _reserveRouteInEachNearbyState(
    BuildContext context,
    WidgetRef ref,
  ) {
    ref.listen(
      nearbyReceiverBlocProvider,
      (previous, current) {
        switch (current) {
          case NearbyReceiverStateResponding():
            final concatenatedName = current.connectionInfo.endpointName;
            final userName = concatenatedName.split('|')[0];
            final dataName = concatenatedName.split('|')[1];

            context.navigator.pushNamed<bool>(
              '/nearby/receive/confirm',
              arguments: {
                'userName': userName,
                'dataName': dataName,
              },
            ).then(
              (isAccepted) {
                /// 거절 버튼을 누른 것이 아니라, 창을 닫은 경우에도 거절로 처리하는 것 주의
                if (isAccepted == null || !isAccepted) {
                  ref.read(nearbyReceiverBlocProvider.notifier).mapEventToState(
                        NearbyReceiverEvent.rejectRequest(current.endpointId),
                      );
                  return;
                } else {
                  ref.read(nearbyReceiverBlocProvider.notifier).mapEventToState(
                        NearbyReceiverEvent.acceptRequest(current.endpointId),
                      );
                }
              },
            );
          case NearbyReceiverStateConnected() || NearbyReceiverStateReceiving():
            context.navigator
                .popUntil((route) => route.settings.name == '/nearby/receive');
            context.navigator.pushNamed(
              '/nearby/receive/process',
              arguments: {
                'message': current is NearbyReceiverStateConnected
                    ? '연결중...'
                    : '데이터 받는중...',
              },
            );
          case NearbyReceiverStateSuccess():
            context.navigator
                .popUntil((route) => route.settings.name == '/nearby/receive');
            context.navigator.pushNamed(
              '/nearby/receive/success',
              arguments: {
                'dataName': current.dataName,
              },
            ).then(
              (_) => context.navigator
                  .popUntil((route) => route.settings.name == '/nearby'),
            );
          case NearbyReceiverStateFailed():
            context.navigator
                .popUntil((route) => route.settings.name == '/nearby/receive');
            context.navigator
                .pushNamed(
                  '/nearby/receive/failure',
                )
                .then(
                  (_) => context.navigator
                      .popUntil((route) => route.settings.name == '/nearby'),
                );
          default:
            break;
        }
      },
    );
  }
}
