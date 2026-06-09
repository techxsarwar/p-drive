import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/supabase_auth_provider.dart';
import '../widgets/auth_header_graphics.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created! Please sign in.'), backgroundColor: Colors.green));
        context.pop(); // Go back to login screen
      }
    }
  }

  void _handleGoogleSignUp() {
    ref.read(authProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Top Animated Graphics
                    const AuthHeaderGraphics(),

                    // Bottom Signup Card
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, -10),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Create Account',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ).animate().fade().slideX(begin: -0.1),
                            const SizedBox(height: 4),
                            Text(
                              'Join P-Drive and unlock unlimited storage',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ).animate().fade(delay: 100.ms).slideX(begin: -0.1),
                            
                            const SizedBox(height: 32),
                            
                            // Name Field
                            _buildTextField(
                              controller: _nameCtrl,
                              hint: 'Full Name',
                              icon: LucideIcons.user,
                            ).animate().fade(delay: 150.ms).slideY(begin: 0.1),
                            
                            const SizedBox(height: 16),

                            // Email Field
                            _buildTextField(
                              controller: _emailCtrl,
                              hint: 'Email Address',
                              icon: LucideIcons.mail,
                            ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                            
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
                            ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
                            
                            const SizedBox(height: 32),
                            
                            // Sign Up Button
                            ElevatedButton(
                              onPressed: authState.isLoading ? null : _handleSignUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.secondary, // Soft Teal
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: authState.isLoading 
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Create Account',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(LucideIcons.arrow_right, size: 20, color: Colors.white),
                                    ],
                                  ),
                            ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
                            
                            const SizedBox(height: 24),
                            
                            // Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'or continue with',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                              ],
                            ).animate().fade(delay: 500.ms),
                            
                            const SizedBox(height: 24),
                            
                            // Google Button
                            OutlinedButton.icon(
                              onPressed: authState.isLoading ? null : _handleGoogleSignUp,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: Theme.of(context).dividerColor),
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
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
                            
                            const SizedBox(height: 32),
                            
                            // Sign In Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(LucideIcons.arrow_right, size: 16, color: Theme.of(context).colorScheme.onSurface),
                                    ],
                                  ),
                                ),
                              ],
                            ).animate().fade(delay: 700.ms),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.inter(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? LucideIcons.eye_off : LucideIcons.eye,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
