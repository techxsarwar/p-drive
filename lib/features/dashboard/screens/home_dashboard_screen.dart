import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/widgets/top_toast.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../providers/telegram_storage_provider.dart';
import '../widgets/upload_bottom_sheet.dart';
import '../widgets/springy_tap.dart';
import 'dashboard_shell.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen>
    with SingleTickerProviderStateMixin {

  // Controls the storage bar animated fill (0→actual)
  late AnimationController _storageController;
  late Animation<double> _storageAnim;
  double _lastPercent = 0;

  @override
  void initState() {
    super.initState();
    _storageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _storageAnim = CurvedAnimation(
      parent: _storageController,
      curve: Curves.easeOutCubic,
    );
    // Kick off after first frame so we have data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storageController.forward();
    });
  }

  @override
  void dispose() {
    _storageController.dispose();
    super.dispose();
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  // ─── Bottom Sheets ──────────────────────────────────────────────────────────

  void _showDocumentScanner(BuildContext context) {
    final theme = Theme.of(context);
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => _BlurSheet(
        height: MediaQuery.of(context).size.height * 0.75,
        child: StatefulBuilder(
          builder: (context, setState) {
            bool isScanning = false;
            bool isProcessing = false;
            String processStep = "Ready to Scan";

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Document Scanner', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      _SheetCloseButton(),
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
                          ],
                          if (isScanning)
                            Positioned.fill(
                              child: Container()
                                  .animate(onPlay: (c) => c.repeat())
                                  .custom(
                                    duration: 1.5.seconds,
                                    builder: (context, value, child) => Align(
                                      alignment: Alignment(0, -1.0 + (value * 2.0)),
                                      child: Container(
                                        height: 3,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.colorScheme.primary.withOpacity(0.8),
                                              blurRadius: 10, spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                                    Text(processStep,
                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))
                                        .animate()
                                        .fade(duration: 200.ms)
                                        .scale(duration: 200.ms),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: isScanning || isProcessing ? null : () async {
                        HapticFeedback.mediumImpact();
                        setState(() { isScanning = true; });
                        await Future.delayed(1.5.seconds);
                        setState(() { isScanning = false; isProcessing = true; processStep = "Detecting document borders..."; });
                        await Future.delayed(1.seconds);
                        setState(() { processStep = "Enhancing image contrast..."; });
                        await Future.delayed(1.seconds);
                        setState(() { processStep = "Creating encrypted PDF..."; });
                        await Future.delayed(800.ms);
                        final docId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
                        final filename = 'Scanned_Doc_$docId.pdf';
                        await ref.read(telegramStorageProvider.notifier).addScannedFile(filename, 1254300);
                        if (context.mounted) {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                          TopToast.show(context, 'Document "$filename" scanned & synced!');
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
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context, String workspaceName) {
    HapticFeedback.lightImpact();
    final theme = Theme.of(context);
    final String mockShareLink = "https://pdrive.cloud/s/${Uri.encodeComponent(workspaceName.toLowerCase().replaceAll(' ', '_'))}";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => _BlurSheet(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Share $workspaceName', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  _SheetCloseButton(),
                ],
              ),
              const SizedBox(height: 12),
              Text('Generate a secure share link for your "$workspaceName" workspace.',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 20),
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
                      child: Text(mockShareLink,
                          style: TextStyle(fontFamily: 'monospace', fontSize: 13, color: theme.colorScheme.onSurface),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                        TopToast.show(context, 'Link copied!');
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
                  _ShareOption(icon: LucideIcons.mail, label: 'Email'),
                  _ShareOption(icon: LucideIcons.message_square, label: 'Messages'),
                  _ShareOption(icon: LucideIcons.qr_code, label: 'QR Code'),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final onboardingState = ref.watch(onboardingProvider);
    final storageState = ref.watch(telegramStorageProvider);
    final storageNotifier = ref.read(telegramStorageProvider.notifier);

    final userName = onboardingState.username.isNotEmpty ? onboardingState.username : 'Alex';

    final int usedBytes = storageNotifier.totalUsedSizeBytes;
    const int totalBytes = 100 * 1024 * 1024 * 1024;
    final double percentUsed = min(1.0, usedBytes / totalBytes);

    // Animate storage fill if value changed
    if ((percentUsed - _lastPercent).abs() > 0.001) {
      _lastPercent = percentUsed;
      _storageAnim = Tween<double>(begin: 0, end: percentUsed).animate(
        CurvedAnimation(parent: _storageController, curve: Curves.easeOutCubic),
      );
      _storageController
        ..reset()
        ..forward();
    }

    final String percentString = '${(percentUsed * 100).toStringAsFixed(0)}%';

    final foldersList = storageState.allFolders
        .where((f) => f.split('/').length == 2)
        .map((f) => f.substring(1))
        .toList();

    final recentFiles = List<Map<String, dynamic>>.from(storageState.allFiles)
      ..sort((a, b) => b['uploaded_at'].toString().compareTo(a['uploaded_at'].toString()));
    final topRecentFiles = recentFiles.take(3).toList();

    // ── Widget helpers ───────────────────────────────────────────────────────

    Widget buildQuickActionButton({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      int delayMs = 0,
    }) {
      return SpringyTap(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
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
              Text(label, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      )
          .animate(delay: delayMs.ms)
          .fade(duration: 350.ms)
          .slideY(begin: 0.08, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1));
    }

    Widget buildFolderCard(String name, int fileCount, VoidCallback onTap, int index) {
      return Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        child: SpringyTap(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
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
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('$fileCount files',
                        style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 11, color: theme.textTheme.labelSmall?.color?.withOpacity(0.5))),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
          .animate(delay: (index * 20).ms)
          .fade(duration: 300.ms)
          .slideX(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
    }

    Widget buildFileRowItem(Map<String, dynamic> file, int index) {
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
      } else if (name.toLowerCase().endsWith('.png') ||
          name.toLowerCase().endsWith('.jpg') ||
          name.toLowerCase().endsWith('.jpeg')) {
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
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/file-details', extra: name);
          },
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
                      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Modified $dateStr • $sizeStr',
                          style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 11, color: theme.textTheme.labelSmall?.color?.withOpacity(0.5))),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(LucideIcons.info),
                              title: const Text('View Details'),
                              onTap: () {
                                Navigator.pop(ctx);
                                context.push('/file-details', extra: name);
                              },
                            ),
                            ListTile(
                              leading: Icon(LucideIcons.trash_2, color: theme.colorScheme.error),
                              title: Text('Delete File', style: TextStyle(color: theme.colorScheme.error)),
                              onTap: () async {
                                Navigator.pop(ctx);
                                TopToast.show(context, 'Deleting file...');
                                await storageNotifier.deleteFile(name, file['file_id'] ?? '');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: Icon(LucideIcons.ellipsis_vertical,
                      color: theme.colorScheme.onSurface.withOpacity(0.4), size: 20),
                ),
              ],
            ),
          ),
        ),
      )
          .animate(delay: (index * 30).ms)   // ← Telegram stagger
          .fade(duration: 350.ms)
          .slideY(begin: 0.06, end: 0, duration: 350.ms, curve: Curves.easeOutCubic);
    }

    // ── Scaffold ─────────────────────────────────────────────────────────────

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            dashboardScaffoldKey.currentState?.openDrawer();
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
            onTap: () {
              HapticFeedback.selectionClick();
              context.go('/dashboard/profile');
            },
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
          )
              // subtle avatar pulse — Telegram profile style
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.06, 1.06),
                  duration: 2400.ms, curve: Curves.easeInOut),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Storage card — animates in first ──────────────────────────
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
                  Text('Hello, $userName', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Your digital workspace is looking clean.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 24),
                  // Storage bar — fills from 0→actual (animated)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
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
                                Text('Cloud Storage',
                                    style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                              ],
                            ),
                            AnimatedBuilder(
                              animation: _storageAnim,
                              builder: (_, __) => Text(
                                '${(_storageAnim.value * 100).toStringAsFixed(0)}%',
                                style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Animated progress bar 0→target
                        AnimatedBuilder(
                          animation: _storageAnim,
                          builder: (_, __) => ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _storageAnim.value,
                              minHeight: 6,
                              backgroundColor: theme.dividerColor,
                              color: _storageAnim.value > 0.8
                                  ? Colors.orange
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${_formatBytes(usedBytes, 1)} Used',
                                style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 11,
                                    color: theme.textTheme.labelSmall?.color?.withOpacity(0.5))),
                            Text('100 GB Total',
                                style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 11,
                                    color: theme.textTheme.labelSmall?.color?.withOpacity(0.5))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                // Card fades + expands in (delay 0ms — first to appear)
                .animate()
                .fade(duration: 400.ms)
                .scaleXY(begin: 0.96, end: 1, duration: 450.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)),

            const SizedBox(height: 32),

            // ── Quick Actions — staggered grid ───────────────────────────
            Text('QUICK ACTIONS',
                style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5))
                .animate(delay: 80.ms)
                .fade(duration: 300.ms),
            const SizedBox(height: 12),

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
                  delayMs: 100,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    barrierColor: Colors.black.withOpacity(0.4),
                    builder: (context) => _BlurSheet(child: const UploadBottomSheetContent()),
                  ),
                ),
                buildQuickActionButton(
                  icon: LucideIcons.folder_plus,
                  label: 'New Folder',
                  delayMs: 120,
                  onTap: () => context.go('/dashboard/files'),
                ),
                buildQuickActionButton(
                  icon: LucideIcons.scan,
                  label: 'Scan',
                  delayMs: 140,
                  onTap: () => _showDocumentScanner(context),
                ),
                buildQuickActionButton(
                  icon: LucideIcons.share_2,
                  label: 'Share',
                  delayMs: 160,
                  onTap: () => _showShareDialog(context, 'Global Workspace'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Suggested Folders ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SUGGESTED FOLDERS',
                    style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5))
                    .animate(delay: 180.ms).fade(duration: 300.ms),
                TextButton(
                  onPressed: () => context.go('/dashboard/files'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

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
                    child: Text('No folders yet.',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4))),
                  )
                : SizedBox(
                    height: 132,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: foldersList.length,
                      itemBuilder: (context, index) {
                        final folderPath = '/${foldersList[index]}';
                        final filesCount = storageState.allFiles
                            .where((f) => f['path'] == folderPath)
                            .length;
                        return buildFolderCard(
                          foldersList[index],
                          filesCount,
                          () {
                            storageNotifier.changeDirectory(folderPath);
                            context.go('/dashboard/files');
                          },
                          index,
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 32),

            // ── Recent Files — staggered list ────────────────────────────
            Text('RECENT FILES',
                style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5))
                .animate(delay: 260.ms).fade(duration: 300.ms),
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
                    child: Text('No files yet. Tap Upload to add files.',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4))),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < topRecentFiles.length; i++)
                        buildFileRowItem(topRecentFiles[i], i),
                    ],
                  ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Reusable: Blurred bottom sheet wrapper (Telegram-style arrive + bounce)
// ═══════════════════════════════════════════════════════════════════════════════

class _BlurSheet extends StatelessWidget {
  final Widget child;
  final double? height;
  const _BlurSheet({required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.92),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
          ),
          child: Column(
            mainAxisSize: height == null ? MainAxisSize.min : MainAxisSize.max,
            children: [
              const SizedBox(height: 12),
              // Drag pill
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.15, end: 0, duration: 380.ms, curve: const Cubic(0.34, 1.56, 0.64, 1))
        .fade(duration: 250.ms);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Reusable: Sheet close button
// ═══════════════════════════════════════════════════════════════════════════════

class _SheetCloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(LucideIcons.x, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Reusable: Share option chip
// ═══════════════════════════════════════════════════════════════════════════════

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ShareOption({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
        TopToast.show(context, 'Shared via $label!');
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
}

// ═══════════════════════════════════════════════════════════════════════════════
// Upload bottom sheet content — now wrapped in _BlurSheet externally
// ═══════════════════════════════════════════════════════════════════════════════

class UploadBottomSheetContent extends ConsumerWidget {
  const UploadBottomSheetContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final storageNotifier = ref.read(telegramStorageProvider.notifier);

    Widget buildOptionButton({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      int delayMs = 0,
    }) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 26),
              ),
              const SizedBox(height: 12),
              Text(label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      )
          .animate(delay: delayMs.ms)
          .fade(duration: 300.ms)
          .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Create New', style: theme.textTheme.headlineMedium),
              _SheetCloseButton(),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.15,
            children: [
              buildOptionButton(
                icon: LucideIcons.file_plus,
                label: 'Upload File',
                delayMs: 0,
                onTap: () async {
                  Navigator.of(context).pop();
                  HapticFeedback.mediumImpact();
                  final success = await storageNotifier.uploadLocalFile();
                  if (context.mounted) {
                    HapticFeedback.lightImpact();
                    TopToast.show(context, success ? 'File uploaded successfully!' : 'Failed to upload file.', isError: !success);
                  }
                },
              ),
              buildOptionButton(
                icon: LucideIcons.folder_plus,
                label: 'New Folder',
                delayMs: 30,
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/dashboard/files');
                },
              ),
              buildOptionButton(icon: LucideIcons.camera, label: 'Take Photo', delayMs: 60,
                  onTap: () => Navigator.of(context).pop()),
              buildOptionButton(icon: LucideIcons.scan, label: 'Scan Document', delayMs: 90,
                  onTap: () => Navigator.of(context).pop()),
            ],
          ),
        ],
      ),
    );
  }
}
