import 'package:flutter/material.dart';
import 'package:poc/src/nearby/presentation/nearby_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NearbyScreen(),
                ),
              ),
              child: const Text('Nearby Example Page'),
            )
          ],
        ),
      ),
    );
  }
}
