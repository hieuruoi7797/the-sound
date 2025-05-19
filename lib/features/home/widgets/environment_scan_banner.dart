import 'package:flutter/material.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../core/constants/text_styles.dart';

class EnvironmentScanBanner extends StatelessWidget {
  const EnvironmentScanBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RouteNames.recording);
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 190,
          maxWidth: 400,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.padding,
          vertical: AppSizes.spaceBtwItems,
        ),
        padding: const EdgeInsets.all(AppSizes.padding * 1.5),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text(
              'Environment Scan',
              style: AppTextStyles.heading1.copyWith(
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Discover sounds that suit your space',
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFFB0B0C3),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
} 