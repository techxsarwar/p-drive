import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: 'Create ', style: TextStyle(color: Color(0xFF0F9D58))),
                        TextSpan(text: 'Account', style: TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fill your details or continue with\nsocial media.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Name Field
                  const Text('Full Name', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Jhon Doe',
                      hintStyle: const TextStyle(color: Colors.black26),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0F9D58))),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Email Field
                  const Text('Email', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      hintText: 'imshuvo97@gmail.com',
                      hintStyle: const TextStyle(color: Colors.black26),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0F9D58))),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Password Field
                  const Text('Password', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: const TextStyle(color: Colors.black26),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0F9D58))),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? LucideIcons.eye_off : LucideIcons.eye,
                          color: Colors.black26,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Sign Up Button
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F9D58),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: authState.isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 16),
                  
                  // Google Sign Up
                  ElevatedButton.icon(
                    onPressed: authState.isLoading ? null : _handleGoogleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: Image.asset('assets/icon/google_logo.png', width: 20, height: 20),
                    label: const Text('Sign Up With Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already Have Account? ', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text('Log In', style: TextStyle(color: Color(0xFF0F9D58), fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  // Bottom Illustration Placeholder
                  Center(
                    child: Icon(LucideIcons.shopping_cart, size: 60, color: const Color(0xFF0F9D58).withOpacity(0.2)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
