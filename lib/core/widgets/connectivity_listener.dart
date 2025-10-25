import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/network_providers.dart';

/// Widget that listens to connectivity changes globally
/// and shows a connectivity indicator when offline
class ConnectivityListener extends ConsumerWidget {
  final Widget child;

  const ConnectivityListener({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityStatusProvider);

    return Stack(
      children: [
        child,
        connectivityState.when(
          data: (isConnected) {
            if (!isConnected) {
              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
