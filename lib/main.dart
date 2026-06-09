import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/transfer_foreground_service.dart';
import 'core/widgets/telegram_theme_switcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env variables (fail gracefully if missing)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("No .env file found or empty. Using fallback/empty credentials.");
  }

  // Set up the foreground service so it's ready before any transfer starts.
  TransferForegroundService.initialize();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
    });
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.notification,
      Permission.storage,
      Permission.photos,
      Permission.videos,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    // WithForegroundTask is required by flutter_foreground_task to properly
    // handle the foreground service lifecycle (e.g. back-press behaviour).
    return WithForegroundTask(
      child: MaterialApp.router(
        title: 'P-Drive',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
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
