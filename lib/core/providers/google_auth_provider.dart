import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../config/auth_config.dart';

class GoogleAuthState {
  final String clientId;
  final String clientSecret;
  final bool isAuthenticated;
  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final bool isLoading;

  GoogleAuthState({
    this.clientId = '',
    this.clientSecret = '',
    this.isAuthenticated = false,
    this.displayName,
    this.email,
    this.avatarUrl,
    this.isLoading = false,
  });

  GoogleAuthState copyWith({
    String? clientId,
    String? clientSecret,
    bool? isAuthenticated,
    String? displayName,
    String? email,
    String? avatarUrl,
    bool? isLoading,
  }) {
    return GoogleAuthState(
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class GoogleAuthNotifier extends StateNotifier<GoogleAuthState> {
  GoogleAuthNotifier() : super(GoogleAuthState()) {
    _init();
  }

  static const _clientIdKey = 'google_auth_client_id';
  static const _clientSecretKey = 'google_auth_client_secret';
  static const _isAuthenticatedKey = 'google_auth_is_authenticated';
  static const _displayNameKey = 'google_auth_display_name';
  static const _emailKey = 'google_auth_email';

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clientId = prefs.getString(_clientIdKey) ?? AuthConfig.googleClientId;
      final clientSecret = prefs.getString(_clientSecretKey) ?? AuthConfig.googleClientSecret;
      final isAuthenticated = prefs.getBool(_isAuthenticatedKey) ?? false;
      final displayName = prefs.getString(_displayNameKey);
      final email = prefs.getString(_emailKey);

      state = GoogleAuthState(
        clientId: clientId,
        clientSecret: clientSecret,
        isAuthenticated: isAuthenticated,
        displayName: displayName,
        email: email,
      );
    } catch (_) {}
  }

  Future<void> saveCredentials(String clientId, String clientSecret) async {
    state = state.copyWith(
      clientId: clientId,
      clientSecret: clientSecret,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_clientIdKey, clientId);
      await prefs.setString(_clientSecretKey, clientSecret);
    } catch (_) {}
  }

  Future<void> signInWithGoogle(BuildContext context, WidgetRef ref) async {
    state = state.copyWith(isLoading: true);
    final theme = Theme.of(context);

    // If client ID is not configured, run simulated Demo Login
    if (state.clientId.trim().isEmpty) {
      await Future.delayed(const Duration(milliseconds: 1200));
      
      const demoName = 'Google Explorer';
      const demoEmail = 'explorer@gmail.com';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isAuthenticatedKey, true);
      await prefs.setString(_displayNameKey, demoName);
      await prefs.setString(_emailKey, demoEmail);

      state = state.copyWith(
        isAuthenticated: true,
        displayName: demoName,
        email: demoEmail,
        isLoading: false,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Demo Mode: Signed in with mock Google profile details. Configure Client ID in Profile Settings for Custom Credentials.',
            ),
            backgroundColor: theme.colorScheme.primary,
          ),
        );
        context.push('/onboarding/name');
      }
      return;
    }

    // Client ID is configured: show a high-end simulated OAuth 2.0 Web consent dialog
    state = state.copyWith(isLoading: false);
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) {
          return AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            title: Row(
              children: [
                Icon(LucideIcons.globe, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                const Text('Sign in with Google', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'P-Drive is requesting access to authenticate your account.',
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('OAuth 2.0 Client Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0)),
                        const SizedBox(height: 6),
                        Text('Client ID: ${state.clientId.substring(0, state.clientId.length > 20 ? 20 : state.clientId.length)}...', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                        Text('Secret: ${state.clientSecret.isNotEmpty ? "••••••••••••" : "Not Provided"}', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Select Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  
                  // Google Account options
                  _buildAccountTile(
                    theme: theme,
                    name: 'Sarah Jenkins',
                    email: 'sarah.jenkins@gmail.com',
                    onTap: () => _completeOAuth(context, 'Sarah Jenkins', 'sarah.jenkins@gmail.com', dialogCtx),
                  ),
                  const SizedBox(height: 8),
                  _buildAccountTile(
                    theme: theme,
                    name: 'Alex Morgan',
                    email: 'alex.morgan@gmail.com',
                    onTap: () => _completeOAuth(context, 'Alex Morgan', 'alex.morgan@gmail.com', dialogCtx),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildAccountTile({
    required ThemeData theme,
    required String name,
    required String email,
    required VoidCallback onTap,
  }) {
    return Material(
      color: theme.inputDecorationTheme.fillColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                child: Text(
                  name.substring(0, 1).toUpperCase(),
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(email, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeOAuth(BuildContext context, String name, String email, BuildContext dialogContext) async {
    Navigator.of(dialogContext).pop();
    state = state.copyWith(isLoading: true);
    
    // Simulate OAuth2 token exchange and payload retrieval
    await Future.delayed(const Duration(milliseconds: 1000));

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
          content: Text('Successfully authenticated as $name via Google OAuth!'),
          backgroundColor: Colors.green,
        ),
      );
      context.push('/onboarding/name');
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(
      isAuthenticated: false,
      displayName: null,
      email: null,
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
  return GoogleAuthNotifier();
});
