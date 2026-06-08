import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class WelcomeLoginScreen extends StatelessWidget {
  const WelcomeLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
            .move(duration: 15.seconds, begin: const Offset(0, 0), end: const Offset(30, -50))
            .scale(duration: 15.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
            
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
            .move(duration: 12.seconds, begin: const Offset(0, 0), end: const Offset(-40, 30))
            .scale(duration: 12.seconds, begin: const Offset(1, 1), end: const Offset(0.9, 0.9)),

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
                    // Logo Box
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.black.withOpacity(0.04)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        LucideIcons.cloud,
                        size: 44,
                        color: theme.colorScheme.primary,
                      ),
                    ).animate().fade(duration: 800.ms).scale(delay: 100.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 24),
                    
                    // App Title & Tagline
                    Text(
                      'P-Drive',
                      style: theme.textTheme.displayLarge,
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
                    const SizedBox(height: 8),
                    Text(
                      'Your files, everywhere.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                      ),
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
                    
                    const SizedBox(height: 56),

                    // Action buttons
                    Column(
                      children: [
                        // Google Login
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/onboarding/name'),
                            icon: Icon(
                              LucideIcons.user,
                              color: theme.colorScheme.onSurface,
                            ),
                            label: const Text('Continue with Google'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: theme.colorScheme.onSurface,
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              textStyle: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ).animate().fade(delay: 450.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
                        
                        const SizedBox(height: 16),
                        
                        // Email Login
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/onboarding/name'),
                            icon: const Icon(LucideIcons.mail, color: Colors.white),
                            label: const Text('Continue with Email'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              textStyle: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              elevation: 0,
                            ),
                          ),
                        ).animate().fade(delay: 550.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
                      ],
                    ),
                    
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
                    ).animate().fade(delay: 700.ms),
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
