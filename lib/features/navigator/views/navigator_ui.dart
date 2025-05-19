import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/navigator_view_model.dart';
import '../widgets/navigation_item.dart';

class NavigatorUI extends ConsumerWidget {
  final List<Widget> screens;
  
  const NavigatorUI({
    super.key,
    required this.screens,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigatorViewModelProvider);
    
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(ref, 0, Icons.home, 'Home'),
                _buildNavItem(ref, 1, Icons.smart_toy, 'AI Helper'),
                _buildNavItem(ref, 2, Icons.music_note, 'My Tune'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(WidgetRef ref, int index, IconData icon, String label) {
    final currentIndex = ref.watch(navigatorViewModelProvider);
    final isSelected = currentIndex == index;
    
    return InkWell(
      onTap: () => ref.read(navigatorViewModelProvider.notifier).setTab(index),
      child: NavigationItem(
        icon: icon,
        label: label,
        isSelected: isSelected,
      ),
    );
  }
} 