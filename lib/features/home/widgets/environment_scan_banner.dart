import 'package:flutter/material.dart';
import '../../../../core/constants/assets.dart'; // Make sure this contains recording_banner.png path
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/recording_banner.png'), // recording_banner.png
            fit: BoxFit.cover,
          ),
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
        foregroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF00000099),
              const Color(0xFF00000000),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                'Environment Scan',
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Discover sounds that suit your space',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 17,
                  color: const Color(0xFF7E7B8F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}