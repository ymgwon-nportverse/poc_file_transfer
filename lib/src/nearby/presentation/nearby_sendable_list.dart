import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/nearby/application/bloc/nearby_state.dart';
import 'package:poc/src/nearby/di.dart';

class NearbySendableList extends ConsumerWidget {
  const NearbySendableList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyState = ref.watch(nearbyBlocProvider);
    if (nearbyState is NearbyStateDiscovering) {
      return Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => _showBottomSheet(
                context,
                nearbyState.devices[index],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Text(nearbyState.devices[index].name),
              ),
            );
          },
          itemCount: nearbyState.devices.length,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void _showBottomSheet(BuildContext context, NearbyDevice device) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          height: MediaQuery.of(context).size.height / 3,
          child: Material(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Text(
                    '연결 하기',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text("id: ${device.id}"),
                  Text("Name: ${device.name}"),
                  ElevatedButton(
                    child: const Text("Request Connection"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
