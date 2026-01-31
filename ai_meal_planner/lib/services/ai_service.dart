import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/meal.dart';

class AIService {
  static const String _baseUrl = 'https://api.xiaomimimo.com/v1';
  static const String _apiKey = 'sk-s133awxy1ih71zi82bourhyzf23cvhjlugtdhtzc5rhsphkn';
  static const String _model = 'mimo-v2-flash';

  Future<String> _sendMessage(List<Map<String, dynamic>> messages) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'max_completion_tokens': 4096,
        'temperature': 0.7,
        'top_p': 0.95,
        'stream': false,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ?? '';
    } else {
      throw Exception('AI request failed: ${response.statusCode}');
    }
  }

  String _buildUserContext(UserProfile profile) {
    final dietTypeStr = switch (profile.dietType) {
      DietType.vegetarian => 'vegetarian',
      DietType.vegan => 'vegan',
      DietType.nonVeg => 'non-vegetarian',
      DietType.eggetarian => 'eggetarian (vegetarian + eggs)',
      DietType.pescatarian => 'pescatarian',
    };

    final goalStr = switch (profile.primaryGoal) {
      WeightGoal.lose => 'lose weight',
      WeightGoal.maintain => 'maintain weight',
      WeightGoal.gain => 'gain weight/muscle',
    };

    return '''
User Profile:
- Name: ${profile.name}
- Age: ${profile.age} years
- Gender: ${profile.gender.name}
- Current Weight: ${profile.weightKg} kg
- Target Weight: ${profile.targetWeight} kg
- Height: ${profile.heightCm} cm
- BMI: ${profile.bmi.toStringAsFixed(1)} (${profile.bmiCategory})
- Primary Goal: $goalStr
- Daily Calorie Target: ${profile.dailyCalorieTarget.round()} kcal
- Daily Protein Target: ${profile.dailyProteinTarget.round()}g
- Diet Type: $dietTypeStr
- Allergies: ${profile.allergies.isEmpty ? 'None' : profile.allergies.join(', ')}
- Disliked Foods: ${profile.dislikedFoods.isEmpty ? 'None' : profile.dislikedFoods.join(', ')}
- Preferred Cuisines: ${profile.preferredCuisines.join(', ')}
- Cooking Time Available: ${profile.cookingTimeMinutes} minutes
- Kitchen Setup: ${profile.kitchenSetup}
- Cooking Level: ${profile.cookingLevel.name}
- Weekly Budget: ₹${profile.weeklyBudget.round()}
- Cooking Days Per Week: ${profile.cookingDaysPerWeek}
''';
  }

  Future<List<Meal>> generateMealSuggestions(
    UserProfile profile, {
    String? mealType,
    int count = 3,
  }) async {
    final userContext = _buildUserContext(profile);
    final mealTypeStr = mealType ?? 'any meal';

    final messages = [
      {
        'role': 'system',
        'content': '''You are an expert nutritionist and chef AI assistant. Generate personalized meal suggestions based on user preferences.

IMPORTANT: You must respond with ONLY a valid JSON array of meal objects. No markdown, no explanations, no code blocks.

Each meal object must have these exact fields:
{
  "name": "string",
  "description": "string (2-3 sentences)",
  "category": "breakfast|lunch|dinner|snack",
  "ingredients": ["ingredient 1 with quantity", "ingredient 2 with quantity"],
  "instructions": "string (step by step cooking instructions)",
  "calories": number,
  "protein": number,
  "carbs": number,
  "fat": number,
  "prepTimeMinutes": number,
  "cookTimeMinutes": number,
  "cuisine": "string",
  "isVegetarian": boolean,
  "isVegan": boolean
}'''
      },
      {
        'role': 'user',
        'content': '''$userContext

Generate exactly $count $mealTypeStr suggestions that:
1. Match the user's dietary preferences and restrictions
2. Fit within their daily calorie and protein goals
3. Use ingredients from their preferred cuisines
4. Can be prepared within their cooking time limit
5. Match their cooking skill level
6. Avoid all allergies and disliked foods

Respond with ONLY the JSON array, no other text.'''
      }
    ];

    final response = await _sendMessage(messages);
    
    try {
      String cleanedResponse = response.trim();
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse
            .replaceAll(RegExp(r'^```\w*\n?'), '')
            .replaceAll(RegExp(r'\n?```$'), '');
      }
      
      final List<dynamic> mealsJson = jsonDecode(cleanedResponse);
      return mealsJson.map((json) => Meal.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to parse meal suggestions: $e');
    }
  }

  Future<Map<String, List<Meal>>> generateWeeklyMealPlan(
    UserProfile profile,
  ) async {
    final userContext = _buildUserContext(profile);

    final messages = [
      {
        'role': 'system',
        'content': '''You are an expert nutritionist. Generate a complete weekly meal plan.

IMPORTANT: Respond with ONLY a valid JSON object. No markdown, no explanations.

Format:
{
  "monday": {"breakfast": {...}, "lunch": {...}, "dinner": {...}, "snack": {...}},
  "tuesday": {...},
  ...
}

Each meal object must have:
{
  "name": "string",
  "description": "string",
  "category": "breakfast|lunch|dinner|snack",
  "ingredients": ["ingredient with quantity"],
  "instructions": "string",
  "calories": number,
  "protein": number,
  "carbs": number,
  "fat": number,
  "prepTimeMinutes": number,
  "cookTimeMinutes": number,
  "cuisine": "string",
  "isVegetarian": boolean,
  "isVegan": boolean
}'''
      },
      {
        'role': 'user',
        'content': '''$userContext

Vegetarian days (0=Monday): ${profile.vegDays.map((d) => ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][d]).join(', ')}

Generate a balanced 7-day meal plan that:
1. Distributes daily calories across meals (25% breakfast, 35% lunch, 30% dinner, 10% snack)
2. Ensures variety across the week
3. Uses meal prep efficiently
4. Respects vegetarian days
5. Stays within weekly budget

Respond with ONLY the JSON object.'''
      }
    ];

    final response = await _sendMessage(messages);
    
    try {
      String cleanedResponse = response.trim();
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse
            .replaceAll(RegExp(r'^```\w*\n?'), '')
            .replaceAll(RegExp(r'\n?```$'), '');
      }
      
      final Map<String, dynamic> weekPlan = jsonDecode(cleanedResponse);
      final Map<String, List<Meal>> result = {};
      
      for (final day in weekPlan.keys) {
        final dayMeals = weekPlan[day] as Map<String, dynamic>;
        result[day] = [];
        for (final mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
          if (dayMeals.containsKey(mealType)) {
            result[day]!.add(Meal.fromJson(dayMeals[mealType]));
          }
        }
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to parse weekly meal plan: $e');
    }
  }

  Future<List<String>> generateShoppingList(List<Meal> meals) async {
    final ingredientsList = meals
        .expand((meal) => meal.ingredients)
        .toList();

    final messages = [
      {
        'role': 'system',
        'content': '''You are a helpful assistant that organizes shopping lists.

IMPORTANT: Respond with ONLY a valid JSON array of strings. No markdown, no explanations.

Consolidate and organize the ingredients by category (Produce, Dairy, Proteins, Grains, Spices, etc.).
Format each item as: "Category: Item - quantity"'''
      },
      {
        'role': 'user',
        'content': '''Organize this shopping list:
${ingredientsList.join('\n')}

Consolidate duplicates by adding quantities. Respond with ONLY the JSON array.'''
      }
    ];

    final response = await _sendMessage(messages);
    
    try {
      String cleanedResponse = response.trim();
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse
            .replaceAll(RegExp(r'^```\w*\n?'), '')
            .replaceAll(RegExp(r'\n?```$'), '');
      }
      return List<String>.from(jsonDecode(cleanedResponse));
    } catch (e) {
      return ingredientsList;
    }
  }

  Future<String> chat(UserProfile profile, String userMessage) async {
    final userContext = _buildUserContext(profile);

    final messages = [
      {
        'role': 'system',
        'content': '''You are a friendly AI nutritionist and meal planning assistant. Help users with:
- Meal suggestions and recipes
- Nutrition advice
- Cooking tips
- Dietary guidance
- Shopping and meal prep tips

User's Profile:
$userContext

Be helpful, concise, and personalized to their goals.'''
      },
      {
        'role': 'user',
        'content': userMessage,
      }
    ];

    return await _sendMessage(messages);
  }
}
