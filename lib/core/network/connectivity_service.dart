import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  /// Stream that emits [true] when connected, [false] when disconnected
  Stream<bool> get connectivityStream => _connectivity.onConnectivityChanged
    .map((List<ConnectivityResult> result) {
      // Check if any connectivity result indicates an active connection
      return !result.contains(ConnectivityResult.none);
    });

  /// Check current connectivity status
  /// Returns [true] if device has internet connection, [false] otherwise
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
