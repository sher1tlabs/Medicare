import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _service = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _service.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = _service.notificationSettings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            const Text(
              'Alert Preferences',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Configure how and when you receive reminders to take your prescribed doses.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Medication Reminders', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Receive timely notifications at scheduled times'),
                    value: settings['medicationReminders'] ?? true,
                    activeColor: const Color(0xFF0D9488),
                    onChanged: (val) => _service.updateNotificationSettings('medicationReminders', val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Reminder Sound', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Play gentle chime with alert notification'),
                    value: settings['reminderSound'] ?? true,
                    activeColor: const Color(0xFF0D9488),
                    onChanged: (val) => _service.updateNotificationSettings('reminderSound', val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Vibration', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Vibrate device when alarms trigger'),
                    value: settings['vibration'] ?? true,
                    activeColor: const Color(0xFF0D9488),
                    onChanged: (val) => _service.updateNotificationSettings('vibration', val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Daily Summary', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Morning overview of all scheduled medications for the day'),
                    value: settings['dailySummary'] ?? true,
                    activeColor: const Color(0xFF0D9488),
                    onChanged: (val) => _service.updateNotificationSettings('dailySummary', val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Missed Medication Alerts', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Follow-up reminder 30 minutes after an unconfirmed dose'),
                    value: settings['missedMedicationAlerts'] ?? true,
                    activeColor: const Color(0xFF0D9488),
                    onChanged: (val) => _service.updateNotificationSettings('missedMedicationAlerts', val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sound & Haptic Test Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.volume_up_outlined, color: Color(0xFF0D9488), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Test Feedback & Console Logs',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Triggers SoundHapticService to play chime sound, vibrate device, and print console event logs.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await _service.testAlert();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🔊 📳 Sound & Haptic alert fired! Check terminal console logs.'),
                              backgroundColor: Color(0xFF0D9488),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFF0D9488)),
                      label: const Text(
                        'Trigger Test Alert',
                        style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
