import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  String? _fcmToken;
  bool _isInitialized = false;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase Messaging with proper error handling
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint("🔥 Initializing Firebase Messaging...");
      
      // Request notification permissions first
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint("📱 Notification permission status: ${settings.authorizationStatus}");

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted notification permission');
        
        // Set up foreground notification presentation options
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // Set up message handlers
        _setupMessageHandlers();

        // Get FCM token with retry logic
        await _getFCMTokenWithRetry();

        // Listen for token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((token) {
          debugPrint("🔄 FCM Token refreshed: $token");
          _fcmToken = token;
          // TODO: Send token to your server
        }).onError((error) {
          debugPrint("❌ Error in token refresh listener: $error");
        });

        _isInitialized = true;
        debugPrint("✅ Firebase Messaging initialized successfully");
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('⚠️ User granted provisional notification permission');
        _isInitialized = true;
      } else {
        debugPrint('❌ User declined notification permission');
        _isInitialized = true; // Still mark as initialized to prevent retries
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing Firebase Messaging: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't mark as initialized so it can be retried later
    }
  }

  /// Get FCM token with retry logic for iOS APNS token delay
  Future<void> _getFCMTokenWithRetry() async {
    int maxRetries = Platform.isIOS ? 5 : 3;
    int retryDelay = Platform.isIOS ? 3 : 1; // seconds

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // On iOS, wait a bit longer on first attempt to allow APNS token to be set
        if (Platform.isIOS && attempt == 1) {
          debugPrint("iOS detected: Waiting for APNS token to be available...");
          await Future.delayed(Duration(seconds: retryDelay * 2));
        }

        _fcmToken = await FirebaseMessaging.instance.getToken();
        
        if (_fcmToken != null) {
          debugPrint("✅ FCM Token obtained successfully (attempt $attempt): $_fcmToken");
          // TODO: Send token to your server
          return;
        } else {
          debugPrint("⚠️ FCM Token is null (attempt $attempt)");
        }
      } catch (e) {
        if (e.toString().contains('apns-token-not-set')) {
          debugPrint("⚠️ APNS token not set yet (attempt $attempt). This is normal on iOS - waiting...");
        } else {
          debugPrint("❌ Error getting FCM token (attempt $attempt): $e");
        }
        
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: retryDelay));
        }
      }
    }

    debugPrint("⚠️ FCM Token not available after $maxRetries attempts. Will be handled by onTokenRefresh.");
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.messageId}');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message notification: ${message.notification!.title} - ${message.notification!.body}');
        // TODO: Show local notification or handle in-app
      }
    });

    // Handle notification taps when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification tapped: ${message.messageId}');
      debugPrint('Message data: ${message.data}');
      // TODO: Navigate to specific screen based on message data
    });
  }

  /// Handle initial message when app is launched from terminated state
  Future<void> handleInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    
    if (initialMessage != null) {
      debugPrint('App launched from notification: ${initialMessage.messageId}');
      debugPrint('Message data: ${initialMessage.data}');
      // TODO: Navigate to specific screen based on message data
    }
  }
}