import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../providers/telegram_storage_provider.dart';
import '../widgets/upload_bottom_sheet.dart';
import '../widgets/springy_tap.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  void _showDocumentScanner(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool isScanning = false;
          bool isProcessing = false;
          String processStep = "Ready to Scan";
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Document Scanner',
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
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.3,
                            child: GridPaper(
                              color: theme.colorScheme.primary,
                              divisions: 2,
                              subdivisions: 4,
                              interval: 100,
                            ),
                          ),
                        ),
                        if (!isProcessing) ...[
                          Center(
                            child: Container(
                              width: 250,
                              height: 350,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 40,
                            child: Text(
                              'Align document within frame',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                        if (isScanning)
                          Positioned.fill(
                            child: Container()
                                .animate(onPlay: (controller) => controller.repeat())
                                .custom(
                                  duration: 1.5.seconds,
                                  builder: (context, value, child) {
                                    return Align(
                                      alignment: Alignment(0, -1.0 + (value * 2.0)),
                                      child: Container(
                                        height: 3,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.colorScheme.primary.withOpacity(0.8),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          ),
                        if (isProcessing)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: theme.colorScheme.primary),
                                  const SizedBox(height: 20),
                                  Text(
                                    processStep,
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                  ).animate().fade(duration: 200.ms).scale(duration: 200.ms),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (!isScanning && !isProcessing)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          isScanning = true;
                        });
                        await Future.delayed(1.5.seconds);
                        setState(() {
                          isScanning = false;
                          isProcessing = true;
                          processStep = "Detecting document borders...";
                        });
                        await Future.delayed(1.seconds);
                        setState(() {
                          processStep = "Enhancing image contrast...";
                        });
                        await Future.delayed(1.seconds);
                        setState(() {
                          processStep = "Creating encrypted PDF...";
                        });
                        await Future.delayed(800.ms);
                        
                        final docId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
                        final filename = 'Scanned_Doc_$docId.pdf';
                        await ref.read(telegramStorageProvider.notifier).addScannedFile(filename, 1254300);
                        
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Document "$filename" scanned & synced!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(LucideIcons.camera),
                      label: const Text('Capture Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  )
                else
                  const SizedBox(
                    height: 56,
                    child: Center(
                      child: Text('Scanning in progress...', style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ),
              ],
            ),
          ).animate().slideY(begin: 0.2, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)).fade(duration: 250.ms);
        },
      ),
    );
  }

  void _showShareDialog(BuildContext context, String workspaceName) {
    final theme = Theme.of(context);
    final String mockShareLink = "https://pdrive.cloud/s/${Uri.encodeComponent(workspaceName.toLowerCase().replaceAll(' ', '_'))}";

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Share $workspaceName',
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
              'Generate a secure share link for your "$workspaceName" workspace.',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.link, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mockShareLink,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied to clipboard!')),
                      );
                    },
                    child: const Text('Copy'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('OR SHARE VIA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(context, LucideIcons.mail, 'Email'),
                _buildShareOption(context, LucideIcons.message_square, 'Messages'),
                _buildShareOption(context, LucideIcons.qr_code, 'QR Code'),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ).animate().slideY(begin: 0.2, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)).fade(duration: 250.ms),
    );
  }

  Widget _buildShareOption(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shared via $label successfully!')),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      return SpringyTap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildFolderCard(String name, int fileCount, VoidCallback onTap) {
      return Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        child: SpringyTap(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
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
                        fontWeight: FontWeight.bold,
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
          ),
        ),
      );
    }

    Widget buildFileRowItem(Map<String, dynamic> file) {
      final String name = file['name'] ?? 'Untitled';
      final int size = (file['size_bytes'] as num?)?.toInt() ?? 0;
      final String sizeStr = _formatBytes(size, 1);
      final String dateStr = file['uploaded_at'].toString().split('T').first;

      IconData fileIcon = LucideIcons.archive;
      Color iconBgColor = theme.brightness == Brightness.dark
          ? const Color(0xFF1E293B)
          : const Color(0xFFF1F1EF);
      Color iconColor = theme.brightness == Brightness.dark
          ? const Color(0xFF94A3B8)
          : const Color(0xFF6B7280);

      if (name.toLowerCase().endsWith('.pdf')) {
        fileIcon = LucideIcons.file_text;
        iconBgColor = theme.brightness == Brightness.dark
            ? const Color(0xFF7F1D1D).withOpacity(0.4)
            : const Color(0xFFFFDAD6);
        iconColor = theme.brightness == Brightness.dark
            ? const Color(0xFFF87171)
            : const Color(0xFFBA1A1A);
      } else if (name.toLowerCase().endsWith('.png') || name.toLowerCase().endsWith('.jpg') || name.toLowerCase().endsWith('.jpeg')) {
        fileIcon = LucideIcons.image;
        iconBgColor = theme.brightness == Brightness.dark
            ? theme.colorScheme.primary.withOpacity(0.2)
            : const Color(0xFFE9EDFF);
        iconColor = theme.colorScheme.primary;
      } else if (name.toLowerCase().endsWith('.docx') || name.toLowerCase().endsWith('.doc')) {
        fileIcon = LucideIcons.file_spreadsheet;
        iconBgColor = theme.brightness == Brightness.dark
            ? const Color(0xFF064E3B).withOpacity(0.4)
            : const Color(0xFFE8F5E9);
        iconColor = theme.brightness == Brightness.dark
            ? const Color(0xFF34D399)
            : const Color(0xFF006B2D);
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: SpringyTap(
          onTap: () => context.push('/file-details', extra: name),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
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
                          fontWeight: FontWeight.bold,
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
                    LucideIcons.ellipsis_vertical,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    size: 20,
                  ),
                ),
              ],
            ),
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
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
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
                color: theme.colorScheme.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.12)),
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
                      color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: theme.brightness == Brightness.light
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.4),
                      ),
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
                            backgroundColor: theme.dividerColor,
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
            ).animate().fade(duration: 350.ms).slideY(begin: 0.1, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)),
            
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
                  icon: LucideIcons.folder_plus,
                  label: 'New Folder',
                  onTap: () {
                    // Navigate to files tab
                    context.go('/dashboard/files');
                  },
                ),
                buildQuickActionButton(
                  icon: LucideIcons.scan,
                  label: 'Scan',
                  onTap: () => _showDocumentScanner(context),
                ),
                buildQuickActionButton(
                  icon: LucideIcons.share_2,
                  label: 'Share',
                  onTap: () => _showShareDialog(context, 'Global Workspace'),
                ),
              ],
            ).animate().fade(delay: 100.ms, duration: 350.ms).slideY(begin: 0.1, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)),
            
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
                      color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
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
                        return buildFolderCard(
                          foldersList[index],
                          filesCount,
                          () {
                            storageNotifier.changeDirectory(folderPath);
                            context.go('/dashboard/files');
                          },
                        );
                      },
                    ),
                  ).animate().fade(delay: 200.ms, duration: 350.ms).slideY(begin: 0.1, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)),
            
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
                      color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      'No files yet. Pick Upload to add files.',
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    ),
                  )
                : Column(
                    children: topRecentFiles.map((f) => buildFileRowItem(f)).toList(),
                  ).animate().fade(delay: 300.ms, duration: 350.ms).slideY(begin: 0.1, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
