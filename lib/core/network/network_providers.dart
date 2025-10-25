import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_service.dart';
import 'request_queue_service.dart';

// Connectivity service provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

// Network connectivity status stream provider
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

// Request queue service provider
final requestQueueServiceProvider = Provider<RequestQueueService>((ref) {
  return RequestQueueService(maxRetries: 3);
});

// Combined connectivity state for easier consumption
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(connectivityServiceProvider);
  return service.checkConnectivity();
});
