import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';
import '../../models/medicine.dart';
import '../../models/medication_log.dart';
import 'add_medicine_screen.dart';

class MedicineDetailsScreen extends StatefulWidget {
  final String medicineId;

  const MedicineDetailsScreen({super.key, required this.medicineId});

  @override
  State<MedicineDetailsScreen> createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends State<MedicineDetailsScreen> {
  final LocalStorageService _service = LocalStorageService();

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

  void _confirmDelete(Medicine med) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this medicine?'),
        content: Text('This will remove "${med.name}" and all its reminders and logs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _service.deleteMedicine(med.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Medicine? medicine;
    try {
      medicine = _service.medicines.firstWhere((m) => m.id == widget.medicineId);
    } catch (_) {
      medicine = null;
    }

    if (medicine == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Medicine Details')),
        body: const Center(child: Text('Medicine not found')),
      );
    }

    final logs = _service.logs.where((l) => l.medicineId == medicine!.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddMedicineScreen(editingMedicine: medicine),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            onPressed: () => _confirmDelete(medicine!),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            medicine.type,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: medicine.isActive
                                ? const Color(0xFF10B981)
                                : Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            medicine.isActive ? 'Active' : 'Paused',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (medicine.genericName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Generic: ${medicine.genericName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildHeroStat('Strength', medicine.strength),
                        const SizedBox(width: 24),
                        _buildHeroStat('Dosage', medicine.dosage),
                        const SizedBox(width: 24),
                        _buildHeroStat('Frequency', medicine.frequency),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons (Pause / Resume)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _service.toggleMedicineActive(medicine!.id),
                      icon: Icon(medicine.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline),
                      label: Text(medicine.isActive ? 'Pause Medication' : 'Resume Medication'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: medicine.isActive ? const Color(0xFFD97706) : const Color(0xFF0D9488),
                        side: BorderSide(
                          color: medicine.isActive ? const Color(0xFFD97706) : const Color(0xFF0D9488),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Details Group
              const Text(
                'Schedule Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              _buildDetailItem(
                Icons.alarm,
                'Reminder Times',
                medicine.reminderTimes.join(', '),
              ),
              _buildDetailItem(
                Icons.calendar_today,
                'Start Date',
                '${medicine.startDate.month}/${medicine.startDate.day}/${medicine.startDate.year}',
              ),
              _buildDetailItem(
                Icons.event_busy,
                'End Date',
                medicine.endDate != null
                    ? '${medicine.endDate!.month}/${medicine.endDate!.day}/${medicine.endDate!.year}'
                    : 'Ongoing (No end date)',
              ),
              if (medicine.instructions.isNotEmpty)
                _buildDetailItem(
                  Icons.restaurant_outlined,
                  'Instructions',
                  medicine.instructions,
                ),
              if (medicine.notes.isNotEmpty)
                _buildDetailItem(
                  Icons.note_outlined,
                  'Notes / Remarks',
                  medicine.notes,
                ),
              _buildDetailItem(
                Icons.notifications_active_outlined,
                'Alarms & Notifications',
                medicine.remindersEnabled ? 'Enabled (Sound + Vibration)' : 'Disabled',
              ),

              const SizedBox(height: 28),

              // Medication History Section
              const Text(
                'Medication History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              if (logs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Text('No logged doses for this medicine yet.'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final isTaken = log.status == LogStatus.taken;
                    final isSkipped = log.status == LogStatus.skipped;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isTaken
                                ? Icons.check_circle
                                : isSkipped
                                    ? Icons.cancel
                                    : Icons.radio_button_unchecked,
                            color: isTaken
                                ? const Color(0xFF059669)
                                : isSkipped
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF94A3B8),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${log.scheduledTime} — ${isTaken ? "Taken" : isSkipped ? "Skipped" : "Upcoming"}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isTaken
                                        ? const Color(0xFF059669)
                                        : isSkipped
                                            ? const Color(0xFFDC2626)
                                            : const Color(0xFF475569),
                                  ),
                                ),
                                if (log.actualTime != null)
                                  Text(
                                    'Logged at ${log.actualTime}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${log.date.month}/${log.date.day}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStat(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0D9488)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
