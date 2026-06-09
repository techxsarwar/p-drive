import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/providers/google_auth_provider.dart';

class WelcomeLoginScreen extends ConsumerWidget {
  const WelcomeLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(googleAuthProvider);
    
    return Scaffold(
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -100,
            left: -100,
            width: 350,
            height: 350,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.15),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
            .move(duration: 15.seconds, begin: const Offset(0, 0), end: const Offset(30, -50), curve: Curves.easeInOutSine)
            .scale(duration: 15.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1), curve: Curves.easeInOutSine),
            
          Positioned(
            bottom: -150,
            right: -150,
            width: 400,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.12),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
            .move(duration: 12.seconds, begin: const Offset(0, 0), end: const Offset(-40, 30), curve: Curves.easeInOutSine)
            .scale(duration: 12.seconds, begin: const Offset(1, 1), end: const Offset(0.9, 0.9), curve: Curves.easeInOutSine),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 90.0, sigmaY: 90.0),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Branded P-Drive Logo
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Subtle cloud icon behind the P
                          Icon(
                            LucideIcons.cloud,
                            size: 54,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          // Large "P" branding letter
                          const Text(
                            'P',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 46,
                              height: 1,
                              letterSpacing: -2,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 800.ms).scale(delay: 100.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 24),
                    
                    // App Title & Tagline
                    Text(
                      'P-Drive',
                      style: theme.textTheme.displayLarge,
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.05, end: 0, curve: const Cubic(0.16, 1, 0.3, 1)),
                    const SizedBox(height: 8),
                    Text(
                      'Your files, everywhere.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                      ),
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.05, end: 0, curve: const Cubic(0.16, 1, 0.3, 1)),
                    
                    const SizedBox(height: 56),

                    // Google Sign-In button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: authState.isLoading
                            ? null
                            : () => ref.read(googleAuthProvider.notifier).signInWithGoogle(context, ref),
                        icon: authState.isLoading
                            ? const SizedBox.shrink()
                            : Icon(
                                LucideIcons.globe,
                                color: theme.colorScheme.onPrimary,
                              ),
                        label: authState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Continue with Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0,
                        ),
                      ),
                    ).animate().fade(delay: 450.ms).slideY(begin: 0.05, end: 0, curve: const Cubic(0.16, 1, 0.3, 1)),
                    
                    const SizedBox(height: 56),
                    
                    // Trust details
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'By continuing, you agree to our Terms of Service and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.textTheme.labelSmall?.color?.withOpacity(0.5),
                        ),
                      ),
                    ).animate().fade(delay: 700.ms).slideY(begin: 0.05, end: 0, curve: const Cubic(0.16, 1, 0.3, 1)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
