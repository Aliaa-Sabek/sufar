import 'package:flutter/material.dart';

class ProcessLoadingStep {
  final String title;
  final String subtitle;
  final IconData icon;

  const ProcessLoadingStep({
    required this.title,
    this.subtitle = '',
    this.icon = Icons.hourglass_empty,
  });
}

/// Controls step progression shown inside [ProcessLoadingOverlay].
class ProcessController {
  ProcessController(this.totalSteps);

  final int totalSteps;
  final ValueNotifier<int> activeStep = ValueNotifier(0);
  bool _finished = false;

  Future<void> advance() async {
    if (_finished) return;
    if (activeStep.value < totalSteps - 1) {
      activeStep.value++;
      await Future.delayed(const Duration(milliseconds: 350));
    }
  }

  Future<void> jumpTo(int index) async {
    if (_finished) return;
    activeStep.value = index.clamp(0, totalSteps - 1);
    await Future.delayed(const Duration(milliseconds: 350));
  }

  Future<void> complete() async {
    _finished = true;
    activeStep.value = totalSteps;
    await Future.delayed(const Duration(milliseconds: 280));
  }
}

/// Full-screen step-by-step loading for booking, payment, and API flows.
class ProcessLoadingOverlay {
  ProcessLoadingOverlay._();

  static Future<T> run<T>({
    required BuildContext context,
    required String title,
    required List<ProcessLoadingStep> steps,
    required Future<T> Function(ProcessController controller) task,
  }) async {
    if (steps.isEmpty) return task(ProcessController(1));

    final controller = ProcessController(steps.length);
    final navigator = Navigator.of(context, rootNavigator: true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: _ProcessLoadingDialog(
          title: title,
          steps: steps,
          controller: controller,
        ),
      ),
    );

    try {
      final result = await task(controller);
      await controller.complete();
      if (navigator.mounted) navigator.pop();
      return result;
    } catch (e) {
      if (navigator.mounted) navigator.pop();
      rethrow;
    }
  }
}

class ProcessLoadingPresets {
  static const hotelBooking = [
    ProcessLoadingStep(
      title: 'Validating details',
      subtitle: 'Checking guest information',
      icon: Icons.person_outline,
    ),
    ProcessLoadingStep(
      title: 'Reserving room',
      subtitle: 'Connecting to hotel system',
      icon: Icons.hotel_outlined,
    ),
    ProcessLoadingStep(
      title: 'Processing payment',
      subtitle: 'Secure encrypted payment',
      icon: Icons.credit_card,
    ),
    ProcessLoadingStep(
      title: 'Confirming booking',
      subtitle: 'Sending your confirmation',
      icon: Icons.mark_email_read_outlined,
    ),
  ];

  static const payment = [
    ProcessLoadingStep(
      title: 'Verifying card',
      subtitle: 'Checking payment details',
      icon: Icons.verified_user_outlined,
    ),
    ProcessLoadingStep(
      title: 'Processing payment',
      subtitle: 'Secure payment gateway',
      icon: Icons.lock_outline,
    ),
    ProcessLoadingStep(
      title: 'Issuing confirmation',
      subtitle: 'Preparing your receipt',
      icon: Icons.receipt_long_outlined,
    ),
  ];

  static const profileSave = [
    ProcessLoadingStep(
      title: 'Saving changes',
      subtitle: 'Updating your information',
      icon: Icons.save_outlined,
    ),
    ProcessLoadingStep(
      title: 'Syncing profile',
      subtitle: 'Refreshing account data',
      icon: Icons.sync,
    ),
  ];

  static const aiPlan = [
    ProcessLoadingStep(
      title: 'Analyzing destination',
      subtitle: 'Loading city insights',
      icon: Icons.travel_explore,
    ),
    ProcessLoadingStep(
      title: 'Building itinerary',
      subtitle: 'AI is crafting your plan',
      icon: Icons.auto_awesome,
    ),
    ProcessLoadingStep(
      title: 'Finding hotels & activities',
      subtitle: 'Matching your preferences',
      icon: Icons.hotel_class_outlined,
    ),
  ];
}

class _ProcessLoadingDialog extends StatelessWidget {
  const _ProcessLoadingDialog({
    required this.title,
    required this.steps,
    required this.controller,
  });

  final String title;
  final List<ProcessLoadingStep> steps;
  final ProcessController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ValueListenableBuilder<int>(
              valueListenable: controller.activeStep,
              builder: (context, active, _) {
                final progress = (active / steps.length).clamp(0.0, 1.0);
                final allDone = active >= steps.length;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A94C4).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            allDone ? Icons.check_circle : Icons.hourglass_top,
                            color: const Color(0xFF1A94C4),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D1C52),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                allDone
                                    ? 'Completed successfully'
                                    : 'Please wait a moment…',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: allDone ? 1 : (progress == 0 ? null : progress),
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color(0xFF1A94C4),
                      ),
                    ),
                    const SizedBox(height: 22),
                    ...List.generate(steps.length, (index) {
                      final step = steps[index];
                      final isDone = allDone || index < active;
                      final isActive = !allDone && index == active;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < steps.length - 1 ? 14 : 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? const Color(0xFF1A94C4)
                                    : isActive
                                        ? const Color(0xFFE0F4FD)
                                        : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: isDone
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : isActive
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF1A94C4),
                                            ),
                                          )
                                        : Icon(
                                            step.icon,
                                            size: 15,
                                            color: Colors.grey.shade400,
                                          ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isActive || isDone
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isDone || isActive
                                          ? const Color(0xFF0D1C52)
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                  if (step.subtitle.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      step.subtitle,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
