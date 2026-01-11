import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

/// Optimized rectangular image widget for cards and thumbnails
class OptimizedRectangleImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedRectangleImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Handle empty URL case
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius,
        ),
        child: Icon(
          Icons.music_note,
          size: (width != null && height != null) ? (width! + height!) / 8 : 24,
          color: Colors.grey[600],
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => placeholder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.music_note,
                    size: (width != null && height != null) ? (width! + height!) / 8 : 24,
                    color: Colors.grey[600],
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          errorWidget: (context, url, error) => errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[400],
              child: Icon(
                Icons.broken_image,
                size: (width != null && height != null) ? (width! + height!) / 8 : 24,
                color: Colors.grey[700],
              ),
            ),
          // Cache configuration for memory optimization
          memCacheWidth: width != null ? (width! * MediaQuery.of(context).devicePixelRatio).round() : null,
          memCacheHeight: height != null ? (height! * MediaQuery.of(context).devicePixelRatio).round() : null,
          maxWidthDiskCache: width != null ? (width! * 2).round() : null,
          maxHeightDiskCache: height != null ? (height! * 2).round() : null,
        ),
      ),
    );
  }
}

/// Optimized square image widget for grid items
class OptimizedSquareImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final ColorFilter? colorFilter;
  final Widget? overlay;

  const OptimizedSquareImage({
    super.key,
    required this.imageUrl,
    required this.size,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.colorFilter,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    // Handle empty URL case
    if (imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius,
        ),
        child: Icon(
          Icons.music_note,
          size: size * 0.4,
          color: Colors.grey[600],
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.zero,
            child: ColorFiltered(
              colorFilter: colorFilter ?? const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                // width: size,
                // height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => placeholder ??
                  Container(
                    width: size,
                    height: size,
                    color: Colors.grey[300],
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: size * 0.4,
                          color: Colors.grey[600],
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                errorWidget: (context, url, error) => errorWidget ??
                  Container(
                    width: size,
                    height: size,
                    color: Colors.grey[400],
                    child: Icon(
                      Icons.broken_image,
                      size: size * 0.4,
                      color: Colors.grey[700],
                    ),
                  ),
                // Cache configuration for memory optimization
                memCacheWidth: (size * MediaQuery.of(context).devicePixelRatio).round(),
                memCacheHeight: (size * MediaQuery.of(context).devicePixelRatio).round(),
                maxWidthDiskCache: (size * 2).round(),
                maxHeightDiskCache: (size * 2).round(),
              ),
            ),
          ),
          if (overlay != null) overlay!,
        ],
      ),
    );
  }
}