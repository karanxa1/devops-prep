import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/meal.dart';
import '../models/meal_plan.dart';
import '../providers/app_provider.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen>
    with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  MealPlan? _selectedDayPlan;
  Map<String, Meal?> _mealDetails = {};
  bool _isGenerating = false;
  
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
    _loadMealPlanForDate(_selectedDay);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadMealPlanForDate(DateTime date) async {
    final provider = context.read<AppProvider>();
    final plan = await provider.getMealPlanForDate(date);
    setState(() => _selectedDayPlan = plan);

    if (plan != null) {
      _mealDetails = {};
      final meals = provider.meals;

      if (plan.breakfastId != null) {
        _mealDetails['breakfast'] = meals.where((m) => m.id == plan.breakfastId).firstOrNull;
      }
      if (plan.lunchId != null) {
        _mealDetails['lunch'] = meals.where((m) => m.id == plan.lunchId).firstOrNull;
      }
      if (plan.dinnerId != null) {
        _mealDetails['dinner'] = meals.where((m) => m.id == plan.dinnerId).firstOrNull;
      }
      if (plan.snackId != null) {
        _mealDetails['snack'] = meals.where((m) => m.id == plan.snackId).firstOrNull;
      }
      setState(() {});
    }
  }

  Future<void> _generateWeeklyPlan() async {
    setState(() => _isGenerating = true);

    final provider = context.read<AppProvider>();
    await provider.generateWeeklyMealPlan();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Weekly meal plan generated! 🎉'),
            ],
          ),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    await _loadMealPlanForDate(_selectedDay);
    setState(() => _isGenerating = false);
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
                        gradient: AppTheme.blueGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Meal Plan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                        ],
                      ),
                      child: Text(
                        DateFormat('MMM yyyy').format(_focusedDay),
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.week,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerVisible: false,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
                    weekendStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      gradient: AppTheme.blueGradient,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: const TextStyle(fontWeight: FontWeight.w600),
                    weekendTextStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                    outsideDaysVisible: false,
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _loadMealPlanForDate(selectedDay);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Selected date header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_rounded, color: AppTheme.primaryOrange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE, MMMM d').format(_selectedDay),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedDayPlan != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Planned',
                              style: TextStyle(
                                color: AppTheme.successGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Meal slots
              Expanded(
                child: FadeTransition(
                  opacity: _fadeController,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildMealSlot('Breakfast', Icons.wb_sunny_rounded, '🌅', _mealDetails['breakfast'], AppTheme.sunsetGradient),
                      _buildMealSlot('Lunch', Icons.restaurant_rounded, '🍽️', _mealDetails['lunch'], AppTheme.blueGradient),
                      _buildMealSlot('Dinner', Icons.nights_stay_rounded, '🌙', _mealDetails['dinner'], AppTheme.purpleGradient),
                      _buildMealSlot('Snack', Icons.cookie_rounded, '🍪', _mealDetails['snack'], AppTheme.tealGradient),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: PulsingFAB(
        icon: Icons.auto_awesome_rounded,
        label: _isGenerating ? 'Generating...' : 'Generate Week',
        onPressed: _generateWeeklyPlan,
        isLoading: _isGenerating,
      ),
    );
  }

  Widget _buildMealSlot(String label, IconData icon, String emoji, Meal? meal, LinearGradient gradient) {
    final hasMeal = meal != null;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Show meal details or add meal
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasMeal ? meal.name : 'Tap to add meal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: hasMeal ? AppTheme.textPrimary : Colors.grey.shade400,
                        ),
                      ),
                      if (hasMeal) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildMealTag(Icons.local_fire_department_rounded, '${meal.calories} kcal', AppTheme.primaryOrange),
                            const SizedBox(width: 8),
                            _buildMealTag(Icons.timer_rounded, '${meal.totalTimeMinutes} min', AppTheme.accentBlue),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hasMeal 
                        ? AppTheme.successGreen.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasMeal ? Icons.check_rounded : Icons.add_rounded,
                    color: hasMeal ? AppTheme.successGreen : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealTag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
