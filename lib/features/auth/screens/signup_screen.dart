import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/supabase_auth_provider.dart';

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
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(LucideIcons.arrow_left, color: Color(0xFF1E293B)),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ).animate().fade(duration: 400.ms).slideX(begin: -0.2),
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Create Account',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Color(0xFF1E293B),
                  ),
                ).animate().fade(delay: 100.ms).slideY(begin: 0.2, curve: Curves.easeOut),
                
                const SizedBox(height: 8),
                Text(
                  'Join P-Drive and unlock unlimited cloud storage through Telegram.',
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color(0xFF64748B),
                  ),
                ).animate().fade(delay: 200.ms).slideY(begin: 0.2, curve: Curves.easeOut),
                
                const SizedBox(height: 48),

                // Name Field
                _buildTextField(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  hint: 'John Doe',
                  icon: LucideIcons.user,
                ).animate().fade(delay: 250.ms).slideY(begin: 0.1, curve: Curves.easeOut),
                
                const SizedBox(height: 20),
                
                // Email Field
                _buildTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'Enter your email',
                  icon: LucideIcons.mail,
                ).animate().fade(delay: 300.ms).slideY(begin: 0.1, curve: Curves.easeOut),
                
                const SizedBox(height: 20),
                
                // Password Field
                _buildTextField(
                  controller: _passCtrl,
                  label: 'Password',
                  hint: '••••••••',
                  icon: LucideIcons.lock,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ).animate().fade(delay: 400.ms).slideY(begin: 0.1, curve: Curves.easeOut),
                
                const SizedBox(height: 40),
                
                // Sign Up Button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: authState.isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ).animate().fade(delay: 500.ms).slideY(begin: 0.1, curve: Curves.easeOut),
                
                const SizedBox(height: 16),
                
                // Google Sign Up Button
                OutlinedButton.icon(
                  onPressed: authState.isLoading ? null : _handleGoogleSignUp,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E293B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Image.asset('assets/icon/google_logo.png', width: 22, height: 22),
                  label: const Text('Sign up with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ).animate().fade(delay: 600.ms).slideY(begin: 0.1, curve: Curves.easeOut),
                
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ", style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text('Sign In', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ).animate().fade(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? LucideIcons.eye_off : LucideIcons.eye,
                        color: const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
