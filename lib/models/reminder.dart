class Reminder {
  final String id;
  final String medicineId;
  final String medicineName;
  final String type;
  final String dosage;
  final String time;
  final bool isTaken;
  final bool isSkipped;
  final DateTime? snoozedUntil;

  const Reminder({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.type,
    required this.dosage,
    required this.time,
    this.isTaken = false,
    this.isSkipped = false,
    this.snoozedUntil,
  });

  Reminder copyWith({
    String? id,
    String? medicineId,
    String? medicineName,
    String? type,
    String? dosage,
    String? time,
    bool? isTaken,
    bool? isSkipped,
    DateTime? snoozedUntil,
  }) {
    return Reminder(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      type: type ?? this.type,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      isTaken: isTaken ?? this.isTaken,
      isSkipped: isSkipped ?? this.isSkipped,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'type': type,
      'dosage': dosage,
      'time': time,
      'isTaken': isTaken,
      'isSkipped': isSkipped,
      'snoozedUntil': snoozedUntil?.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] ?? '',
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      type: map['type'] ?? 'Tablet',
      dosage: map['dosage'] ?? '',
      time: map['time'] ?? '',
      isTaken: map['isTaken'] ?? false,
      isSkipped: map['isSkipped'] ?? false,
      snoozedUntil: map['snoozedUntil'] != null
          ? DateTime.parse(map['snoozedUntil'])
          : null,
    );
  }
}
