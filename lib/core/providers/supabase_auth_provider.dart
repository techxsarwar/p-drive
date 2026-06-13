import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pdrive/core/config/auth_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_preferences_provider.dart';

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
  final SharedPreferences _prefs;

  SupabaseAuthNotifier(this._prefs) : super(AuthState()) {
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
      _prefs.setBool('google_auth_is_authenticated', true);
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
        _prefs.setBool('google_auth_is_authenticated', true);
        _upsertProfile(session.user);
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          email: null,
          displayName: null,
        );
        _prefs.setBool('google_auth_is_authenticated', false);
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

      // Simulate a brief premium auth loading delay (e.g., 1.2 seconds)
      await Future.delayed(const Duration(milliseconds: 1200));

      // Successfully sign in locally using a mock user profile shortcut
      state = state.copyWith(
        isAuthenticated: true,
        email: 'mock.google.user@gmail.com',
        displayName: 'Mock Google User',
        isLoading: false,
      );

      await _prefs.setBool('google_auth_is_authenticated', true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _supabase.auth.signOut();
    _prefs.setBool('google_auth_is_authenticated', false);
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
  final prefs = ref.watch(sharedPreferencesProvider);
  return SupabaseAuthNotifier(prefs);
});
