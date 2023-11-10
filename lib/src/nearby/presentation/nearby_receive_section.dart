import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NearbyReceiveSection extends ConsumerWidget {
  const NearbyReceiveSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(child: CircularProgressIndicator.adaptive()),
      ],
    );
  }
}
