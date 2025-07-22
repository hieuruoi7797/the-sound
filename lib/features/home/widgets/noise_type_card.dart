import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoiseTypeCard extends StatelessWidget {
  final String title;
  final String icon;
  final Color color;

  const NoiseTypeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: () {
              final lowerTitle = title.toLowerCase();
              if (lowerTitle.contains('white')) {
                return SvgPicture.asset('assets/icons/white_noise.svg', height: 24, width: 24);
              } else if (lowerTitle.contains('gray')) {
                return SvgPicture.asset('assets/icons/gray_noise.svg', height: 24, width: 24);
              } else if (lowerTitle.contains('blue')) {
                return SvgPicture.asset('assets/icons/blue_noise.svg', height: 24, width: 24);
              } else if (lowerTitle.contains('violet')) {
                return SvgPicture.asset('assets/icons/violet_noise.svg', height: 24, width: 24);
              } else if (lowerTitle.contains('brown')) {
                return SvgPicture.asset('assets/icons/brown_noise.svg', height: 24, width: 24);
              } else if (lowerTitle.contains('green')) {
                return SvgPicture.asset('assets/icons/green_noise.svg', height: 24, width: 24);
              } else if (lowerTitle.contains('pink')) {
                return SvgPicture.asset('assets/icons/pink_noise.svg', height: 24, width: 24);
              } else {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    image: DecorationImage(
                      image: NetworkImage(icon),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                );
              }
            }(),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 