import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../providers/telegram_storage_provider.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  void _showTelegramConfigDialog(BuildContext context, WidgetRef ref) {
    final storageState = ref.read(telegramStorageProvider);
    final storageNotifier = ref.read(telegramStorageProvider.notifier);
    
    final tokenController = TextEditingController(text: storageState.botToken);
    final chatController = TextEditingController(text: storageState.chatId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
                    'Telegram Pipeline',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                'Configure your private Telegram channel storage pipeline. The app will store your files as documents inside the channel.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              
              // Token Field
              const Text('BOT TOKEN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              TextField(
                controller: tokenController,
                decoration: InputDecoration(
                  hintText: 'Enter Bot Token from @BotFather',
                  fillColor: const Color(0xFFF1F1EF),
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
                  fillColor: const Color(0xFFF1F1EF),
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
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Syncing with Telegram channel...')),
                    );
                    
                    await storageNotifier.updateCredentials(token, chatId);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Telegram settings saved successfully!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
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
      return ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F1EF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor ?? const Color(0xFF6B7280), size: 18),
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
            color: const Color(0xFF6B7280).withOpacity(0.8),
          ),
        ),
        trailing: const Icon(LucideIcons.chevronRight, color: Color(0xFFC5C5D8), size: 20),
      );
    }

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
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(LucideIcons.edit2, color: Colors.white, size: 14),
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
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 400.ms),
            const SizedBox(height: 32),

            // Storage Bento Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F3FF),
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
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: hasBackend ? const Color(0xFFE8F5E9) : const Color(0xFFF1F1EF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: (hasBackend ? const Color(0xFF00873B) : const Color(0xFFC5C5D8)).withOpacity(0.2)),
                        ),
                        child: Text(
                          hasBackend ? 'Live Bot Storage' : 'Local Preview',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: hasBackend ? const Color(0xFF006B2D) : const Color(0xFF6B7280),
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
                      backgroundColor: const Color(0xFFE5E7EB),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0 GB',
                        style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                      ),
                      Text(
                        '100 GB',
                        style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fade(delay: 100.ms),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Telegram Backend configuration trigger
                  buildSettingItem(
                    icon: LucideIcons.send,
                    iconColor: theme.colorScheme.primary,
                    title: 'Telegram Pipeline',
                    subtitle: hasBackend ? 'Active (Tap to edit config)' : 'Tap to configure Bot Credentials',
                    onTap: () => _showTelegramConfigDialog(context, ref),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F1EF)),
                  buildSettingItem(
                    icon: LucideIcons.shield,
                    title: 'Security',
                    subtitle: 'Passwords, 2FA',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F1EF)),
                  buildSettingItem(
                    icon: LucideIcons.palette,
                    title: 'Theme',
                    subtitle: 'Light Mode',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F1EF)),
                  buildSettingItem(
                    icon: LucideIcons.bell,
                    title: 'Notifications',
                    subtitle: 'Push & Email',
                    onTap: () {},
                  ),
                ],
              ),
            ).animate().fade(delay: 200.ms),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(onboardingProvider.notifier).reset();
                  storageNotifier.updateCredentials('', ''); // clear storage settings too
                  context.go('/');
                },
                icon: const Icon(LucideIcons.logOut, color: Color(0xFFBA1A1A), size: 18),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFBA1A1A),
                  side: const BorderSide(color: Color(0xFFBA1A1A), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).animate().fade(delay: 250.ms),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
