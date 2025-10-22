class MedicationLog {
  final String id;
  final String userMedicationId;
  final String timeSlot; // "morning", "afternoon", "evening", "night"
  final int plannedDose;
  final bool taken;
  final String timestamp;

  MedicationLog({
    required this.id,
    required this.userMedicationId,
    required this.timeSlot,
    required this.plannedDose,
    required this.taken,
    required this.timestamp,
  });

  bool get isTaken => taken;
  bool get isPending => !taken;

  factory MedicationLog.fromJson(Map<String, dynamic> json) {
    return MedicationLog(
      id: json['id'] ?? '',
      userMedicationId: json['user_medication_id'] ?? '',
      timeSlot: json['time_slot'] ?? '',
      plannedDose: json['planned_dose'] ?? 0,
      taken: json['taken'] ?? false,
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_medication_id': userMedicationId,
      'time_slot': timeSlot,
      'planned_dose': plannedDose,
      'taken': taken,
      'timestamp': timestamp,
    };
  }
}

class UserMedicationStats {
  final int totalPills;
  final int usedPills;
  final int remainingPills;
  final int dailyConsumption;
  final int estimatedDaysRemaining;
  final String estimatedEndDate;
  final int plannedDurationDays;
  final int daysElapsed;
  final int plannedDaysRemaining;
  final String warningLevel; // "normal", "low", "critical"

  UserMedicationStats({
    required this.totalPills,
    required this.usedPills,
    required this.remainingPills,
    required this.dailyConsumption,
    required this.estimatedDaysRemaining,
    required this.estimatedEndDate,
    required this.plannedDurationDays,
    required this.daysElapsed,
    required this.plannedDaysRemaining,
    required this.warningLevel,
  });

  factory UserMedicationStats.fromJson(Map<String, dynamic> json) {
    return UserMedicationStats(
      totalPills: json['total_pills'] ?? 0,
      usedPills: json['used_pills'] ?? 0,
      remainingPills: json['remaining_pills'] ?? 0,
      dailyConsumption: json['daily_consumption'] ?? 0,
      estimatedDaysRemaining: json['estimated_days_remaining'] ?? 0,
      estimatedEndDate: json['estimated_end_date'] ?? '',
      plannedDurationDays: json['planned_duration_days'] ?? 0,
      daysElapsed: json['days_elapsed'] ?? 0,
      plannedDaysRemaining: json['planned_days_remaining'] ?? 0,
      warningLevel: json['warning_level'] ?? 'normal',
    );
  }
}
