import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/supabase_auth_provider.dart';
import '../widgets/transformable_login_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isSignUpSuccess = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    
    await ref.read(authProvider.notifier).signUpWithEmailPassword(name, email, password);
    
    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authState.errorMessage!), backgroundColor: Colors.red));
      } else {
        setState(() {
          _isSignUpSuccess = true;
        });
        // Wait for checkmark morph animation to complete
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created! Please sign in.'), backgroundColor: Colors.green));
          context.pop(); // Go back to login screen
        }
      }
    }
  }

  void _handleGoogleSignUp() {
    ref.read(authProvider.notifier).signInWithGoogle();
  }

  Widget _buildGlowBlob({required double width, required double height, required Color color}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isDark = theme.brightness == Brightness.dark;

    final glassColor = isDark 
        ? const Color(0xFF1E222D).withOpacity(0.65) 
        : Colors.white.withOpacity(0.75);
        
    final glassBorderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.2);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Drifting Glowing Background Blobs
          Positioned(
            top: -100,
            left: -100,
            child: _buildGlowBlob(
              width: 320,
              height: 320,
              color: theme.colorScheme.primary.withOpacity(isDark ? 0.22 : 0.16),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .moveY(begin: 0, end: 30, duration: 6.seconds, curve: Curves.easeInOut)
             .moveX(begin: 0, end: 20, duration: 7.seconds, curve: Curves.easeInOut),
          ),
          Positioned(
            bottom: -80,
            right: -100,
            child: _buildGlowBlob(
              width: 360,
              height: 360,
              color: theme.colorScheme.secondary.withOpacity(isDark ? 0.22 : 0.16),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .moveY(begin: 0, end: -30, duration: 7.seconds, curve: Curves.easeInOut)
             .moveX(begin: 0, end: -20, duration: 8.seconds, curve: Curves.easeInOut),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: -120,
            child: _buildGlowBlob(
              width: 260,
              height: 260,
              color: theme.colorScheme.secondary.withOpacity(isDark ? 0.15 : 0.1),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .moveY(begin: 0, end: -20, duration: 5.seconds, curve: Curves.easeInOut)
             .moveX(begin: 0, end: 25, duration: 6.seconds, curve: Curves.easeInOut),
          ),

          // 2. Immersive Content Layout
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          
                          // P-Drive Branding Box
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(isDark ? 0.8 : 0.95),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(color: glassBorderColor, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 25,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: Icon(
                              LucideIcons.cloud_upload,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                          ).animate().fade().scale(curve: Curves.easeOutBack, duration: 600.ms),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            'P-Drive',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              color: theme.colorScheme.onSurface,
                            ),
                          ).animate().fade(delay: 100.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                          
                          const SizedBox(height: 6),
                          
                          Text(
                            'Your secure cloud powered by Telegram',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ).animate().fade(delay: 200.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                          
                          const SizedBox(height: 40),

                          // Glassmorphic Signup Card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                              child: Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: glassColor,
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(color: glassBorderColor, width: 1.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Create Account',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ).animate().fade().slideX(begin: -0.05),
                                    
                                    const SizedBox(height: 4),
                                    
                                    Text(
                                      'Join P-Drive and unlock unlimited storage',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                    ).animate().fade(delay: 100.ms).slideX(begin: -0.05),
                                    
                                    const SizedBox(height: 28),
                                    
                                    // Name Field
                                    _buildTextField(
                                      controller: _nameCtrl,
                                      hint: 'Full Name',
                                      icon: LucideIcons.user,
                                    ).animate().fade(delay: 150.ms).slideY(begin: 0.05),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Email Field
                                    _buildTextField(
                                      controller: _emailCtrl,
                                      hint: 'Email Address',
                                      icon: LucideIcons.mail,
                                    ).animate().fade(delay: 200.ms).slideY(begin: 0.05),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Password Field
                                    _buildTextField(
                                      controller: _passCtrl,
                                      hint: 'Password',
                                      icon: LucideIcons.lock,
                                      isPassword: true,
                                      obscureText: _obscurePassword,
                                      onToggleVisibility: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ).animate().fade(delay: 250.ms).slideY(begin: 0.05),
                                    
                                    const SizedBox(height: 32),
                                    
                                    // Sign Up Button
                                    TransformableLoginButton(
                                      buttonText: 'Create Account',
                                      state: authState.isLoading
                                          ? TransformableButtonState.loading
                                          : (_isSignUpSuccess
                                              ? TransformableButtonState.success
                                              : TransformableButtonState.idle),
                                      onPressed: _handleSignUp,
                                    ).animate().fade(delay: 300.ms).slideY(begin: 0.05),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Divider
                                    Row(
                                      children: [
                                        Expanded(child: Divider(color: theme.dividerColor.withOpacity(0.3))),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            'or continue with',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: theme.colorScheme.onSurface.withOpacity(0.4),
                                            ),
                                          ),
                                        ),
                                        Expanded(child: Divider(color: theme.dividerColor.withOpacity(0.3))),
                                      ],
                                    ).animate().fade(delay: 350.ms),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Google Button (Glassmorphic)
                                    OutlinedButton.icon(
                                      onPressed: authState.isLoading ? null : _handleGoogleSignUp,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        backgroundColor: isDark 
                                            ? Colors.white.withOpacity(0.04) 
                                            : Colors.black.withOpacity(0.02),
                                        side: BorderSide(color: glassBorderColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      icon: Image.asset('assets/icon/google_logo.png', width: 22, height: 22),
                                      label: Text(
                                        'Sign up with Google',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ).animate().fade(delay: 400.ms).slideY(begin: 0.05),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fade(delay: 150.ms).slideY(begin: 0.08, end: 0, curve: const Cubic(0.16, 1, 0.3, 1)),

                          const SizedBox(height: 32),
                          
                          // Sign In Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: Row(
                                  children: [
                                    Text(
                                      'Sign In',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(LucideIcons.arrow_right, size: 16, color: theme.colorScheme.primary),
                                  ],
                                ),
                              ),
                            ],
                          ).animate().fade(delay: 450.ms),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.inter(fontSize: 15, color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: theme.colorScheme.onSurface.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.5), size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? LucideIcons.eye_off : LucideIcons.eye,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}
