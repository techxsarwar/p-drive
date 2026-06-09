import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../providers/onboarding_provider.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onboardingState = ref.watch(onboardingProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);
    
    final hasSelection = onboardingState.discoverySource.isNotEmpty;

    Widget buildOptionCard({
      required String id,
      required String title,
      required String subtitle,
      required IconData icon,
      bool isFullWidth = false,
    }) {
      final isSelected = onboardingState.discoverySource == id;

      return GestureDetector(
        onTap: () => onboardingNotifier.setDiscoverySource(id),
        child: AnimatedScale(
          scale: isSelected ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.08)
                  : (theme.cardTheme.color ?? theme.colorScheme.surfaceVariant),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : (theme.dividerColor.withOpacity(0.5)),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.brightness == Brightness.dark
                      ? Colors.transparent
                      : Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
                            : theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: theme.textTheme.labelSmall?.color?.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Segmented Onboarding Progress Bar (all 3 steps active now)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Headers
              Text(
                "How did you hear about P-Drive?",
                style: theme.textTheme.headlineLarge,
              ).animate().fade(duration: 500.ms).slideX(begin: -0.05, end: 0, curve: const Cubic(0.16, 1, 0.3, 1)),
              const SizedBox(height: 8),
              Text(
                "We're curious to know what brought you to our tranquil workspace.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ).animate().fade(delay: 100.ms).slideX(begin: -0.05, end: 0, curve: const Cubic(0.16, 1, 0.3, 1)),
              const SizedBox(height: 32),

              // Bento Options Grid
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: buildOptionCard(
                              id: 'google',
                              title: 'Search',
                              subtitle: 'Google, Bing, etc.',
                              icon: LucideIcons.search,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: buildOptionCard(
                              id: 'friend',
                              title: 'Friend',
                              subtitle: 'Word of mouth',
                              icon: LucideIcons.users,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: buildOptionCard(
                              id: 'youtube',
                              title: 'YouTube',
                              subtitle: 'Video review or ad',
                              icon: LucideIcons.circle_play,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: buildOptionCard(
                              id: 'instagram',
                              title: 'Instagram',
                              subtitle: 'Social media post',
                              icon: LucideIcons.camera,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      buildOptionCard(
                        id: 'other',
                        title: 'Other',
                        subtitle: 'Somewhere else entirely',
                        icon: LucideIcons.ellipsis,
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.05, end: 0, curve: const Cubic(0.16, 1, 0.3, 1)),
                ),
              ),

              // Bottom continue area
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 16),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: hasSelection ? 1.0 : 0.5,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: hasSelection
                          ? () => context.push('/onboarding/ready')
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Continue'),
                          SizedBox(width: 8),
                          Icon(LucideIcons.arrow_right, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
