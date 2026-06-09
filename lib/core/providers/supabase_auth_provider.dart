import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pdrive/core/config/auth_config.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? email;
  final String? displayName;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.email,
    this.displayName,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? email,
    String? displayName,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SupabaseAuthNotifier extends StateNotifier<AuthState> {
  SupabaseAuthNotifier() : super(AuthState()) {
    _init();
  }

  final _supabase = Supabase.instance.client;

  void _init() {
    // Check initial session
    final session = _supabase.auth.currentSession;
    if (session != null) {
      state = state.copyWith(
        isAuthenticated: true,
        email: session.user.email,
        displayName: session.user.userMetadata?['full_name'] ?? session.user.email?.split('@').first,
      );
      _upsertProfile(session.user);
    }

    // Listen to auth changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        state = state.copyWith(
          isAuthenticated: true,
          email: session.user.email,
          displayName: session.user.userMetadata?['full_name'] ?? session.user.email?.split('@').first,
        );
        _upsertProfile(session.user);
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          email: null,
          displayName: null,
        );
      }
    });
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signUpWithEmailPassword(String name, String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
        );
        state = state.copyWith(isLoading: false);
        return;
      }

      // 1. Initialize GoogleSignIn with Web Client ID
      final googleSignIn = GoogleSignIn(
        serverClientId: AuthConfig.webClientId,
      );

      // 2. Trigger native Google Sign-In popup
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled login
        state = state.copyWith(isLoading: false);
        return;
      }

      // 3. Extract tokens
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null || accessToken == null) {
        throw 'Missing Google Auth Tokens. Make sure you set the correct Web Client ID and SHA-1.';
      }

      // 4. Authenticate with Supabase using the ID token
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _supabase.auth.signOut();
    state = state.copyWith(isLoading: false, isAuthenticated: false);
  }

  Future<void> _upsertProfile(User user) async {
    try {
      final updates = {
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'] ?? user.email?.split('@').first,
      };
      // Upsert: if row exists, it updates provided fields. Omitted fields (like telegram configs) are untouched.
      await _supabase.from('user_profiles').upsert(updates);
    } catch (e) {
      debugPrint('Supabase profile upsert error: $e');
    }
  }
}

final authProvider = StateNotifierProvider<SupabaseAuthNotifier, AuthState>((ref) {
  return SupabaseAuthNotifier();
});
