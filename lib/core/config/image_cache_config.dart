import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheConfig {
  static const String cacheKey = 'soundImageCache';
  
  static CacheManager get cacheManager => CacheManager(
    Config(
      cacheKey,
      stalePeriod: const Duration(days: 7), // Cache for 7 days
      maxNrOfCacheObjects: 200, // Maximum 200 cached images
      repo: JsonCacheInfoRepository(databaseName: cacheKey),
      fileService: HttpFileService(),
    ),
  );

  /// Configure global image cache settings
  static void configureImageCache() {
    // Set image cache size (in bytes) - 100MB
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024;
    
    // Set maximum number of images in memory cache
    PaintingBinding.instance.imageCache.maximumSize = 100;
  }

  /// Clear all cached images
  static Future<void> clearCache() async {
    await cacheManager.emptyCache();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Get cache size information
  static Future<Map<String, dynamic>> getCacheInfo() async {
    final cacheSize = await cacheManager.store.getCacheSize();
    final memoryCache = PaintingBinding.instance.imageCache;
    
    return {
      'diskCacheSize': cacheSize,
      'memoryCacheSize': memoryCache.currentSize,
      'memoryCacheMaxSize': memoryCache.maximumSize,
      'memoryCacheSizeBytes': memoryCache.currentSizeBytes,
      'memoryCacheMaxSizeBytes': memoryCache.maximumSizeBytes,
    };
  }
}