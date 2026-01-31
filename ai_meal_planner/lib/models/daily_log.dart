class DailyLog {
  final int? id;
  final DateTime date;
  final int caloriesConsumed;
  final double proteinConsumed;
  final int mealsCompleted;
  final int totalMeals;
  final int waterGlasses;

  DailyLog({
    this.id,
    required this.date,
    this.caloriesConsumed = 0,
    this.proteinConsumed = 0,
    this.mealsCompleted = 0,
    this.totalMeals = 4,
    this.waterGlasses = 0,
  });

  double get completionPercentage =>
      totalMeals > 0 ? (mealsCompleted / totalMeals) * 100 : 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'caloriesConsumed': caloriesConsumed,
      'proteinConsumed': proteinConsumed,
      'mealsCompleted': mealsCompleted,
      'totalMeals': totalMeals,
      'waterGlasses': waterGlasses,
    };
  }

  factory DailyLog.fromMap(Map<String, dynamic> map) {
    return DailyLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      caloriesConsumed: map['caloriesConsumed'] ?? 0,
      proteinConsumed: (map['proteinConsumed'] ?? 0).toDouble(),
      mealsCompleted: map['mealsCompleted'] ?? 0,
      totalMeals: map['totalMeals'] ?? 4,
      waterGlasses: map['waterGlasses'] ?? 0,
    );
  }

  DailyLog copyWith({
    int? id,
    DateTime? date,
    int? caloriesConsumed,
    double? proteinConsumed,
    int? mealsCompleted,
    int? totalMeals,
    int? waterGlasses,
  }) {
    return DailyLog(
      id: id ?? this.id,
      date: date ?? this.date,
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      proteinConsumed: proteinConsumed ?? this.proteinConsumed,
      mealsCompleted: mealsCompleted ?? this.mealsCompleted,
      totalMeals: totalMeals ?? this.totalMeals,
      waterGlasses: waterGlasses ?? this.waterGlasses,
    );
  }
}
