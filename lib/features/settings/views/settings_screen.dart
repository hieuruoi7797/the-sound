import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                value: '5 second',
                subtitle: 'Gently increase the volume at the start of playback for a smoother listening experience',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.linear_scale,
                title: 'Fade Out',
                value: '5 second',
                subtitle: 'Slowly lower the volume at the end of playback to avoid abrupt stops',
                onTap: () {},
              ),
              // _buildSettingItem(
              //   icon: Icons.layers,
              //   title: 'Background Audio',
              //   subtitle: 'Keep your sound playing while using other apps — perfect for multitasking with music, podcasts, or audiobooks',
              //   trailing: Switch(
              //     value: true, // This will be managed by the view model
              //     onChanged: (value) {},
              //     activeColor: Colors.purple,
              //   ),
              // ),
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
              // _buildSettingItem(
              //   icon: Icons.language,
              //   title: 'Language',
              //   value: 'English',
              //   onTap: () {},
              // ),
              // _buildSettingItem(
              //   icon: Icons.notifications_none,
              //   title: 'Reminder',
              //   value: 'Off',
              //   onTap: () {},
              // ),
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
} 