import 'package:flutter/material.dart';
import '../views/navigator_ui.dart';
import '../widgets/placeholder_screen.dart';
import '../../home/views/home_screen.dart';
import '../../my_tune/my_tune_view.dart';

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigatorUI(
      screens: const [
        // Home Screen
        HomeScreen(),
        MyTuneView(),
        // AI Helper Screen
        PlaceholderScreen(
          title: 'AI Helper',
          icon: Icons.settings,
        ),
      ],
    );
  }
} 