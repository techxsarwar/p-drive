import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

// Shared tab placeholder screen
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
                child: Icon(
                  LucideIcons.users,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Collaborative Folders',
                style: theme.textTheme.headlineMedium,
              ),
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

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Welcome / Login screen
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeLoginScreen(),
    ),
    
    // Onboarding screens
    GoRoute(
      path: '/onboarding/name',
      builder: (context, state) => const UserInformationScreen(),
    ),
    GoRoute(
      path: '/onboarding/store',
      builder: (context, state) => const StoragePreferenceScreen(),
    ),
    GoRoute(
      path: '/onboarding/discovery',
      builder: (context, state) => const DiscoveryScreen(),
    ),
    GoRoute(
      path: '/onboarding/ready',
      builder: (context, state) => const ReadyToGoScreen(),
    ),

    // Shell route for bottom navigation tabs
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

    // File Details Screen (Nested or stand-alone path)
    GoRoute(
      path: '/file-details',
      builder: (context, state) {
        final extraString = state.extra as String? ?? 'Q4_Marketing_Assets.zip';
        return FileDetailsScreen(filename: extraString);
      },
    ),
  ],
);
