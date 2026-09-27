import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/medicine.dart';
import '../models/medication_log.dart';
import '../models/reminder.dart';
import '../models/medicine_info.dart';
import 'sound_haptic_service.dart';

/// Service class that abstracts local data persistence for MediCare.
/// Uses [SharedPreferences] for persistent storage across app launches,
/// with automatic in-memory caching and fallback initial seeding.
class LocalStorageService extends ChangeNotifier {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;

  LocalStorageService._internal() {
    init();
    _startReminderPeriodicCheck();
  }

  // Storage Keys
  static const String _keyUser = 'medicare_user_profile';
  static const String _keyMedicines = 'medicare_medicines_list';
  static const String _keyLogs = 'medicare_medication_logs';
  static const String _keyReminders = 'medicare_reminders';
  static const String _keyDarkMode = 'medicare_dark_mode';
  static const String _keyNotificationSettings = 'medicare_notification_settings';
  static const String _keyIsLoggedIn = 'medicare_is_logged_in';

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  Timer? _reminderCheckTimer;

  // Sound and Haptic alert interface (defaults to MockSoundHapticService)
  SoundHapticService _soundHapticService = MockSoundHapticService();

  User? _currentUser;
  bool _isLoggedIn = true;
  bool _isDarkMode = false;

  final List<Medicine> _medicines = [];
  final List<MedicationLog> _logs = [];
  final List<Reminder> _reminders = [];
  final List<MedicineInfo> _medicineInfos = [];

  Map<String, bool> _notificationSettings = {
    'medicationReminders': true,
    'reminderSound': true,
    'vibration': true,
    'dailySummary': true,
    'missedMedicationAlerts': true,
  };

  // Getters
  bool get isInitialized => _isInitialized;
  SoundHapticServiceInterface get soundHapticService => _soundHapticService;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isDarkMode => _isDarkMode;
  List<Medicine> get medicines => List.unmodifiable(_medicines);
  List<MedicationLog> get logs => List.unmodifiable(_logs);
  List<Reminder> get reminders => List.unmodifiable(_reminders);
  List<MedicineInfo> get medicineInfos => List.unmodifiable(_medicineInfos);
  Map<String, bool> get notificationSettings => Map.unmodifiable(_notificationSettings);

  /// Allows swapping in another SoundHapticServiceInterface implementation
  /// (e.g. when integrating with flutter_local_notifications plugin in production).
  void setSoundHapticService(SoundHapticServiceInterface service) {
    _soundHapticService = service;
  }

  // ==========================================
  // INITIALIZATION & PERSISTENCE LOAD
  // ==========================================

  /// Initializes SharedPreferences and loads persisted data.
  Future<void> init() async {
    _populateEducationalLibrary();

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadFromStorage();
    } catch (e) {
      // In web preview or testing environments without native shared_preferences plugins,
      // fallback to memory mock data gracefully.
      debugPrint('SharedPreferences init notice: $e');
      if (_medicines.isEmpty) {
        _seedMockData();
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadFromStorage() async {
    if (_prefs == null) return;

    // Load Dark Mode & Login State
    _isDarkMode = _prefs!.getBool(_keyDarkMode) ?? false;
    _isLoggedIn = _prefs!.getBool(_keyIsLoggedIn) ?? true;

    // Load Notification Settings
    final notifJson = _prefs!.getString(_keyNotificationSettings);
    if (notifJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(notifJson);
        _notificationSettings = decoded.map((k, v) => MapEntry(k, v as bool));
      } catch (e) {
        debugPrint('Error parsing notification settings: $e');
      }
    }

    // Load User Profile
    final userJson = _prefs!.getString(_keyUser);
    if (userJson != null) {
      try {
        _currentUser = User.fromMap(jsonDecode(userJson));
      } catch (e) {
        debugPrint('Error loading user profile: $e');
      }
    }

    // Load Medicines
    final medsJson = _prefs!.getString(_keyMedicines);
    if (medsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(medsJson);
        _medicines.clear();
        _medicines.addAll(decoded.map((m) => Medicine.fromMap(m as Map<String, dynamic>)));
      } catch (e) {
        debugPrint('Error loading medicines list: $e');
      }
    }

    // Load Medication Logs
    final logsJson = _prefs!.getString(_keyLogs);
    if (logsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(logsJson);
        _logs.clear();
        _logs.addAll(decoded.map((l) => MedicationLog.fromMap(l as Map<String, dynamic>)));
      } catch (e) {
        debugPrint('Error loading medication logs: $e');
      }
    }

    // Load Reminders
    final remsJson = _prefs!.getString(_keyReminders);
    if (remsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(remsJson);
        _reminders.clear();
        _reminders.addAll(decoded.map((r) => Reminder.fromMap(r as Map<String, dynamic>)));
      } catch (e) {
        debugPrint('Error loading reminders: $e');
      }
    }

    // If storage is completely empty (first launch), seed initial default data
    if (_currentUser == null && _medicines.isEmpty) {
      _seedMockData();
      await _saveAll();
    }
  }

  // ==========================================
  // PERSISTENCE SAVE METHODS
  // ==========================================

  /// Saves the user profile model to persistent storage.
  Future<bool> saveUserProfile(User user) async {
    _currentUser = user;
    notifyListeners();
    if (_prefs == null) return false;
    try {
      final jsonString = jsonEncode(user.toMap());
      return await _prefs!.setString(_keyUser, jsonString);
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      return false;
    }
  }

  /// Retrieves the persisted user profile.
  Future<User?> getUserProfile() async {
    if (_prefs == null) return _currentUser;
    final userJson = _prefs!.getString(_keyUser);
    if (userJson != null) {
      try {
        return User.fromMap(jsonDecode(userJson));
      } catch (e) {
        debugPrint('Error retrieving user: $e');
      }
    }
    return _currentUser;
  }

  /// Saves the entire list of medicines to persistent storage.
  Future<bool> saveMedicines(List<Medicine> medicinesList) async {
    _medicines.clear();
    _medicines.addAll(medicinesList);
    notifyListeners();
    if (_prefs == null) return false;
    try {
      final jsonString = jsonEncode(_medicines.map((m) => m.toMap()).toList());
      return await _prefs!.setString(_keyMedicines, jsonString);
    } catch (e) {
      debugPrint('Error saving medicines list: $e');
      return false;
    }
  }

  /// Retrieves the persisted list of medicines.
  Future<List<Medicine>> getMedicines() async {
    if (_prefs == null) return medicines;
    final medsJson = _prefs!.getString(_keyMedicines);
    if (medsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(medsJson);
        return decoded.map((m) => Medicine.fromMap(m as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Error retrieving medicines: $e');
      }
    }
    return medicines;
  }

  /// Saves medication history logs to persistent storage.
  Future<bool> saveMedicationLogs(List<MedicationLog> logsList) async {
    _logs.clear();
    _logs.addAll(logsList);
    notifyListeners();
    if (_prefs == null) return false;
    try {
      final jsonString = jsonEncode(_logs.map((l) => l.toMap()).toList());
      return await _prefs!.setString(_keyLogs, jsonString);
    } catch (e) {
      debugPrint('Error saving medication logs: $e');
      return false;
    }
  }

  /// Retrieves persisted medication history logs.
  Future<List<MedicationLog>> getMedicationLogs() async {
    if (_prefs == null) return logs;
    final logsJson = _prefs!.getString(_keyLogs);
    if (logsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(logsJson);
        return decoded.map((l) => MedicationLog.fromMap(l as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Error retrieving logs: $e');
      }
    }
    return logs;
  }

  /// Saves reminders list to persistent storage.
  Future<bool> saveReminders(List<Reminder> remindersList) async {
    _reminders.clear();
    _reminders.addAll(remindersList);
    notifyListeners();
    if (_prefs == null) return false;
    try {
      final jsonString = jsonEncode(_reminders.map((r) => r.toMap()).toList());
      return await _prefs!.setString(_keyReminders, jsonString);
    } catch (e) {
      debugPrint('Error saving reminders: $e');
      return false;
    }
  }

  /// Retrieves persisted reminders.
  Future<List<Reminder>> getReminders() async {
    if (_prefs == null) return reminders;
    final remsJson = _prefs!.getString(_keyReminders);
    if (remsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(remsJson);
        return decoded.map((r) => Reminder.fromMap(r as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Error retrieving reminders: $e');
      }
    }
    return reminders;
  }

  Future<void> _saveAll() async {
    if (_currentUser != null) {
      await saveUserProfile(_currentUser!);
    }
    await saveMedicines(_medicines);
    await saveMedicationLogs(_logs);
    await saveReminders(_reminders);
    if (_prefs != null) {
      await _prefs!.setBool(_keyDarkMode, _isDarkMode);
      await _prefs!.setBool(_keyIsLoggedIn, _isLoggedIn);
      await _prefs!.setString(_keyNotificationSettings, jsonEncode(_notificationSettings));
    }
  }

  /// Clears all stored data (e.g. on account deletion or app reset).
  Future<void> clearAll() async {
    _currentUser = null;
    _isLoggedIn = false;
    _medicines.clear();
    _logs.clear();
    _reminders.clear();
    if (_prefs != null) {
      await _prefs!.clear();
    }
    notifyListeners();
  }

  // ==========================================
  // AUTH & PROFILE METHODS
  // ==========================================

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _isLoggedIn = true;
    if (_currentUser == null) {
      _currentUser = User(
        id: 'usr_new',
        name: email.split('@').first,
        email: email,
        phone: '+1 (555) 000-0000',
        dateOfBirth: DateTime(1990, 1, 1),
      );
    }
    if (_prefs != null) {
      await _prefs!.setBool(_keyIsLoggedIn, true);
    }
    await saveUserProfile(_currentUser!);
    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required DateTime dateOfBirth,
    required String password,
    bool takesMedicines = true,
    String preferredReminderTime = '8:00 AM',
    bool notificationsEnabled = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _currentUser = User(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      dateOfBirth: dateOfBirth,
      takesMedicines: takesMedicines,
      preferredReminderTime: preferredReminderTime,
      notificationsEnabled: notificationsEnabled,
    );
    _isLoggedIn = true;
    if (_prefs != null) {
      await _prefs!.setBool(_keyIsLoggedIn, true);
    }
    await saveUserProfile(_currentUser!);
    notifyListeners();
    return true;
  }

  void logout() {
    _isLoggedIn = false;
    if (_prefs != null) {
      _prefs!.setBool(_keyIsLoggedIn, false);
    }
    notifyListeners();
  }

  void updateProfile(User updatedUser) {
    saveUserProfile(updatedUser);
  }

  void toggleDarkMode(bool enabled) {
    _isDarkMode = enabled;
    if (_prefs != null) {
      _prefs!.setBool(_keyDarkMode, enabled);
    }
    notifyListeners();
  }

  void updateNotificationSettings(String key, bool value) {
    _notificationSettings[key] = value;
    if (_prefs != null) {
      _prefs!.setString(_keyNotificationSettings, jsonEncode(_notificationSettings));
    }
    notifyListeners();
  }

  // ==========================================
  // MEDICINE OPERATIONS
  // ==========================================

  void addMedicine(Medicine medicine) {
    _medicines.add(medicine);

    // Also auto-generate reminders and logs for today
    final now = DateTime.now();
    for (final time in medicine.reminderTimes) {
      _reminders.add(Reminder(
        id: 'rem_${DateTime.now().millisecondsSinceEpoch}_${time.replaceAll(' ', '')}',
        medicineId: medicine.id,
        medicineName: medicine.name,
        type: medicine.type,
        dosage: medicine.dosage,
        time: time,
        isTaken: false,
      ));

      _logs.add(MedicationLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}_${time.replaceAll(' ', '')}',
        medicineId: medicine.id,
        medicineName: medicine.name,
        dosage: medicine.dosage,
        scheduledTime: time,
        status: LogStatus.upcoming,
        date: now,
      ));
    }

    saveMedicines(_medicines);
    saveReminders(_reminders);
    saveMedicationLogs(_logs);

    // Schedule reminder notifications (ready for flutter_local_notifications)
    if (medicine.remindersEnabled) {
      for (int i = 0; i < medicine.reminderTimes.length; i++) {
        final timeStr = medicine.reminderTimes[i];
        final notifId = (medicine.id.hashCode ^ timeStr.hashCode).abs() % 100000;
        _soundHapticService.scheduleReminderNotification(
          notificationId: notifId,
          title: 'Time for ${medicine.name}',
          body: '${medicine.dosage} (${medicine.strength}) - $timeStr',
          scheduledDateTime: DateTime.now(), // scheduled according to timeStr
          payload: jsonEncode({'medicineId': medicine.id, 'time': timeStr}),
        );
      }
    }
  }

  void updateMedicine(Medicine updated) {
    final index = _medicines.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      _medicines[index] = updated;
      saveMedicines(_medicines);
    }
  }

  void toggleMedicineActive(String id) {
    final index = _medicines.indexWhere((m) => m.id == id);
    if (index != -1) {
      final current = _medicines[index];
      _medicines[index] = current.copyWith(isActive: !current.isActive);
      saveMedicines(_medicines);
    }
  }

  void deleteMedicine(String id) {
    // Cancel scheduled notifications for this medicine
    final medReminders = _reminders.where((r) => r.medicineId == id).toList();
    for (final rem in medReminders) {
      final notifId = (id.hashCode ^ rem.time.hashCode).abs() % 100000;
      _soundHapticService.cancelReminderNotification(notifId);
    }

    _medicines.removeWhere((m) => m.id == id);
    _reminders.removeWhere((r) => r.medicineId == id);
    saveMedicines(_medicines);
    saveReminders(_reminders);
  }

  // ==========================================
  // LOGS & REMINDER INTERACTIONS
  // ==========================================

  void markAsTaken(String medicineId, String time) {
    final remIndex = _reminders.indexWhere(
      (r) => r.medicineId == medicineId && r.time == time,
    );
    if (remIndex != -1) {
      _reminders[remIndex] = _reminders[remIndex].copyWith(
        isTaken: true,
        isSkipped: false,
      );
    }

    final logIndex = _logs.indexWhere(
      (l) => l.medicineId == medicineId && l.scheduledTime == time,
    );
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    final actualTimeString = '$hour:$minute $period';

    if (logIndex != -1) {
      _logs[logIndex] = _logs[logIndex].copyWith(
        status: LogStatus.taken,
        actualTime: actualTimeString,
      );
    } else {
      final med = _medicines.firstWhere(
        (m) => m.id == medicineId,
        orElse: () => _medicines.first,
      );
      _logs.add(MedicationLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        medicineId: medicineId,
        medicineName: med.name,
        dosage: med.dosage,
        scheduledTime: time,
        actualTime: actualTimeString,
        status: LogStatus.taken,
        date: now,
      ));
    }

    // Confirmation haptic feedback on taking dose
    if (_notificationSettings['vibration'] ?? true) {
      _soundHapticService.triggerHapticFeedback(heavy: false);
    }

    saveReminders(_reminders);
    saveMedicationLogs(_logs);
  }

  void markAsSkipped(String medicineId, String time) {
    final remIndex = _reminders.indexWhere(
      (r) => r.medicineId == medicineId && r.time == time,
    );
    if (remIndex != -1) {
      _reminders[remIndex] = _reminders[remIndex].copyWith(
        isTaken: false,
        isSkipped: true,
      );
    }

    final logIndex = _logs.indexWhere(
      (l) => l.medicineId == medicineId && l.scheduledTime == time,
    );
    if (logIndex != -1) {
      _logs[logIndex] = _logs[logIndex].copyWith(
        status: LogStatus.skipped,
      );
    }

    saveReminders(_reminders);
    saveMedicationLogs(_logs);
  }

  void snoozeReminder(String medicineId, String time, Duration snoozeDuration) {
    final remIndex = _reminders.indexWhere(
      (r) => r.medicineId == medicineId && r.time == time,
    );
    if (remIndex != -1) {
      final snoozeTarget = DateTime.now().add(snoozeDuration);
      _reminders[remIndex] = _reminders[remIndex].copyWith(
        snoozedUntil: snoozeTarget,
      );
      saveReminders(_reminders);

      // Schedule follow-up notification for snoozed interval
      final notifId = (medicineId.hashCode ^ time.hashCode ^ snoozeDuration.inMinutes).abs() % 100000;
      _soundHapticService.scheduleReminderNotification(
        notificationId: notifId,
        title: 'Snoozed: ${_reminders[remIndex].medicineName}',
        body: 'Reminder to take ${_reminders[remIndex].dosage}',
        scheduledDateTime: snoozeTarget,
        payload: jsonEncode({'medicineId': medicineId, 'time': time, 'snoozed': true}),
      );
    }
  }

  /// Triggers a sound/haptic alert when a specific dose is due.
  /// Honors user's notification preferences (sound, vibration, global reminders toggle).
  Future<void> triggerDoseDue({
    required String medicineId,
    required String scheduledTime,
  }) async {
    final remindersEnabled = _notificationSettings['medicationReminders'] ?? true;
    if (!remindersEnabled) {
      debugPrint('[LocalStorageService] Medication reminders disabled in settings. Skipping alert.');
      return;
    }

    final reminder = _reminders.firstWhere(
      (r) => r.medicineId == medicineId && r.time == scheduledTime,
      orElse: () => _reminders.firstWhere(
        (r) => r.medicineId == medicineId,
        orElse: () => Reminder(
          id: 'temp',
          medicineId: medicineId,
          medicineName: 'Medicine',
          type: 'Tablet',
          dosage: '1 dose',
          time: scheduledTime,
        ),
      ),
    );

    final soundEnabled = _notificationSettings['reminderSound'] ?? true;
    final hapticEnabled = _notificationSettings['vibration'] ?? true;

    await _soundHapticService.triggerReminderAlert(
      reminder,
      enableSound: soundEnabled,
      enableHaptic: hapticEnabled,
    );
  }

  /// Checks untaken reminders for today against the given or current time,
  /// triggering sound/haptic alerts when a scheduled time matches the current time.
  Future<List<Reminder>> checkDueReminders({DateTime? currentTime}) async {
    final remindersEnabled = _notificationSettings['medicationReminders'] ?? true;
    if (!remindersEnabled) return [];

    final now = currentTime ?? DateTime.now();
    final soundEnabled = _notificationSettings['reminderSound'] ?? true;
    final hapticEnabled = _notificationSettings['vibration'] ?? true;

    return await _soundHapticService.checkRemindersList(
      _reminders,
      now,
      enableSound: soundEnabled,
      enableHaptic: hapticEnabled,
    );
  }

  void _startReminderPeriodicCheck() {
    _reminderCheckTimer?.cancel();
    // Run an initial check after a brief startup delay
    Timer(const Duration(seconds: 2), () {
      checkDueReminders();
    });
    // Periodically evaluate scheduled reminders against current time every 30 seconds
    _reminderCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      checkDueReminders();
    });
  }

  /// Stops the background reminder check timer if needed.
  void stopReminderPeriodicCheck() {
    _reminderCheckTimer?.cancel();
    _reminderCheckTimer = null;
  }

  /// Triggers a test sound/haptic alert using the current notification settings.
  Future<void> testAlert() async {
    final sampleReminder = _reminders.isNotEmpty
        ? _reminders.first
        : Reminder(
            id: 'test_sample',
            medicineId: 'med_test',
            medicineName: 'Vitamin D3',
            type: 'Capsule',
            dosage: '1000 IU',
            time: '12:00 PM',
          );

    final soundEnabled = _notificationSettings['reminderSound'] ?? true;
    final hapticEnabled = _notificationSettings['vibration'] ?? true;

    await _soundHapticService.triggerReminderAlert(
      sampleReminder,
      enableSound: soundEnabled,
      enableHaptic: hapticEnabled,
    );
  }

  // ==========================================
  // PROGRESS & METRICS
  // ==========================================

  int get todayTotalMedicines => _reminders.length;
  int get todayTakenMedicines => _reminders.where((r) => r.isTaken).length;
  double get todayProgressPercentage =>
      todayTotalMedicines == 0 ? 0.0 : todayTakenMedicines / todayTotalMedicines;

  Reminder? get nextReminder {
    final upcoming = _reminders.where((r) => !r.isTaken && !r.isSkipped).toList();
    if (upcoming.isEmpty) return null;
    return upcoming.first;
  }

  // ==========================================
  // INITIAL MOCK DATA SEEDING
  // ==========================================

  void _seedMockData() {
    _currentUser = User(
      id: 'usr_001',
      name: 'Adnan Sher',
      email: 'adnanshersb@gmail.com',
      phone: '+1 (555) 329-8472',
      dateOfBirth: DateTime(1988, 5, 14),
      takesMedicines: true,
      preferredReminderTime: '8:00 AM',
      notificationsEnabled: true,
    );

    final now = DateTime.now();
    _medicines.addAll([
      Medicine(
        id: 'med_01',
        name: 'Vitamin D3',
        genericName: 'Cholecalciferol',
        type: 'Capsule',
        strength: '1000 IU',
        dosage: '1 Capsule',
        frequency: 'Once daily',
        reminderTimes: ['8:00 AM'],
        startDate: now.subtract(const Duration(days: 30)),
        instructions: 'Take in the morning with a meal containing fats',
        notes: 'Prescribed by Dr. Robert for bone density support',
        isActive: true,
        remindersEnabled: true,
      ),
      Medicine(
        id: 'med_02',
        name: 'Metformin',
        genericName: 'Metformin Hydrochloride',
        type: 'Tablet',
        strength: '500 mg',
        dosage: '1 Tablet',
        frequency: 'Twice daily',
        reminderTimes: ['8:00 AM', '8:00 PM'],
        startDate: now.subtract(const Duration(days: 90)),
        instructions: 'Take immediately with or right after meals',
        notes: 'Helps control blood sugar levels',
        isActive: true,
        remindersEnabled: true,
      ),
      Medicine(
        id: 'med_03',
        name: 'Paracetamol',
        genericName: 'Acetaminophen',
        type: 'Tablet',
        strength: '650 mg',
        dosage: '1 Tablet',
        frequency: 'Three times daily',
        reminderTimes: ['8:00 AM', '1:00 PM', '8:00 PM'],
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 4)),
        instructions: 'Take with plenty of water',
        notes: 'Mild fever and pain relief post dental procedure',
        isActive: true,
        remindersEnabled: true,
      ),
      Medicine(
        id: 'med_04',
        name: 'Atorvastatin',
        genericName: 'Atorvastatin Calcium',
        type: 'Tablet',
        strength: '20 mg',
        dosage: '1 Tablet',
        frequency: 'Once daily',
        reminderTimes: ['9:30 PM'],
        startDate: now.subtract(const Duration(days: 120)),
        instructions: 'Take at bedtime',
        notes: 'Cholesterol management',
        isActive: true,
        remindersEnabled: true,
      ),
    ]);

    _logs.addAll([
      MedicationLog(
        id: 'log_01',
        medicineId: 'med_01',
        medicineName: 'Vitamin D3',
        dosage: '1 Capsule',
        scheduledTime: '8:00 AM',
        actualTime: '8:05 AM',
        status: LogStatus.taken,
        date: now,
      ),
      MedicationLog(
        id: 'log_02',
        medicineId: 'med_02',
        medicineName: 'Metformin',
        dosage: '1 Tablet',
        scheduledTime: '8:00 AM',
        actualTime: '8:12 AM',
        status: LogStatus.taken,
        date: now,
      ),
      MedicationLog(
        id: 'log_03',
        medicineId: 'med_03',
        medicineName: 'Paracetamol',
        dosage: '1 Tablet',
        scheduledTime: '1:00 PM',
        actualTime: '1:10 PM',
        status: LogStatus.taken,
        date: now,
      ),
      MedicationLog(
        id: 'log_04',
        medicineId: 'med_03',
        medicineName: 'Paracetamol',
        dosage: '1 Tablet',
        scheduledTime: '8:00 PM',
        status: LogStatus.upcoming,
        date: now,
      ),
      MedicationLog(
        id: 'log_05',
        medicineId: 'med_02',
        medicineName: 'Metformin',
        dosage: '1 Tablet',
        scheduledTime: '8:00 PM',
        status: LogStatus.upcoming,
        date: now,
      ),
      MedicationLog(
        id: 'log_06',
        medicineId: 'med_04',
        medicineName: 'Atorvastatin',
        dosage: '1 Tablet',
        scheduledTime: '9:30 PM',
        status: LogStatus.upcoming,
        date: now,
      ),
      MedicationLog(
        id: 'log_hist_1',
        medicineId: 'med_01',
        medicineName: 'Vitamin D3',
        dosage: '1 Capsule',
        scheduledTime: '8:00 AM',
        actualTime: '8:10 AM',
        status: LogStatus.taken,
        date: now.subtract(const Duration(days: 1)),
      ),
      MedicationLog(
        id: 'log_hist_2',
        medicineId: 'med_02',
        medicineName: 'Metformin',
        dosage: '1 Tablet',
        scheduledTime: '8:00 AM',
        actualTime: '8:15 AM',
        status: LogStatus.taken,
        date: now.subtract(const Duration(days: 1)),
      ),
      MedicationLog(
        id: 'log_hist_3',
        medicineId: 'med_02',
        medicineName: 'Metformin',
        dosage: '1 Tablet',
        scheduledTime: '8:00 PM',
        status: LogStatus.skipped,
        date: now.subtract(const Duration(days: 1)),
      ),
    ]);

    _reminders.addAll([
      const Reminder(
        id: 'rem_01',
        medicineId: 'med_01',
        medicineName: 'Vitamin D3',
        type: 'Capsule',
        dosage: '1 Capsule',
        time: '8:00 AM',
        isTaken: true,
      ),
      const Reminder(
        id: 'rem_02',
        medicineId: 'med_02',
        medicineName: 'Metformin',
        type: 'Tablet',
        dosage: '1 Tablet',
        time: '8:00 AM',
        isTaken: true,
      ),
      const Reminder(
        id: 'rem_03',
        medicineId: 'med_03',
        medicineName: 'Paracetamol',
        type: 'Tablet',
        dosage: '1 Tablet',
        time: '1:00 PM',
        isTaken: true,
      ),
      const Reminder(
        id: 'rem_04',
        medicineId: 'med_02',
        medicineName: 'Metformin',
        type: 'Tablet',
        dosage: '1 Tablet',
        time: '8:00 PM',
        isTaken: false,
      ),
      const Reminder(
        id: 'rem_05',
        medicineId: 'med_03',
        medicineName: 'Paracetamol',
        type: 'Tablet',
        dosage: '1 Tablet',
        time: '8:00 PM',
        isTaken: false,
      ),
      const Reminder(
        id: 'rem_06',
        medicineId: 'med_04',
        medicineName: 'Atorvastatin',
        type: 'Tablet',
        dosage: '1 Tablet',
        time: '9:30 PM',
        isTaken: false,
      ),
    ]);
  }

  void _populateEducationalLibrary() {
    _medicineInfos.clear();
    _medicineInfos.addAll([
      const MedicineInfo(
        id: 'info_01',
        name: 'Paracetamol',
        genericName: 'Acetaminophen',
        type: 'Tablet / Syrup',
        shortDescription: 'A widely used pain reliever and fever reducer.',
        commonUses: [
          'Mild to moderate pain relief (headaches, muscle aches, toothaches)',
          'Fever reduction during colds or flu',
          'Osteoarthritis symptom management',
        ],
        dosageInfo:
            'Adults typically take 500 mg to 1000 mg every 4 to 6 hours as needed. Maximum daily dose should not exceed 4,000 mg in 24 hours to prevent liver toxicity.',
        sideEffects: [
          'Rare at recommended doses',
          'Nausea or stomach upset',
          'Skin rash or allergic reactions (rare)',
        ],
        warnings: [
          'Excessive doses can cause severe and irreversible liver damage.',
          'Avoid consuming alcohol while taking acetaminophen.',
          'Always check if other over-the-counter cough or flu remedies also contain paracetamol to prevent accidental overdose.',
        ],
        storageInfo:
            'Store at room temperature (15°C to 30°C / 59°F to 86°F) away from moisture and direct sunlight.',
        precautions: [
          'Inform your doctor if you have liver disease or severe renal impairment.',
          'Safe for most pregnant and breastfeeding individuals under clinical guidance.',
        ],
      ),
      const MedicineInfo(
        id: 'info_02',
        name: 'Metformin',
        genericName: 'Metformin Hydrochloride',
        type: 'Tablet',
        shortDescription: 'First-line prescription medication for managing type 2 diabetes mellitus.',
        commonUses: [
          'Lowering blood glucose levels in type 2 diabetes',
          'Improving insulin sensitivity',
          'Polycystic ovary syndrome (PCOS) insulin resistance',
        ],
        dosageInfo:
            'Usually initiated at 500 mg once or twice daily with meals to reduce gastrointestinal distress. May be gradually titrated up to 2,000 mg daily by a healthcare provider.',
        sideEffects: [
          'Diarrhea, nausea, stomach cramping',
          'Metallic taste in mouth',
          'Reduced vitamin B12 absorption over long-term use',
        ],
        warnings: [
          'Rare risk of lactic acidosis, especially in patients with acute renal impairment.',
          'Must be temporarily discontinued prior to iodinated contrast radiological procedures.',
        ],
        storageInfo: 'Store between 20°C and 25°C (68°F to 77°F). Keep tightly closed in original bottle.',
        precautions: [
          'Requires routine monitoring of kidney function (eGFR) and vitamin B12 levels.',
          'Take with food to minimize stomach upset.',
        ],
      ),
      const MedicineInfo(
        id: 'info_03',
        name: 'Vitamin D3',
        genericName: 'Cholecalciferol',
        type: 'Capsule / Drops',
        shortDescription: 'Essential fat-soluble vitamin for calcium absorption, bone health, and immune support.',
        commonUses: [
          'Treatment and prevention of vitamin D deficiency',
          'Supporting bone and teeth mineralization',
          'Osteoporosis management in conjunction with calcium',
        ],
        dosageInfo:
            'Maintenance daily doses range from 600 IU to 2,000 IU daily. High-dose weekly regimens (e.g. 50,000 IU) may be prescribed for severe deficiency.',
        sideEffects: [
          'Extremely well tolerated within recommended limits',
          'Hypercalcemia symptoms if mega-dosed (dry mouth, nausea, confusion)',
        ],
        warnings: [
          'Fat-soluble vitamin that accumulates in body fat; do not exceed prescribed doses without blood level testing (25-hydroxy vitamin D).',
        ],
        storageInfo: 'Store in a cool, dry place away from heat and light.',
        precautions: [
          'Take with a meal containing dietary fats for optimal gastrointestinal absorption.',
        ],
      ),
      const MedicineInfo(
        id: 'info_04',
        name: 'Atorvastatin',
        genericName: 'Atorvastatin Calcium',
        type: 'Tablet',
        shortDescription: 'HMG-CoA reductase inhibitor (statin) used to lower LDL cholesterol and triglycerides.',
        commonUses: [
          'Reduction of cardiovascular disease risks (heart attack, stroke)',
          'Hypercholesterolemia management',
          'Atherosclerosis prevention',
        ],
        dosageInfo:
            'Typical starting dose is 10 mg to 20 mg once daily, taken at any time of day (often evening), with or without food. Maximum dose is 80 mg daily.',
        sideEffects: [
          'Mild muscle soreness or arthralgia',
          'Mild elevations in liver enzymes',
          'Digestive disturbances',
        ],
        warnings: [
          'Report unexplained muscle pain, tenderness, or weakness immediately (risk of rhabdomyolysis).',
          'Avoid large quantities of grapefruit juice as it increases drug concentration.',
        ],
        storageInfo: 'Store below 25°C (77°F) in a dry container.',
        precautions: [
          'Periodic liver and lipid panel lab tests are recommended.',
          'Contraindicated during pregnancy and breastfeeding.',
        ],
      ),
      const MedicineInfo(
        id: 'info_05',
        name: 'Amoxicillin',
        genericName: 'Amoxicillin Trihydrate',
        type: 'Capsule / Suspension',
        shortDescription: 'Penicillin-class antibiotic effective against a broad spectrum of bacterial infections.',
        commonUses: [
          'Respiratory tract infections (sinusitis, bronchitis, pneumonia)',
          'Middle ear infections (otitis media)',
          'Skin and urinary tract infections',
        ],
        dosageInfo:
            'Commonly 250 mg to 500 mg every 8 hours, or 875 mg every 12 hours, for 7 to 10 days depending on infection severity.',
        sideEffects: [
          'Diarrhea, nausea, vomiting',
          'Mild cutaneous rash',
        ],
        warnings: [
          'Do NOT take if you have a known allergy to penicillin or cephalosporin antibiotics.',
          'Finish the entire prescribed course even if symptoms improve early.',
        ],
        storageInfo: 'Capsules at room temperature. Liquid suspension must be refrigerated and discarded after 14 days.',
        precautions: [
          'Can decrease efficacy of oral contraceptives in some individuals.',
        ],
      ),
    ]);
  }
}
