import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/core/presentation/extensions.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_event.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_state.dart';

import 'package:poc/src/nearby/di.dart';
import 'package:poc/src/nearby/presentation/sender/nearby_send_data_section.dart';
import 'package:poc/src/nearby/presentation/sender/nearby_send_receivers_section.dart';
import 'package:poc/src/nearby/presentation/sender/state/ui_send_property.dart';

class NearbySendScreen extends ConsumerWidget {
  const NearbySendScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _reserveRouteForEachNearbyState(context, ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('데이터 전송 하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: _BorderDecorationWidget(
                child: NearbySendReceiversSection(),
              ),
            ),
            const SizedBox(height: 4),
            const Expanded(
              child: _BorderDecorationWidget(
                child: NearbySendDataSection(),
              ),
            ),
            const SizedBox(height: 4),
            ElevatedButton.icon(
              onPressed: ref.watch(uiSendPropertyProvider).isReadySubmit
                  ? () => _showBottomSheetForSend(context, ref)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.colorScheme.onPrimaryContainer,
                foregroundColor: context.theme.colorScheme.onPrimary,
              ),
              icon: const Icon(Icons.send),
              label: const Text('전송'),
            ),
          ],
        ),
      ),
    );
  }

  void _reserveRouteForEachNearbyState(BuildContext context, WidgetRef ref) {
    ref.listen(
      nearbySenderBlocProvider,
      (previous, current) {
        switch (current) {
          case NearbySenderStateNone():
            log('here goes none');
          case NearbySenderStateDiscovering():
            log('here goes discovering');
          case NearbySenderStateRequesting():
            log('here goes requesting');
          case NearbySenderStateConnected():
            showDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.black87,
              builder: (context) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '데이터 보내는 중...',
                      style: context.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                      ),
                    )
                  ],
                );
              },
            );

            ref
                .read(nearbySenderBlocProvider.notifier)
                .mapEventToState(NearbySenderEvent.sendPayload(
                  Uint8List.fromList(
                      ref.read(uiSendPropertyProvider).selectedData!.codeUnits),
                ));

          case NearbySenderStateRejected():
            context.showCustomDialog(
              builder: (context) {
                return Column(
                  children: [
                    Text(
                      '전송 거절',
                      style: context.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    const Text('상대방이 전송을 거절하였습니다.'),
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
            ).then((_) => ref
                .read(nearbySenderBlocProvider.notifier)
                .mapEventToState(
                    const NearbySenderEvent.recoverFromRejection()));
          case NearbySenderStateFailed():
            log(current.message);
            log('here goes failed');
          case NearbySenderStateSuccess():
          // TODO: Handle this case.
        }
      },
    );
  }

  // TODO: 보내려고 pop up 이 떴는데, onEndpointLost 가 발생하면 어떻게 처리할지 고민 필요
  //       route path 를 사용하면 되긴 함
  void _showBottomSheetForSend(BuildContext context, WidgetRef ref) {
    context.showOneThirdBottomSheet(
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To',
                style: context.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                ref.watch(uiSendPropertyProvider).selectedDevice?.name ??
                    'something went wrong',
                style: context.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Data',
                style: context.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                ref.watch(uiSendPropertyProvider).selectedData ??
                    'something went wrong',
                style: context.textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: context.navigator.pop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            context.theme.colorScheme.primaryContainer,
                        foregroundColor: context.theme.colorScheme.primary,
                      ),
                      icon: const Icon(Icons.cancel),
                      label: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.navigator.pop();
                        ref
                            .read(nearbySenderBlocProvider.notifier)
                            .mapEventToState(
                              NearbySenderEvent.requestConnection(
                                ref
                                    .watch(uiSendPropertyProvider)
                                    .selectedDevice!
                                    .id,
                                ref
                                    .watch(uiSendPropertyProvider)
                                    .selectedDevice!
                                    .name,
                                ref.watch(uiSendPropertyProvider).selectedData!,
                              ),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            context.theme.colorScheme.onPrimaryContainer,
                        foregroundColor: context.theme.colorScheme.onPrimary,
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text('보내기'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 테두리 두르고 Padding 넣어주는 위젯
///
/// **private class로 만든 이유**
///
/// - (얼마 차이 나겠냐만은) Widget Method 보다 Widget class 로 생성했을 때 성능상 이점이
/// 있다고 함
/// - private 으로 만든 이유는 여기서만 사용되고 사용되지 않을거 같아서임
class _BorderDecorationWidget extends StatelessWidget {
  const _BorderDecorationWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 2.0,
          color: context.theme.dividerColor,
        ),
      ),
      child: child,
    );
  }
}
