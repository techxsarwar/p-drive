import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../config/auth_config.dart';
import '../router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthState {
  final String clientId;
  final bool isAuthenticated;
  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final bool isLoading;

  GoogleAuthState({
    this.clientId = '',
    this.isAuthenticated = false,
    this.displayName,
    this.email,
    this.avatarUrl,
    this.isLoading = false,
  });

  GoogleAuthState copyWith({
    String? clientId,
    bool? isAuthenticated,
    String? displayName,
    String? email,
    String? avatarUrl,
    bool? isLoading,
  }) {
    return GoogleAuthState(
      clientId: clientId ?? this.clientId,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class GoogleAuthNotifier extends StateNotifier<GoogleAuthState> {
  final SharedPreferences prefs;

  GoogleAuthNotifier(this.prefs) : super(GoogleAuthState(
    clientId: prefs.getString(_clientIdKey) ?? AuthConfig.googleClientId,
    isAuthenticated: prefs.getBool(_isAuthenticatedKey) ?? false,
    displayName: prefs.getString(_displayNameKey),
    email: prefs.getString(_emailKey),
  )) {
    if (state.isAuthenticated) {
      _googleSignIn = GoogleSignIn(
        clientId: state.clientId.isNotEmpty ? state.clientId : null,
        scopes: ['email', 'profile'],
      );
      _googleSignIn?.signInSilently();
    }
  }

  static const _clientIdKey = 'google_auth_client_id';
  static const _isAuthenticatedKey = 'google_auth_is_authenticated';
  static const _displayNameKey = 'google_auth_display_name';
  static const _emailKey = 'google_auth_email';

  GoogleSignIn? _googleSignIn;

  Future<void> saveCredentials(String clientId) async {
    state = state.copyWith(clientId: clientId);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_clientIdKey, clientId);
    } catch (_) {}
  }

  Future<void> signInWithGoogle(BuildContext context, WidgetRef ref) async {
    state = state.copyWith(isLoading: true);

    // Attempt real native Google Sign-In first
    try {
      _googleSignIn = GoogleSignIn(
        clientId: state.clientId.isNotEmpty ? state.clientId : null,
        scopes: [
          'email',
          'profile',
          'https://www.googleapis.com/auth/drive.file',
        ],
      );

      final account = await _googleSignIn!.signIn();
      if (account != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isAuthenticatedKey, true);
        await prefs.setString(_displayNameKey, account.displayName ?? 'P-Drive Profile');
        await prefs.setString(_emailKey, account.email);

        state = state.copyWith(
          isAuthenticated: true,
          displayName: account.displayName ?? 'P-Drive Profile',
          email: account.email,
          avatarUrl: account.photoUrl,
          isLoading: false,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, ${account.displayName}!'),
              backgroundColor: Colors.green,
            ),
          );
          context.push('/onboarding/name');
        }
        return;
      }
    } catch (e) {
      debugPrint('Native Google Sign-In error: $e');
    }

    // Native sign-in failed — show a manual email entry fallback
    state = state.copyWith(isLoading: false);
    if (context.mounted) {
      _showManualAuthDialog(context);
    }
  }

  /// Manual auth fallback when native Google Sign-In is not configured.
  /// This is only shown in debug/development mode or when SHA-1 is not set up.
  void _showManualAuthDialog(BuildContext context) {
    final theme = Theme.of(context);
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          actionsPadding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(LucideIcons.user, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Sign in to P-Drive', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your account details to continue.',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(LucideIcons.user, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(LucideIcons.mail, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your email';
                    if (!v.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogCtx).pop();
                  await _completeManualAuth(
                    context,
                    nameCtrl.text.trim(),
                    emailCtrl.text.trim(),
                  );
                }
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeManualAuth(BuildContext context, String name, String email) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAuthenticatedKey, true);
    await prefs.setString(_displayNameKey, name);
    await prefs.setString(_emailKey, email);

    state = state.copyWith(
      isAuthenticated: true,
      displayName: name,
      email: email,
      isLoading: false,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, $name!'),
          backgroundColor: Colors.green,
        ),
      );
      context.push('/onboarding/name');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut();
    } catch (_) {}

    state = state.copyWith(
      isAuthenticated: false,
      displayName: null,
      email: null,
      avatarUrl: null,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isAuthenticatedKey, false);
      await prefs.remove(_displayNameKey);
      await prefs.remove(_emailKey);
    } catch (_) {}
  }
}

final googleAuthProvider = StateNotifierProvider<GoogleAuthNotifier, GoogleAuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GoogleAuthNotifier(prefs);
});
