import 'package:flutter/material.dart';
import 'package:mytune/core/widgets/optimized_avatar_image.dart';

class MiniPlayer extends StatelessWidget {
  final String title;
  final String artist;
  final String imageUrl;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            OptimizedSquareImage(
              imageUrl: imageUrl,
              size: 40,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artist,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onPlayPause,
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 