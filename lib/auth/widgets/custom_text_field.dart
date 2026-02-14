import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
