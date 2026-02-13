import 'package:flutter/material.dart';

class CustomStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const CustomStepper({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          // Even indices are steps, odd indices are lines
          if (index % 2 == 0) {
            final stepIndex = index ~/ 2 + 1;
            final isCompletedOrActive = stepIndex <= currentStep;
            
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompletedOrActive ? const Color(0xFF1A94C4) : const Color(0xFFE0E0E0),
              ),
              child: Center(
                child: isCompletedOrActive
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : Text(
                        '$stepIndex',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            );
          } else {
            return Expanded(
              child: Container(
                height: 2,
                color: const Color(0xFFE0E0E0),
              ),
            );
          }
        }),
      ),
    );
  }
}
