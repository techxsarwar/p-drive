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
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Background Parallax Blobs
          Positioned(
            top: -150,
            left: -100,
            width: 400,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.3),
                    theme.colorScheme.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .move(duration: 12.seconds, begin: const Offset(0, 0), end: const Offset(50, 50), curve: Curves.easeInOutSine)
           .scale(duration: 10.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2), curve: Curves.easeInOutSine),
            
          Positioned(
            bottom: -200,
            right: -150,
            width: 500,
            height: 500,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.secondary.withOpacity(0.2),
                    theme.colorScheme.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .move(duration: 14.seconds, begin: const Offset(0, 0), end: const Offset(-60, -40), curve: Curves.easeInOutSine)
           .scale(duration: 12.seconds, begin: const Offset(1, 1), end: const Offset(0.8, 1.1), curve: Curves.easeInOutSine),

          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.3,
            right: -50,
            width: 300,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.tertiary.withOpacity(0.15),
                    theme.colorScheme.tertiary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .move(duration: 16.seconds, begin: const Offset(0, 0), end: const Offset(-40, 60), curve: Curves.easeInOutSine),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    
                    // App Icon Image (Trademark)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ).animate()
                     .scale(duration: 1.seconds, curve: Curves.easeOutBack, begin: const Offset(0, 0), end: const Offset(1, 1))
                     .shimmer(delay: 1.5.seconds, duration: 1.5.seconds, color: Colors.white54)
                     .then()
                     .animate(onPlay: (c) => c.repeat(reverse: true))
                     .moveY(begin: 0, end: -8, duration: 3.seconds, curve: Curves.easeInOutSine),

                    const SizedBox(height: 32),
                    
                    // App Title & Tagline
                    Text(
                      'P-Drive',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                      ),
                    ).animate().fade(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Secure. Fast. Unbound.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ).animate().fade(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                    
                    const SizedBox(height: 64),

                    // Google Sign-In button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: authState.isLoading
                            ? null
                            : () => ref.read(googleAuthProvider.notifier).signInWithGoogle(context, ref),
                        icon: authState.isLoading
                            ? const SizedBox.shrink()
                            : Icon(
                                LucideIcons.globe,
                                color: theme.colorScheme.onPrimary,
                                size: 24,
                              ),
                        label: authState.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Continue with Google',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 8,
                          shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                    ).animate().fade(delay: 800.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic)
                     .shimmer(delay: 2.seconds, duration: 1.5.seconds, color: Colors.white24),
                    
                    const SizedBox(height: 48),
                    
                    // Trust details
                    Text(
                      'By continuing, you agree to our\nTerms of Service and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                        height: 1.5,
                      ),
                    ).animate().fade(delay: 1000.ms, duration: 600.ms),
                    
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
