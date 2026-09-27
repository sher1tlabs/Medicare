class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final bool takesMedicines;
  final String preferredReminderTime;
  final bool notificationsEnabled;
  final String? profileImageUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    this.takesMedicines = true,
    this.preferredReminderTime = '8:00 AM',
    this.notificationsEnabled = true,
    this.profileImageUrl,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    bool? takesMedicines,
    String? preferredReminderTime,
    bool? notificationsEnabled,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      takesMedicines: takesMedicines ?? this.takesMedicines,
      preferredReminderTime: preferredReminderTime ?? this.preferredReminderTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'takesMedicines': takesMedicines,
      'preferredReminderTime': preferredReminderTime,
      'notificationsEnabled': notificationsEnabled,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      dateOfBirth: DateTime.parse(map['dateOfBirth']),
      takesMedicines: map['takesMedicines'] ?? true,
      preferredReminderTime: map['preferredReminderTime'] ?? '8:00 AM',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      profileImageUrl: map['profileImageUrl'],
    );
  }
}
