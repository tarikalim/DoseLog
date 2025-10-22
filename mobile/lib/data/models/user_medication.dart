import 'medication.dart';

class MedicationSchedule {
  final String timeSlot; // "morning", "noon", "evening", "night"
  final double doseAmount;

  MedicationSchedule({
    required this.timeSlot,
    required this.doseAmount,
  });

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) {
    return MedicationSchedule(
      timeSlot: json['time_slot'] ?? '',
      doseAmount: (json['dose_amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_slot': timeSlot,
      'dose_amount': doseAmount,
    };
  }
}

class UserMedication {
  final String id;
  final String userId;
  final String medicationId;
  final int boxesOwned;
  final List<MedicationSchedule> schedules;
  final int durationDays;
  final String startAt;
  final bool active;
  final String createdAt;
  final Medication? medication;

  UserMedication({
    required this.id,
    required this.userId,
    required this.medicationId,
    required this.boxesOwned,
    required this.schedules,
    required this.durationDays,
    required this.startAt,
    required this.active,
    required this.createdAt,
    this.medication,
  });

  factory UserMedication.fromJson(Map<String, dynamic> json) {
    return UserMedication(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      medicationId: json['medication_id'] ?? '',
      boxesOwned: json['boxes_owned'] ?? 0,
      schedules: json['schedules'] != null
          ? (json['schedules'] as List)
              .map((s) => MedicationSchedule.fromJson(s))
              .toList()
          : [],
      durationDays: json['duration_days'] ?? 0,
      startAt: json['start_at'] ?? '',
      active: json['active'] ?? false,
      createdAt: json['created_at'] ?? '',
      medication: json['medication'] != null
          ? Medication.fromJson(json['medication'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'medication_id': medicationId,
      'boxes_owned': boxesOwned,
      'schedules': schedules.map((s) => s.toJson()).toList(),
      'duration_days': durationDays,
      'start_at': startAt,
      'active': active,
      'created_at': createdAt,
      if (medication != null) 'medication': medication!.toJson(),
    };
  }
}

class UserMedicationCreateRequest {
  final String medicationId;
  final int boxesOwned;
  final List<MedicationSchedule> schedules;
  final int durationDays;

  UserMedicationCreateRequest({
    required this.medicationId,
    required this.boxesOwned,
    required this.schedules,
    required this.durationDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'medication_id': medicationId,
      'boxes_owned': boxesOwned,
      'schedules': schedules.map((s) => s.toJson()).toList(),
      'duration_days': durationDays,
    };
  }
}
