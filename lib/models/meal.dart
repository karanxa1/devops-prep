import 'dart:convert';

class Meal {
  final int? id;
  final String name;
  final String description;
  final String category; // breakfast, lunch, dinner, snack
  final List<String> ingredients;
  final String instructions;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final String cuisine;
  final bool isVegetarian;
  final bool isVegan;
  final String imageUrl;
  final bool isFavorite;
  final DateTime createdAt;

  Meal({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.ingredients,
    required this.instructions,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.cuisine,
    required this.isVegetarian,
    required this.isVegan,
    this.imageUrl = '',
    this.isFavorite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'ingredients': jsonEncode(ingredients),
      'instructions': instructions,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'cuisine': cuisine,
      'isVegetarian': isVegetarian ? 1 : 0,
      'isVegan': isVegan ? 1 : 0,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      ingredients: List<String>.from(jsonDecode(map['ingredients'])),
      instructions: map['instructions'],
      calories: map['calories'],
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      prepTimeMinutes: map['prepTimeMinutes'],
      cookTimeMinutes: map['cookTimeMinutes'],
      cuisine: map['cuisine'],
      isVegetarian: map['isVegetarian'] == 1,
      isVegan: map['isVegan'] == 1,
      imageUrl: map['imageUrl'] ?? '',
      isFavorite: map['isFavorite'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'lunch',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: json['instructions'] ?? '',
      calories: json['calories'] ?? 0,
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      prepTimeMinutes: json['prepTimeMinutes'] ?? 15,
      cookTimeMinutes: json['cookTimeMinutes'] ?? 30,
      cuisine: json['cuisine'] ?? '',
      isVegetarian: json['isVegetarian'] ?? false,
      isVegan: json['isVegan'] ?? false,
    );
  }

  Meal copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    List<String>? ingredients,
    String? instructions,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    String? cuisine,
    bool? isVegetarian,
    bool? isVegan,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      cuisine: cuisine ?? this.cuisine,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }
}
