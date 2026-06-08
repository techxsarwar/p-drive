import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  OnboardingNotifier() : super(OnboardingState());

  void setUsername(String name) {
    state = state.copyWith(username: name);
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
  }

  void reset() {
    state = OnboardingState();
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});
