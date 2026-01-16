import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../config/image_cache_config.dart';

class CacheManagementService {
  static const String _lastEnvironmentKey = 'last_environment';
  static const String _dataVersionKey = 'data_version';
  
  /// Check if environment has changed and clear cache if needed
  static Future<void> checkAndClearCacheIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastEnvironment = prefs.getString(_lastEnvironmentKey);
      final currentEnvironment = AppConfig.environmentKey;
      
      debugPrint('🔄 Cache check - Last: $lastEnvironment, Current: $currentEnvironment');
      
      if (lastEnvironment != currentEnvironment) {
        debugPrint('🧹 Environment changed, clearing image cache...');
        await clearAllCache();
        await prefs.setString(_lastEnvironmentKey, currentEnvironment);
        debugPrint('✅ Cache cleared for environment change');
      }
    } catch (e) {
      debugPrint('❌ Error checking cache: $e');
    }
  }
  
  /// Clear all cached data (images, preferences, etc.)
  static Future<void> clearAllCache() async {
    try {
      // Clear image cache
      await ImageCacheConfig.clearCache();
      
      // Clear any other cached data if needed
      debugPrint('🧹 All cache cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }
  
  /// Force refresh cache (useful for manual refresh)
  static Future<void> forceRefreshCache() async {
    debugPrint('🔄 Force refreshing cache...');
    await clearAllCache();
    debugPrint('✅ Cache force refreshed');
  }
  
  /// Set data version to track updates
  static Future<void> setDataVersion(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dataVersionKey, version);
      debugPrint('📝 Data version set to: $version');
    } catch (e) {
      debugPrint('❌ Error setting data version: $e');
    }
  }
  
  /// Get current data version
  static Future<String?> getDataVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_dataVersionKey);
    } catch (e) {
      debugPrint('❌ Error getting data version: $e');
      return null;
    }
  }
  
  /// Check if data version has changed and clear cache if needed
  static Future<void> checkDataVersionAndClearCache(String newVersion) async {
    try {
      final currentVersion = await getDataVersion();
      
      if (currentVersion != newVersion) {
        debugPrint('🔄 Data version changed from $currentVersion to $newVersion');
        await clearAllCache();
        await setDataVersion(newVersion);
        debugPrint('✅ Cache cleared for data version change');
      }
    } catch (e) {
      debugPrint('❌ Error checking data version: $e');
    }
  }
  
  /// Get cache information for debugging
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final imageCache = await ImageCacheConfig.getCacheInfo();
      final prefs = await SharedPreferences.getInstance();
      final lastEnv = prefs.getString(_lastEnvironmentKey);
      final dataVersion = prefs.getString(_dataVersionKey);
      
      return {
        'imageCache': imageCache,
        'lastEnvironment': lastEnv,
        'currentEnvironment': AppConfig.environmentKey,
        'dataVersion': dataVersion,
      };
    } catch (e) {
      debugPrint('❌ Error getting cache info: $e');
      return {};
    }
  }
}