import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

// Screens
import '../features/auth/screens/welcome_login_screen.dart';
import '../features/onboarding/screens/user_information_screen.dart';
import '../features/onboarding/screens/storage_preference_screen.dart';
import '../features/onboarding/screens/discovery_screen.dart';
import '../features/onboarding/screens/ready_to_go_screen.dart';
import '../features/dashboard/screens/dashboard_shell.dart';
import '../features/dashboard/screens/home_dashboard_screen.dart';
import '../features/dashboard/screens/files_organization_screen.dart';
import '../features/dashboard/screens/file_details_screen.dart';
import '../features/dashboard/screens/profile_settings_screen.dart';
import '../features/dashboard/screens/legal_documents_screen.dart';

// ─── Telegram-style page transition (slide left, current fades-slides left 8%) ─

CustomTransitionPage<T> _telegramPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // New page slides in from right
      final enterSlide = Tween<Offset>(
        begin: const Offset(1.0, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      // Current page moves left 8% and fades slightly (Telegram feel)
      final exitSlide = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.08, 0),
      ).animate(CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInCubic));
      final exitFade = Tween<double>(begin: 1.0, end: 0.88)
          .animate(CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInCubic));

      return SlideTransition(
        position: exitSlide,
        child: FadeTransition(
          opacity: exitFade,
          child: SlideTransition(position: enterSlide, child: child),
        ),
      );
    },
  );
}

// ─── Shared tab placeholder ─────────────────────────────────────────────────

class SharedTabPlaceholder extends StatelessWidget {
  const SharedTabPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          'Shared Space',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.users, color: theme.colorScheme.primary, size: 32),
              ),
              const SizedBox(height: 24),
              Text('Collaborative Folders', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Files shared with you or by you will appear here. Invite team members to collaborate.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── App Router ─────────────────────────────────────────────────────────────

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Welcome / Login screen
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _telegramPage(
        context: context, state: state, child: const WelcomeLoginScreen()),
    ),

    // Onboarding screens — all with Telegram transitions
    GoRoute(
      path: '/onboarding/name',
      pageBuilder: (context, state) => _telegramPage(
        context: context, state: state, child: const UserInformationScreen()),
    ),
    GoRoute(
      path: '/onboarding/store',
      pageBuilder: (context, state) => _telegramPage(
        context: context, state: state, child: const StoragePreferenceScreen()),
    ),
    GoRoute(
      path: '/onboarding/discovery',
      pageBuilder: (context, state) => _telegramPage(
        context: context, state: state, child: const DiscoveryScreen()),
    ),
    GoRoute(
      path: '/onboarding/ready',
      pageBuilder: (context, state) => _telegramPage(
        context: context, state: state, child: const ReadyToGoScreen()),
    ),

    // Shell route — no transition between tabs (feels instant like Telegram)
    ShellRoute(
      builder: (context, state, child) => DashboardShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/dashboard/files',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FilesOrganizationScreen(),
          ),
        ),
        GoRoute(
          path: '/dashboard/shared',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SharedTabPlaceholder(),
          ),
        ),
        GoRoute(
          path: '/dashboard/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileSettingsScreen(),
          ),
        ),
      ],
    ),

    // File Details — Telegram slide transition
    GoRoute(
      path: '/file-details',
      pageBuilder: (context, state) {
        HapticFeedback.lightImpact();
        final extraString = state.extra as String? ?? 'Q4_Marketing_Assets.zip';
        return _telegramPage(
          context: context,
          state: state,
          child: FileDetailsScreen(filename: extraString),
        );
      },
    ),
    GoRoute(
      path: '/legal',
      pageBuilder: (context, state) => _telegramPage(
        context: context,
        state: state,
        child: const LegalDocumentsScreen(),
      ),
    ),
  ],
);
