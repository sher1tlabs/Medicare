import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';
import '../../models/medicine.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? editingMedicine;

  const AddMedicineScreen({super.key, this.editingMedicine});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _genericNameController;
  late TextEditingController _strengthController;
  late TextEditingController _dosageController;
  late TextEditingController _instructionsController;
  late TextEditingController _notesController;

  String _medicineType = 'Tablet';
  String _frequency = 'Once daily';
  List<String> _reminderTimes = ['8:00 AM'];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _hasEndDate = false;
  bool _remindersEnabled = true;

  final List<String> _medicineTypes = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Cream',
    'Drops',
    'Other',
  ];

  final List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Every 8 hours',
    'Every 12 hours',
    'Weekly',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    final med = widget.editingMedicine;
    _nameController = TextEditingController(text: med?.name ?? '');
    _genericNameController = TextEditingController(text: med?.genericName ?? '');
    _strengthController = TextEditingController(text: med?.strength ?? '500 mg');
    _dosageController = TextEditingController(text: med?.dosage ?? '1 Tablet');
    _instructionsController = TextEditingController(text: med?.instructions ?? 'Take after food');
    _notesController = TextEditingController(text: med?.notes ?? '');

    if (med != null) {
      _medicineType = med.type;
      _frequency = med.frequency;
      _reminderTimes = List.from(med.reminderTimes);
      _startDate = med.startDate;
      _endDate = med.endDate;
      _hasEndDate = med.endDate != null;
      _remindersEnabled = med.remindersEnabled;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genericNameController.dispose();
    _strengthController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addReminderTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (pickedTime != null) {
      final hour = pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod;
      final minute = pickedTime.minute.toString().padLeft(2, '0');
      final period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
      final formatted = '$hour:$minute $period';
      if (!_reminderTimes.contains(formatted)) {
        setState(() => _reminderTimes.add(formatted));
      }
    }
  }

  void _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  void _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 14)),
      firstDate: _startDate,
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _hasEndDate = true;
      });
    }
  }

  void _saveMedicine() {
    if (!_formKey.currentState!.validate()) return;
    if (_reminderTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one reminder time')),
      );
      return;
    }

    final newMed = Medicine(
      id: widget.editingMedicine?.id ?? 'med_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      genericName: _genericNameController.text.trim(),
      type: _medicineType,
      strength: _strengthController.text.trim(),
      dosage: _dosageController.text.trim(),
      frequency: _frequency,
      reminderTimes: _reminderTimes,
      startDate: _startDate,
      endDate: _hasEndDate ? _endDate : null,
      instructions: _instructionsController.text.trim(),
      notes: _notesController.text.trim(),
      isActive: widget.editingMedicine?.isActive ?? true,
      remindersEnabled: _remindersEnabled,
    );

    if (widget.editingMedicine != null) {
      LocalStorageService().updateMedicine(newMed);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine updated successfully!')),
      );
    } else {
      LocalStorageService().addMedicine(newMed);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine saved successfully!')),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingMedicine != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medicine' : 'Add Medicine'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Medicine Information', Icons.medication_outlined),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _nameController,
                  label: 'Medicine Name *',
                  hint: 'e.g. Paracetamol, Amoxicillin',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _genericNameController,
                  label: 'Generic Name (Optional)',
                  hint: 'e.g. Acetaminophen',
                ),
                const SizedBox(height: 14),
                const Text(
                  'Medicine Type',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _medicineType,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
                  items: _medicineTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _medicineType = v ?? 'Tablet'),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _strengthController,
                  label: 'Strength',
                  hint: 'e.g. 500 mg, 10 ml, 250 mcg',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Strength is required' : null,
                ),

                const SizedBox(height: 28),
                _buildSectionHeader('Dosage', Icons.local_pharmacy_outlined),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _dosageController,
                  label: 'Dosage Amount',
                  hint: 'e.g. 1 Tablet, 2 Spoonfuls',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Dosage is required' : null,
                ),

                const SizedBox(height: 28),
                _buildSectionHeader('Schedule & Reminders', Icons.alarm_outlined),
                const SizedBox(height: 14),
                const Text(
                  'Frequency',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _frequency,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.repeat)),
                  items: _frequencies
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) => setState(() => _frequency = v ?? 'Once daily'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reminder Times',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _reminderTimes.map((time) {
                    return Chip(
                      label: Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: const Color(0xFFF0FDFA),
                      deleteIconColor: const Color(0xFF0D9488),
                      onDeleted: _reminderTimes.length > 1
                          ? () => setState(() => _reminderTimes.remove(time))
                          : null,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _addReminderTime,
                  icon: const Icon(Icons.add_alarm, size: 18),
                  label: const Text('Add Another Time'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0D9488),
                    side: const BorderSide(color: Color(0xFF0D9488)),
                  ),
                ),

                const SizedBox(height: 28),
                _buildSectionHeader('Duration', Icons.date_range_outlined),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectStartDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Date', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              Text(
                                '${_startDate.month}/${_startDate.day}/${_startDate.year}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _hasEndDate ? _selectEndDate : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: _hasEndDate ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Date', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              Text(
                                _hasEndDate && _endDate != null
                                    ? '${_endDate!.month}/${_endDate!.day}/${_endDate!.year}'
                                    : 'Ongoing',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _hasEndDate ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                CheckboxListTile(
                  title: const Text('Set specific end date'),
                  value: _hasEndDate,
                  activeColor: const Color(0xFF0D9488),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setState(() {
                      _hasEndDate = val ?? false;
                      if (_hasEndDate && _endDate == null) {
                        _endDate = _startDate.add(const Duration(days: 7));
                      }
                    });
                  },
                ),

                const SizedBox(height: 20),
                _buildSectionHeader('Additional Information', Icons.info_outline),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _instructionsController,
                  label: 'Instructions',
                  hint: 'e.g. Take after food with full glass of water',
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _notesController,
                  label: 'Doctor Notes / Remarks',
                  hint: 'e.g. Prescribed for 2 weeks review with Dr. Smith',
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  title: const Text('Enable Alarms & Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Sound alarm when it is time to take this medicine'),
                  value: _remindersEnabled,
                  activeColor: const Color(0xFF0D9488),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => _remindersEnabled = v),
                ),

                const SizedBox(height: 32),
                CustomButton(
                  text: isEditing ? 'Update Medicine' : 'Save Medicine',
                  onPressed: _saveMedicine,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0D9488)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
