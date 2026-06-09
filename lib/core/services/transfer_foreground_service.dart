import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Top-level entry-point required by flutter_foreground_task.
/// Must be a top-level (non-class) function annotated with vm:entry-point.
@pragma('vm:entry-point')
void startForegroundTaskCallback() {
  FlutterForegroundTask.setTaskHandler(_TransferTaskHandler());
}

/// Minimal TaskHandler — we don't need to do any work here because the
/// actual upload/download runs in the main isolate via Dio.
/// The sole purpose of this foreground service is to hold an Android
/// foreground-service wakelock so that the OS does NOT suspend the main
/// Dart isolate while the user has switched to another app.
class _TransferTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Nothing to do — the real work happens in the main isolate.
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // No-op: we use ForegroundTaskEventAction.nothing() so this is never called.
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // Nothing to clean up.
  }
}

/// Service wrapper — call [initialize] once at app start, then
/// [startUpload] / [startDownload] before a transfer and [stop] when done.
class TransferForegroundService {
  static bool _initialized = false;

  /// Call this once in main() before runApp().
  static void initialize() {
    if (_initialized) return;
    _initialized = true;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'pdrive_transfers',
        channelName: 'P-Drive Transfers',
        channelDescription:
            'Keeps file uploads and downloads running when you switch apps.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWifiLock: true,
        allowWakeLock: true,
      ),
    );
  }

  /// Call before starting an upload to keep the process alive.
  static Future<void> startUpload(String filename) async {
    await _startOrUpdate(
      title: 'Uploading — P-Drive',
      body: 'Uploading "$filename" in the background…',
    );
  }

  /// Call before starting a download to keep the process alive.
  static Future<void> startDownload(String filename) async {
    await _startOrUpdate(
      title: 'Downloading — P-Drive',
      body: 'Downloading "$filename" in the background…',
    );
  }

  /// Call when the transfer finishes (success or failure).
  static Future<void> stop() async {
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (_) {}
  }

  // ─── internal ────────────────────────────────────────────────────────────

  static Future<void> _startOrUpdate({
    required String title,
    required String body,
  }) async {
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.updateService(
          notificationTitle: title,
          notificationText: body,
        );
      } else {
        await FlutterForegroundTask.startService(
          serviceId: 0x50445256, // 'PDRV' in hex — unique service ID
          notificationTitle: title,
          notificationText: body,
          callback: startForegroundTaskCallback,
        );
      }
    } catch (_) {
      // Foreground service is best-effort — never crash the upload because of it.
    }
  }
}
