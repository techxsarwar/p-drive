import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../providers/telegram_storage_provider.dart';
import '../widgets/upload_bottom_sheet.dart';
import '../../../core/providers/supabase_auth_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';

/// Global key that exposes the DashboardShell's ScaffoldState so that
/// child screens (which have their own inner Scaffold) can open the Drawer.
final GlobalKey<ScaffoldState> dashboardScaffoldKey = GlobalKey<ScaffoldState>();

class DashboardShell extends ConsumerStatefulWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/dashboard/files')) return 1;
    if (location.startsWith('/dashboard/shared')) return 2;
    if (location.startsWith('/dashboard/profile')) return 3;
    return 0; // Default to home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard/home');
        break;
      case 1:
        context.go('/dashboard/files');
        break;
      case 2:
        context.go('/dashboard/shared');
        break;
      case 3:
        context.go('/dashboard/profile');
        break;
    }
  }

  void _showUploadBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) => const UploadBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _getSelectedIndex(location);
    
    // Watch transfer progress
    final storageState = ref.watch(telegramStorageProvider);
    final isTransferring = storageState.isUploading || storageState.isDownloading;
    final progress = storageState.isUploading ? storageState.uploadProgress : storageState.downloadProgress;
    final message = storageState.isUploading ? 'Uploading file' : 'Downloading file';

    Widget buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
      final isSelected = currentIndex == index;
      return GestureDetector(
        onTap: () => _onItemTapped(index, context),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? theme.colorScheme.primary : theme.textTheme.labelSmall?.color?.withOpacity(0.6),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? theme.colorScheme.primary : theme.textTheme.labelSmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    final authState = ref.watch(authProvider);
    final onboardingState = ref.watch(onboardingProvider);

    final displayName = authState.isAuthenticated 
        ? (authState.displayName ?? 'P-Drive Profile') 
        : (onboardingState.username.isNotEmpty ? onboardingState.username : 'Local Explorer');
    final userEmail = authState.isAuthenticated 
        ? (authState.email ?? 'Connected') 
        : 'Encrypted Mode';

    final int usedBytes = storageState.allFiles.fold(0, (sum, f) => sum + ((f['size_bytes'] as num?)?.toInt() ?? 0));
    const int totalBytes = 100 * 1024 * 1024 * 1024; // 100 GB
    final double percentUsed = min(1.0, usedBytes / totalBytes);
    final String usedStr = _formatBytes(usedBytes, 1);
    final String freeStr = _formatBytes(totalBytes - usedBytes, 1);

    return Scaffold(
      key: dashboardScaffoldKey,
      drawer: Drawer(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              displayName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                userEmail,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Storage usage bar
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(LucideIcons.hard_drive, size: 14, color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Storage',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$usedStr / 100 GB',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentUsed,
                              minHeight: 6,
                              backgroundColor: theme.dividerColor,
                              color: percentUsed > 0.8
                                  ? Colors.orange
                                  : theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$freeStr free',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    _buildDrawerItem(
                      theme: theme,
                      icon: LucideIcons.layout_grid,
                      label: 'Home Dashboard',
                      isSelected: currentIndex == 0,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(0, context);
                      },
                    ),
                    _buildDrawerItem(
                      theme: theme,
                      icon: LucideIcons.folder,
                      label: 'My Files',
                      isSelected: currentIndex == 1,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(1, context);
                      },
                    ),
                    _buildDrawerItem(
                      theme: theme,
                      icon: LucideIcons.users,
                      label: 'Shared Spaces',
                      isSelected: currentIndex == 2,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(2, context);
                      },
                    ),
                    _buildDrawerItem(
                      theme: theme,
                      icon: LucideIcons.star,
                      label: 'Favorites',
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Favorites coming soon')));
                      },
                    ),
                    _buildDrawerItem(
                      theme: theme,
                      icon: LucideIcons.clock,
                      label: 'Recent Files',
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recent Files coming soon')));
                      },
                    ),
                    _buildDrawerItem(
                      theme: theme,
                      icon: LucideIcons.trash_2,
                      label: 'Trash Bin',
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trash Bin coming soon')));
                      },
                    ),
                    _buildDrawerItem(
                      theme: theme,
                      icon: LucideIcons.user,
                      label: 'Profile Settings',
                      isSelected: currentIndex == 3,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(3, context);
                      },
                    ),
                    _buildDrawerItem(
                      theme: theme,
                      icon: LucideIcons.file_text,
                      label: 'Legal & Policies',
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/legal');
                      },
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildDrawerItem(
                      theme: theme,
                      icon: LucideIcons.cloud_upload,
                      label: 'Upload Files',
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
                        _showUploadBottomSheet(context);
                      },
                    ),
                  ],
                ),
              ),
              
              // Footer â€” version only, no internal tech settings
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'P-Drive',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'v1.0.0',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: 84 + MediaQuery.of(context).padding.bottom),
              child: widget.child,
            ),
          ),
          
          // Telegram-Style Floating Action Button (FAB) / Progress Indicator
          if (location.startsWith('/dashboard'))
            Positioned(
              bottom: 100 + MediaQuery.of(context).padding.bottom,
              right: 16,
              child: AnimatedUploadFab(
                isTransferring: isTransferring,
                progress: progress,
                isUploading: storageState.isUploading,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showUploadBottomSheet(context);
                },
              ),
            ),

          // Custom Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 84 + MediaQuery.of(context).padding.bottom,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.only(
                    top: 12,
                    bottom: MediaQuery.of(context).padding.bottom + 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.9),
                    border: Border(
                      top: BorderSide(
                        color: theme.dividerColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    boxShadow: theme.brightness == Brightness.light
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 20,
                              offset: const Offset(0, -4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildNavItem(0, LucideIcons.layout_grid, LucideIcons.layout_grid, 'Home'),
                      buildNavItem(1, LucideIcons.folder, LucideIcons.folder, 'Files'),
                      buildNavItem(2, LucideIcons.users, LucideIcons.users, 'Shared'),
                      buildNavItem(3, LucideIcons.user, LucideIcons.user, 'Profile'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
          size: 20,
        ),
        title: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dense: true,
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Telegram-style Upload FAB: Morphs into a circular progress indicator
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class AnimatedUploadFab extends StatefulWidget {
  final bool isTransferring;
  final double progress;
  final bool isUploading;
  final VoidCallback onTap;

  const AnimatedUploadFab({
    super.key,
    required this.isTransferring,
    required this.progress,
    required this.isUploading,
    required this.onTap,
  });

  @override
  State<AnimatedUploadFab> createState() => _AnimatedUploadFabState();
}

class _AnimatedUploadFabState extends State<AnimatedUploadFab> {
  bool _showSuccess = false;

  @override
  void didUpdateWidget(AnimatedUploadFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isTransferring && !widget.isTransferring) {
      // Transfer just finished! Show checkmark briefly.
      setState(() => _showSuccess = true);
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) setState(() => _showSuccess = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProgress = widget.isTransferring;
    final isCheck = _showSuccess;

    // Telegram philosophy: One object. Never replaced. Always transformed.
    // Default FAB shape: width 56, rounded 16
    // Progress shape: width 52, circle (rounded 26)
    final double size = isProgress || isCheck ? 52.0 : 56.0;
    final double radius = isProgress || isCheck ? 26.0 : 16.0;

    return GestureDetector(
      onTap: isProgress ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: const Cubic(0.34, 1.56, 0.64, 1), // Bouncy spring curve
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isCheck ? Colors.green.shade600 : theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: (isCheck ? Colors.green.shade600 : theme.colorScheme.primary).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: isCheck
              ? const Icon(LucideIcons.check, color: Colors.white, size: 26, key: ValueKey('check'))
              : isProgress
                  ? Stack(
                      key: const ValueKey('progress'),
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: widget.progress),
                            duration: const Duration(milliseconds: 250),
                            builder: (context, value, _) => CircularProgressIndicator(
                              value: value,
                              strokeWidth: 3,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        Icon(
                          widget.isUploading ? LucideIcons.arrow_up : LucideIcons.arrow_down,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    )
                  : const Icon(LucideIcons.plus, color: Colors.white, size: 28, key: ValueKey('plus')),
        ),
      ),
    );
  }
}

