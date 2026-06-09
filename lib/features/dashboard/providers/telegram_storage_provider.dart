import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/services/telegram_service.dart';
import '../../../core/services/transfer_foreground_service.dart';
import '../../../core/providers/supabase_auth_provider.dart';

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
  final bool isChunkingEnabled;
  final String? transferStatus;

  TelegramStorageState({
    this.botToken = '',
    this.chatId = '',
    this.currentPath = '/',
    this.allFolders = const [],
    this.allFiles = const [],
    this.isLoading = false,
    this.isUploading = false,
    this.isDownloading = false,
    this.uploadProgress = 0.0,
    this.downloadProgress = 0.0,
    this.pinnedMessageId,
    this.isChunkingEnabled = true,
    this.transferStatus,
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
    bool? isChunkingEnabled,
    String? transferStatus,
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
      isChunkingEnabled: isChunkingEnabled ?? this.isChunkingEnabled,
      transferStatus: transferStatus == null ? (transferStatus ?? this.transferStatus) : (transferStatus == '' ? null : transferStatus),
    );
  }
}

class TelegramStorageNotifier extends StateNotifier<TelegramStorageState> {
  final TelegramService _telegramService = TelegramService();
  final Ref _ref;
  SharedPreferences? _prefs;

  TelegramStorageNotifier(this._ref) : super(TelegramStorageState()) {
    _init();
  }

  // Load configured keys and retrieve channel catalog
  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    _prefs = await SharedPreferences.getInstance();
    
    final savedToken = _prefs?.getString('tg_bot_token') ?? dotenv.env['TELEGRAM_BOT_TOKEN'] ?? '';
    final savedChatId = _prefs?.getString('tg_chat_id') ?? dotenv.env['TELEGRAM_CHAT_ID'] ?? '';
    final savedChunking = _prefs?.getBool('tg_is_chunking_enabled') ?? false;
    
    state = state.copyWith(
      botToken: savedToken,
      chatId: savedChatId,
      isChunkingEnabled: savedChunking,
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
          'owner_email': _currentUserEmail,
        },
        {
          'name': 'Brand_Guidelines_V2.png',
          'path': '/',
          'size_bytes': 5347737, // 5.1 MB
          'uploaded_at': '2026-06-07T14:30:00Z',
          'file_id': 'mock_png_id_2',
          'owner_email': _currentUserEmail,
        },
        {
          'name': 'Project_Kickoff_Notes.docx',
          'path': '/',
          'size_bytes': 148480, // 145 KB
          'uploaded_at': '2026-06-08T10:00:00Z',
          'file_id': 'mock_docx_id_3',
          'owner_email': _currentUserEmail,
        },
        {
          'name': 'Q4_Marketing_Assets.zip',
          'path': '/Campaigns/Q4',
          'size_bytes': 149422080, // 142.5 MB
          'uploaded_at': '2026-06-08T18:15:00Z',
          'file_id': 'mock_zip_id_4',
          'owner_email': _currentUserEmail,
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
    }
  }

  // Toggle file chunking pipeline
  Future<void> toggleChunking(bool enabled) async {
    state = state.copyWith(isChunkingEnabled: enabled);
    await _prefs?.setBool('tg_is_chunking_enabled', enabled);
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
              final List<dynamic> allCatalogFiles = catalog['files'] ?? [];

              // Filter files strictly by the current logged-in user
              final List<Map<String, dynamic>> userFiles = allCatalogFiles
                  .map((f) => Map<String, dynamic>.from(f))
                  .where((f) => f['owner_email'] == _currentUserEmail)
                  .toList();

              // Get folders that actually contain user files (or root folders)
              // We'll trust the catalog folders but in a real app, you'd filter folders by ownership too.
              state = state.copyWith(
                allFolders: folders.cast<String>(),
                allFiles: userFiles,
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

      // Fetch current pinned catalog directly to avoid overwriting other users' files
      List<dynamic> completeCatalogFiles = [];
      List<dynamic> completeCatalogFolders = [];
      try {
        final chatDetails = await _telegramService.getChatDetails(
          botToken: state.botToken,
          chatId: state.chatId,
        );
        if (chatDetails != null && chatDetails['pinned_message'] != null) {
          final fileId = chatDetails['pinned_message']['document']['file_id'];
          final filePath = await _telegramService.getFilePath(botToken: state.botToken, fileId: fileId);
          if (filePath != null) {
            final jsonString = await _telegramService.downloadTextFile(botToken: state.botToken, filePath: filePath);
            if (jsonString != null) {
              final Map<String, dynamic> catalog = jsonDecode(jsonString);
              completeCatalogFiles = catalog['files'] ?? [];
              completeCatalogFolders = catalog['folders'] ?? [];
            }
          }
        }
      } catch (_) {}

      // Replace the current user's files in the complete catalog
      completeCatalogFiles.removeWhere((f) => f['owner_email'] == _currentUserEmail);
      completeCatalogFiles.addAll(state.allFiles);

      // Merge folders (simplified, just union them)
      final Set<String> mergedFolders = Set<String>.from(completeCatalogFolders.cast<String>())..addAll(state.allFolders);

      final catalogMap = {
        'folders': mergedFolders.toList(),
        'files': completeCatalogFiles,
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
        transferStatus: 'Preparing file upload...',
      );

      // Start foreground service so upload survives app-switching
      await TransferForegroundService.startUpload(fileName);

      final isMockMode = state.botToken.isEmpty || state.chatId.isEmpty;
      final int maxChunkSize = 5 * 1024 * 1024; // 5 MB chunks
      final bool shouldChunk = state.isChunkingEnabled && fileSize > maxChunkSize;

      if (shouldChunk) {
        final sourceFile = File(filePath);
        final fileBytes = await sourceFile.readAsBytes();
        final totalChunks = (fileBytes.length / maxChunkSize).ceil();
        final List<Map<String, dynamic>> chunksMeta = [];

        for (int chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
          final start = chunkIndex * maxChunkSize;
          final end = (start + maxChunkSize > fileBytes.length) ? fileBytes.length : start + maxChunkSize;
          final chunkBytes = fileBytes.sublist(start, end);
          final chunkFileName = '$fileName.part_${chunkIndex + 1}_of_$totalChunks';

          state = state.copyWith(
            uploadProgress: chunkIndex / totalChunks,
            transferStatus: 'Uploading file...',
          );

          if (isMockMode) {
            for (int i = 0; i <= 5; i++) {
              await Future.delayed(const Duration(milliseconds: 120));
              final chunkProgress = (chunkIndex + (i / 5.0)) / totalChunks;
              state = state.copyWith(
                uploadProgress: chunkProgress,
                transferStatus: 'Uploading file...',
              );
            }
            chunksMeta.add({
              'chunk_index': chunkIndex,
              'file_id': 'mock_chunk_${chunkIndex}_${DateTime.now().millisecondsSinceEpoch}',
              'size_bytes': chunkBytes.length,
            });
          } else {
            final tempDir = await getTemporaryDirectory();
            final tempFile = File('${tempDir.path}/$chunkFileName');
            await tempFile.writeAsBytes(chunkBytes);

            final uploadResult = await _telegramService.uploadFile(
              botToken: state.botToken,
              chatId: state.chatId,
              filePath: tempFile.path,
              fileName: chunkFileName,
              onProgress: (sent, total) {
                if (total > 0) {
                  final chunkProgress = (chunkIndex + (sent / total)) / totalChunks;
                  state = state.copyWith(
                    uploadProgress: chunkProgress,
                    transferStatus: 'Uploading file...',
                  );
                }
              },
            );

            if (await tempFile.exists()) {
              await tempFile.delete();
            }

            if (uploadResult != null) {
              final doc = uploadResult['document'];
              final fileId = doc['file_id'];
              final msgId = uploadResult['message_id'];
              chunksMeta.add({
                'chunk_index': chunkIndex,
                'file_id': fileId,
                'message_id': msgId,
                'size_bytes': chunkBytes.length,
              });
            } else {
              throw Exception('Failed to upload chunk ${chunkIndex + 1}');
            }
          }
        }

        // Complete chunked file entry
        final fileIdRoot = isMockMode ? 'mock_chunked_${DateTime.now().millisecondsSinceEpoch}' : chunksMeta.first['file_id'];
        final newFile = {
          'name': fileName,
          'path': state.currentPath,
          'size_bytes': fileSize,
          'uploaded_at': DateTime.now().toIso8601String(),
          'file_id': fileIdRoot,
          'is_chunked': true,
          'chunks': chunksMeta,
          'owner_email': _currentUserEmail,
        };

        state = state.copyWith(
          allFiles: List<Map<String, dynamic>>.from(state.allFiles)..add(newFile),
        );

        if (!isMockMode) {
          await _syncCatalogToTelegram();
        }

        state = state.copyWith(isUploading: false, uploadProgress: 0.0, transferStatus: '');
        await TransferForegroundService.stop();
        return true;
      } else {
        // Standard upload
        if (isMockMode) {
          for (int i = 0; i <= 10; i++) {
            await Future.delayed(const Duration(milliseconds: 100));
            state = state.copyWith(
              uploadProgress: i / 10.0,
              transferStatus: 'Uploading file (${(i * 10).toStringAsFixed(0)}%)...',
            );
          }

          final mockFile = {
            'name': fileName,
            'path': state.currentPath,
            'size_bytes': fileSize,
            'uploaded_at': DateTime.now().toIso8601String(),
            'file_id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
            'owner_email': _currentUserEmail,
          };

          state = state.copyWith(
            allFiles: List<Map<String, dynamic>>.from(state.allFiles)..add(mockFile),
            isUploading: false,
            uploadProgress: 0.0,
            transferStatus: '',
          );
          await TransferForegroundService.stop();
          return true;
        }

        final uploadResult = await _telegramService.uploadFile(
          botToken: state.botToken,
          chatId: state.chatId,
          filePath: filePath,
          fileName: fileName,
          onProgress: (sentBytes, totalBytes) {
            if (totalBytes > 0) {
              state = state.copyWith(
                uploadProgress: sentBytes / totalBytes,
                transferStatus: 'Uploading file (${(sentBytes / totalBytes * 100).toStringAsFixed(0)}%)...',
              );
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
            'owner_email': _currentUserEmail,
          };

          state = state.copyWith(
            allFiles: List<Map<String, dynamic>>.from(state.allFiles)..add(newFile),
          );

          await _syncCatalogToTelegram();
          state = state.copyWith(isUploading: false, uploadProgress: 0.0, transferStatus: '');
          await TransferForegroundService.stop();
          return true;
        }
      }
    } catch (e) {
      print('File upload error: $e');
    }
    state = state.copyWith(isUploading: false, uploadProgress: 0.0, transferStatus: '');
    await TransferForegroundService.stop();
    return false;
  }

  // Download file from Telegram channel to local Downloads folder
  Future<String?> downloadFile(String filename, String fileId) async {
    state = state.copyWith(
      isDownloading: true,
      downloadProgress: 0.0,
      transferStatus: 'Preparing download...',
    );

    // Start foreground service so download survives app-switching
    await TransferForegroundService.startDownload(filename);

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
      final isMockMode = state.botToken.isEmpty || state.chatId.isEmpty;

      // Find file record in catalog to check if it's chunked
      final fileRecord = state.allFiles.firstWhere(
        (f) => f['file_id'] == fileId || f['name'] == filename,
        orElse: () => <String, dynamic>{},
      );

      final bool isChunked = fileRecord['is_chunked'] == true;

      if (isChunked && fileRecord['chunks'] != null) {
        final List<dynamic> chunksMeta = fileRecord['chunks'];
        final totalChunks = chunksMeta.length;
        final targetFile = File(savePath);

        // Delete if target exists so we start fresh
        if (await targetFile.exists()) {
          await targetFile.delete();
        }

        for (int chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
          final chunk = chunksMeta[chunkIndex];
          final chunkFileId = chunk['file_id'];
          final chunkIndexNum = chunk['chunk_index'] ?? chunkIndex;

          state = state.copyWith(
            downloadProgress: chunkIndex / totalChunks,
            transferStatus: 'Downloading file...',
          );

          if (isMockMode) {
            for (int i = 0; i <= 5; i++) {
              await Future.delayed(const Duration(milliseconds: 120));
              final chunkProgress = (chunkIndex + (i / 5.0)) / totalChunks;
              state = state.copyWith(
                downloadProgress: chunkProgress,
                transferStatus: 'Downloading file...',
              );
            }
          } else {
            final tempDir = await getTemporaryDirectory();
            final tempSavePath = '${tempDir.path}/${filename}_chunk_$chunkIndexNum';

            final filePath = await _telegramService.getFilePath(
              botToken: state.botToken,
              fileId: chunkFileId,
            );

            if (filePath == null) throw Exception('Failed to get path for chunk $chunkIndexNum');

            final success = await _telegramService.downloadFile(
              botToken: state.botToken,
              filePath: filePath,
              savePath: tempSavePath,
              onProgress: (received, total) {
                if (total > 0) {
                  final chunkProgress = (chunkIndex + (received / total)) / totalChunks;
                  state = state.copyWith(
                    downloadProgress: chunkProgress,
                    transferStatus: 'Downloading file...',
                  );
                }
              },
            );

            if (!success) throw Exception('Failed to download chunk $chunkIndexNum');

            // Append chunk bytes to the final file
            final tempFile = File(tempSavePath);
            final chunkBytes = await tempFile.readAsBytes();
            await targetFile.writeAsBytes(chunkBytes, mode: FileMode.append);

            if (await tempFile.exists()) {
              await tempFile.delete();
            }
          }
        }

        state = state.copyWith(isDownloading: false, downloadProgress: 0.0, transferStatus: '');
        await TransferForegroundService.stop();
        return savePath;
      } else {
        // Standard download
        if (isMockMode) {
          for (int i = 0; i <= 10; i++) {
            await Future.delayed(const Duration(milliseconds: 100));
            state = state.copyWith(
              downloadProgress: i / 10.0,
              transferStatus: 'Downloading file (${(i * 10).toStringAsFixed(0)}%)...',
            );
          }
          state = state.copyWith(isDownloading: false, downloadProgress: 0.0, transferStatus: '');
          await TransferForegroundService.stop();
          return savePath;
        }

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
                state = state.copyWith(
                  downloadProgress: received / total,
                  transferStatus: 'Downloading file (${(received / total * 100).toStringAsFixed(0)}%)...',
                );
              }
            },
          );

          if (success) {
            state = state.copyWith(isDownloading: false, downloadProgress: 0.0, transferStatus: '');
            await TransferForegroundService.stop();
            return savePath;
          }
        }
      }
    } catch (e) {
      print('Download file error: $e');
    }
    state = state.copyWith(isDownloading: false, downloadProgress: 0.0, transferStatus: '');
    await TransferForegroundService.stop();
    return null;
  }

  // Rename a file in the local catalog and sync it
  Future<void> renameFile(String oldName, String newName, [String? fileId]) async {
    final updatedFiles = state.allFiles.map((f) {
      final matchesName = f['name'] == oldName;
      final matchesId = fileId == null || f['file_id'] == fileId;
      if (matchesName && matchesId) {
        return Map<String, dynamic>.from(f)..['name'] = newName;
      }
      return f;
    }).toList();
    
    state = state.copyWith(allFiles: updatedFiles);

    if (state.botToken.isNotEmpty && state.chatId.isNotEmpty) {
      await _syncCatalogToTelegram();
    }
  }

  // Move a file to another folder in the local catalog and sync it
  Future<void> moveFile(String filename, String targetFolderPath, [String? fileId]) async {
    String actualFolder = targetFolderPath;
    String? actualId = fileId;
    if (fileId != null && !targetFolderPath.startsWith('/')) {
      actualFolder = fileId;
      actualId = targetFolderPath;
    }

    final updatedFiles = state.allFiles.map((f) {
      final matchesName = f['name'] == filename;
      final matchesId = actualId == null || f['file_id'] == actualId;
      if (matchesName && matchesId) {
        return Map<String, dynamic>.from(f)..['path'] = actualFolder;
      }
      return f;
    }).toList();

    state = state.copyWith(allFiles: updatedFiles);

    if (state.botToken.isNotEmpty && state.chatId.isNotEmpty) {
      await _syncCatalogToTelegram();
    }
  }

  // Add a scanned file entry locally and sync it
  Future<void> addScannedFile(String filename, int sizeBytes) async {
    final mockFile = {
      'name': filename,
      'path': state.currentPath,
      'size_bytes': sizeBytes,
      'uploaded_at': DateTime.now().toIso8601String(),
      'file_id': 'scanned_${DateTime.now().millisecondsSinceEpoch}',
    };

    state = state.copyWith(
      allFiles: List<Map<String, dynamic>>.from(state.allFiles)..add(mockFile),
    );

    if (state.botToken.isNotEmpty && state.chatId.isNotEmpty) {
      await _syncCatalogToTelegram();
    }
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
  String get _currentUserEmail {
    return _ref.read(authProvider).email ?? 'user@example.com';
  }
}

final telegramStorageProvider = StateNotifierProvider<TelegramStorageNotifier, TelegramStorageState>((ref) {
  return TelegramStorageNotifier(ref);
});
