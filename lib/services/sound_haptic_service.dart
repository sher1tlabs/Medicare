import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/reminder.dart';

/// Predefined standard vibration patterns (in milliseconds: [delay, vibrate, sleep, vibrate...])
/// Compatible with Android's `VibrationEffect` and `flutter_local_notifications` vibration pattern lists.
class VibrationPatterns {
  /// Standard alert: 1s vibrate, 500ms pause, 1s vibrate
  static const List<int> defaultPattern = [0, 1000, 500, 1000];

  /// Urgent medical alert: rapid pulsing pattern
  static const List<int> urgent = [0, 500, 200, 500, 200, 1000];

  /// Gentle reminder: short subtle double-buzz
  static const List<int> gentle = [0, 250, 250, 250];

  /// Heartbeat rhythm: simulates pulse
  static const List<int> heartbeat = [0, 120, 100, 120, 500, 120, 100, 120];
}

/// Abstract contract for sound playback and haptic vibration feedback.
/// Serves as the extensible foundation for integrating the `flutter_local_notifications`
/// package for real-world background reminder alerts on Android and iOS.
abstract class SoundHapticService {
  /// Initializes notification channels, permissions, and audio drivers.
  Future<void> initialize();

  /// Plays or simulates sound playback with specific audio resource and volume.
  Future<void> playSound({String? soundResource, double volume = 1.0});

  /// Executes or simulates a haptic vibration pattern given millisecond intervals [delay, vibrate, pause, ...].
  Future<void> triggerVibrationPattern(List<int> patternMs, {String? patternName});

  /// Quick haptic pulse on supported mobile hardware.
  Future<void> triggerHaptic({bool heavy = false});

  /// Orchestrates combined sound playback and vibration pattern for a due medication reminder.
  Future<void> triggerReminderAlert(
    Reminder reminder, {
    bool enableSound = true,
    bool enableHaptic = true,
    List<int>? customVibrationPattern,
    String? customSound,
  });

  /// Evaluates whether a reminder's scheduled time matches the given [currentTime].
  /// If it matches and the reminder is pending, triggers sound playback and vibration.
  Future<bool> checkAndTriggerIfTimeMatches(
    Reminder reminder,
    DateTime currentTime, {
    bool enableSound = true,
    bool enableHaptic = true,
  });

  /// Checks a list of reminders against [currentTime] and triggers matching alerts.
  Future<List<Reminder>> checkRemindersList(
    List<Reminder> reminders,
    DateTime currentTime, {
    bool enableSound = true,
    bool enableHaptic = true,
  });

  /// Schedules a future local notification (foundation for flutter_local_notifications).
  Future<void> scheduleLocalNotification({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String channelId = 'medication_reminders',
    String channelName = 'Medication Reminders',
    String? soundResource,
    List<int>? vibrationPattern,
    String? payload,
  });

  /// Displays an immediate local notification (foundation for flutter_local_notifications).
  Future<void> showImmediateNotification({
    required int notificationId,
    required String title,
    required String body,
    String channelId = 'medication_reminders',
    String? soundResource,
    List<int>? vibrationPattern,
    String? payload,
  });

  /// Legacy alias for notification scheduling
  Future<void> scheduleReminderNotification({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  });

  /// Cancels a scheduled notification by ID.
  Future<void> cancelReminderNotification(int notificationId);

  /// Cancels all pending notifications.
  Future<void> cancelAllNotifications();
}

/// Backwards compatibility alias
typedef SoundHapticServiceInterface = SoundHapticService;

/// Mock implementation of [SoundHapticService] that logs sound playback events
/// and vibration patterns to the debug console while invoking Flutter's native
/// system sound and haptic feedback where supported.
class MockSoundHapticService implements SoundHapticService {
  static final MockSoundHapticService _instance = MockSoundHapticService._internal();
  factory MockSoundHapticService() => _instance;

  MockSoundHapticService._internal();

  bool _isInitialized = false;
  final List<void Function(Map<String, dynamic>)> _alertListeners = [];

  /// Registers an alert callback for UI observation or in-app dialogs.
  void addAlertListener(void Function(Map<String, dynamic>) listener) {
    _alertListeners.add(listener);
  }

  /// Unregisters an alert callback.
  void removeAlertListener(void Function(Map<String, dynamic>) listener) {
    _alertListeners.remove(listener);
  }

  @override
  Future<void> initialize() async {
    _isInitialized = true;
    debugPrint(
      '\n=======================================================\n'
      '[SoundHapticService] 🚀 Initialized MockSoundHapticService\n'
      '  • Foundation: flutter_local_notifications ready\n'
      '  • Channels configured: "medication_reminders" (HIGH_IMPORTANCE)\n'
      '  • Audio output: System Sound / Audio Stream simulated\n'
      '  • Haptic motor: Vibration Pattern Engine active\n'
      '=======================================================',
    );
  }

  @override
  Future<void> playSound({String? soundResource, double volume = 1.0}) async {
    final soundFile = soundResource ?? 'medication_chime.wav';
    final volumePercent = (volume.clamp(0.0, 1.0) * 100).toInt();

    // Log sound playback to debug console
    debugPrint(
      '[SoundHapticService] 🔊 [SOUND PLAYBACK]\n'
      '   File    : "$soundFile"\n'
      '   Volume  : $volumePercent%\n'
      '   Channel : "medication_reminders"\n'
      '   Status  : Playing audible alert chime...',
    );

    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      debugPrint('[SoundHapticService] Native SystemSound notice: $e');
    }
  }

  /// Backwards compatibility for triggerSound
  Future<void> triggerSound({String? soundName}) => playSound(soundResource: soundName);

  @override
  Future<void> triggerVibrationPattern(List<int> patternMs, {String? patternName}) async {
    final name = patternName ?? 'Medication Alert Pattern';
    final patternDescription = _formatVibrationPattern(patternMs);

    // Log vibration pattern to debug console
    debugPrint(
      '[SoundHapticService] 📳 [VIBRATION PATTERN]\n'
      '   Pattern Name: "$name"\n'
      '   Raw Intervals: [${patternMs.join(', ')}] ms\n'
      '   Sequence    : $patternDescription\n'
      '   Status      : Actuating device haptic motor...',
    );

    try {
      await HapticFeedback.heavyImpact();
      // Simulate subsequent bursts in the pattern
      if (patternMs.length > 2) {
        Future.delayed(Duration(milliseconds: patternMs[1]), () {
          HapticFeedback.mediumImpact();
        });
      }
    } catch (e) {
      debugPrint('[SoundHapticService] Native HapticFeedback notice: $e');
    }
  }

  String _formatVibrationPattern(List<int> patternMs) {
    if (patternMs.isEmpty) return 'No vibration';
    final parts = <String>[];
    for (int i = 0; i < patternMs.length; i++) {
      if (i % 2 == 0) {
        parts.add('wait ${patternMs[i]}ms');
      } else {
        parts.add('vibrate ${patternMs[i]}ms');
      }
    }
    return parts.join(' ➔ ');
  }

  @override
  Future<void> triggerHaptic({bool heavy = false}) async {
    final type = heavy ? "HEAVY_IMPACT" : "MEDIUM_IMPACT";
    debugPrint('[SoundHapticService] 📳 [HAPTIC PULSE] Single pulse triggered ($type)');
    try {
      if (heavy) {
        await HapticFeedback.heavyImpact();
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      debugPrint('[SoundHapticService] Native haptic notice: $e');
    }
  }

  @override
  Future<void> triggerReminderAlert(
    Reminder reminder, {
    bool enableSound = true,
    bool enableHaptic = true,
    List<int>? customVibrationPattern,
    String? customSound,
  }) async {
    final pattern = customVibrationPattern ?? VibrationPatterns.defaultPattern;
    final soundFile = customSound ?? 'medication_alert_chime.wav';

    debugPrint(
      '\n'
      '╔═══════════════════════════════════════════════════════════════════╗\n'
      '║  🚨 [SoundHapticService] DOSE DUE REMINDER ALERT                 ║\n'
      '╠═══════════════════════════════════════════════════════════════════╣\n'
      '║  Medicine: ${reminder.medicineName.padRight(50)} ║\n'
      '║  Dosage  : ${reminder.dosage.padRight(50)} ║\n'
      '║  Time    : ${reminder.time.padRight(50)} ║\n'
      '║  Sound   : ${(enableSound ? "PLAYING ($soundFile)" : "MUTED").padRight(50)} ║\n'
      '║  Haptic  : ${(enableHaptic ? "PATTERN [${pattern.join(', ')} ms]" : "DISABLED").padRight(50)} ║\n'
      '╚═══════════════════════════════════════════════════════════════════╝',
    );

    // 1. Actuate vibration pattern
    if (enableHaptic) {
      await triggerVibrationPattern(pattern, patternName: '${reminder.medicineName} Due Pattern');
    }

    // 2. Play sound playback
    if (enableSound) {
      await playSound(soundResource: soundFile);
    }

    // 3. Emit notification payload to listeners
    final alertPayload = {
      'id': reminder.id,
      'medicineId': reminder.medicineId,
      'medicineName': reminder.medicineName,
      'dosage': reminder.dosage,
      'time': reminder.time,
      'timestamp': DateTime.now().toIso8601String(),
    };

    for (final listener in _alertListeners) {
      try {
        listener(alertPayload);
      } catch (e) {
        debugPrint('[SoundHapticService] Listener error: $e');
      }
    }
  }

  @override
  Future<bool> checkAndTriggerIfTimeMatches(
    Reminder reminder,
    DateTime currentTime, {
    bool enableSound = true,
    bool enableHaptic = true,
  }) async {
    if (reminder.isTaken || reminder.isSkipped) {
      return false;
    }

    // Handle snoozed state
    if (reminder.snoozedUntil != null) {
      if (currentTime.isAfter(reminder.snoozedUntil!) ||
          currentTime.isAtSameMomentAs(reminder.snoozedUntil!)) {
        debugPrint(
          '[SoundHapticService] ⏰ Snooze interval reached for ${reminder.medicineName}! Triggering alert...',
        );
        await triggerReminderAlert(
          reminder,
          enableSound: enableSound,
          enableHaptic: enableHaptic,
          customVibrationPattern: VibrationPatterns.urgent,
        );
        return true;
      }
      return false;
    }

    // Check scheduled time against current time
    if (isTimeMatching(reminder.time, currentTime)) {
      debugPrint(
        '[SoundHapticService] ⏰ SCHEDULED TIME MATCH!\n'
        '   Reminder: "${reminder.medicineName}"\n'
        '   Time    : "${reminder.time}" matches current clock ${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')}\n'
        '   Action  : Executing sound playback and vibration pattern...',
      );

      await triggerReminderAlert(
        reminder,
        enableSound: enableSound,
        enableHaptic: enableHaptic,
      );
      return true;
    }

    return false;
  }

  @override
  Future<List<Reminder>> checkRemindersList(
    List<Reminder> reminders,
    DateTime currentTime, {
    bool enableSound = true,
    bool enableHaptic = true,
  }) async {
    final triggeredReminders = <Reminder>[];
    for (final reminder in reminders) {
      final triggered = await checkAndTriggerIfTimeMatches(
        reminder,
        currentTime,
        enableSound: enableSound,
        enableHaptic: enableHaptic,
      );
      if (triggered) {
        triggeredReminders.add(reminder);
      }
    }
    return triggeredReminders;
  }

  /// Resilient time string comparison logic (supports 12-hour AM/PM and 24-hour)
  bool isTimeMatching(String scheduledTimeString, DateTime currentTime) {
    final raw = scheduledTimeString.trim();
    if (raw.isEmpty) return false;

    final hour12 = currentTime.hour == 0
        ? 12
        : (currentTime.hour > 12 ? currentTime.hour - 12 : currentTime.hour);
    final period = currentTime.hour >= 12 ? 'PM' : 'AM';
    final minutePadded = currentTime.minute.toString().padLeft(2, '0');

    final formatted12H = '$hour12:$minutePadded $period';
    final formatted12HPadded = '${hour12.toString().padLeft(2, '0')}:$minutePadded $period';
    final formattedNoSpace = '$hour12:$minutePadded$period';
    final formatted24H = '${currentTime.hour.toString().padLeft(2, '0')}:$minutePadded';
    final formatted24HNoPad = '${currentTime.hour}:$minutePadded';

    final upperScheduled = raw.toUpperCase().replaceAll(' ', '');

    if (upperScheduled == formatted12H.toUpperCase().replaceAll(' ', '') ||
        upperScheduled == formatted12HPadded.toUpperCase().replaceAll(' ', '') ||
        upperScheduled == formattedNoSpace.toUpperCase() ||
        upperScheduled == formatted24H ||
        upperScheduled == formatted24HNoPad) {
      return true;
    }

    try {
      final match = RegExp(r'^(\d{1,2}):(\d{2})(?:\s*(AM|PM))?$', caseSensitive: false)
          .firstMatch(raw);
      if (match != null) {
        int parsedHour = int.parse(match.group(1)!);
        final int parsedMinute = int.parse(match.group(2)!);
        final String? parsedPeriod = match.group(3)?.toUpperCase();

        if (parsedPeriod != null) {
          if (parsedPeriod == 'PM' && parsedHour < 12) parsedHour += 12;
          if (parsedPeriod == 'AM' && parsedHour == 12) parsedHour = 0;
        }

        return parsedHour == currentTime.hour && parsedMinute == currentTime.minute;
      }
    } catch (_) {}

    return false;
  }

  @override
  Future<void> scheduleLocalNotification({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String channelId = 'medication_reminders',
    String channelName = 'Medication Reminders',
    String? soundResource,
    List<int>? vibrationPattern,
    String? payload,
  }) async {
    final pattern = vibrationPattern ?? VibrationPatterns.defaultPattern;
    final sound = soundResource ?? 'medication_alert_chime.wav';

    debugPrint(
      '[SoundHapticService] 📅 [flutter_local_notifications: SCHEDULED]\n'
      '   ID              : #$notificationId\n'
      '   Title           : "$title"\n'
      '   Body            : "$body"\n'
      '   Scheduled For   : ${scheduledDateTime.toIso8601String()}\n'
      '   Channel ID      : "$channelId" ($channelName)\n'
      '   Sound Resource  : "$sound"\n'
      '   Vibration Pattern: [${pattern.join(', ')}] ms\n'
      '   Payload         : ${payload ?? "(none)"}',
    );
  }

  @override
  Future<void> scheduleReminderNotification({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) =>
      scheduleLocalNotification(
        notificationId: notificationId,
        title: title,
        body: body,
        scheduledDateTime: scheduledDateTime,
        payload: payload,
      );

  @override
  Future<void> showImmediateNotification({
    required int notificationId,
    required String title,
    required String body,
    String channelId = 'medication_reminders',
    String? soundResource,
    List<int>? vibrationPattern,
    String? payload,
  }) async {
    final pattern = vibrationPattern ?? VibrationPatterns.defaultPattern;
    final sound = soundResource ?? 'medication_alert_chime.wav';

    debugPrint(
      '[SoundHapticService] 🔔 [flutter_local_notifications: IMMEDIATE SHOW]\n'
      '   ID              : #$notificationId\n'
      '   Title           : "$title"\n'
      '   Body            : "$body"\n'
      '   Channel ID      : "$channelId"\n'
      '   Sound Resource  : "$sound"\n'
      '   Vibration Pattern: [${pattern.join(', ')}] ms\n'
      '   Payload         : ${payload ?? "(none)"}',
    );

    await triggerVibrationPattern(pattern, patternName: 'Immediate Notification');
    await playSound(soundResource: sound);
  }

  @override
  Future<void> cancelReminderNotification(int notificationId) async {
    debugPrint(
      '[SoundHapticService] 🚫 [flutter_local_notifications: CANCEL] Notification #$notificationId cancelled',
    );
  }

  @override
  Future<void> cancelAllNotifications() async {
    debugPrint(
      '[SoundHapticService] 🚫 [flutter_local_notifications: CANCEL ALL] All pending notifications cancelled',
    );
  }
}
