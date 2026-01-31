class MealPlan {
  final int? id;
  final DateTime date;
  final int? breakfastId;
  final int? lunchId;
  final int? dinnerId;
  final int? snackId;
  final bool isCompleted;
  final int caloriesConsumed;

  MealPlan({
    this.id,
    required this.date,
    this.breakfastId,
    this.lunchId,
    this.dinnerId,
    this.snackId,
    this.isCompleted = false,
    this.caloriesConsumed = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'breakfastId': breakfastId,
      'lunchId': lunchId,
      'dinnerId': dinnerId,
      'snackId': snackId,
      'isCompleted': isCompleted ? 1 : 0,
      'caloriesConsumed': caloriesConsumed,
    };
  }

  factory MealPlan.fromMap(Map<String, dynamic> map) {
    return MealPlan(
      id: map['id'],
      date: DateTime.parse(map['date']),
      breakfastId: map['breakfastId'],
      lunchId: map['lunchId'],
      dinnerId: map['dinnerId'],
      snackId: map['snackId'],
      isCompleted: map['isCompleted'] == 1,
      caloriesConsumed: map['caloriesConsumed'] ?? 0,
    );
  }

  MealPlan copyWith({
    int? id,
    DateTime? date,
    int? breakfastId,
    int? lunchId,
    int? dinnerId,
    int? snackId,
    bool? isCompleted,
    int? caloriesConsumed,
  }) {
    return MealPlan(
      id: id ?? this.id,
      date: date ?? this.date,
      breakfastId: breakfastId ?? this.breakfastId,
      lunchId: lunchId ?? this.lunchId,
      dinnerId: dinnerId ?? this.dinnerId,
      snackId: snackId ?? this.snackId,
      isCompleted: isCompleted ?? this.isCompleted,
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
    );
  }

  int get totalMeals {
    int count = 0;
    if (breakfastId != null) count++;
    if (lunchId != null) count++;
    if (dinnerId != null) count++;
    if (snackId != null) count++;
    return count;
  }
}
