import 'dart:async';

typedef AsyncRequest = Future<void> Function();

/// Represents a queued request that can be retried
class QueuedRequest {
  final String id;
  final String resourceType; // 'audio', 'image', 'thumbnail', etc.
  final String resourceUrl;
  final AsyncRequest request;
  final Completer<void> completer;
  int retryCount;

  QueuedRequest({
    required this.id,
    required this.resourceType,
    required this.resourceUrl,
    required this.request,
    this.retryCount = 0,
  }) : completer = Completer<void>();
}

/// Service to manage a queue of failed requests
/// Retries them when connectivity is restored
class RequestQueueService {
  final Map<String, QueuedRequest> _queue = {};
  final int maxRetries;
  bool _isProcessing = false;

  RequestQueueService({this.maxRetries = 3});

  /// Add a request to the queue
  /// Returns a Future that completes when the request succeeds or max retries exceeded
  Future<void> queueRequest({
    required String resourceType,
    required String resourceUrl,
    required AsyncRequest request,
  }) async {
    final id = '${resourceType}_${resourceUrl.hashCode}';
    
    final queuedRequest = QueuedRequest(
      id: id,
      resourceType: resourceType,
      resourceUrl: resourceUrl,
      request: request,
    );
    
    _queue[id] = queuedRequest;
    print('[RequestQueue] Queued request: $resourceType - $resourceUrl');
    
    return queuedRequest.completer.future;
  }

  /// Process all queued requests
  /// Called when connectivity is restored
  Future<void> processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;
    
    _isProcessing = true;
    print('[RequestQueue] Processing ${_queue.length} queued requests');
    
    final requestsToProcess = List<QueuedRequest>.from(_queue.values);
    
    for (final queuedRequest in requestsToProcess) {
      try {
        print('[RequestQueue] Executing ${queuedRequest.resourceType} - ${queuedRequest.resourceUrl}');
        await queuedRequest.request();
        
        _queue.remove(queuedRequest.id);
        queuedRequest.completer.complete();
        print('[RequestQueue] Request completed: ${queuedRequest.id}');
        
      } catch (e) {
        queuedRequest.retryCount++;
        
        if (queuedRequest.retryCount >= maxRetries) {
          print('[RequestQueue] Max retries exceeded for ${queuedRequest.id}');
          _queue.remove(queuedRequest.id);
          queuedRequest.completer.completeError(e);
        } else {
          print('[RequestQueue] Retry ${queuedRequest.retryCount}/$maxRetries for ${queuedRequest.id}');
        }
      }
    }
    
    _isProcessing = false;
    print('[RequestQueue] Queue processing completed. Remaining: ${_queue.length}');
  }

  /// Get count of pending requests
  int get pendingCount => _queue.length;

  /// Get pending requests by type
  List<QueuedRequest> getPendingByType(String resourceType) {
    return _queue.values
        .where((req) => req.resourceType == resourceType)
        .toList();
  }

  /// Clear all queued requests
  void clearQueue() {
    for (final request in _queue.values) {
      request.completer.completeError(
        Exception('Queue cleared'),
      );
    }
    _queue.clear();
    print('[RequestQueue] Queue cleared');
  }

  /// Remove a specific request from the queue
  void removeRequest(String resourceType, String resourceUrl) {
    final id = '${resourceType}_${resourceUrl.hashCode}';
    _queue.remove(id);
  }
}
