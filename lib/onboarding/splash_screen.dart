import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sufar_project/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A94C4), // Light Blue
              Color(0xFF0D1C52), // Dark Blue
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/Sufar.png', height: 100, fit: BoxFit.contain),
            const SizedBox(height: 16),
            const Text(
              'Beyond the journey',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
