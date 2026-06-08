import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../providers/telegram_storage_provider.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Observers
    final storageState = ref.watch(telegramStorageProvider);
    final storageNotifier = ref.read(telegramStorageProvider.notifier);

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
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 96,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? theme.colorScheme.primary.withOpacity(0.12)
                      : const Color(0xFFF1F1EF),
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
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF6B7280)),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
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
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: Text(
          'Details',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: const Color(0xFF6B7280),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.moreVertical),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Large File Preview
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width - 48,
                maxHeight: 240,
                aspectRatio: 4 / 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1EF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    name.endsWith('.pdf')
                        ? LucideIcons.fileText
                        : name.endsWith('.png') || name.endsWith('.jpg') || name.endsWith('.jpeg')
                            ? LucideIcons.image
                            : LucideIcons.archive,
                    size: 80,
                    color: const Color(0xFFC5C5D8),
                  ),
                ),
              ),
            ).animate().fade(duration: 400.ms).scale(curve: Curves.easeOutBack),
            const SizedBox(height: 24),

            // File title & details info
            Text(
              name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fade(delay: 100.ms),
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
                      ? 'PDF Document • $sizeStr'
                      : name.endsWith('.png') || name.endsWith('.jpg') || name.endsWith('.jpeg')
                          ? 'Image File • $sizeStr'
                          : name.endsWith('.docx') || name.endsWith('.doc')
                              ? 'Word Document • $sizeStr'
                              : 'Archive • $sizeStr',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ).animate().fade(delay: 150.ms),
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
                    icon: LucideIcons.share2,
                    label: 'Share',
                    isPrimary: true,
                    onTap: () {},
                  ),
                  buildBentoAction(
                    icon: LucideIcons.download,
                    label: 'Save',
                    onTap: () async {
                      if (fileId.isEmpty || fileId == 'fallback_id') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mock File: Downloading simulator complete.')),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Starting download from Telegram...')),
                      );
                      
                      final path = await storageNotifier.downloadFile(name, fileId);
                      
                      if (context.mounted) {
                        if (path != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('File saved to: $path')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to download file from Telegram.')),
                          );
                        }
                      }
                    },
                  ),
                  buildBentoAction(
                    icon: LucideIcons.edit3,
                    label: 'Rename',
                    onTap: () {},
                  ),
                  buildBentoAction(
                    icon: LucideIcons.folderInput,
                    label: 'Move',
                    onTap: () {},
                  ),
                ],
              ),
            ).animate().fade(delay: 200.ms),

            // Delete File action row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
              child: OutlinedButton.icon(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleting "$name" from cloud...')),
                  );
                  await storageNotifier.deleteFile(name, fileId);
                  if (context.mounted) {
                    context.pop();
                  }
                },
                icon: const Icon(LucideIcons.trash2, color: Color(0xFFBA1A1A), size: 18),
                label: const Text('Delete File'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFBA1A1A),
                  side: const BorderSide(color: Color(0xFFFFDAD6), width: 1),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).animate().fade(delay: 250.ms),
            const SizedBox(height: 16),

            // Metadata Card Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 8.0),
                      child: Text(
                        'INFORMATION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0xFF6B7280),
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
                    const Divider(height: 1, color: Color(0xFFF1F1EF)),
                    buildDetailRow(
                      icon: LucideIcons.clock,
                      label: 'Modified',
                      value: Text(
                        'Sync Active',
                        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F1EF)),
                    buildDetailRow(
                      icon: LucideIcons.folderOpen,
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
                    const Divider(height: 1, color: Color(0xFFF1F1EF)),
                    buildDetailRow(
                      icon: LucideIcons.user,
                      label: 'Owner',
                      value: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF1F3FF),
                            ),
                            child: const Center(
                              child: Text(
                                'SJ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5B6CFF),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sarah Jenkins',
                            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fade(delay: 300.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
