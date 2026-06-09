import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../providers/onboarding_provider.dart';

class ReadyToGoScreen extends ConsumerWidget {
  const ReadyToGoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background ambient glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.08),
                    theme.colorScheme.background,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Celebration Illustration Container
                  Center(
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withOpacity(0.05),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.05),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            LucideIcons.sparkles,
                            size: 120,
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .scale(duration: 3.seconds, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), curve: Curves.easeInOutSine)
                            .rotate(duration: 6.seconds, begin: 0, end: 0.1, curve: Curves.easeInOutSine),
                          
                          Icon(
                            LucideIcons.cloud,
                            size: 80,
                            color: theme.colorScheme.primary,
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .moveY(duration: 2.seconds, begin: -10, end: 10, curve: Curves.easeInOutSine),
                        ],
                      ),
                    ),
                  ).animate().fade(duration: 600.ms).scale(curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 48),

                  // Texts
                  Text(
                    "Your personal drive is ready.",
                    style: theme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.05, end: 0, curve: const Cubic(0.16, 1, 0.3, 1)),
                  const SizedBox(height: 12),
                  Text(
                    "A quiet, organized space for your most important work. All systems are set up and waiting for you.",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fade(delay: 350.ms).slideY(begin: 0.05, end: 0, curve: const Cubic(0.16, 1, 0.3, 1)),

                  const Spacer(),

                  // Continue Action
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(onboardingProvider.notifier).completeOnboarding();
                        context.go('/dashboard/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Enter P-Drive'),
                          SizedBox(width: 8),
                          Icon(LucideIcons.arrow_right, size: 20),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.05, end: 0, curve: const Cubic(0.16, 1, 0.3, 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
