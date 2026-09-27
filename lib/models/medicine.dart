class Medicine {
  final String id;
  final String name;
  final String genericName;
  final String type; // Tablet, Capsule, Syrup, Injection, Cream, Drops, Other
  final String strength; // e.g. "500 mg"
  final String dosage; // e.g. "1 tablet"
  final String frequency; // Once daily, Twice daily, Three times daily, Every X hours, Weekly, Custom
  final List<String> reminderTimes; // e.g. ["8:00 AM", "2:00 PM"]
  final DateTime startDate;
  final DateTime? endDate;
  final String instructions; // e.g. "Take after food"
  final String notes;
  final bool isActive;
  final bool remindersEnabled;

  const Medicine({
    required this.id,
    required this.name,
    this.genericName = '',
    required this.type,
    required this.strength,
    required this.dosage,
    required this.frequency,
    required this.reminderTimes,
    required this.startDate,
    this.endDate,
    this.instructions = '',
    this.notes = '',
    this.isActive = true,
    this.remindersEnabled = true,
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? genericName,
    String? type,
    String? strength,
    String? dosage,
    String? frequency,
    List<String>? reminderTimes,
    DateTime? startDate,
    DateTime? endDate,
    String? instructions,
    String? notes,
    bool? isActive,
    bool? remindersEnabled,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      type: type ?? this.type,
      strength: strength ?? this.strength,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      instructions: instructions ?? this.instructions,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'type': type,
      'strength': strength,
      'dosage': dosage,
      'frequency': frequency,
      'reminderTimes': reminderTimes,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'instructions': instructions,
      'notes': notes,
      'isActive': isActive,
      'remindersEnabled': remindersEnabled,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      genericName: map['genericName'] ?? '',
      type: map['type'] ?? 'Tablet',
      strength: map['strength'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? 'Once daily',
      reminderTimes: List<String>.from(map['reminderTimes'] ?? []),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      instructions: map['instructions'] ?? '',
      notes: map['notes'] ?? '',
      isActive: map['isActive'] ?? true,
      remindersEnabled: map['remindersEnabled'] ?? true,
    );
  }
}
