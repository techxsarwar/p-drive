import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/telegram_service.dart';

class TelegramStorageState {
  final String botToken;
  final String chatId;
  final String currentPath;
  final List<String> allFolders;
  final List<Map<String, dynamic>> allFiles;
  final bool isLoading;
  final bool isUploading;
  final bool isDownloading;
  final double uploadProgress;
  final double downloadProgress;
  final int? pinnedMessageId;

  TelegramStorageState({
    this.botToken = '8888156987:AAFQNwjgnTR6GQ2JKdEaYbWbxlT7r1pS8kw',
    this.chatId = '-1003875203962',
    this.currentPath = '/',
    this.allFolders = const [],
    this.allFiles = const [],
    this.isLoading = false,
    this.isUploading = false,
    this.isDownloading = false,
    this.uploadProgress = 0.0,
    this.downloadProgress = 0.0,
    this.pinnedMessageId,
  });

  TelegramStorageState copyWith({
    String? botToken,
    String? chatId,
    String? currentPath,
    List<String>? allFolders,
    List<Map<String, dynamic>>? allFiles,
    bool? isLoading,
    bool? isUploading,
    bool? isDownloading,
    double? uploadProgress,
    double? downloadProgress,
    int? pinnedMessageId,
  }) {
    return TelegramStorageState(
      botToken: botToken ?? this.botToken,
      chatId: chatId ?? this.chatId,
      currentPath: currentPath ?? this.currentPath,
      allFolders: allFolders ?? this.allFolders,
      allFiles: allFiles ?? this.allFiles,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      isDownloading: isDownloading ?? this.isDownloading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      pinnedMessageId: pinnedMessageId ?? this.pinnedMessageId,
    );
  }
}

class TelegramStorageNotifier extends StateNotifier<TelegramStorageState> {
  final TelegramService _telegramService = TelegramService();
  SharedPreferences? _prefs;

  TelegramStorageNotifier() : super(TelegramStorageState()) {
    _init();
  }

  // Load configured keys and retrieve channel catalog
  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    _prefs = await SharedPreferences.getInstance();
    
    final savedToken = _prefs?.getString('tg_bot_token') ?? '8888156987:AAFQNwjgnTR6GQ2JKdEaYbWbxlT7r1pS8kw';
    final savedChatId = _prefs?.getString('tg_chat_id') ?? '-1003875203962';
    
    state = state.copyWith(
      botToken: savedToken,
      chatId: savedChatId,
    );

    if (savedToken.isNotEmpty && savedChatId.isNotEmpty) {
      await loadCatalog();
    } else {
      // Set up mock fallback catalog for immediate preview
      _loadMockData();
    }
  }

  void _loadMockData() {
    state = state.copyWith(
      allFolders: [
        '/Design Assets',
        '/Team Projects',
        '/Invoices 2024',
        '/Personal',
        '/Campaigns/Q4',
      ],
      allFiles: [
        {
          'name': 'Q3_Financial_Report.pdf',
          'path': '/',
          'size_bytes': 2516582, // 2.4 MB
          'uploaded_at': '2026-06-08T19:00:00Z',
          'file_id': 'mock_pdf_id_1',
        },
        {
          'name': 'Brand_Guidelines_V2.png',
          'path': '/',
          'size_bytes': 5347737, // 5.1 MB
          'uploaded_at': '2026-06-07T14:30:00Z',
          'file_id': 'mock_png_id_2',
        },
        {
          'name': 'Project_Kickoff_Notes.docx',
          'path': '/',
          'size_bytes': 148480, // 145 KB
          'uploaded_at': '2026-06-08T10:00:00Z',
          'file_id': 'mock_docx_id_3',
        },
        {
          'name': 'Q4_Marketing_Assets.zip',
          'path': '/Campaigns/Q4',
          'size_bytes': 149422080, // 142.5 MB
          'uploaded_at': '2026-06-08T18:15:00Z',
          'file_id': 'mock_zip_id_4',
        }
      ],
      isLoading: false,
    );
  }

  // Update credentials
  Future<void> updateCredentials(String token, String chatId) async {
    state = state.copyWith(isLoading: true);
    await _prefs?.setString('tg_bot_token', token);
    await _prefs?.setString('tg_chat_id', chatId);
    
    state = state.copyWith(
      botToken: token,
      chatId: chatId,
    );

    if (token.isNotEmpty && chatId.isNotEmpty) {
      await loadCatalog();
    } else {
      _loadMockData();
    }
  }

  // Reload catalog from channel Pinned message
  Future<void> loadCatalog() async {
    if (state.botToken.isEmpty || state.chatId.isEmpty) return;

    state = state.copyWith(isLoading: true);
    try {
      final chatDetails = await _telegramService.getChatDetails(
        botToken: state.botToken,
        chatId: state.chatId,
      );

      if (chatDetails != null && chatDetails['pinned_message'] != null) {
        final pinnedMessage = chatDetails['pinned_message'];
        final int messageId = pinnedMessage['message_id'];
        
        if (pinnedMessage['document'] != null) {
          final fileId = pinnedMessage['document']['file_id'];
          final filePath = await _telegramService.getFilePath(
            botToken: state.botToken,
            fileId: fileId,
          );

          if (filePath != null) {
            final jsonString = await _telegramService.downloadTextFile(
              botToken: state.botToken,
              filePath: filePath,
            );

            if (jsonString != null) {
              final Map<String, dynamic> catalog = jsonDecode(jsonString);
              final List<dynamic> folders = catalog['folders'] ?? [];
              final List<dynamic> files = catalog['files'] ?? [];

              state = state.copyWith(
                allFolders: folders.cast<String>(),
                allFiles: files.map((f) => Map<String, dynamic>.from(f)).toList(),
                pinnedMessageId: messageId,
                isLoading: false,
              );
              return;
            }
          }
        }
      }
      
      // No pinned catalog found, initialize one
      state = state.copyWith(
        allFolders: ['/Design Assets', '/Team Projects', '/Invoices 2024', '/Personal'],
        allFiles: [],
        pinnedMessageId: null,
      );
      await _syncCatalogToTelegram();
    } catch (e) {
      print('Load catalog error: $e');
      _loadMockData(); // fallback
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Upload/Pin the current local catalog as catalog.json
  Future<void> _syncCatalogToTelegram() async {
    if (state.botToken.isEmpty || state.chatId.isEmpty) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/catalog.json');

      final catalogMap = {
        'folders': state.allFolders,
        'files': state.allFiles,
      };

      await file.writeAsString(jsonEncode(catalogMap));

      // Upload file
      final uploadResult = await _telegramService.uploadFile(
        botToken: state.botToken,
        chatId: state.chatId,
        filePath: file.path,
        fileName: 'catalog.json',
      );

      if (uploadResult != null) {
        final int messageId = uploadResult['message_id'];
        
        // Pin new catalog
        final pinSuccess = await _telegramService.pinMessage(
          botToken: state.botToken,
          chatId: state.chatId,
          messageId: messageId,
        );

        if (pinSuccess) {
          // Unpin old catalog to avoid cluttering channel pins
          if (state.pinnedMessageId != null) {
            await _telegramService.unpinMessage(
              botToken: state.botToken,
              chatId: state.chatId,
              messageId: state.pinnedMessageId!,
            );
          }
          state = state.copyWith(pinnedMessageId: messageId);
        }
      }
    } catch (e) {
      print('Sync catalog error: $e');
    }
  }

  // Folder navigation logic
  void changeDirectory(String targetPath) {
    state = state.copyWith(currentPath: targetPath);
  }

  void navigateUp() {
    if (state.currentPath == '/') return;
    final parts = state.currentPath.split('/');
    parts.removeLast();
    var parent = parts.join('/');
    if (parent.isEmpty) parent = '/';
    state = state.copyWith(currentPath: parent);
  }

  // Create new directory in catalog
  Future<void> createFolder(String folderName) async {
    final prefix = state.currentPath == '/' ? '' : state.currentPath;
    final folderPath = '$prefix/$folderName';

    if (state.allFolders.contains(folderPath)) return;

    final updatedFolders = List<String>.from(state.allFolders)..add(folderPath);
    state = state.copyWith(allFolders: updatedFolders);

    if (state.botToken.isNotEmpty && state.chatId.isNotEmpty) {
      await _syncCatalogToTelegram();
    }
  }

  // Pick file from device and upload it to Telegram
  Future<bool> uploadLocalFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) return false;

      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;
      final fileSize = result.files.single.size;

      state = state.copyWith(
        isUploading: true,
        uploadProgress: 0.0,
      );

      // If mock mode, simulate progress and add local entry
      if (state.botToken.isEmpty || state.chatId.isEmpty) {
        for (int i = 0; i <= 10; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          state = state.copyWith(uploadProgress: i / 10.0);
        }

        final mockFile = {
          'name': fileName,
          'path': state.currentPath,
          'size_bytes': fileSize,
          'uploaded_at': DateTime.now().toIso8601String(),
          'file_id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
        };

        state = state.copyWith(
          allFiles: List<Map<String, dynamic>>.from(state.allFiles)..add(mockFile),
          isUploading: false,
          uploadProgress: 0.0,
        );
        return true;
      }

      // Real upload to Telegram
      final uploadResult = await _telegramService.uploadFile(
        botToken: state.botToken,
        chatId: state.chatId,
        filePath: filePath,
        fileName: fileName,
        onProgress: (sentBytes, totalBytes) {
          if (totalBytes > 0) {
            state = state.copyWith(uploadProgress: sentBytes / totalBytes);
          }
        },
      );

      if (uploadResult != null) {
        final doc = uploadResult['document'];
        final fileId = doc['file_id'];
        final msgId = uploadResult['message_id'];

        final newFile = {
          'name': fileName,
          'path': state.currentPath,
          'size_bytes': fileSize,
          'uploaded_at': DateTime.now().toIso8601String(),
          'file_id': fileId,
          'message_id': msgId,
        };

        state = state.copyWith(
          allFiles: List<Map<String, dynamic>>.from(state.allFiles)..add(newFile),
        );

        await _syncCatalogToTelegram();
        state = state.copyWith(isUploading: false, uploadProgress: 0.0);
        return true;
      }
    } catch (e) {
      print('File upload error: $e');
    }
    state = state.copyWith(isUploading: false, uploadProgress: 0.0);
    return false;
  }

  // Download file from Telegram channel to local Downloads folder
  Future<String?> downloadFile(String filename, String fileId) async {
    state = state.copyWith(isDownloading: true, downloadProgress: 0.0);

    try {
      Directory? appDir;
      if (Platform.isAndroid) {
        appDir = Directory('/storage/emulated/0/Download');
        if (!await appDir.exists()) {
          appDir = await getExternalStorageDirectory();
        }
      } else {
        appDir = await getApplicationDocumentsDirectory();
      }

      final savePath = '${appDir!.path}/$filename';

      // Mock mode simulator
      if (state.botToken.isEmpty || state.chatId.isEmpty) {
        for (int i = 0; i <= 10; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          state = state.copyWith(downloadProgress: i / 10.0);
        }
        state = state.copyWith(isDownloading: false, downloadProgress: 0.0);
        return savePath;
      }

      // Real download
      final filePath = await _telegramService.getFilePath(
        botToken: state.botToken,
        fileId: fileId,
      );

      if (filePath != null) {
        final success = await _telegramService.downloadFile(
          botToken: state.botToken,
          filePath: filePath,
          savePath: savePath,
          onProgress: (received, total) {
            if (total > 0) {
              state = state.copyWith(downloadProgress: received / total);
            }
          },
        );

        if (success) {
          state = state.copyWith(isDownloading: false, downloadProgress: 0.0);
          return savePath;
        }
      }
    } catch (e) {
      print('Download file error: $e');
    }
    state = state.copyWith(isDownloading: false, downloadProgress: 0.0);
    return null;
  }

  // Delete file document entry in local catalog and update on Telegram
  Future<void> deleteFile(String filename, String fileId) async {
    final updatedFiles = List<Map<String, dynamic>>.from(state.allFiles)
      ..removeWhere((f) => f['name'] == filename && f['file_id'] == fileId);
    
    state = state.copyWith(allFiles: updatedFiles);

    if (state.botToken.isNotEmpty && state.chatId.isNotEmpty) {
      await _syncCatalogToTelegram();
    }
  }

  // Get dynamic files in current path level
  List<Map<String, dynamic>> get currentPathFiles {
    return state.allFiles.where((f) => f['path'] == state.currentPath).toList();
  }

  // Get dynamic folder names in current path level
  List<String> get currentPathFolders {
    final current = state.currentPath == '/' ? '' : state.currentPath;
    final Set<String> directChildren = {};

    for (final folder in state.allFolders) {
      if (folder.startsWith('$current/')) {
        final relative = folder.substring(current.length + 1);
        final slashIndex = relative.indexOf('/');
        if (slashIndex == -1) {
          directChildren.add(relative);
        } else {
          directChildren.add(relative.substring(0, slashIndex));
        }
      }
    }
    return directChildren.toList();
  }

  // Storage usage calculation
  int get totalUsedSizeBytes {
    int total = 0;
    for (final file in state.allFiles) {
      total += (file['size_bytes'] as num).toInt();
    }
    return total;
  }
}

final telegramStorageProvider = StateNotifierProvider<TelegramStorageNotifier, TelegramStorageState>((ref) {
  return TelegramStorageNotifier();
});
