import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../providers/telegram_storage_provider.dart';

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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
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
            fillColor: const Color(0xFFF1F1EF),
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
              foregroundColor: Colors.white,
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
      return GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = name;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive ? theme.colorScheme.primary : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Text(
            name,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : theme.colorScheme.onSurface,
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

      return GestureDetector(
        onTap: () => storageNotifier.changeDirectory(fullPath),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
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
      Color iconBgColor = const Color(0xFFF1F1EF);
      Color iconColor = const Color(0xFF6B7280);

      if (name.toLowerCase().endsWith('.pdf')) {
        fileIcon = LucideIcons.file_text;
        iconBgColor = const Color(0xFFFFDAD6);
        iconColor = const Color(0xFFBA1A1A);
      } else if (name.toLowerCase().endsWith('.png') || name.toLowerCase().endsWith('.jpg') || name.toLowerCase().endsWith('.jpeg')) {
        fileIcon = LucideIcons.image;
        iconBgColor = const Color(0xFFE9EDFF);
        iconColor = theme.colorScheme.primary;
      } else if (name.toLowerCase().endsWith('.docx') || name.toLowerCase().endsWith('.doc')) {
        fileIcon = LucideIcons.file_spreadsheet;
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar Row
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search your files...',
                  prefixIcon: const Icon(LucideIcons.search, size: 20),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.sliders_horizontal, size: 18),
                  ),
                  fillColor: const Color(0xFFF1F1EF),
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
                      backgroundColor: const Color(0xFFF1F1EF),
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
                    return GestureDetector(
                      onTap: _showNewFolderDialog,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFC5C5D8),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F1EF),
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
              ).animate().fade(duration: 350.ms)
            else if (_activeTab == 'Files')
              files.isEmpty
                  ? Container(
                      height: 160,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                      ),
                      child: Text(
                        'No files in this folder.',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      ),
                    )
                  : Column(
                      children: files.map((f) => buildFileRowItem(f)).toList(),
                    ).animate().fade(duration: 350.ms)
            else
              // Shared/Starred placeholder
              Container(
                height: 160,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
                ),
                child: Text(
                  'No items shared or starred in this workspace.',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
