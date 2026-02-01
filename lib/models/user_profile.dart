import 'dart:convert';

enum Gender { male, female, other }
enum WeightGoal { lose, maintain, gain }
enum ActivityLevel { sedentary, light, moderate, active, veryActive }
enum DietType { vegetarian, vegan, nonVeg, eggetarian, pescatarian }
enum CookingLevel { beginner, intermediate, advanced }

class UserProfile {
  final int? id;
  final String name;
  final Gender gender;
  final DateTime birthDate;
  final double heightCm;
  final double weightKg;
  final WeightGoal primaryGoal;
  final double targetWeight;
  final String weightLossSpeed; // slow, moderate, fast
  final ActivityLevel activityLevel;
  final DietType dietType;
  final List<String> allergies;
  final List<String> dislikedFoods;
  final List<String> preferredCuisines;
  final String healthGoal;
  final int cookingTimeMinutes;
  final String kitchenSetup; // basic, intermediate, full
  final int cookingDaysPerWeek;
  final List<int> vegDays; // 0=Mon, 1=Tue, etc.
  final double weeklyBudget;
  final CookingLevel cookingLevel;
  final bool onboardingComplete;
  final DateTime createdAt;

  UserProfile({
    this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
    required this.primaryGoal,
    required this.targetWeight,
    required this.weightLossSpeed,
    required this.activityLevel,
    required this.dietType,
    required this.allergies,
    required this.dislikedFoods,
    required this.preferredCuisines,
    required this.healthGoal,
    required this.cookingTimeMinutes,
    required this.kitchenSetup,
    required this.cookingDaysPerWeek,
    required this.vegDays,
    required this.weeklyBudget,
    required this.cookingLevel,
    this.onboardingComplete = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  double get dailyCalorieTarget {
    // Mifflin-St Jeor Equation
    double bmr;
    if (gender == Gender.male) {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }

    double activityMultiplier = switch (activityLevel) {
      ActivityLevel.sedentary => 1.2,
      ActivityLevel.light => 1.375,
      ActivityLevel.moderate => 1.55,
      ActivityLevel.active => 1.725,
      ActivityLevel.veryActive => 1.9,
    };

    double tdee = bmr * activityMultiplier;

    return switch (primaryGoal) {
      WeightGoal.lose => tdee - 500,
      WeightGoal.gain => tdee + 500,
      WeightGoal.maintain => tdee,
    };
  }

  double get dailyProteinTarget {
    return switch (primaryGoal) {
      WeightGoal.lose => weightKg * 2.0,
      WeightGoal.gain => weightKg * 2.2,
      WeightGoal.maintain => weightKg * 1.6,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender.index,
      'birthDate': birthDate.toIso8601String(),
      'heightCm': heightCm,
      'weightKg': weightKg,
      'primaryGoal': primaryGoal.index,
      'targetWeight': targetWeight,
      'weightLossSpeed': weightLossSpeed,
      'activityLevel': activityLevel.index,
      'dietType': dietType.index,
      'allergies': jsonEncode(allergies),
      'dislikedFoods': jsonEncode(dislikedFoods),
      'preferredCuisines': jsonEncode(preferredCuisines),
      'healthGoal': healthGoal,
      'cookingTimeMinutes': cookingTimeMinutes,
      'kitchenSetup': kitchenSetup,
      'cookingDaysPerWeek': cookingDaysPerWeek,
      'vegDays': jsonEncode(vegDays),
      'weeklyBudget': weeklyBudget,
      'cookingLevel': cookingLevel.index,
      'onboardingComplete': onboardingComplete ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      gender: Gender.values[map['gender']],
      birthDate: DateTime.parse(map['birthDate']),
      heightCm: map['heightCm'],
      weightKg: map['weightKg'],
      primaryGoal: WeightGoal.values[map['primaryGoal']],
      targetWeight: map['targetWeight'],
      weightLossSpeed: map['weightLossSpeed'],
      activityLevel: ActivityLevel.values[map['activityLevel']],
      dietType: DietType.values[map['dietType']],
      allergies: List<String>.from(jsonDecode(map['allergies'])),
      dislikedFoods: List<String>.from(jsonDecode(map['dislikedFoods'])),
      preferredCuisines: List<String>.from(jsonDecode(map['preferredCuisines'])),
      healthGoal: map['healthGoal'],
      cookingTimeMinutes: map['cookingTimeMinutes'],
      kitchenSetup: map['kitchenSetup'],
      cookingDaysPerWeek: map['cookingDaysPerWeek'],
      vegDays: List<int>.from(jsonDecode(map['vegDays'])),
      weeklyBudget: map['weeklyBudget'],
      cookingLevel: CookingLevel.values[map['cookingLevel']],
      onboardingComplete: map['onboardingComplete'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  UserProfile copyWith({
    int? id,
    String? name,
    Gender? gender,
    DateTime? birthDate,
    double? heightCm,
    double? weightKg,
    WeightGoal? primaryGoal,
    double? targetWeight,
    String? weightLossSpeed,
    ActivityLevel? activityLevel,
    DietType? dietType,
    List<String>? allergies,
    List<String>? dislikedFoods,
    List<String>? preferredCuisines,
    String? healthGoal,
    int? cookingTimeMinutes,
    String? kitchenSetup,
    int? cookingDaysPerWeek,
    List<int>? vegDays,
    double? weeklyBudget,
    CookingLevel? cookingLevel,
    bool? onboardingComplete,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      targetWeight: targetWeight ?? this.targetWeight,
      weightLossSpeed: weightLossSpeed ?? this.weightLossSpeed,
      activityLevel: activityLevel ?? this.activityLevel,
      dietType: dietType ?? this.dietType,
      allergies: allergies ?? this.allergies,
      dislikedFoods: dislikedFoods ?? this.dislikedFoods,
      preferredCuisines: preferredCuisines ?? this.preferredCuisines,
      healthGoal: healthGoal ?? this.healthGoal,
      cookingTimeMinutes: cookingTimeMinutes ?? this.cookingTimeMinutes,
      kitchenSetup: kitchenSetup ?? this.kitchenSetup,
      cookingDaysPerWeek: cookingDaysPerWeek ?? this.cookingDaysPerWeek,
      vegDays: vegDays ?? this.vegDays,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      cookingLevel: cookingLevel ?? this.cookingLevel,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      createdAt: createdAt,
    );
  }
}
