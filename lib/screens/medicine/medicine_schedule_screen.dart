class MedicineSchedule {
  final String time;
  final String reminderTime;

  MedicineSchedule({required this.time, required this.reminderTime});

  Map<String, dynamic> toJson() {
    return {'time': time, 'reminder_time': reminderTime};
  }
}
