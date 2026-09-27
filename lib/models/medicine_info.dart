class MedicineInfo {
  final String id;
  final String name;
  final String genericName;
  final String type;
  final String shortDescription;
  final List<String> commonUses;
  final String dosageInfo;
  final List<String> sideEffects;
  final List<String> warnings;
  final String storageInfo;
  final List<String> precautions;

  const MedicineInfo({
    required this.id,
    required this.name,
    required this.genericName,
    required this.type,
    required this.shortDescription,
    required this.commonUses,
    required this.dosageInfo,
    required this.sideEffects,
    required this.warnings,
    required this.storageInfo,
    required this.precautions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'type': type,
      'shortDescription': shortDescription,
      'commonUses': commonUses,
      'dosageInfo': dosageInfo,
      'sideEffects': sideEffects,
      'warnings': warnings,
      'storageInfo': storageInfo,
      'precautions': precautions,
    };
  }

  factory MedicineInfo.fromMap(Map<String, dynamic> map) {
    return MedicineInfo(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      genericName: map['genericName'] ?? '',
      type: map['type'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      commonUses: List<String>.from(map['commonUses'] ?? []),
      dosageInfo: map['dosageInfo'] ?? '',
      sideEffects: List<String>.from(map['sideEffects'] ?? []),
      warnings: List<String>.from(map['warnings'] ?? []),
      storageInfo: map['storageInfo'] ?? '',
      precautions: List<String>.from(map['precautions'] ?? []),
    );
  }
}
