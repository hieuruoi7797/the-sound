import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/image_cache_config.dart';

class OptimizedAvatarImage extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedAvatarImage({
    super.key,
    required this.imageUrl,
    this.radius = 120,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Handle empty URL case
    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        child: Icon(
          Icons.music_note,
          size: radius * 0.6,
          color: Colors.grey[600],
        ),
      );
    }

    // Use a simpler approach that works reliably
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => placeholder ??
            Stack(
              alignment: Alignment.center,
              children: [
                // Background container with music note
                Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.music_note,
                      size: radius * 0.5,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                // Loading indicator positioned at the border
                Positioned.fill(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                    backgroundColor: Colors.grey[400]?.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          errorWidget: (context, url, error) => errorWidget ??
            Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.broken_image,
                size: radius * 0.6,
                color: Colors.grey[700],
              ),
            ),
          // Cache configuration for memory optimization
          memCacheWidth: (radius * 2 * MediaQuery.of(context).devicePixelRatio).round(),
          memCacheHeight: (radius * 2 * MediaQuery.of(context).devicePixelRatio).round(),
          maxWidthDiskCache: (radius * 4).round(),
          maxHeightDiskCache: (radius * 4).round(),
        ),
      ),
    );
  }
}