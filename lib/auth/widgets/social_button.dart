import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onTap;

  const SocialButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1C52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
