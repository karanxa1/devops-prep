import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import 'meal_plan_screen.dart';
import 'ai_suggest_screen.dart';
import 'shopping_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  final List<Widget> _screens = [
    const _HomeTab(),
    const MealPlanScreen(),
    const AISuggestScreen(),
    const ShoppingListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeOut),
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.calendar_month_rounded, 'Plan'),
                _buildCenterNavItem(),
                _buildNavItem(3, Icons.shopping_cart_rounded, 'Shop'),
                _buildNavItem(4, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryOrange : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryOrange : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNavItem() {
    final isSelected = _currentIndex == 2;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: ScaleTransition(
        scale: _fabAnimation,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryOrange.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: isSelected ? 28 : 24,
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.bgGradientStart, AppTheme.bgGradientEnd],
        ),
      ),
      child: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final profile = provider.userProfile;
            if (profile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good ${_getGreeting()}! 👋',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.notifications_rounded,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Streak Card
                SliverToBoxAdapter(
                  child: AnimatedListItem(
                    index: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GradientCard(
                        gradient: AppTheme.primaryGradient,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 28),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${provider.currentStreak} Day Streak!',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Best: ${provider.bestStreak} days 🏆',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${provider.totalMeals} meals logged',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedProgressRing(
                              progress: provider.todayLog != null 
                                  ? provider.todayLog!.completionPercentage 
                                  : 0,
                              size: 80,
                              strokeWidth: 8,
                              color: Colors.white,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${((provider.todayLog?.completionPercentage ?? 0) * 100).round()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'today',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Quick Stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.insights_rounded, color: AppTheme.primaryOrange, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Today\'s Goals',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Metric Cards Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    delegate: SliverChildListDelegate([
                      AnimatedListItem(
                        index: 1,
                        child: MetricCard(
                          icon: Icons.local_fire_department_rounded,
                          title: 'Calories',
                          value: '${profile.dailyCalorieTarget.round()}',
                          subtitle: 'kcal target',
                          iconColor: AppTheme.primaryOrange,
                        ),
                      ),
                      AnimatedListItem(
                        index: 2,
                        child: MetricCard(
                          icon: Icons.fitness_center_rounded,
                          title: 'Protein',
                          value: '${profile.dailyProteinTarget.round()}g',
                          subtitle: 'daily goal',
                          iconColor: AppTheme.accentPurple,
                        ),
                      ),
                      AnimatedListItem(
                        index: 3,
                        child: MetricCard(
                          icon: Icons.monitor_weight_rounded,
                          title: 'BMI',
                          value: profile.bmi.toStringAsFixed(1),
                          subtitle: _getBmiCategory(profile.bmi),
                          iconColor: AppTheme.accentTeal,
                        ),
                      ),
                      AnimatedListItem(
                        index: 4,
                        child: MetricCard(
                          icon: Icons.flag_rounded,
                          title: 'Goal',
                          value: _formatGoal(profile.primaryGoal),
                          subtitle: '${profile.targetWeight.round()} kg target',
                          iconColor: AppTheme.accentBlue,
                        ),
                      ),
                    ]),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppTheme.accentPurple, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildListDelegate([
                      AnimatedListItem(
                        index: 5,
                        child: AnimatedIconCard(
                          icon: Icons.auto_awesome_rounded,
                          label: 'AI Meal Ideas',
                          subtitle: 'Get suggestions',
                          gradient: AppTheme.purpleGradient,
                          onTap: () {
                            // Navigate to AI suggestions
                          },
                        ),
                      ),
                      AnimatedListItem(
                        index: 6,
                        child: AnimatedIconCard(
                          icon: Icons.calendar_month_rounded,
                          label: 'Weekly Plan',
                          subtitle: 'Generate plan',
                          gradient: AppTheme.blueGradient,
                          onTap: () {
                            // Navigate to meal plan
                          },
                        ),
                      ),
                      AnimatedListItem(
                        index: 7,
                        child: AnimatedIconCard(
                          icon: Icons.shopping_cart_rounded,
                          label: 'Shopping List',
                          subtitle: 'View items',
                          gradient: AppTheme.tealGradient,
                          onTap: () {
                            // Navigate to shopping list
                          },
                        ),
                      ),
                      AnimatedListItem(
                        index: 8,
                        child: AnimatedIconCard(
                          icon: Icons.restaurant_menu_rounded,
                          label: 'Saved Meals',
                          subtitle: '${provider.meals.length} recipes',
                          gradient: AppTheme.sunsetGradient,
                          onTap: () {
                            // Navigate to saved meals
                          },
                        ),
                      ),
                    ]),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  String _formatGoal(dynamic goal) {
    return goal.toString().split('.').last.replaceAll('_', ' ');
  }
}
