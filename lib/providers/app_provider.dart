import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/meal.dart';
import '../models/meal_plan.dart';
import '../models/daily_log.dart';
import '../models/shopping_item.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final AIService _ai = AIService();

  UserProfile? _userProfile;
  List<Meal> _meals = [];
  List<Meal> _favoriteMeals = [];
  MealPlan? _todayPlan;
  DailyLog? _todayLog;
  List<ShoppingItem> _shoppingItems = [];
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _totalMeals = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile? get userProfile => _userProfile;
  List<Meal> get meals => _meals;
  List<Meal> get favoriteMeals => _favoriteMeals;
  MealPlan? get todayPlan => _todayPlan;
  DailyLog? get todayLog => _todayLog;
  List<ShoppingItem> get shoppingItems => _shoppingItems;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  int get totalMeals => _totalMeals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnboardingComplete => _userProfile?.onboardingComplete ?? false;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // Initialize app data
  Future<void> initialize() async {
    setLoading(true);
    try {
      _userProfile = await _db.getUserProfile();
      if (_userProfile != null && _userProfile!.onboardingComplete) {
        await _loadAllData();
      }
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }

  Future<void> _loadAllData() async {
    _meals = await _db.getMeals();
    _favoriteMeals = await _db.getFavoriteMeals();
    _todayPlan = await _db.getMealPlanForDate(DateTime.now());
    _todayLog = await _db.getDailyLog(DateTime.now());
    _currentStreak = await _db.getCurrentStreak();
    _bestStreak = await _db.getBestStreak();
    _totalMeals = await _db.getTotalMeals();
    _shoppingItems = await _db.getShoppingItems(_getWeekStart());
    notifyListeners();
  }

  DateTime _getWeekStart() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  // User Profile
  Future<void> saveUserProfile(UserProfile profile) async {
    setLoading(true);
    try {
      await _db.saveUserProfile(profile);
      _userProfile = profile;
      if (profile.onboardingComplete) {
        await _loadAllData();
      }
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }

  /// Update user profile (for inline edits, without full reload)
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _db.saveUserProfile(profile);
      _userProfile = profile;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }


  // Meals
  Future<void> addMeal(Meal meal) async {
    try {
      final id = await _db.insertMeal(meal);
      _meals.add(meal.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> updateMeal(Meal meal) async {
    try {
      await _db.updateMeal(meal);
      final index = _meals.indexWhere((m) => m.id == meal.id);
      if (index != -1) {
        _meals[index] = meal;
        notifyListeners();
      }
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> deleteMeal(int id) async {
    try {
      await _db.deleteMeal(id);
      _meals.removeWhere((m) => m.id == id);
      _favoriteMeals.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> toggleFavorite(int id) async {
    try {
      final meal = _meals.firstWhere((m) => m.id == id);
      final newFavorite = !meal.isFavorite;
      await _db.toggleFavorite(id, newFavorite);
      
      final index = _meals.indexWhere((m) => m.id == id);
      _meals[index] = meal.copyWith(isFavorite: newFavorite);
      
      if (newFavorite) {
        _favoriteMeals.add(_meals[index]);
      } else {
        _favoriteMeals.removeWhere((m) => m.id == id);
      }
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  // Meal Plans
  Future<void> saveMealPlan(MealPlan plan) async {
    try {
      await _db.saveMealPlan(plan);
      if (_isSameDay(plan.date, DateTime.now())) {
        _todayPlan = plan;
      }
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<MealPlan?> getMealPlanForDate(DateTime date) async {
    return await _db.getMealPlanForDate(date);
  }

  Future<List<MealPlan>> getMealPlansForWeek(DateTime weekStart) async {
    return await _db.getMealPlansForWeek(weekStart);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Daily Log
  Future<void> logMealCompleted(String mealType, Meal meal) async {
    try {
      final today = DateTime.now();
      var log = _todayLog ?? DailyLog(date: today);
      
      log = log.copyWith(
        mealsCompleted: log.mealsCompleted + 1,
        caloriesConsumed: log.caloriesConsumed + meal.calories,
        proteinConsumed: log.proteinConsumed + meal.protein,
      );
      
      await _db.saveDailyLog(log);
      _todayLog = log;
      _currentStreak = await _db.getCurrentStreak();
      _totalMeals = await _db.getTotalMeals();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  // Shopping List
  Future<void> addShoppingItem(ShoppingItem item) async {
    try {
      final id = await _db.insertShoppingItem(item);
      _shoppingItems.add(item.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> toggleShoppingItem(int id) async {
    try {
      final item = _shoppingItems.firstWhere((i) => i.id == id);
      await _db.toggleShoppingItem(id, !item.isChecked);
      final index = _shoppingItems.indexWhere((i) => i.id == id);
      _shoppingItems[index] = item.copyWith(isChecked: !item.isChecked);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> deleteShoppingItem(int id) async {
    try {
      await _db.deleteShoppingItem(id);
      _shoppingItems.removeWhere((i) => i.id == id);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> clearShoppingList() async {
    try {
      await _db.clearShoppingList(_getWeekStart());
      _shoppingItems.clear();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  // AI Functions
  Future<List<Meal>> generateMealSuggestions({String? mealType, int count = 3}) async {
    if (_userProfile == null) return [];
    setLoading(true);
    try {
      final suggestions = await _ai.generateMealSuggestions(
        _userProfile!,
        mealType: mealType,
        count: count,
      );
      setLoading(false);
      return suggestions;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return [];
    }
  }

  Future<Map<String, List<Meal>>> generateWeeklyMealPlan() async {
    if (_userProfile == null) return {};
    setLoading(true);
    try {
      final plan = await _ai.generateWeeklyMealPlan(_userProfile!);
      
      // Map day names to day indices (0=Monday, 6=Sunday)
      final dayNameToIndex = {
        'monday': 0, 'tuesday': 1, 'wednesday': 2, 'thursday': 3,
        'friday': 4, 'saturday': 5, 'sunday': 6
      };
      
      // Start from today and plan for the next 7 days
      final today = DateTime.now();
      final todayDayOfWeek = (today.weekday - 1) % 7; // 0=Monday, 6=Sunday
      
      // Process each day's meals
      for (final dayName in plan.keys) {
        final targetDayIndex = dayNameToIndex[dayName.toLowerCase()];
        if (targetDayIndex == null) continue;
        
        // Calculate offset from today to reach this day name in the next 7 days
        int daysUntil = (targetDayIndex - todayDayOfWeek) % 7;
        if (daysUntil == 0 && plan.keys.toList().indexOf(dayName) > 0) {
          // If this is not the first day processed and offset is 0, it's next week
          daysUntil = 7;
        }
        
        final dayDate = DateTime(today.year, today.month, today.day + daysUntil);
        final dayMeals = plan[dayName]!;
        
        int? breakfastId, lunchId, dinnerId, snackId;
        
        // Save each meal and get its ID
        for (final meal in dayMeals) {
          final savedId = await _db.insertMeal(meal);
          final savedMeal = meal.copyWith(id: savedId);
          _meals.add(savedMeal);
          
          switch (meal.category.toLowerCase()) {
            case 'breakfast':
              breakfastId = savedId;
              break;
            case 'lunch':
              lunchId = savedId;
              break;
            case 'dinner':
              dinnerId = savedId;
              break;
            case 'snack':
              snackId = savedId;
              break;
          }
        }
        
        // Create meal plan for this day
        final mealPlan = MealPlan(
          date: dayDate,
          breakfastId: breakfastId,
          lunchId: lunchId,
          dinnerId: dinnerId,
          snackId: snackId,
        );
        await _db.saveMealPlan(mealPlan);
      }
      
      notifyListeners();
      setLoading(false);
      return plan;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return {};
    }
  }

  Future<String> chatWithAI(String message) async {
    if (_userProfile == null) return 'Please complete onboarding first.';
    try {
      return await _ai.chat(_userProfile!, message);
    } catch (e) {
      return 'Sorry, I encountered an error: $e';
    }
  }

  /// Streaming chat - yields tokens for real-time display
  Stream<String> chatWithAIStream(String message) {
    if (_userProfile == null) {
      return Stream.value('Please complete onboarding first.');
    }
    return _ai.chatStream(_userProfile!, message);
  }

  Future<void> generateAndSaveShoppingList(List<Meal> meals) async {
    setLoading(true);
    try {
      final items = await _ai.generateShoppingList(meals);
      final weekStart = _getWeekStart();
      
      await _db.clearShoppingList(weekStart);
      _shoppingItems.clear();
      
      for (final item in items) {
        final parts = item.split(':');
        final category = parts.length > 1 ? parts[0].trim() : 'Other';
        final rest = parts.length > 1 ? parts[1].trim() : item;
        
        final shoppingItem = ShoppingItem(
          name: rest,
          quantity: '',
          unit: '',
          category: category,
          weekStart: weekStart,
        );
        await addShoppingItem(shoppingItem);
      }
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }
}
