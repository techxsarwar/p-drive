import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import '../providers/telegram_storage_provider.dart';
import '../widgets/upload_bottom_sheet.dart';
import '../../../core/providers/google_auth_provider.dart';

class DashboardShell extends ConsumerStatefulWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
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

    final authState = ref.watch(googleAuthProvider);

    return Scaffold(
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
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                          child: Text(
                            (authState.displayName ?? 'Guest').substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authState.displayName ?? 'Guest Explorer',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                authState.email ?? 'Connected Mode (Local)',
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
                    // Quick stats
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.hard_drive, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Used: 32.4 GB / 100 GB',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
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
                      icon: LucideIcons.user,
                      label: 'Profile Settings',
                      isSelected: currentIndex == 3,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(3, context);
                      },
                    ),
                  ],
                ),
              ),
              
              // Footer settings quick switches
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chunking Pipeline',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Switch.adaptive(
                      value: storageState.isChunkingEnabled,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        ref.read(telegramStorageProvider.notifier).toggleChunking(val);
                      },
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
          
          // Background/Foreground Progress Banner Overlay
          if (isTransferring)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
                shadowColor: theme.brightness == Brightness.light ? Colors.black.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            storageState.isUploading ? LucideIcons.cloud_upload : LucideIcons.cloud_download,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (storageState.transferStatus != null && storageState.transferStatus!.isNotEmpty)
                                  ? storageState.transferStatus!
                                  : '$message...',
                              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: theme.dividerColor,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Floating Action Button (FAB)
          if (location.startsWith('/dashboard'))
            Positioned(
              bottom: 100 + MediaQuery.of(context).padding.bottom,
              right: 16,
              child: FloatingActionButton(
                onPressed: () => _showUploadBottomSheet(context),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(LucideIcons.plus, size: 28),
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
