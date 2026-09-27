import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';
import '../../models/medication_log.dart';
import '../../widgets/empty_state_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final LocalStorageService _service = LocalStorageService();
  String _selectedFilter = 'Today'; // Today, This Week, This Month, Custom Date
  DateTime? _customSelectedDate;

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

  void _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customSelectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _customSelectedDate = picked;
        _selectedFilter = 'Custom Date';
      });
    }
  }

  List<MedicationLog> _getFilteredLogs() {
    final now = DateTime.now();
    return _service.logs.where((log) {
      if (_selectedFilter == 'Today') {
        return log.date.year == now.year &&
            log.date.month == now.month &&
            log.date.day == now.day;
      } else if (_selectedFilter == 'This Week') {
        final difference = now.difference(log.date).inDays;
        return difference >= 0 && difference <= 7;
      } else if (_selectedFilter == 'This Month') {
        return log.date.year == now.year && log.date.month == now.month;
      } else if (_selectedFilter == 'Custom Date' && _customSelectedDate != null) {
        return log.date.year == _customSelectedDate!.year &&
            log.date.month == _customSelectedDate!.month &&
            log.date.day == _customSelectedDate!.day;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredLogs();
    final takenCount = filtered.where((l) => l.status == LogStatus.taken).length;
    final skippedCount = filtered.where((l) => l.status == LogStatus.skipped).length;
    final totalNonUpcoming = takenCount + skippedCount;
    final adherenceRate = totalNonUpcoming == 0
        ? 100
        : ((takenCount / totalNonUpcoming) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication History'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: ['Today', 'This Week', 'This Month', 'Custom Date'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        filter == 'Custom Date' && _customSelectedDate != null
                            ? '${_customSelectedDate!.month}/${_customSelectedDate!.day}'
                            : filter,
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFFCCFBF1),
                      labelStyle: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? const Color(0xFF0D9488) : const Color(0xFF64748B),
                      ),
                      onSelected: (_) {
                        if (filter == 'Custom Date') {
                          _pickCustomDate();
                        } else {
                          setState(() => _selectedFilter = filter);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // Adherence summary card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: adherenceRate >= 80
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$adherenceRate%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: adherenceRate >= 80
                                ? const Color(0xFF059669)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Medication Adherence',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$takenCount taken, $skippedCount missed in this period',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: adherenceRate >= 80
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        adherenceRate >= 80 ? 'On Track' : 'Needs Focus',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: adherenceRate >= 80
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Logs list
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.history_outlined,
                      title: 'No history found',
                      description: 'There are no medicine records for the selected time filter.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final log = filtered[index];
                        final isTaken = log.status == LogStatus.taken;
                        final isSkipped = log.status == LogStatus.skipped;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isTaken
                                      ? const Color(0xFFECFDF5)
                                      : isSkipped
                                          ? const Color(0xFFFEF2F2)
                                          : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isTaken
                                      ? Icons.check
                                      : isSkipped
                                          ? Icons.close
                                          : Icons.schedule,
                                  color: isTaken
                                      ? const Color(0xFF059669)
                                      : isSkipped
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.medicineName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${log.dosage} • Scheduled: ${log.scheduledTime}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    if (log.actualTime != null)
                                      Text(
                                        'Recorded at ${log.actualTime}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF0D9488),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isTaken
                                      ? const Color(0xFFECFDF5)
                                      : isSkipped
                                          ? const Color(0xFFFEF2F2)
                                          : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isTaken
                                      ? 'Taken ✓'
                                      : isSkipped
                                          ? 'Skipped'
                                          : 'Upcoming',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isTaken
                                        ? const Color(0xFF059669)
                                        : isSkipped
                                            ? const Color(0xFFDC2626)
                                            : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
