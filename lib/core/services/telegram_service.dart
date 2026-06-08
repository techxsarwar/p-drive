import 'dart:io';
import 'package:dio/dio.dart';

class TelegramService {
  final Dio _dio = Dio();

  // Upload file document to Telegram channel/chat
  Future<Map<String, dynamic>?> uploadFile({
    required String botToken,
    required String chatId,
    required String filePath,
    required String fileName,
    ProgressCallback? onProgress,
  }) async {
    final url = 'https://api.telegram.org/bot$botToken/sendDocument';
    
    final formData = FormData.fromMap({
      'chat_id': chatId,
      'document': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    try {
      final response = await _dio.post(
        url,
        data: formData,
        onSendProgress: onProgress,
        options: Options(
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      if (response.statusCode == 200 && response.data['ok'] == true) {
        return response.data['result'];
      }
    } catch (e) {
      // Log or handle error
      print('Telegram upload error: $e');
    }
    return null;
  }

  // Pin a specific message in the channel
  Future<bool> pinMessage({
    required String botToken,
    required String chatId,
    required int messageId,
  }) async {
    final url = 'https://api.telegram.org/bot$botToken/pinChatMessage';
    try {
      final response = await _dio.post(url, data: {
        'chat_id': chatId,
        'message_id': messageId,
        'disable_notification': true,
      });
      return response.statusCode == 200 && response.data['ok'] == true;
    } catch (e) {
      print('Telegram pin message error: $e');
      return false;
    }
  }

  // Unpin a specific message
  Future<bool> unpinMessage({
    required String botToken,
    required String chatId,
    required int messageId,
  }) async {
    final url = 'https://api.telegram.org/bot$botToken/unpinChatMessage';
    try {
      final response = await _dio.post(url, data: {
        'chat_id': chatId,
        'message_id': messageId,
      });
      return response.statusCode == 200 && response.data['ok'] == true;
    } catch (e) {
      print('Telegram unpin message error: $e');
      return false;
    }
  }

  // Get chat details (specifically to retrieve the pinned catalog message ID)
  Future<Map<String, dynamic>?> getChatDetails({
    required String botToken,
    required String chatId,
  }) async {
    final url = 'https://api.telegram.org/bot$botToken/getChat?chat_id=$chatId';
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data['ok'] == true) {
        return response.data['result'];
      }
    } catch (e) {
      print('Telegram get chat details error: $e');
    }
    return null;
  }

  // Retrieve file path via file_id
  Future<String?> getFilePath({
    required String botToken,
    required String fileId,
  }) async {
    final url = 'https://api.telegram.org/bot$botToken/getFile?file_id=$fileId';
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data['ok'] == true) {
        return response.data['result']['file_path'];
      }
    } catch (e) {
      print('Telegram get file path error: $e');
    }
    return null;
  }

  // Download raw file from Telegram servers
  Future<bool> downloadFile({
    required String botToken,
    required String filePath,
    required String savePath,
    ProgressCallback? onProgress,
  }) async {
    final url = 'https://api.telegram.org/file/bot$botToken/$filePath';
    try {
      final response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Telegram file download error: $e');
      return false;
    }
  }
  
  // Download file content directly as a String (useful for download catalog JSON)
  Future<String?> downloadTextFile({
    required String botToken,
    required String filePath,
  }) async {
    final url = 'https://api.telegram.org/file/bot$botToken/$filePath';
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        return response.data.toString();
      }
    } catch (e) {
      print('Telegram download text file error: $e');
    }
    return null;
  }
}
