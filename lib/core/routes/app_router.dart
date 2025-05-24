import 'package:flutter/material.dart';
import 'package:mytune/features/recording/views/recording_view.dart';
import '../../features/user/views/user_list_view.dart';
import '../../features/navigator/views/app_navigator.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const AppNavigator());
      
      case RouteNames.userList:
        return MaterialPageRoute(builder: (_) => const UserListView());
      
      case RouteNames.recording:
        return MaterialPageRoute(builder: (_) => const RecordingView());

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