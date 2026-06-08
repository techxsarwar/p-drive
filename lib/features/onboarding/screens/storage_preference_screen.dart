import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../providers/onboarding_provider.dart';

class StoragePreferenceScreen extends ConsumerWidget {
  const StoragePreferenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onboardingState = ref.watch(onboardingProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);

    // Initial state: default checks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (onboardingState.selectedCategories.isEmpty) {
        onboardingNotifier.toggleCategory('documents');
        onboardingNotifier.toggleCategory('work');
      }
    });

    // Categories definition
    Widget buildCategoryCard({
      required String id,
      required String title,
      required IconData icon,
      String? subtitle,
      bool isFullWidth = false,
    }) {
      final isSelected = onboardingState.selectedCategories.contains(id);

      return GestureDetector(
        onTap: () => onboardingNotifier.toggleCategory(id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 140,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                      color: isSelected ? Colors.white : theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : const Color(0xFFC5C5D8),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          )
                        : null,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: theme.textTheme.labelSmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ],
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
              // Header navigation row
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(LucideIcons.arrow_left),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
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
                              color: theme.colorScheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Title and subtitle
              Text(
                "What do you want to store?",
                style: theme.textTheme.headlineLarge,
              ).animate().fade(duration: 400.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                "Select all the file types you plan to keep in P-Drive. We'll set up your initial folders based on these choices.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ).animate().fade(delay: 100.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 32),

              // Selection Layout
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Documents & Photos row
                      Row(
                        children: [
                          Expanded(
                            child: buildCategoryCard(
                              id: 'documents',
                              title: 'Documents',
                              icon: LucideIcons.file_text,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: buildCategoryCard(
                              id: 'photos',
                              title: 'Photos',
                              icon: LucideIcons.camera,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Videos (Full width, Bento block)
                      buildCategoryCard(
                        id: 'videos',
                        title: 'Videos',
                        icon: LucideIcons.video,
                        subtitle: 'Large file optimization',
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 16),

                      // Music & Work
                      Row(
                        children: [
                          Expanded(
                            child: buildCategoryCard(
                              id: 'music',
                              title: 'Music',
                              icon: LucideIcons.music,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: buildCategoryCard(
                              id: 'work',
                              title: 'Work Files',
                              icon: LucideIcons.briefcase,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),
                ),
              ),

              // Bottom continue area
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.push('/onboarding/discovery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Continue'),
                  ),
                ).animate().fade(delay: 350.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
