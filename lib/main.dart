import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/transfer_foreground_service.dart';
import 'core/widgets/telegram_theme_switcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set up the foreground service so it's ready before any transfer starts.
  TransferForegroundService.initialize();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    // WithForegroundTask is required by flutter_foreground_task to properly
    // handle the foreground service lifecycle (e.g. back-press behaviour).
    return WithForegroundTask(
      child: MaterialApp.router(
        title: 'P-Drive',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: appRouter,
        builder: (context, child) {
          // Wraps the entire app content to enable the circular theme reveal animation.
          return TelegramThemeSwitcher(
            child: child!,
          );
        },
      ),
    );
  }
}
