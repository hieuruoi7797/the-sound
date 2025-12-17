import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImagePreloaderService {
  static final ImagePreloaderService _instance = ImagePreloaderService._internal();
  factory ImagePreloaderService() => _instance;
  ImagePreloaderService._internal();

  final Set<String> _preloadedImages = {};
  final Set<String> _preloadingImages = {};

  /// Preload a single image
  Future<void> preloadImage(String imageUrl, BuildContext context) async {
    if (_preloadedImages.contains(imageUrl) || _preloadingImages.contains(imageUrl)) {
      return;
    }

    _preloadingImages.add(imageUrl);
    
    try {
      await precacheImage(
        CachedNetworkImageProvider(imageUrl),
        context,
      );
      _preloadedImages.add(imageUrl);
    } catch (e) {
      debugPrint('Failed to preload image: $imageUrl, Error: $e');
    } finally {
      _preloadingImages.remove(imageUrl);
    }
  }

  /// Preload multiple images
  Future<void> preloadImages(List<String> imageUrls, BuildContext context) async {
    final futures = imageUrls.map((url) => preloadImage(url, context));
    await Future.wait(futures);
  }

  /// Check if image is already preloaded
  bool isPreloaded(String imageUrl) {
    return _preloadedImages.contains(imageUrl);
  }

  /// Clear preloaded images cache
  void clearCache() {
    _preloadedImages.clear();
    _preloadingImages.clear();
  }
}