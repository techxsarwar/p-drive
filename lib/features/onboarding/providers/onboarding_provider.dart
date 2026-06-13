import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/shared_preferences_provider.dart';

class OnboardingState {
  final String username;
  final List<String> selectedCategories;
  final String discoverySource;
  final bool completedOnboarding;

  OnboardingState({
    this.username = '',
    this.selectedCategories = const [],
    this.discoverySource = '',
    this.completedOnboarding = false,
  });

  OnboardingState copyWith({
    String? username,
    List<String>? selectedCategories,
    String? discoverySource,
    bool? completedOnboarding,
  }) {
    return OnboardingState(
      username: username ?? this.username,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      discoverySource: discoverySource ?? this.discoverySource,
      completedOnboarding: completedOnboarding ?? this.completedOnboarding,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final SharedPreferences _prefs;

  OnboardingNotifier(this._prefs) : super(OnboardingState()) {
    _init();
  }

  void _init() {
    final completed = _prefs.getBool('completed_onboarding') ?? false;
    final username = _prefs.getString('username') ?? '';
    state = OnboardingState(
      completedOnboarding: completed,
      username: username,
    );
  }

  void setUsername(String name) {
    state = state.copyWith(username: name);
    _prefs.setString('username', name);
  }

  void toggleCategory(String category) {
    final list = List<String>.from(state.selectedCategories);
    if (list.contains(category)) {
      list.remove(category);
    } else {
      list.add(category);
    }
    state = state.copyWith(selectedCategories: list);
  }

  void setDiscoverySource(String source) {
    state = state.copyWith(discoverySource: source);
  }

  void completeOnboarding() {
    state = state.copyWith(completedOnboarding: true);
    _prefs.setBool('completed_onboarding', true);
  }

  void reset() {
    state = OnboardingState();
    _prefs.remove('completed_onboarding');
    _prefs.remove('username');
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingNotifier(prefs);
});
