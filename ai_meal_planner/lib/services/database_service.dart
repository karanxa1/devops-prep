import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';
import '../models/meal.dart';
import '../models/meal_plan.dart';
import '../models/shopping_item.dart';
import '../models/daily_log.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'meal_planner.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gender INTEGER NOT NULL,
        birthDate TEXT NOT NULL,
        heightCm REAL NOT NULL,
        weightKg REAL NOT NULL,
        primaryGoal INTEGER NOT NULL,
        targetWeight REAL NOT NULL,
        weightLossSpeed TEXT NOT NULL,
        activityLevel INTEGER NOT NULL,
        dietType INTEGER NOT NULL,
        allergies TEXT NOT NULL,
        dislikedFoods TEXT NOT NULL,
        preferredCuisines TEXT NOT NULL,
        healthGoal TEXT NOT NULL,
        cookingTimeMinutes INTEGER NOT NULL,
        kitchenSetup TEXT NOT NULL,
        cookingDaysPerWeek INTEGER NOT NULL,
        vegDays TEXT NOT NULL,
        weeklyBudget REAL NOT NULL,
        cookingLevel INTEGER NOT NULL,
        onboardingComplete INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        instructions TEXT NOT NULL,
        calories INTEGER NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        prepTimeMinutes INTEGER NOT NULL,
        cookTimeMinutes INTEGER NOT NULL,
        cuisine TEXT NOT NULL,
        isVegetarian INTEGER NOT NULL DEFAULT 0,
        isVegan INTEGER NOT NULL DEFAULT 0,
        imageUrl TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE meal_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        breakfastId INTEGER,
        lunchId INTEGER,
        dinnerId INTEGER,
        snackId INTEGER,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        caloriesConsumed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE shopping_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity TEXT NOT NULL,
        unit TEXT NOT NULL,
        category TEXT NOT NULL,
        isChecked INTEGER NOT NULL DEFAULT 0,
        weekStart TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        caloriesConsumed INTEGER NOT NULL DEFAULT 0,
        proteinConsumed REAL NOT NULL DEFAULT 0,
        mealsCompleted INTEGER NOT NULL DEFAULT 0,
        totalMeals INTEGER NOT NULL DEFAULT 4,
        waterGlasses INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // User Profile Operations
  Future<int> saveUserProfile(UserProfile profile) async {
    final db = await database;
    final existing = await getUserProfile();
    if (existing != null) {
      return await db.update(
        'user_profile',
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
    return await db.insert('user_profile', profile.toMap());
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final maps = await db.query('user_profile', limit: 1);
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  // Meal Operations
  Future<int> insertMeal(Meal meal) async {
    final db = await database;
    return await db.insert('meals', meal.toMap());
  }

  Future<List<Meal>> getMeals({String? category}) async {
    final db = await database;
    final maps = category != null
        ? await db.query('meals', where: 'category = ?', whereArgs: [category])
        : await db.query('meals');
    return maps.map((m) => Meal.fromMap(m)).toList();
  }

  Future<Meal?> getMealById(int id) async {
    final db = await database;
    final maps = await db.query('meals', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Meal.fromMap(maps.first);
  }

  Future<List<Meal>> getFavoriteMeals() async {
    final db = await database;
    final maps = await db.query('meals', where: 'isFavorite = 1');
    return maps.map((m) => Meal.fromMap(m)).toList();
  }

  Future<int> updateMeal(Meal meal) async {
    final db = await database;
    return await db.update('meals', meal.toMap(),
        where: 'id = ?', whereArgs: [meal.id]);
  }

  Future<int> deleteMeal(int id) async {
    final db = await database;
    return await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'meals',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Meal Plan Operations
  Future<int> saveMealPlan(MealPlan plan) async {
    final db = await database;
    final dateStr = plan.date.toIso8601String().split('T')[0];
    final existing = await db.query('meal_plans',
        where: 'date = ?', whereArgs: [dateStr]);
    if (existing.isNotEmpty) {
      return await db.update('meal_plans', plan.toMap(),
          where: 'date = ?', whereArgs: [dateStr]);
    }
    return await db.insert('meal_plans', plan.toMap());
  }

  Future<MealPlan?> getMealPlanForDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final maps = await db.query('meal_plans',
        where: 'date = ?', whereArgs: [dateStr]);
    if (maps.isEmpty) return null;
    return MealPlan.fromMap(maps.first);
  }

  Future<List<MealPlan>> getMealPlansForWeek(DateTime weekStart) async {
    final db = await database;
    final startStr = weekStart.toIso8601String().split('T')[0];
    final endStr = weekStart.add(const Duration(days: 7)).toIso8601String().split('T')[0];
    final maps = await db.query('meal_plans',
        where: 'date >= ? AND date < ?', whereArgs: [startStr, endStr]);
    return maps.map((m) => MealPlan.fromMap(m)).toList();
  }

  // Shopping Items Operations
  Future<int> insertShoppingItem(ShoppingItem item) async {
    final db = await database;
    return await db.insert('shopping_items', item.toMap());
  }

  Future<List<ShoppingItem>> getShoppingItems(DateTime weekStart) async {
    final db = await database;
    final weekStr = weekStart.toIso8601String().split('T')[0];
    final maps = await db.query('shopping_items',
        where: 'weekStart = ?', whereArgs: [weekStr]);
    return maps.map((m) => ShoppingItem.fromMap(m)).toList();
  }

  Future<int> toggleShoppingItem(int id, bool isChecked) async {
    final db = await database;
    return await db.update(
      'shopping_items',
      {'isChecked': isChecked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteShoppingItem(int id) async {
    final db = await database;
    return await db.delete('shopping_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearShoppingList(DateTime weekStart) async {
    final db = await database;
    final weekStr = weekStart.toIso8601String().split('T')[0];
    await db.delete('shopping_items', where: 'weekStart = ?', whereArgs: [weekStr]);
  }

  // Daily Log Operations
  Future<int> saveDailyLog(DailyLog log) async {
    final db = await database;
    final dateStr = log.date.toIso8601String().split('T')[0];
    final existing = await db.query('daily_logs',
        where: 'date = ?', whereArgs: [dateStr]);
    if (existing.isNotEmpty) {
      return await db.update('daily_logs', log.toMap(),
          where: 'date = ?', whereArgs: [dateStr]);
    }
    return await db.insert('daily_logs', log.toMap());
  }

  Future<DailyLog?> getDailyLog(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final maps = await db.query('daily_logs',
        where: 'date = ?', whereArgs: [dateStr]);
    if (maps.isEmpty) return null;
    return DailyLog.fromMap(maps.first);
  }

  Future<int> getCurrentStreak() async {
    final db = await database;
    final logs = await db.query('daily_logs',
        orderBy: 'date DESC', where: 'mealsCompleted > 0');
    if (logs.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (final log in logs) {
      final logDate = DateTime.parse(log['date'] as String);
      final diff = checkDate.difference(logDate).inDays;

      if (diff <= 1) {
        streak++;
        checkDate = logDate;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<int> getBestStreak() async {
    final db = await database;
    final logs = await db.query('daily_logs',
        orderBy: 'date ASC', where: 'mealsCompleted > 0');
    if (logs.isEmpty) return 0;

    int bestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final log in logs) {
      final logDate = DateTime.parse(log['date'] as String);
      if (lastDate == null || logDate.difference(lastDate).inDays == 1) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }
      if (currentStreak > bestStreak) bestStreak = currentStreak;
      lastDate = logDate;
    }
    return bestStreak;
  }

  Future<int> getTotalMeals() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM(mealsCompleted) as total FROM daily_logs');
    return (result.first['total'] as int?) ?? 0;
  }
}
