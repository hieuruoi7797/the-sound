import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/user/viewmodels/user_view_model.dart';
import 'core/routes/app_router.dart';
import 'core/routes/route_names.dart';
import 'core/config/image_cache_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/widgets/connectivity_listener.dart';
import 'core/utils/app_initializer.dart';
import 'core/utils/firebase_test.dart';
import 'l10n/app_localizations.dart';

// Define a top-level named handler for background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background,
  // such as Firestore, make sure you call `initializeApp` before using
  // any Firebase services. Note: this is already called in your main function.
  // await Firebase.initializeApp();

  debugPrint("Handling a background message: ${message.messageId}");
  // Add your background message handling logic here
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Configure image cache for better performance
    ImageCacheConfig.configureImageCache();

    // Initialize Firebase Core
    final firebaseInitialized = await AppInitializer.initializeFirebase();
    
    if (firebaseInitialized) {
      // Set up background message handler
      AppInitializer.setupBackgroundHandler(_firebaseMessagingBackgroundHandler);

      // Initialize Firebase Messaging service
      await AppInitializer.initializeMessaging();
    } else {
      debugPrint("⚠️ Running app without Firebase features");
    }

    // Run Firebase setup test in debug mode
    if (kDebugMode && firebaseInitialized) {
      // Delay the test to allow Firebase to fully initialize
      Future.delayed(const Duration(seconds: 3), () {
        FirebaseTest.testFirebaseSetup();
      });
    }

    final prefs = await SharedPreferences.getInstance();
    
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint("❌ Fatal error during app initialization: $e");
    debugPrint("Stack trace: $stackTrace");
    
    // Try to run the app with minimal features
    try {
      final prefs = await SharedPreferences.getInstance();
      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MyApp(),
        ),
      );
    } catch (fallbackError) {
      debugPrint("❌ Fallback initialization also failed: $fallbackError");
      // At this point, we can't recover
      rethrow;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Sound',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: "Public Sans",
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('vi'), // Vietnamese
      ],
      initialRoute: RouteNames.home,
      onGenerateRoute: AppRouter.generateRoute,
      builder: (context, child) {
        return ConnectivityListener(child: child!);
      },
    );
  }
}