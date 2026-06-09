import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter/services.dart';
import '../../../core/providers/google_auth_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../../core/widgets/telegram_theme_switcher.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/top_toast.dart';
import '../providers/telegram_storage_provider.dart';
import '../widgets/springy_tap.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  void _showCloudConfigDialog(BuildContext context, WidgetRef ref) {
    final storageState = ref.read(telegramStorageProvider);
    final storageNotifier = ref.read(telegramStorageProvider.notifier);
    
    final tokenController = TextEditingController(text: storageState.botToken);
    final chatController = TextEditingController(text: storageState.chatId);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cloud Storage Pipeline',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Configure your private secure cloud storage pipeline. The app will store your files securely as encrypted packets.',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              
              // Token Field
              const Text('BOT TOKEN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              TextField(
                controller: tokenController,
                decoration: InputDecoration(
                  hintText: 'Only For Tele. Devs.',
                  fillColor: theme.inputDecorationTheme.fillColor,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // Chat ID Field
              const Text('CHANNEL/CHAT ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              TextField(
                controller: chatController,
                decoration: InputDecoration(
                  hintText: 'Enter Channel ID (e.g. -100xxxxxxxxxx)',
                  fillColor: theme.inputDecorationTheme.fillColor,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 28),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    final token = tokenController.text.trim();
                    final chatId = chatController.text.trim();
                    
                    Navigator.of(context).pop();
                    
                    await storageNotifier.updateCredentials(token, chatId);
                    
                    if (context.mounted) {
                      TopToast.show(context, 'Profile settings saved.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Save & Synchronize', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {});
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Theme',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...ThemeMode.values.map((mode) {
              final isSelected = mode == currentMode;
              String label = '';
              IconData icon = LucideIcons.laptop;
              if (mode == ThemeMode.light) {
                label = 'Warm Sand (Light)';
                icon = LucideIcons.sun;
              } else if (mode == ThemeMode.dark) {
                label = 'Midnight Obsidian (Dark)';
                icon = LucideIcons.moon;
              } else {
                label = 'System Default';
                icon = LucideIcons.laptop;
              }
              
              Offset? lastTapDown;
              
              return Listener(
                onPointerDown: (event) => lastTapDown = event.position,
                child: ListTile(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop(); // Pop bottom sheet
                    
                    TelegramThemeSwitcher.changeTheme(
                      context: context,
                      tapPosition: lastTapDown ?? Offset(
                        MediaQuery.sizeOf(context).width / 2, 
                        MediaQuery.sizeOf(context).height / 2
                      ),
                      changeThemeAction: () {
                        ref.read(themeProvider.notifier).setThemeMode(mode);
                      },
                    );
                  },
                leading: Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.textTheme.labelSmall?.color),
                title: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  ),
                ),
                trailing: isSelected ? Icon(LucideIcons.check, color: theme.colorScheme.primary) : null,
                ),
              );
            }).toList(),
          ],
        ),
      ).animate().slideY(begin: 0.2, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)).fade(duration: 250.ms),
    );
  }

void _showSecurityDialog(BuildContext context, WidgetRef ref) {
  final theme = Theme.of(context);
  bool appLockEnabled = true;
  bool twoFactorEnabled = false;
  bool encryptionEnabled = true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.25),
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Security Settings',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(LucideIcons.x),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Configure biometric lock, two-factor authentication, and end-to-end client encryption settings.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                
                SwitchListTile.adaptive(
                  value: appLockEnabled,
                  onChanged: (val) {
                    setState(() {
                      appLockEnabled = val;
                    });
                  },
                  title: const Text('App Lock Passcode', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Require PIN or Biometrics on launch'),
                  activeColor: theme.colorScheme.primary,
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  value: twoFactorEnabled,
                  onChanged: (val) {
                    setState(() {
                      twoFactorEnabled = val;
                    });
                  },
                  title: const Text('Two-Factor Auth (2FA)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Additional secure OTP check for key operations'),
                  activeColor: theme.colorScheme.primary,
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  value: encryptionEnabled,
                  onChanged: (val) {
                    setState(() {
                      encryptionEnabled = val;
                    });
                  },
                  title: const Text('E2E Zero-Knowledge Encryption', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Encrypt filenames & payloads before upload'),
                  activeColor: theme.colorScheme.primary,
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      TopToast.show(context, 'Security settings have been updated.');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Save Security Configuration', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: 0.2, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)).fade(duration: 250.ms);
      },
    ),
  );
}

void _showNotificationsDialog(BuildContext context, WidgetRef ref) {
  final theme = Theme.of(context);
  bool pushEnabled = true;
  bool emailEnabled = false;
  bool warningEnabled = true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.25),
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notification Settings',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(LucideIcons.x),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Configure push notifications, storage limits warning notifications, and weekly reports.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                
                SwitchListTile.adaptive(
                  value: pushEnabled,
                  onChanged: (val) {
                    setState(() {
                      pushEnabled = val;
                    });
                  },
                  title: const Text('Push Alerts', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Get instant alerts for uploads and downloads'),
                  activeColor: theme.colorScheme.primary,
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  value: emailEnabled,
                  onChanged: (val) {
                    setState(() {
                      emailEnabled = val;
                    });
                  },
                  title: const Text('Email Summaries', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Receive weekly usage & activity reports'),
                  activeColor: theme.colorScheme.primary,
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  value: warningEnabled,
                  onChanged: (val) {
                    setState(() {
                      warningEnabled = val;
                    });
                  },
                  title: const Text('Storage Limit Warnings', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Notify when space usage reaches 90% threshold'),
                  activeColor: theme.colorScheme.primary,
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      TopToast.show(context, 'Notification settings updated.');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Save Notification Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: 0.2, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)).fade(duration: 250.ms);
      },
    ),
  );
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onboardingState = ref.watch(onboardingProvider);
    final storageState = ref.watch(telegramStorageProvider);
    final storageNotifier = ref.read(telegramStorageProvider.notifier);

    final userName = onboardingState.username.isNotEmpty ? onboardingState.username : 'Alex Morgan';
    final hasBackend = storageState.botToken.isNotEmpty && storageState.chatId.isNotEmpty;

    // Quota calculations (using 100 GB as base total quota)
    final int usedBytes = storageNotifier.totalUsedSizeBytes;
    const int totalBytes = 100 * 1024 * 1024 * 1024; // 100 GB
    final double percentUsed = min(1.0, usedBytes / totalBytes);

    Widget buildSettingItem({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      Color? iconColor,
    }) {
      return SpringyTap(
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor ?? theme.textTheme.labelSmall?.color, size: 18),
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: theme.textTheme.labelSmall?.color?.withOpacity(0.8),
            ),
          ),
          trailing: Icon(LucideIcons.chevron_right, color: theme.dividerColor, size: 20),
        ),
      );
    }

    final themeMode = ref.watch(themeProvider);
    String themeLabel = 'System Default';
    if (themeMode == ThemeMode.light) {
      themeLabel = 'Warm Sand (Light)';
    } else if (themeMode == ThemeMode.dark) {
      themeLabel = 'Midnight Obsidian (Dark)';
    }

    // Profile Header
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          'Profile',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          border: Border.all(color: theme.scaffoldBackgroundColor, width: 4),
                          boxShadow: theme.brightness == Brightness.light
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            userName.substring(0, 1).toUpperCase(),
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 36,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: theme.brightness == Brightness.light
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(LucideIcons.pencil, color: theme.colorScheme.onPrimary, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'alex@pdrive.com',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.labelSmall?.color,
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 500.ms, curve: const Cubic(0.16, 1, 0.3, 1)).slideY(begin: 0.1, end: 0, duration: 500.ms, curve: const Cubic(0.16, 1, 0.3, 1)),
            const SizedBox(height: 32),

            // Storage Bento Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                boxShadow: theme.brightness == Brightness.light
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.cloud, color: theme.colorScheme.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Storage',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_formatBytes(usedBytes, 1)} of 100 GB used',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: theme.textTheme.labelSmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: hasBackend
                              ? (theme.brightness == Brightness.dark
                                  ? const Color(0xFF064E3B).withOpacity(0.4)
                                  : const Color(0xFFE8F5E9))
                              : theme.inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasBackend
                                ? (theme.brightness == Brightness.dark
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF00873B)).withOpacity(0.2)
                                : theme.dividerColor.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          hasBackend ? 'Live Bot Storage' : 'Local Preview',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: hasBackend
                                ? (theme.brightness == Brightness.dark
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF006B2D))
                                : theme.textTheme.labelSmall?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentUsed,
                      minHeight: 6,
                      backgroundColor: theme.dividerColor,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0 GB',
                        style: TextStyle(fontSize: 11, color: theme.textTheme.labelSmall?.color),
                      ),
                      Text(
                        '100 GB',
                        style: TextStyle(fontSize: 11, color: theme.textTheme.labelSmall?.color),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fade(delay: 100.ms, duration: 500.ms, curve: const Cubic(0.16, 1, 0.3, 1)).slideY(begin: 0.1, end: 0, duration: 500.ms, curve: const Cubic(0.16, 1, 0.3, 1)),
            const SizedBox(height: 32),

            // Settings Header
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                child: Text(
                  'SETTINGS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            // Settings Card Container
            Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                boxShadow: theme.brightness == Brightness.light
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  buildSettingItem(
                    icon: LucideIcons.shield,
                    title: 'Security',
                    subtitle: 'Passwords, 2FA',
                    onTap: () => _showSecurityDialog(context, ref),
                  ),
                  Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                  buildSettingItem(
                    icon: LucideIcons.palette,
                    title: 'Theme',
                    subtitle: themeLabel,
                    onTap: () => _showThemeSelector(context, ref, themeMode),
                  ),
                  Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                  buildSettingItem(
                    icon: LucideIcons.bell,
                    title: 'Notifications',
                    subtitle: 'Push & Email',
                    onTap: () => _showNotificationsDialog(context, ref),
                  ),
                  Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                  buildSettingItem(
                    icon: LucideIcons.file_text,
                    title: 'Legal & Policies',
                    subtitle: 'Terms, Privacy, and Use Policies',
                    onTap: () => context.push('/legal'),
                  ),
                ],
              ),
            ).animate().fade(delay: 200.ms, duration: 350.ms).slideY(begin: 0.1, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)),
            const SizedBox(height: 32),

            // Logout Button
            SpringyTap(
              onTap: () async {
                ref.read(onboardingProvider.notifier).reset();
                storageNotifier.updateCredentials('', ''); // clear storage settings too
                await ref.read(googleAuthProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/');
                }
              },
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(LucideIcons.log_out, color: theme.colorScheme.error, size: 18),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ).animate().fade(delay: 250.ms, duration: 350.ms).slideY(begin: 0.1, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
