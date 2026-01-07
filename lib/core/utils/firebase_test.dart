import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/firebase_service.dart';

class FirebaseTest {
  static Future<void> testFirebaseSetup() async {
    debugPrint("=== Firebase Setup Test ===");
    
    // Test 1: Check if Firebase is initialized
    try {
      Firebase.app();
      debugPrint("✅ Firebase Core is initialized");
    } catch (e) {
      debugPrint("❌ Firebase Core initialization failed: $e");
      return;
    }
    
    // Test 2: Check Firebase Messaging availability
    try {
      final messaging = FirebaseMessaging.instance;
      debugPrint("✅ Firebase Messaging instance available");
      
      // Test 3: Check notification settings
      final settings = await messaging.getNotificationSettings();
      debugPrint("📱 Notification authorization status: ${settings.authorizationStatus}");
      debugPrint("📱 Alert setting: ${settings.alert}");
      debugPrint("📱 Badge setting: ${settings.badge}");
      debugPrint("📱 Sound setting: ${settings.sound}");
      
    } catch (e) {
      debugPrint("❌ Firebase Messaging test failed: $e");
    }
    
    // Test 4: Check FirebaseService
    try {
      final firebaseService = FirebaseService();
      debugPrint("📋 FirebaseService initialized: ${firebaseService.isInitialized}");
      debugPrint("🔑 FCM Token available: ${firebaseService.fcmToken != null}");
      if (firebaseService.fcmToken != null) {
        debugPrint("🔑 FCM Token: ${firebaseService.fcmToken}");
      }
    } catch (e) {
      debugPrint("❌ FirebaseService test failed: $e");
    }
    
    debugPrint("=== Firebase Setup Test Complete ===");
  }
}