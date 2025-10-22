class Medication {
  final String id;
  final String name;
  final String description;
  final String manufacturer;
  final String form;
  final int strengthMg;
  final int pillsPerBox;
  final String mealRelation; // "before_meal" or "after_meal"
  final String createdAt;

  Medication({
    required this.id,
    required this.name,
    required this.description,
    required this.manufacturer,
    required this.form,
    required this.strengthMg,
    required this.pillsPerBox,
    required this.mealRelation,
    required this.createdAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      form: json['form'] ?? '',
      strengthMg: json['strength_mg'] ?? 0,
      pillsPerBox: json['pills_per_box'] ?? 0,
      mealRelation: json['meal_relation'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'manufacturer': manufacturer,
      'form': form,
      'strength_mg': strengthMg,
      'pills_per_box': pillsPerBox,
      'meal_relation': mealRelation,
      'created_at': createdAt,
    };
  }
}

class MedicationCreateRequest {
  final String name;
  final String description;
  final String manufacturer;
  final String form;
  final int strengthMg;
  final int pillsPerBox;
  final String mealRelation;

  MedicationCreateRequest({
    required this.name,
    required this.description,
    required this.manufacturer,
    required this.form,
    required this.strengthMg,
    required this.pillsPerBox,
    required this.mealRelation,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'manufacturer': manufacturer,
      'form': form,
      'strength_mg': strengthMg,
      'pills_per_box': pillsPerBox,
      'meal_relation': mealRelation,
    };
  }
}
