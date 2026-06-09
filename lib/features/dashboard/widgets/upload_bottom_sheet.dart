import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import '../providers/telegram_storage_provider.dart';

/// The old UploadBottomSheet is kept for backward compatibility.
/// The Home screen now uses UploadBottomSheetContent directly inside _BlurSheet.
/// This class wraps UploadBottomSheetContent in a simple container for screens
/// that still call showModalBottomSheet with UploadBottomSheet.
class UploadBottomSheet extends StatelessWidget {
  const UploadBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Blurred sheet with spring entrance
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              const UploadBottomSheetContent(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The actual content — imported and used directly by other screens too.
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
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 26),
              ),
              const SizedBox(height: 12),
              Text(label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600, fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
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
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.x, size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
              ),
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
                onTap: () async {
                  Navigator.of(context).pop();
                  HapticFeedback.mediumImpact();
                  final success = await storageNotifier.uploadLocalFile();
                  if (context.mounted) {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success
                          ? 'File uploaded successfully!'
                          : 'Failed to upload file.'),
                    ));
                  }
                },
              ),
              buildOptionButton(
                icon: LucideIcons.folder_plus,
                label: 'New Folder',
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/dashboard/files');
                },
              ),
              buildOptionButton(
                icon: LucideIcons.camera,
                label: 'Take Photo',
                onTap: () => Navigator.of(context).pop(),
              ),
              buildOptionButton(
                icon: LucideIcons.scan,
                label: 'Scan Document',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
