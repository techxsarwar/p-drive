import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

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
      // Supabase OAuth via web browser (no SHA-1 required)
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.pdrive://login-callback',
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
}

final authProvider = StateNotifierProvider<SupabaseAuthNotifier, AuthState>((ref) {
  return SupabaseAuthNotifier();
});
