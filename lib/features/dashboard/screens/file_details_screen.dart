import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/top_toast.dart';
import '../../../core/providers/supabase_auth_provider.dart';
import '../providers/telegram_storage_provider.dart';
import '../widgets/springy_tap.dart';
import '../widgets/video_preview_widget.dart';

class FileDetailsScreen extends ConsumerWidget {
  final String filename;
  
  const FileDetailsScreen({
    super.key,
    required this.filename,
  });

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  void _showShareDialog(BuildContext context, String filename) {
    final theme = Theme.of(context);
    final String mockShareLink = "https://pdrive.cloud/s/${Uri.encodeComponent(filename)}";

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
                  'Share File',
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
              'Generate a secure share link for "$filename".',
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
                      Clipboard.setData(ClipboardData(text: mockShareLink));
                      TopToast.show(context, 'Link copied to clipboard!');
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
        // Since we are simulating, we just trigger the native share dialog with the generated link.
        final String mockShareLink = "https://pdrive.cloud/s/${Uri.encodeComponent('file')}";
        Share.share('Check out my file on P-Drive: $mockShareLink', subject: 'P-Drive File Share');
        TopToast.show(context, 'Opening native share sheet...');
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

  void _showRenameDialog(BuildContext context, WidgetRef ref, String oldName, String fileId) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: oldName);

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
                    'Rename File',
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
                'Enter a new name for the file.',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'File Name',
                  fillColor: theme.inputDecorationTheme.fillColor,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    final newName = controller.text.trim();
                    if (newName.isEmpty || newName == oldName) {
                      Navigator.of(context).pop();
                      return;
                    }
                    
                    Navigator.of(context).pop(); // pop bottom sheet
                    TopToast.show(context, 'Renaming file to "$newName"...');
                    
                    await ref.read(telegramStorageProvider.notifier).renameFile(oldName, newName, fileId);
                    
                    if (context.mounted) {
                      Navigator.of(context).pop(); // pop details page to refresh list view
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Rename', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ).animate().slideY(begin: 0.2, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)).fade(duration: 250.ms),
    );
  }

  void _showMoveDialog(BuildContext context, WidgetRef ref, String filename, String fileId, String currentFolderPath) {
    final theme = Theme.of(context);
    final storageState = ref.read(telegramStorageProvider);
    final allFolders = <String>{'/', ...storageState.allFolders}.toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          String selectedFolder = currentFolderPath;
          
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
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
                      'Move File',
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
                  'Select target folder to move "$filename":',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: allFolders.length,
                    itemBuilder: (context, index) {
                      final folder = allFolders[index];
                      final isSelected = folder == selectedFolder;
                      return ListTile(
                        leading: Icon(
                          LucideIcons.folder,
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        title: Text(
                          folder == '/' ? 'Root Directory (/)' : folder,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: isSelected ? Icon(LucideIcons.check, color: theme.colorScheme.primary) : null,
                        onTap: () {
                          setState(() {
                            selectedFolder = folder;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedFolder == currentFolderPath) {
                        Navigator.of(context).pop();
                        return;
                      }
                      
                      Navigator.of(context).pop(); // pop bottom sheet
                      TopToast.show(context, 'Moving file to "$selectedFolder"...');
                      
                      await ref.read(telegramStorageProvider.notifier).moveFile(filename, fileId, selectedFolder);
                      
                      if (context.mounted) {
                        Navigator.of(context).pop(); // pop details page to refresh list view
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Move File Here', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) {});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Observers
    final storageState = ref.watch(telegramStorageProvider);
    final storageNotifier = ref.read(telegramStorageProvider.notifier);
    final authState = ref.watch(authProvider);
    final ownerName = authState.displayName ?? 'Unknown User';
    final ownerInitials = ownerName.isNotEmpty ? ownerName.substring(0, 1).toUpperCase() : '?';

    // Find current file matching details
    final file = storageState.allFiles.firstWhere(
      (f) => f['name'] == filename,
      orElse: () => {
        'name': filename,
        'path': '/',
        'size_bytes': 149422080, // Default fallback zip size
        'uploaded_at': '2023-10-24T18:15:00Z',
        'file_id': 'fallback_id',
      },
    );

    final String name = file['name'] ?? 'Untitled';
    final int size = (file['size_bytes'] as num?)?.toInt() ?? 0;
    final String sizeStr = _formatBytes(size, 1);
    final String pathStr = file['path'] ?? '/';
    final String dateStr = file['uploaded_at'].toString().split('T').first;
    final String fileId = file['file_id'] ?? '';

    Widget buildBentoAction({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      bool isPrimary = false,
    }) {
      return SpringyTap(
        onTap: onTap,
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
            boxShadow: theme.brightness == Brightness.light
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? theme.colorScheme.primary.withOpacity(0.12)
                      : theme.inputDecorationTheme.fillColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildDetailRow({
      required IconData icon,
      required String label,
      required Widget value,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.textTheme.labelSmall?.color),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.labelSmall?.color,
                  ),
                ),
              ],
            ),
            value,
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrow_left),
        ),
        title: Text(
          'Details',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: theme.textTheme.labelSmall?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Large File Preview
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 48,
                    decoration: BoxDecoration(
                      color: theme.inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                      boxShadow: theme.brightness == Brightness.light
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: name.toLowerCase().endsWith('.mp4') || name.toLowerCase().endsWith('.mov') || name.toLowerCase().endsWith('.mkv')
                          ? const VideoPreviewWidget(videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4')
                          : Icon(
                              name.endsWith('.pdf')
                                  ? LucideIcons.file_text
                                  : name.endsWith('.png') || name.endsWith('.jpg') || name.endsWith('.jpeg')
                                      ? LucideIcons.image
                                      : LucideIcons.archive,
                              size: 80,
                              color: theme.brightness == Brightness.dark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFC5C5D8),
                            ),
                    ),
                  ),
                ),
              ),
            ).animate().fade(duration: 350.ms).scale(duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1), begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 24),

            // File title & details info
            Text(
              name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fade(delay: 100.ms, duration: 350.ms).slideY(begin: 0.1, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  name.endsWith('.pdf')
                      ? 'PDF Document â€¢ $sizeStr'
                      : name.endsWith('.png') || name.endsWith('.jpg') || name.endsWith('.jpeg')
                          ? 'Image File â€¢ $sizeStr'
                          : name.endsWith('.docx') || name.endsWith('.doc')
                              ? 'Word Document â€¢ $sizeStr'
                              : 'Archive â€¢ $sizeStr',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.labelSmall?.color,
                  ),
                ),
              ],
            ).animate().fade(delay: 150.ms, duration: 350.ms).slideY(begin: 0.1, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)),
            const SizedBox(height: 32),

            // Bento Actions Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  buildBentoAction(
                    icon: LucideIcons.share_2,
                    label: 'Share',
                    isPrimary: true,
                    onTap: () => _showShareDialog(context, name),
                  ),
                  buildBentoAction(
                    icon: LucideIcons.download,
                    label: 'Save',
                    onTap: () async {
                      if (fileId.isEmpty || fileId == 'fallback_id') {
                        TopToast.show(context, 'Mock File: Downloading simulator complete.');
                        return;
                      }

                      TopToast.show(context, 'Starting download from secure cloud...');
                      
                      final path = await storageNotifier.downloadFile(name, fileId);
                      
                      if (context.mounted) {
                        if (path != null) {
                          TopToast.show(context, 'File saved to: $path');
                        } else {
                          TopToast.show(context, 'Failed to download file from secure cloud.', isError: true);
                        }
                      }
                    },
                  ),
                  buildBentoAction(
                    icon: LucideIcons.pencil,
                    label: 'Rename',
                    onTap: () => _showRenameDialog(context, ref, name, fileId),
                  ),
                  buildBentoAction(
                    icon: LucideIcons.folder_input,
                    label: 'Move',
                    onTap: () => _showMoveDialog(context, ref, name, fileId, pathStr),
                  ),
                ],
              ),
            ).animate().fade(delay: 200.ms, duration: 350.ms).slideY(begin: 0.1, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)),

            // Delete File action row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
              child: SpringyTap(
                onTap: () async {
                  TopToast.show(context, 'Deleting "$name" from cloud...');
                  await storageNotifier.deleteFile(name, fileId);
                  if (context.mounted) {
                    context.pop();
                  }
                },
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(LucideIcons.trash_2, color: theme.colorScheme.error, size: 18),
                  label: const Text('Delete File'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error.withOpacity(0.3), width: 1),
                    minimumSize: const Size(double.infinity, 54),
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
            const SizedBox(height: 16),

            // Metadata Card Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                  boxShadow: theme.brightness == Brightness.light
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 8.0),
                      child: Text(
                        'INFORMATION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: theme.textTheme.labelSmall?.color,
                        ),
                      ),
                    ),
                    buildDetailRow(
                      icon: LucideIcons.calendar,
                      label: 'Added',
                      value: Text(
                        dateStr,
                        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                    buildDetailRow(
                      icon: LucideIcons.clock,
                      label: 'Modified',
                      value: Text(
                        'Sync Active',
                        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                    buildDetailRow(
                      icon: LucideIcons.folder_open,
                      label: 'Location',
                      value: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          pathStr,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                    buildDetailRow(
                      icon: LucideIcons.user,
                      label: 'Owner',
                      value: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary.withOpacity(0.12),
                            ),
                            child: Center(
                              child: Text(
                                ownerInitials,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ownerName,
                            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fade(delay: 300.ms, duration: 350.ms).slideY(begin: 0.1, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
