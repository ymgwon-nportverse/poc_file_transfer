import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/nearby/application/bloc/nearby_event.dart';
import 'package:poc/src/nearby/application/bloc/nearby_state.dart';
import 'package:poc/src/nearby/di.dart';
import 'package:poc/src/nearby/presentation/nearby_receive_section.dart';
import 'package:poc/src/nearby/presentation/nearby_send_section.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  TransferMode _mode = TransferMode.none;

  @override
  Widget build(BuildContext context) {
    ref.listen(
      nearbyBlocProvider,
      (previous, current) {
        switch (current) {
          case NearbyStateNone(userName: var userName):
            log('$userName is added');
          case NearbyStateAdvertising():
            log('Here goes advertising');
          case NearbyStateDiscovering():
            log('Here goes discovering');
          case NearbyStateConnecting():
            log('Here goes connecting');
          case NearbyStateConnected():
            log('Here goes connected');
          case NearbyStateFailed():
            log('Here goes failed');
        }
      },
    );

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nearby Connections Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('데이터 보내기/받기'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _mode = TransferMode.send;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                _colorByMode(TransferMode.send)),
                          ),
                          child: const Text('Send'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(nearbyBlocProvider.notifier)
                                .mapEventToState(const NearbyEvent.advertise());
                            setState(() {
                              _mode = TransferMode.receive;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                _colorByMode(TransferMode.receive)),
                          ),
                          child: const Text('Receive'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_mode != TransferMode.none)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ref
                                .read(nearbyBlocProvider.notifier)
                                .mapEventToState(const NearbyEvent.end());
                            setState(() {
                              _mode = TransferMode.none;
                            });
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      _widgetByMode(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _widgetByMode() {
    return switch (_mode) {
      TransferMode.send => NearbySendSection(
          onSubmit: () => ref
              .read(nearbyBlocProvider.notifier)
              .mapEventToState(const NearbyEvent.discover()),
        ),
      TransferMode.receive => const NearbyReceiveSection(),
      TransferMode.none => throw UnimplementedError(),
    };
  }

  Color _colorByMode(TransferMode targetMode) {
    if (_mode == targetMode) {
      return Theme.of(context).buttonTheme.colorScheme!.primaryContainer;
    } else {
      return Theme.of(context).buttonTheme.colorScheme!.background;
    }
  }
}

enum TransferMode {
  none,
  send,
  receive,
}
