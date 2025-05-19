import 'package:flutter/material.dart';
import '../views/navigator_ui.dart';
import '../widgets/placeholder_screen.dart';
import '../../home/views/home_screen.dart';

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigatorUI(
      screens: const [
        // Home Screen
        HomeScreen(),
        // AI Helper Screen
        PlaceholderScreen(
          title: 'AI Helper',
          icon: Icons.smart_toy,
        ),
        // My Tune Screen
        PlaceholderScreen(
          title: 'My Tune',
          icon: Icons.music_note,
        ),
      ],
    );
  }
} 