class Medicine {
  final int id;
  final int userId;
  final String name;
  final String dose;
  final String time;
  final int duration;
  final bool taken;
  final DateTime? takenAt;
  final String? description;
  final String? reminderTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<dynamic>? schedules;

  Medicine({
    required this.id,
    required this.userId,
    required this.name,
    required this.dose,
    required this.time,
    required this.duration,
    required this.taken,
    this.takenAt,
    this.description,
    this.reminderTime,
    this.createdAt,
    this.updatedAt,
    this.schedules,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 1,
      name: json['name'] ?? '',
      dose: json['dose'] ?? '',
      time: json['time'] ?? '',
      duration: json['duration'] ?? 0,
      taken: json['taken'] ?? false,
      takenAt:
          json['taken_at'] != null ? DateTime.parse(json['taken_at']) : null,
      description: json['description'],
      reminderTime: json['reminder_time'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      schedules: json['schedules'],
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final data = {
      'user_id': userId,
      'name': name,
      'dose': dose,
      'time': time,
      'duration': duration,
      'taken': taken,
      'taken_at': takenAt?.toIso8601String(),
      'description': description,
      'reminder_time': reminderTime,
    };
    if (includeId) {
      data['id'] = id;
    }
    return data;
  }
}
