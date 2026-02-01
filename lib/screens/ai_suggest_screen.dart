import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/meal.dart';
import '../providers/app_provider.dart';

class AISuggestScreen extends StatefulWidget {
  const AISuggestScreen({super.key});

  @override
  State<AISuggestScreen> createState() => _AISuggestScreenState();
}

class _AISuggestScreenState extends State<AISuggestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _chatMessages = [];
  
  String _selectedMealType = 'any';
  List<Meal> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load saved meals from database on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedMeals();
    });
  }

  Future<void> _loadSavedMeals() async {
    final provider = context.read<AppProvider>();
    final meals = provider.meals;
    if (meals.isNotEmpty) {
      setState(() {
        _suggestions = meals.take(10).toList(); // Show last 10 saved meals
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getSuggestions() async {
    setState(() => _isLoading = true);

    final provider = context.read<AppProvider>();
    final meals = await provider.generateMealSuggestions(
      mealType: _selectedMealType == 'any' ? null : _selectedMealType,
    );

    setState(() {
      _suggestions = meals;
      _isLoading = false;
    });
  }

  Future<void> _sendMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    _chatController.clear();
    setState(() {
      _chatMessages.add({'role': 'user', 'content': message});
      _chatMessages.add({'role': 'assistant', 'content': ''}); // Placeholder for streaming
      _isLoading = true;
    });

    _scrollToBottom();

    final provider = context.read<AppProvider>();
    final responseIndex = _chatMessages.length - 1;
    String fullResponse = '';
    
    try {
      await for (final token in provider.chatWithAIStream(message)) {
        fullResponse += token;
        if (mounted) {
          setState(() {
            _chatMessages[responseIndex]['content'] = fullResponse;
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      fullResponse = 'Sorry, I encountered an error: $e';
      if (mounted) {
        setState(() {
          _chatMessages[responseIndex]['content'] = fullResponse;
        });
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.bgGradientStart, AppTheme.bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.purpleGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'AI Assistant',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: AppTheme.accentPurple, size: 18),
                          const SizedBox(width: 4),
                          const Text('MiMo AI', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: AppTheme.purpleGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentPurple.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lightbulb_rounded, size: 18),
                          const SizedBox(width: 8),
                          const Text('Meal Ideas'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_rounded, size: 18),
                          const SizedBox(width: 8),
                          const Text('Chat'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMealIdeasTab(),
                    _buildChatTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealIdeasTab() {
    final mealTypes = [
      {'type': 'any', 'label': 'All', 'emoji': '🍽️'},
      {'type': 'breakfast', 'label': 'Breakfast', 'emoji': '🌅'},
      {'type': 'lunch', 'label': 'Lunch', 'emoji': '☀️'},
      {'type': 'dinner', 'label': 'Dinner', 'emoji': '🌙'},
      {'type': 'snack', 'label': 'Snack', 'emoji': '🍪'},
    ];

    return Column(
      children: [
        // Meal type selector
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: mealTypes.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final type = mealTypes[index];
              final isSelected = _selectedMealType == type['type'];
              return GestureDetector(
                onTap: () => setState(() => _selectedMealType = type['type']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.primaryGradient : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppTheme.primaryOrange.withValues(alpha: 0.3), blurRadius: 10)]
                        : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
                  ),
                  child: Row(
                    children: [
                      Text(type['emoji']!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        type['label']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Generate button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppTheme.purpleGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentPurple.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _getSuggestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.auto_awesome_rounded),
                  const SizedBox(width: 8),
                  Text(_isLoading ? 'Generating Ideas...' : 'Get AI Suggestions'),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Suggestions list
        Expanded(
          child: _suggestions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return AnimatedListItem(
                      index: index,
                      child: _buildMealCard(_suggestions[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.purpleGradient.scale(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant_menu_rounded, size: 48, color: AppTheme.accentPurple),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ready to discover meals? ✨',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button above to get AI-powered suggestions',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(Meal meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _showMealDetails(meal),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (meal.isVegetarian)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('🥬 Veg', style: TextStyle(color: Colors.white, fontSize: 11)),
                                ),
                              Text(
                                meal.cuisine,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 20),
                          const SizedBox(height: 2),
                          Text(
                            '${meal.calories}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.description,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Use Wrap to prevent overflow on narrow screens
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildMealTag(Icons.timer_rounded, '${meal.totalTimeMinutes} min', AppTheme.accentBlue),
                        _buildMealTag(Icons.fitness_center_rounded, '${meal.protein.round()}g', AppTheme.accentPurple),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.touch_app_rounded, size: 14, color: AppTheme.primaryOrange),
                              const SizedBox(width: 4),
                              Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryOrange)),
                            ],
                          ),
                        ),
                        // Quick Save Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await context.read<AppProvider>().addMeal(meal);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Colors.white),
                                        const SizedBox(width: 8),
                                        const Text('Meal saved! 🎉'),
                                      ],
                                    ),
                                    backgroundColor: AppTheme.successGreen,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.bookmark_add_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMealDetails(Meal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meal.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 4),
                              Text('${meal.calories} kcal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (meal.isVegetarian)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('🥬 Vegetarian', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(meal.cuisine, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Nutrition info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNutritionPill('🔥 ${meal.calories}', 'Calories'),
                        _buildNutritionPill('💪 ${meal.protein.round()}g', 'Protein'),
                        _buildNutritionPill('🌾 ${meal.carbs.round()}g', 'Carbs'),
                        _buildNutritionPill('🧈 ${meal.fat.round()}g', 'Fat'),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Time info
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            Icons.timer_outlined,
                            'Prep Time',
                            '${meal.prepTimeMinutes} min',
                            AppTheme.accentBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            Icons.restaurant_rounded,
                            'Cook Time',
                            '${meal.cookTimeMinutes} min',
                            AppTheme.accentPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Description
                    Text(
                      meal.description,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    // Ingredients
                    if (meal.ingredients.isNotEmpty) ...[
                      _buildSectionHeader(Icons.shopping_basket_rounded, 'Ingredients', AppTheme.successGreen),
                      const SizedBox(height: 12),
                      ...meal.ingredients.map((ingredient) => _buildIngredientItem(ingredient)),
                      const SizedBox(height: 24),
                    ],
                    // Instructions
                    if (meal.instructions.isNotEmpty) ...[
                      _buildSectionHeader(Icons.menu_book_rounded, 'Instructions', AppTheme.primaryOrange),
                      const SizedBox(height: 12),
                      _buildInstructionsCard(meal.instructions),
                      const SizedBox(height: 24),
                    ],
                    // Save button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          await context.read<AppProvider>().addMeal(meal);
                          
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text('${meal.name} added to meal plan! 🎉'),
                                ],
                              ),
                              backgroundColor: AppTheme.successGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add to Meal Plan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionPill(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(String ingredient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.successGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(String instructions) {
    final steps = instructions.split('\n').where((s) => s.trim().isNotEmpty).toList();
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryOrange.withValues(alpha: 0.08),
            AppTheme.primaryOrange.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cooking Steps',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${steps.length} steps',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          // Steps
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value.trim();
                // Remove leading numbers/dots if present
                final cleanStep = step.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '');
                final isLast = index == steps.length - 1;
                
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step indicator with connecting line
                        Column(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 20,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryOrange.withValues(alpha: 0.5),
                                      AppTheme.primaryOrange.withValues(alpha: 0.1),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        // Step content
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(top: 6, bottom: 12),
                            child: Text(
                              cleanStep,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        // Chat messages
        Expanded(
          child: _chatMessages.isEmpty
              ? _buildChatEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _chatMessages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _chatMessages.length && _isLoading) {
                      return _buildTypingIndicator();
                    }
                    return _buildChatBubble(_chatMessages[index]);
                  },
                ),
        ),

        // Quick prompts
        if (_chatMessages.isEmpty)
          Container(
            height: 45,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildQuickPrompt('🍎 Healthy breakfast ideas'),
                _buildQuickPrompt('🥗 Low calorie dinner'),
                _buildQuickPrompt('💪 High protein snacks'),
                _buildQuickPrompt('🌱 Vegetarian meals'),
              ],
            ),
          ),

        // Input area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Ask about nutrition, recipes...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _isLoading ? null : _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: AppTheme.purpleGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentPurple.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isLoading ? Icons.hourglass_top_rounded : Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.purpleGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentPurple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.chat_rounded, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your AI Nutrition Assistant 🤖',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Ask me anything about food, nutrition, or recipes!',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompt(String text) {
    return GestureDetector(
      onTap: () {
        _chatController.text = text.replaceAll(RegExp(r'^\S+ '), '');
        _sendMessage();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';
    final content = message['content'] as String;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          gradient: isUser ? AppTheme.primaryGradient : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
          ],
        ),
        child: isUser
            ? Text(
                content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.5,
                ),
              )
            : _buildFormattedAIResponse(content),
      ),
    );
  }

  Widget _buildFormattedAIResponse(String content) {
    // Check if content looks like a recipe
    // Basic heuristic: contains "Ingredients" and "Instructions" or "Steps"
    final hasIngredients = content.toLowerCase().contains('ingredients:');
    final hasInstructions = content.toLowerCase().contains('instructions:') || content.toLowerCase().contains('steps:');
    final isRecipe = hasIngredients && hasInstructions;

    // Parse content for better formatting
    final lines = content.split('\n');
    final List<Widget> widgets = [];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }
      
      // Check for headers (lines ending with :)
      if (line.endsWith(':') && line.length < 50) {
        widgets.add(Padding(
          padding: EdgeInsets.only(top: i > 0 ? 12 : 0, bottom: 6),
          child: Text(
            line,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
        ));
      }
      // Check for bullet points or numbered lists
      else if (RegExp(r'^[\•\-\*]\s').hasMatch(line) || RegExp(r'^\d+[\.\)]\s').hasMatch(line)) {
        final cleanLine = line.replaceFirst(RegExp(r'^[\•\-\*\d\.]+[\.\)]*\s*'), '');
        final isNumbered = RegExp(r'^\d+[\.\)]').hasMatch(line);
        final number = isNumbered ? line.substring(0, line.indexOf(RegExp(r'[\.\)]')) + 1) : null;
        
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNumbered)
                Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(right: 10, top: 2),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number!,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 10, top: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              Expanded(
                child: Text(
                  cleanLine,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ));
      }
      // Check for bold text (surrounded by **)
      else if (line.contains('**')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildRichText(line),
        ));
      }
      // Regular text
      else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            line,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ));
      }
    }
    
    if (isRecipe) {
      widgets.add(const SizedBox(height: 16));
      widgets.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Optimistic parsing
              try {
                final parsedMeal = _parseMealFromText(content);
                _showMealDetails(parsedMeal);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open recipe view.')),
                  );
                }
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryOrange.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('View as Recipe Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        )
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets.isEmpty
          ? [Text(content, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.5))]
          : widgets,
    );
  }

  Meal _parseMealFromText(String text) {
    // Simple parser
    final lines = text.split('\n');
    String name = 'Recipe';
    String description = 'Generated from chat discussion.';
    List<String> ingredients = [];
    StringBuffer instructions = StringBuffer();
    
    // Find name (first non-empty line usually, or bold text)
    for (var line in lines) {
      if (line.trim().isNotEmpty && !line.toLowerCase().startsWith('sure') && !line.toLowerCase().startsWith('here')) {
        name = line.replaceAll('**', '').replaceAll('#', '').trim();
        // If name is too long, truncate
        if (name.length > 50) name = '${name.substring(0, 50)}...';
        break;
      }
    }

    bool inIngredients = false;
    bool inInstructions = false;

    for (var line in lines) {
      final lower = line.toLowerCase();
      if (lower.contains('ingredients:')) {
        inIngredients = true;
        inInstructions = false;
        continue;
      } else if (lower.contains('instructions:') || lower.contains('steps:')) {
        inIngredients = false;
        inInstructions = true;
        continue;
      }

      if (inIngredients) {
        if (line.trim().isNotEmpty && (line.startsWith('-') || line.startsWith('•') || RegExp(r'^\d').hasMatch(line))) {
           ingredients.add(line.replaceAll(RegExp(r'^[\-\•\*\d\.]+\s*'), '').trim());
        }
      } else if (inInstructions) {
        if (line.trim().isNotEmpty) {
          instructions.writeln(line.trim());
        }
      }
    }

    return Meal(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      description: description,
      category: 'dinner',
      ingredients: ingredients,
      instructions: instructions.toString(),
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      prepTimeMinutes: 15,
      cookTimeMinutes: 30,
      cuisine: 'International',
      isVegetarian: false,
      isVegan: false,
    );
  }

  Widget _buildRichText(String text) {
    final List<TextSpan> spans = [];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;
    
    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.5),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, height: 1.5),
      ));
      lastEnd = match.end;
    }
    
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.5),
      ));
    }
    
    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            _buildDot(1),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + index * 200),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withValues(alpha: 0.3 + 0.7 * value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
