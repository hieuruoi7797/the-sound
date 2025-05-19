import 'package:flutter/material.dart';

class SocialDivider extends StatelessWidget {
  final String text;

  const SocialDivider({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Colors.grey),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        const Expanded(
          child: Divider(color: Colors.grey),
        ),
      ],
    );
  }
} 