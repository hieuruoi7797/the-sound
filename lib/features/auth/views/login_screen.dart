import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mytune/core/constants/assets.dart';
import 'package:mytune/core/constants/colors.dart';
import 'package:mytune/core/constants/sizes.dart';
import 'package:mytune/core/constants/text_styles.dart';
import 'package:mytune/core/widgets/custom_button.dart';
import 'package:mytune/core/widgets/custom_text_field.dart';
import 'package:mytune/features/auth/widgets/social_button.dart';
import 'package:mytune/features/auth/widgets/social_divider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    // TODO: Implement login logic
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.spaceBtwSections),
                Text(
                  l10n.loginTitle,
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: AppSizes.spaceBtwItems),
                CustomTextField(
                  controller: _emailController,
                  hintText: l10n.emailHint,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSizes.spaceBtwItems),
                CustomTextField(
                  controller: _passwordController,
                  hintText: l10n.passwordHint,
                  isPassword: true,
                ),
                const SizedBox(height: AppSizes.spaceBtwItems),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: Text(
                      l10n.forgotPassword,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spaceBtwSections),
                CustomButton(
                  text: l10n.loginButton,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: AppSizes.spaceBtwSections),
                SocialDivider(text: l10n.orText),
                const SizedBox(height: AppSizes.spaceBtwSections),
                SocialButton(
                  text: l10n.continueWithGoogle,
                  icon: Assets.googleIcon,
                  onPressed: () {
                    // TODO: Implement Google sign in
                  },
                ),
                const SizedBox(height: AppSizes.spaceBtwItems),
                SocialButton(
                  text: l10n.continueWithApple,
                  icon: Assets.appleIcon,
                  onPressed: () {
                    // TODO: Implement Apple sign in
                  },
                ),
                const SizedBox(height: AppSizes.spaceBtwSections),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.dontHaveAccount,
                      style: AppTextStyles.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to sign up screen
                      },
                      child: Text(
                        l10n.signUp,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 