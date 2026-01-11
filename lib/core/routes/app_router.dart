import 'package:flutter/material.dart';
import 'package:mytune/features/home/views/mode_sounds_screen.dart';
import 'package:mytune/features/recording/views/recording_view.dart';
import 'package:mytune/features/home/views/home_screen.dart';
import 'package:mytune/features/settings/views/settings_screen.dart';
import '../../features/user/views/user_list_view.dart';
import '../../features/navigator/views/app_navigator.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case RouteNames.userList:
        return MaterialPageRoute(builder: (_) => const UserListView());
      
      case RouteNames.recording:
        return MaterialPageRoute(builder: (_) => const RecordingView());

      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case '/modeSounds':
        final args = settings.arguments as Map<String, dynamic>?;
        final title = args?['title'] as String? ?? '';
        final tag = args?['tag'] as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => ModeSoundsScreen(title: title, tag: tag),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
} 