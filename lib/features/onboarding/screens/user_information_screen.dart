import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/providers/supabase_auth_provider.dart';
import '../providers/onboarding_provider.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  const UserInformationScreen({super.key});

  @override
  ConsumerState<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final googleAuth = ref.read(authProvider);
      if (googleAuth.isAuthenticated && googleAuth.displayName != null) {
        _nameController.text = googleAuth.displayName!;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate a light network request or delay for micro-interactions
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          ref.read(onboardingProvider.notifier).setUsername(_nameController.text.trim());
          ref.read(onboardingProvider.notifier).completeOnboarding();
          setState(() {
            _isLoading = false;
          });
          context.go('/dashboard/home');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Friendly Illustration Container (24px radius, soft styled container)
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.transparent
                                    : Colors.black.withOpacity(0.02),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // soft decor circles
                              Positioned(
                                top: -20,
                                left: -20,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.colorScheme.primary.withOpacity(0.06),
                                  ),
                                ),
                              ),
                              Icon(
                                LucideIcons.smile,
                                size: 80,
                                color: theme.colorScheme.primary.withOpacity(0.8),
                              ),
                            ],
                          ),
                        ).animate().fade(duration: 600.ms).scale(curve: Curves.easeOutBack),
                        const SizedBox(height: 40),

                        // Title & Prompt
                        Text(
                          "Welcome to P-Drive",
                          style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ).animate().fade(delay: 100.ms).slideY(begin: 0.05, end: 0, curve: const Cubic(0.16, 1, 0.3, 1)),
                        const SizedBox(height: 8),
                        Text(
                          "What should we call you in your workspace?",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fade(delay: 200.ms).slideY(begin: 0.05, end: 0, curve: const Cubic(0.16, 1, 0.3, 1)),
                        const SizedBox(height: 32),

                        // Name input field
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.transparent
                                    : Colors.black.withOpacity(0.01),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _nameController,
                            autofocus: true,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Your full name',
                              fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surfaceVariant,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 22,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                        ).animate().fade(delay: 300.ms).slideY(begin: 0.05, end: 0, curve: const Cubic(0.16, 1, 0.3, 1)),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom docked action area
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Enter Dashboard'),
                              SizedBox(width: 8),
                              Icon(LucideIcons.arrow_right, size: 18),
                            ],
                          ),
                  ),
                ).animate().fade(delay: 400.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
