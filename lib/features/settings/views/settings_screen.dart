import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/settings_view_model.dart';
import 'fade_setting_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider);
    final settingsNotifier = ref.read(settingsViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: const Color(0xFF141318),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Sound Control
              const Text(
                'SOUND CONTROL',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              _buildSettingItem(
                icon: Icons.graphic_eq,
                title: 'Fade In',
                value: _formatFade(settings.fadeInSeconds),
                subtitle: 'Gently increase the volume at the start of playback for a smoother listening experience',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FadeSettingScreen(
                        title: 'Fade In',
                        selectedSeconds: settings.fadeInSeconds,
                        options: [0, 5, 10, 30, 60, 120, 300, 600],
                        onSelected: (value) => settingsNotifier.setFadeInSeconds(value),
                      ),
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.linear_scale,
                title: 'Fade Out',
                value: _formatFade(settings.fadeOutSeconds),
                subtitle: 'Slowly lower the volume at the end of playback to avoid abrupt stops',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FadeSettingScreen(
                        title: 'Fade Out',
                        selectedSeconds: settings.fadeOutSeconds,
                        options: [0, 5, 10, 30, 60, 120, 300, 600],
                        onSelected: (value) => settingsNotifier.setFadeOutSeconds(value),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // General
              const Text(
                'GENERAL',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              _buildSettingItem(
                icon: Icons.thumb_up_alt_outlined,
                title: 'Rate us',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.share_outlined,
                title: 'Share this app',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.shield_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.description_outlined,
                title: 'Term of Use',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? value,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                if (value != null)
                  Text(
                    value,
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                if (trailing == null && onTap != null)
                  Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                if (trailing != null) trailing,
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 36.0),
                child: Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatFade(int seconds) {
    if (seconds == 0) return '0 second';
    if (seconds < 60) return '$seconds second';
    if (seconds % 60 == 0) return '${seconds ~/ 60} minute';
    return '${seconds ~/ 60} minute ${seconds % 60} second';
  }
} 