import 'package:flutter/material.dart';
import '../models/reminder.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTake;
  final VoidCallback onSkip;
  final void Function(Duration) onSnooze;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onTake,
    required this.onSkip,
    required this.onSnooze,
  });

  void _showSnoozeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Snooze Reminder'),
        content: const Text('Select how long you want to delay this reminder:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onSnooze(const Duration(minutes: 10));
            },
            child: const Text('10 Minutes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onSnooze(const Duration(minutes: 30));
            },
            child: const Text('30 Minutes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onSnooze(const Duration(hours: 1));
            },
            child: const Text('1 Hour'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDone = reminder.isTaken;
    final isSkipped = reminder.isSkipped;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Time box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDone
                    ? const Color(0xFFECFDF5)
                    : isSkipped
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDone
                      ? const Color(0xFFA7F3D0)
                      : isSkipped
                          ? const Color(0xFFFECACA)
                          : const Color(0xFF99F6E4),
                ),
              ),
              child: Text(
                reminder.time,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDone
                      ? const Color(0xFF059669)
                      : isSkipped
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF0D9488),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.medicineName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reminder.dosage,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  if (reminder.snoozedUntil != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Snoozed until ${reminder.snoozedUntil!.hour}:${reminder.snoozedUntil!.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Action or Status
            if (isDone)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Color(0xFF059669)),
                    SizedBox(width: 4),
                    Text(
                      'Taken',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              )
            else if (isSkipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Skipped',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC2626),
                  ),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showSnoozeDialog(context),
                    icon: const Icon(Icons.snooze, size: 20),
                    tooltip: 'Snooze',
                    color: const Color(0xFF64748B),
                  ),
                  IconButton(
                    onPressed: onSkip,
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: 'Skip',
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    onPressed: onTake,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      minimumSize: const Size(60, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Take',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
