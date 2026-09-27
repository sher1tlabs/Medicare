import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';
import '../../models/medicine.dart';
import '../../widgets/medicine_card.dart';
import '../../widgets/empty_state_widget.dart';
import 'add_medicine_screen.dart';
import 'medicine_details_screen.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  final LocalStorageService _service = LocalStorageService();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // All, Active, Paused, Completed

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

  List<Medicine> _getFilteredMedicines() {
    return _service.medicines.where((med) {
      // Search filter
      final matchesSearch = med.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          med.genericName.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      // Status filter
      if (_selectedFilter == 'Active') return med.isActive;
      if (_selectedFilter == 'Paused') return !med.isActive;
      if (_selectedFilter == 'Completed') {
        return med.endDate != null && med.endDate!.isBefore(DateTime.now());
      }
      return true;
    }).toList();
  }

  void _confirmDelete(Medicine med) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this medicine?'),
        content: Text('This will remove "${med.name}" and all associated reminders and logs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _service.deleteMedicine(med.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${med.name} deleted')),
              );
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
    final filtered = _getFilteredMedicines();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medicines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF0D9488), size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search medicines...',
                  prefixIcon: const Icon(Icons.search, size: 22, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: ['All', 'Active', 'Paused', 'Completed'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: const Color(0xFFCCFBF1),
                      labelStyle: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? const Color(0xFF0D9488) : const Color(0xFF64748B),
                      ),
                      onSelected: (_) => setState(() => _selectedFilter = filter),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Medicines List or Empty State
            Expanded(
              child: filtered.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.medication_outlined,
                      title: _searchQuery.isNotEmpty
                          ? 'No results found'
                          : 'No medicines added yet.',
                      description: _searchQuery.isNotEmpty
                          ? 'Try searching with another name or clearing filters.'
                          : 'Keep track of doses, schedules, and reminders by adding your first medicine.',
                      buttonText: _searchQuery.isNotEmpty ? null : 'Add Your First Medicine',
                      onButtonPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
                        );
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final med = filtered[index];
                        return MedicineCard(
                          medicine: med,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MedicineDetailsScreen(medicineId: med.id),
                              ),
                            );
                          },
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddMedicineScreen(editingMedicine: med),
                              ),
                            );
                          },
                          onToggleActive: () => _service.toggleMedicineActive(med.id),
                          onDelete: () => _confirmDelete(med),
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
