import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/core/presentation/extensions.dart';
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

            context.showOneThirdBottomSheet(
              builder: (context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'From',
                      style: context.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: context.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Data',
                      style: context.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      dataName,
                      style: context.textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.navigator.pop(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  context.theme.colorScheme.onPrimaryContainer,
                              foregroundColor:
                                  context.theme.colorScheme.onPrimary,
                            ),
                            icon: const Icon(Icons.cancel),
                            label: const Text('취소'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.navigator.pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  context.theme.colorScheme.primaryContainer,
                              foregroundColor:
                                  context.theme.colorScheme.primary,
                            ),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('확인'),
                          ),
                        )
                      ],
                    ),
                  ],
                );
              },
            ).then(
              (isAccepted) {
                if (isAccepted == null) {
                  ref.read(nearbyReceiverBlocProvider.notifier).mapEventToState(
                        NearbyReceiverEvent.rejectRequest(current.endpointId),
                      );
                  return;
                }

                if (isAccepted) {
                  ref.read(nearbyReceiverBlocProvider.notifier).mapEventToState(
                        NearbyReceiverEvent.acceptRequest(current.endpointId),
                      );
                } else {
                  ref.read(nearbyReceiverBlocProvider.notifier).mapEventToState(
                        NearbyReceiverEvent.rejectRequest(current.endpointId),
                      );
                }
              },
            );
          case NearbyReceiverStateConnected() || NearbyReceiverStateReceiving():
            showDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.black87,
              builder: (context) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      current is NearbyReceiverStateConnected
                          ? '연결중...'
                          : '데이터 받는중...',
                      style: context.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                      ),
                    )
                  ],
                );
              },
            );

          case NearbyReceiverStateSuccess():
            context.showCustomDialog(
              builder: (context) {
                return Column(
                  children: [
                    Text(
                      '전송 성공',
                      style: context.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    const Text('데이터를 성공적으로 받았습니다!'),
                    const SizedBox(height: 12),
                    Text('데이터: ${current.dataName}'),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: context.navigator.pop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              context.theme.colorScheme.onPrimaryContainer,
                          foregroundColor: context.theme.colorScheme.onPrimary,
                        ),
                        child: const Text('확인'),
                      ),
                    ),
                  ],
                );
              },
            );
          case NearbyReceiverStateFailed():
            context.showCustomDialog(
              builder: (context) {
                return Column(
                  children: [
                    Text(
                      '전송 실패',
                      style: context.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    const Text('데이터 수신에 실패했습니다.\n다시 시도해주세요.'),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: context.navigator.pop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              context.theme.colorScheme.onPrimaryContainer,
                          foregroundColor: context.theme.colorScheme.onPrimary,
                        ),
                        child: const Text('확인'),
                      ),
                    ),
                  ],
                );
              },
            );
          default:
            break;
        }
      },
    );
  }
}
