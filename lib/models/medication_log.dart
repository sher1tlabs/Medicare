enum LogStatus {
  taken,
  skipped,
  upcoming,
}

class MedicationLog {
  final String id;
  final String medicineId;
  final String medicineName;
  final String dosage;
  final String scheduledTime;
  final String? actualTime;
  final LogStatus status;
  final DateTime date;

  const MedicationLog({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.scheduledTime,
    this.actualTime,
    required this.status,
    required this.date,
  });

  MedicationLog copyWith({
    String? id,
    String? medicineId,
    String? medicineName,
    String? dosage,
    String? scheduledTime,
    String? actualTime,
    LogStatus? status,
    DateTime? date,
  }) {
    return MedicationLog(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualTime: actualTime ?? this.actualTime,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'dosage': dosage,
      'scheduledTime': scheduledTime,
      'actualTime': actualTime,
      'status': status.name,
      'date': date.toIso8601String(),
    };
  }

  factory MedicationLog.fromMap(Map<String, dynamic> map) {
    return MedicationLog(
      id: map['id'] ?? '',
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      dosage: map['dosage'] ?? '',
      scheduledTime: map['scheduledTime'] ?? '',
      actualTime: map['actualTime'],
      status: LogStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LogStatus.upcoming,
      ),
      date: DateTime.parse(map['date']),
    );
  }
}
