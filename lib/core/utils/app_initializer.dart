import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../services/firebase_service.dart';

class AppInitializer {
  static bool _firebaseInitialized = false;
  static bool _messagingInitialized = false;
  static bool _crashlyticsInitialized = false;

  static bool get isFirebaseReady => _firebaseInitialized;
  static bool get isMessagingReady => _messagingInitialized;
  static bool get isCrashlyticsReady => _crashlyticsInitialized;

  /// Initialize Firebase Core with error handling
  static Future<bool> initializeFirebase() async {
    try {
      debugPrint("🔥 Initializing Firebase Core...");
      await Firebase.initializeApp();
      _firebaseInitialized = true;
      debugPrint("✅ Firebase Core initialized successfully");
      return true;
    } catch (e, stackTrace) {
      debugPrint("❌ Failed to initialize Firebase Core: $e");
      debugPrint("Stack trace: $stackTrace");
      _firebaseInitialized = false;
      return false;
    }
  }

  /// Initialize Firebase Crashlytics with error handling
  static Future<bool> initializeCrashlytics() async {
    if (!_firebaseInitialized) {
      debugPrint("⚠️ Cannot initialize Crashlytics: Firebase Core not initialized");
      return false;
    }

    try {
      debugPrint("💥 Initializing Firebase Crashlytics...");
      
      // Pass all uncaught Flutter errors to Crashlytics
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      
      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      
      _crashlyticsInitialized = true;
      debugPrint("✅ Firebase Crashlytics initialized successfully");
      return true;
    } catch (e, stackTrace) {
      debugPrint("❌ Failed to initialize Firebase Crashlytics: $e");
      debugPrint("Stack trace: $stackTrace");
      _crashlyticsInitialized = false;
      return false;
    }
  }

  /// Initialize Firebase Messaging with error handling
  static Future<bool> initializeMessaging() async {
    if (!_firebaseInitialized) {
      debugPrint("⚠️ Cannot initialize messaging: Firebase Core not initialized");
      return false;
    }

    try {
      debugPrint("📱 Initializing Firebase Messaging...");
      final firebaseService = FirebaseService();
      await firebaseService.initialize();
      await firebaseService.handleInitialMessage();
      _messagingInitialized = true;
      debugPrint("✅ Firebase Messaging initialized successfully");
      return true;
    } catch (e, stackTrace) {
      debugPrint("❌ Failed to initialize Firebase Messaging: $e");
      debugPrint("Stack trace: $stackTrace");
      _messagingInitialized = false;
      return false;
    }
  }

  /// Set up background message handler
  static void setupBackgroundHandler(Future<void> Function(RemoteMessage) handler) {
    if (_firebaseInitialized) {
      try {
        FirebaseMessaging.onBackgroundMessage(handler);
        debugPrint("✅ Background message handler set up");
      } catch (e) {
        debugPrint("❌ Failed to set up background message handler: $e");
      }
    }
  }

  /// Get initialization status summary
  static Map<String, bool> getStatus() {
    return {
      'firebase_core': _firebaseInitialized,
      'firebase_crashlytics': _crashlyticsInitialized,
      'firebase_messaging': _messagingInitialized,
    };
  }
}