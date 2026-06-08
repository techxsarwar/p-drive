import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../providers/telegram_storage_provider.dart';
import '../widgets/upload_bottom_sheet.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Observers
    final onboardingState = ref.watch(onboardingProvider);
    final storageState = ref.watch(telegramStorageProvider);
    final storageNotifier = ref.read(telegramStorageProvider.notifier);

    final userName = onboardingState.username.isNotEmpty ? onboardingState.username : 'Alex';
    
    // Storage math
    final int usedBytes = storageNotifier.totalUsedSizeBytes;
    const int totalBytes = 100 * 1024 * 1024 * 1024; // 100 GB
    final double percentUsed = min(1.0, usedBytes / totalBytes);
    final String percentString = '${(percentUsed * 100).toStringAsFixed(0)}%';

    // Suggested dynamic folders (top level folders matching currentPath="/")
    final foldersList = storageState.allFolders
        .where((f) => f.split('/').length == 2) // e.g. /Folder, depth=1
        .map((f) => f.substring(1)) // Remove leading slash
        .toList();

    // Recent files sorted (most recent first)
    final recentFiles = List<Map<String, dynamic>>.from(storageState.allFiles)
      ..sort((a, b) => b['uploaded_at'].toString().compareTo(a['uploaded_at'].toString()));
    final topRecentFiles = recentFiles.take(3).toList();

    // Widget helpers
    Widget buildQuickActionButton({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F3FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildFolderCard(String name, int fileCount) {
      return Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(LucideIcons.folder, size: 36, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$fileCount files',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: theme.textTheme.labelSmall?.color?.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildFileRowItem(Map<String, dynamic> file) {
      final String name = file['name'] ?? 'Untitled';
      final int size = (file['size_bytes'] as num?)?.toInt() ?? 0;
      final String sizeStr = _formatBytes(size, 1);
      final String dateStr = file['uploaded_at'].toString().split('T').first;

      IconData fileIcon = LucideIcons.archive;
      Color iconBgColor = const Color(0xFFF1F1EF);
      Color iconColor = const Color(0xFF6B7280);

      if (name.toLowerCase().endsWith('.pdf')) {
        fileIcon = LucideIcons.fileText;
        iconBgColor = const Color(0xFFFFDAD6);
        iconColor = const Color(0xFFBA1A1A);
      } else if (name.toLowerCase().endsWith('.png') || name.toLowerCase().endsWith('.jpg') || name.toLowerCase().endsWith('.jpeg')) {
        fileIcon = LucideIcons.image;
        iconBgColor = const Color(0xFFE9EDFF);
        iconColor = theme.colorScheme.primary;
      } else if (name.toLowerCase().endsWith('.docx') || name.toLowerCase().endsWith('.doc')) {
        fileIcon = LucideIcons.fileSpreadsheet;
        iconBgColor = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF006B2D);
      }

      return GestureDetector(
        onTap: () => context.push('/file-details', extra: name),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(fileIcon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Modified $dateStr • $sizeStr',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        color: theme.textTheme.labelSmall?.color?.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  LucideIcons.moreVertical,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(LucideIcons.menu),
        ),
        title: Text(
          'P-Drive',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => context.go('/dashboard/profile'),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  userName.substring(0, 1).toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hello Bento Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EDFF).withOpacity(0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE9EDFF).withOpacity(0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $userName',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your digital workspace is looking clean.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Quota inside container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.01),
                          blurRadius: 10,
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
                                Icon(LucideIcons.cloud, color: theme.colorScheme.primary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Cloud Storage',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              percentString,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_formatBytes(usedBytes, 1)} Used',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                color: theme.textTheme.labelSmall?.color?.withOpacity(0.5),
                              ),
                            ),
                            Text(
                              '100 GB Total',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                color: theme.textTheme.labelSmall?.color?.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0),
            
            const SizedBox(height: 32),
            
            // Quick Actions header
            Text(
              'QUICK ACTIONS',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            
            // Bento Quick Actions Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                buildQuickActionButton(
                  icon: LucideIcons.upload,
                  label: 'Upload',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      barrierColor: Colors.black.withOpacity(0.25),
                      builder: (context) => const UploadBottomSheet(),
                    );
                  },
                ),
                buildQuickActionButton(
                  icon: LucideIcons.folderPlus,
                  label: 'New Folder',
                  onTap: () {
                    // Navigate to files tab
                    context.go('/dashboard/files');
                  },
                ),
                buildQuickActionButton(
                  icon: LucideIcons.scan,
                  label: 'Scan',
                  onTap: () {},
                ),
                buildQuickActionButton(
                  icon: LucideIcons.share2,
                  label: 'Share',
                  onTap: () {},
                ),
              ],
            ).animate().fade(delay: 100.ms),
            
            const SizedBox(height: 32),
            
            // Suggested Folders row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SUGGESTED FOLDERS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.5,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/dashboard/files'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Horizontal scroll container of suggested folders
            foldersList.isEmpty
                ? Container(
                    height: 120,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.4)),
                    ),
                    child: Text(
                      'No folders yet.',
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    ),
                  )
                : SizedBox(
                    height: 132,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: foldersList.length,
                      itemBuilder: (context, index) {
                        final folderPath = '/${foldersList[index]}';
                        final filesCount = storageState.allFiles.where((f) => f['path'] == folderPath).length;
                        return GestureDetector(
                          onTap: () {
                            storageNotifier.changeDirectory(folderPath);
                            context.go('/dashboard/files');
                          },
                          child: buildFolderCard(foldersList[index], filesCount),
                        );
                      },
                    ),
                  ).animate().fade(delay: 200.ms),
            
            const SizedBox(height: 32),
            
            // Recent Files
            Text(
              'RECENT FILES',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            
            topRecentFiles.isEmpty
                ? Container(
                    height: 120,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.4)),
                    ),
                    child: Text(
                      'No files yet. Pick Upload to add files.',
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    ),
                  )
                : Column(
                    children: topRecentFiles.map((f) => buildFileRowItem(f)).toList(),
                  ).animate().fade(delay: 300.ms),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
