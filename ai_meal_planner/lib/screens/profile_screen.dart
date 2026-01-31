import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../models/user_profile.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppTheme.purpleGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                AppTheme.fadeRoute(const OnboardingScreen()),
                              );
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                                ],
                              ),
                              child: Icon(Icons.edit_rounded, color: AppTheme.accentPurple, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Profile card
                  SliverToBoxAdapter(
                    child: AnimatedListItem(
                      index: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.name,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.flag_rounded, color: Colors.white, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            _formatGoal(profile.primaryGoal),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                          ),
                                        ],
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

                  // Stats cards
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      delegate: SliverChildListDelegate([
                        AnimatedListItem(
                          index: 1,
                          child: _buildStatCard(
                            '${profile.age}',
                            'Age',
                            Icons.cake_rounded,
                            AppTheme.purpleGradient,
                          ),
                        ),
                        AnimatedListItem(
                          index: 2,
                          child: _buildStatCard(
                            '${profile.heightCm.round()}',
                            'cm tall',
                            Icons.height_rounded,
                            AppTheme.blueGradient,
                          ),
                        ),
                        AnimatedListItem(
                          index: 3,
                          child: _buildStatCard(
                            '${profile.weightKg.round()}',
                            'kg',
                            Icons.monitor_weight_rounded,
                            AppTheme.tealGradient,
                          ),
                        ),
                      ]),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Section: Health Metrics
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_rounded, color: AppTheme.secondaryPink, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Health Metrics',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
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
                        childAspectRatio: 1.5,
                      ),
                      delegate: SliverChildListDelegate([
                        AnimatedListItem(
                          index: 4,
                          child: _buildMetricTile(
                            'BMI',
                            profile.bmi.toStringAsFixed(1),
                            profile.bmiCategory,
                            Icons.speed_rounded,
                            AppTheme.primaryOrange,
                          ),
                        ),
                        AnimatedListItem(
                          index: 5,
                          child: _buildMetricTile(
                            'Daily Calories',
                            '${profile.dailyCalorieTarget.round()}',
                            'kcal target',
                            Icons.local_fire_department_rounded,
                            AppTheme.secondaryPink,
                          ),
                        ),
                        AnimatedListItem(
                          index: 6,
                          child: _buildMetricTile(
                            'Protein',
                            '${profile.dailyProteinTarget.round()}g',
                            'daily goal',
                            Icons.fitness_center_rounded,
                            AppTheme.accentPurple,
                          ),
                        ),
                        AnimatedListItem(
                          index: 7,
                          child: _buildMetricTile(
                            'Target Weight',
                            '${profile.targetWeight.round()} kg',
                            _formatGoal(profile.primaryGoal),
                            Icons.flag_rounded,
                            AppTheme.accentBlue,
                          ),
                        ),
                      ]),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Section: Preferences
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.tune_rounded, color: AppTheme.accentPurple, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Preferences',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  SliverToBoxAdapter(
                    child: AnimatedListItem(
                      index: 8,
                      child: _buildPreferenceCard(
                        context,
                        'Diet',
                        _formatDiet(profile.dietType),
                        Icons.restaurant_rounded,
                        AppTheme.tealGradient,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: AnimatedListItem(
                      index: 9,
                      child: _buildPreferenceCard(
                        context,
                        'Activity Level',
                        _formatActivityLevel(profile.activityLevel),
                        Icons.directions_run_rounded,
                        AppTheme.blueGradient,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: AnimatedListItem(
                      index: 10,
                      child: _buildPreferenceCard(
                        context,
                        'Cooking Skill',
                        _formatCookingLevel(profile.cookingLevel),
                        Icons.restaurant_menu_rounded,
                        AppTheme.sunsetGradient,
                      ),
                    ),
                  ),

                  if (profile.allergies.isNotEmpty)
                    SliverToBoxAdapter(
                      child: AnimatedListItem(
                        index: 11,
                        child: _buildChipsCard(
                          context,
                          'Allergies',
                          profile.allergies,
                          Icons.warning_rounded,
                          AppTheme.errorRed,
                        ),
                      ),
                    ),

                  if (profile.preferredCuisines.isNotEmpty)
                    SliverToBoxAdapter(
                      child: AnimatedListItem(
                        index: 12,
                        child: _buildChipsCard(
                          context,
                          'Favorite Cuisines',
                          profile.preferredCuisines,
                          Icons.public_rounded,
                          AppTheme.accentPurple,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, LinearGradient gradient) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceCard(BuildContext context, String title, String value, IconData icon, LinearGradient gradient) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildChipsCard(BuildContext context, String title, List<String> items, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatGoal(WeightGoal goal) {
    return switch (goal) {
      WeightGoal.lose => 'Lose Weight',
      WeightGoal.maintain => 'Maintain Weight',
      WeightGoal.gain => 'Gain Weight',
    };
  }

  String _formatDiet(DietType diet) {
    return switch (diet) {
      DietType.nonVeg => 'Non-Vegetarian 🥩',
      DietType.vegetarian => 'Vegetarian 🥬',
      DietType.vegan => 'Vegan 🌱',
      DietType.eggetarian => 'Eggetarian 🥚',
      DietType.pescatarian => 'Pescatarian 🐟',
    };
  }

  String _formatActivityLevel(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.sedentary => 'Sedentary 🪑',
      ActivityLevel.light => 'Lightly Active 🚶',
      ActivityLevel.moderate => 'Moderately Active 🏃',
      ActivityLevel.active => 'Very Active 💪',
      ActivityLevel.veryActive => 'Extremely Active 🔥',
    };
  }

  String _formatCookingLevel(CookingLevel level) {
    return switch (level) {
      CookingLevel.beginner => 'Beginner 👶',
      CookingLevel.intermediate => 'Intermediate 👨‍🍳',
      CookingLevel.advanced => 'Advanced 🌟',
    };
  }
}
