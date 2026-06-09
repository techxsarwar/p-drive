import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../providers/telegram_storage_provider.dart';
import '../widgets/springy_tap.dart';
import 'dashboard_shell.dart';

class FilesOrganizationScreen extends ConsumerStatefulWidget {
  const FilesOrganizationScreen({super.key});

  @override
  ConsumerState<FilesOrganizationScreen> createState() => _FilesOrganizationScreenState();
}

class _FilesOrganizationScreenState extends ConsumerState<FilesOrganizationScreen> {
  String _activeTab = 'Folders';

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  void _showNewFolderDialog() {
    final controller = TextEditingController();
    final storageNotifier = ref.read(telegramStorageProvider.notifier);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
        ),
        title: const Text(
          'New Folder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Folder name',
            fillColor: theme.inputDecorationTheme.fillColor,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Creating folder "$name"...')),
                );
                await storageNotifier.createFolder(name);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create'),
          ),
        ],
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
    final currentPath = storageState.currentPath;
    final isRoot = currentPath == '/';

    // Get dynamic content
    final folders = storageNotifier.currentPathFolders;
    final files = storageNotifier.currentPathFiles;

    Widget buildTabButton(String name) {
      final isActive = _activeTab == name;
      return Container(
        margin: const EdgeInsets.only(right: 8),
        child: Material(
          color: isActive ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () {
              setState(() {
                _activeTab = name;
              });
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isActive ? theme.colorScheme.primary : theme.dividerColor,
                  width: 1,
                ),
              ),
              child: Text(
                name,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget buildFolderGridCard(String relativeFolderName) {
      final prefix = currentPath == '/' ? '' : currentPath;
      final fullPath = '$prefix/$relativeFolderName';
      
      // Calculate file counts inside this folder recursively
      final filesInFolder = storageState.allFiles.where((f) => f['path'].toString().startsWith(fullPath)).toList();
      final totalSizeBytes = filesInFolder.fold<int>(0, (sum, f) => sum + (f['size_bytes'] as num).toInt());

      return SpringyTap(
        onTap: () => storageNotifier.changeDirectory(fullPath),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
            boxShadow: theme.brightness == Brightness.light
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.folder, color: theme.colorScheme.primary, size: 22),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      LucideIcons.ellipsis_vertical,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      size: 20,
                    ),
                    style: IconButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    relativeFolderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${filesInFolder.length} items • ${_formatBytes(totalSizeBytes, 0)}',
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

      return SpringyTap(
        onTap: () => context.push('/file-details', extra: name),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
            boxShadow: theme.brightness == Brightness.light
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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
                      'Uploaded $dateStr • $sizeStr',
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
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar Row
            Container(
              decoration: BoxDecoration(
                boxShadow: theme.brightness == Brightness.light
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.01),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search your files...',
                  prefixIcon: const Icon(LucideIcons.search, size: 20),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.sliders_horizontal, size: 18),
                  ),
                  fillColor: theme.inputDecorationTheme.fillColor,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // In-page Horizontal Tabs
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  buildTabButton('Folders'),
                  buildTabButton('Files'),
                  buildTabButton('Shared'),
                  buildTabButton('Starred'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Breadcrumb path and navigation controls
            Row(
              children: [
                if (!isRoot)
                  IconButton(
                    onPressed: () => storageNotifier.navigateUp(),
                    icon: const Icon(LucideIcons.chevron_left, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.inputDecorationTheme.fillColor,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                if (!isRoot) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isRoot ? 'ROOT DIRECTORY' : currentPath.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_activeTab == 'Folders')
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.arrow_up_down, size: 14),
                    label: const Text('Name'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Main Tab View switcher
            if (_activeTab == 'Folders')
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.15,
                ),
                itemCount: folders.length + 1,
                itemBuilder: (context, index) {
                  if (index < folders.length) {
                    return buildFolderGridCard(folders[index]);
                  } else {
                    // Dashed card for New Folder
                    return SpringyTap(
                      onTap: _showNewFolderDialog,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.inputDecorationTheme.fillColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.plus,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'New Folder',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.labelSmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ).animate().fade(duration: 350.ms).slideY(begin: 0.08, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1))
            else if (_activeTab == 'Files')
              files.isEmpty
                  ? Container(
                      height: 160,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        'No files in this folder.',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      ),
                    )
                  : Column(
                      children: files.map((f) => buildFileRowItem(f)).toList(),
                    ).animate().fade(duration: 350.ms).slideY(begin: 0.08, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1))
            else
              // Shared/Starred placeholder
              Container(
                height: 160,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.cardTheme.color ?? theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                ),
                child: Text(
                  'No items shared or starred in this workspace.',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                ),
              ).animate().fade(duration: 350.ms).slideY(begin: 0.08, end: 0, duration: 350.ms, curve: const Cubic(0.34, 1.56, 0.64, 1)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
