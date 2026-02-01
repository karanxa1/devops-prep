import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../models/user_profile.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  void _editBasicInfo(UserProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final ageController = TextEditingController(text: profile.age.toString());
    final heightController = TextEditingController(text: profile.heightCm.round().toString());
    final weightController = TextEditingController(text: profile.weightKg.round().toString());
    final targetWeightController = TextEditingController(text: profile.targetWeight.round().toString());
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Edit Basic Info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildEditField(nameController, 'Name', Icons.person_rounded),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildEditField(ageController, 'Age', Icons.cake_rounded, isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildEditField(heightController, 'Height (cm)', Icons.height_rounded, isNumber: true)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildEditField(weightController, 'Weight (kg)', Icons.monitor_weight_rounded, isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildEditField(targetWeightController, 'Target (kg)', Icons.flag_rounded, isNumber: true)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Update birthDate based on Age change
                    final int currentAge = profile.age;
                    final int newAge = int.tryParse(ageController.text) ?? currentAge;
                    final int ageDiff = newAge - currentAge;
                    final DateTime newBirthDate = DateTime(
                      profile.birthDate.year - ageDiff,
                      profile.birthDate.month,
                      profile.birthDate.day,
                    );

                    final updated = profile.copyWith(
                      name: nameController.text,
                      birthDate: newBirthDate,
                      heightCm: double.tryParse(heightController.text) ?? profile.heightCm,
                      weightKg: double.tryParse(weightController.text) ?? profile.weightKg,
                      targetWeight: double.tryParse(targetWeightController.text) ?? profile.targetWeight,
                    );
                    context.read<AppProvider>().updateUserProfile(updated);
                    Navigator.pop(context);
                    _showSuccessSnackbar('Profile updated! AI will use your new info 🧠');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editGoal(UserProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Select Your Goal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...WeightGoal.values.map((goal) => _buildOptionTile(
              title: _formatGoal(goal),
              icon: Icons.flag_rounded,
              isSelected: profile.primaryGoal == goal,
              onTap: () {
                context.read<AppProvider>().updateUserProfile(profile.copyWith(primaryGoal: goal));
                Navigator.pop(context);
                _showSuccessSnackbar('Goal updated!');
              },
            )),
          ],
        ),
      ),
    );
  }

  void _editDiet(UserProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Select Diet Type', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...DietType.values.map((diet) => _buildOptionTile(
              title: _formatDiet(diet),
              icon: Icons.restaurant_rounded,
              isSelected: profile.dietType == diet,
              onTap: () {
                context.read<AppProvider>().updateUserProfile(profile.copyWith(dietType: diet));
                Navigator.pop(context);
                _showSuccessSnackbar('Diet preference updated!');
              },
            )),
          ],
        ),
      ),
    );
  }

  void _editActivityLevel(UserProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Activity Level', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...ActivityLevel.values.map((level) => _buildOptionTile(
              title: _formatActivityLevel(level),
              icon: Icons.directions_run_rounded,
              isSelected: profile.activityLevel == level,
              onTap: () {
                context.read<AppProvider>().updateUserProfile(profile.copyWith(activityLevel: level));
                Navigator.pop(context);
                _showSuccessSnackbar('Activity level updated!');
              },
            )),
          ],
        ),
      ),
    );
  }

  void _editCookingLevel(UserProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Cooking Skill Level', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...CookingLevel.values.map((level) => _buildOptionTile(
              title: _formatCookingLevel(level),
              icon: Icons.restaurant_menu_rounded,
              isSelected: profile.cookingLevel == level,
              onTap: () {
                context.read<AppProvider>().updateUserProfile(profile.copyWith(cookingLevel: level));
                Navigator.pop(context);
                _showSuccessSnackbar('Cooking level updated!');
              },
            )),
          ],
        ),
      ),
    );
  }

  void _editAllergies(UserProfile profile) {
    final commonAllergies = ['Dairy', 'Eggs', 'Gluten', 'Peanuts', 'Tree Nuts', 'Soy', 'Fish', 'Shellfish', 'Sesame'];
    final selected = List<String>.from(profile.allergies);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Allergies & Restrictions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: commonAllergies.map((allergy) {
                  final isSelected = selected.contains(allergy);
                  return GestureDetector(
                    onTap: () {
                      setModalState(() {
                        if (isSelected) {
                          selected.remove(allergy);
                        } else {
                          selected.add(allergy);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.errorRed.withValues(alpha: 0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppTheme.errorRed : Colors.grey.shade300),
                      ),
                      child: Text(
                        allergy,
                        style: TextStyle(
                          color: isSelected ? AppTheme.errorRed : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AppProvider>().updateUserProfile(profile.copyWith(allergies: selected));
                    Navigator.pop(context);
                    _showSuccessSnackbar('Allergies updated!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editCuisines(UserProfile profile) {
    final allCuisines = ['Indian', 'Chinese', 'Italian', 'Mexican', 'Thai', 'Japanese', 'Mediterranean', 'American', 'Korean', 'French'];
    final selected = List<String>.from(profile.preferredCuisines);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Favorite Cuisines', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allCuisines.map((cuisine) {
                  final isSelected = selected.contains(cuisine);
                  return GestureDetector(
                    onTap: () {
                      setModalState(() {
                        if (isSelected) {
                          selected.remove(cuisine);
                        } else {
                          selected.add(cuisine);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.accentPurple.withValues(alpha: 0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppTheme.accentPurple : Colors.grey.shade300),
                      ),
                      child: Text(
                        cuisine,
                        style: TextStyle(
                          color: isSelected ? AppTheme.accentPurple : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AppProvider>().updateUserProfile(profile.copyWith(preferredCuisines: selected));
                    Navigator.pop(context);
                    _showSuccessSnackbar('Cuisines updated!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryOrange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
        ),
      ),
    );
  }

  Widget _buildOptionTile({required String title, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppTheme.primaryOrange : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryOrange : Colors.grey.shade500),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppTheme.primaryOrange),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              AppTheme.fadeRoute(const OnboardingScreen()),
                            ),
                            icon: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                                ],
                              ),
                              child: Icon(Icons.refresh_rounded, color: AppTheme.accentPurple, size: 20),
                            ),
                            tooltip: 'Redo onboarding',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Profile card (tappable)
                  SliverToBoxAdapter(
                    child: AnimatedListItem(
                      index: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () => _editBasicInfo(profile),
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
                                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            profile.name,
                                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(Icons.edit_rounded, color: Colors.white.withValues(alpha: 0.7), size: 18),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () => _editGoal(profile),
                                        child: Container(
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
                                              Text(_formatGoal(profile.primaryGoal), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                              const SizedBox(width: 4),
                                              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withValues(alpha: 0.7), size: 16),
                                            ],
                                          ),
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
                        AnimatedListItem(index: 1, child: _buildStatCard('${profile.age}', 'Age', Icons.cake_rounded, AppTheme.purpleGradient)),
                        AnimatedListItem(index: 2, child: _buildStatCard('${profile.heightCm.round()}', 'cm tall', Icons.height_rounded, AppTheme.blueGradient)),
                        AnimatedListItem(index: 3, child: _buildStatCard('${profile.weightKg.round()}', 'kg', Icons.monitor_weight_rounded, AppTheme.tealGradient)),
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
                          const Text('Health Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
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
                        AnimatedListItem(index: 4, child: _buildMetricTile('BMI', profile.bmi.toStringAsFixed(1), profile.bmiCategory, Icons.speed_rounded, AppTheme.primaryOrange)),
                        AnimatedListItem(index: 5, child: _buildMetricTile('Daily Calories', '${profile.dailyCalorieTarget.round()}', 'kcal target', Icons.local_fire_department_rounded, AppTheme.secondaryPink)),
                        AnimatedListItem(index: 6, child: _buildMetricTile('Protein', '${profile.dailyProteinTarget.round()}g', 'daily goal', Icons.fitness_center_rounded, AppTheme.accentPurple)),
                        AnimatedListItem(index: 7, child: _buildMetricTile('Target Weight', '${profile.targetWeight.round()} kg', _formatGoal(profile.primaryGoal), Icons.flag_rounded, AppTheme.accentBlue)),
                      ]),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Section: Preferences (Editable)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.tune_rounded, color: AppTheme.accentPurple, size: 20),
                          const SizedBox(width: 8),
                          const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const Spacer(),
                          Text('Tap to edit', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  SliverToBoxAdapter(
                    child: AnimatedListItem(
                      index: 8,
                      child: _buildEditablePreferenceCard(
                        'Diet', _formatDiet(profile.dietType), Icons.restaurant_rounded, AppTheme.tealGradient,
                        onTap: () => _editDiet(profile),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: AnimatedListItem(
                      index: 9,
                      child: _buildEditablePreferenceCard(
                        'Activity Level', _formatActivityLevel(profile.activityLevel), Icons.directions_run_rounded, AppTheme.blueGradient,
                        onTap: () => _editActivityLevel(profile),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: AnimatedListItem(
                      index: 10,
                      child: _buildEditablePreferenceCard(
                        'Cooking Skill', _formatCookingLevel(profile.cookingLevel), Icons.restaurant_menu_rounded, AppTheme.sunsetGradient,
                        onTap: () => _editCookingLevel(profile),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: AnimatedListItem(
                      index: 11,
                      child: _buildEditableChipsCard(
                        'Allergies',
                        profile.allergies.isEmpty ? ['None'] : profile.allergies,
                        Icons.warning_rounded,
                        AppTheme.errorRed,
                        onTap: () => _editAllergies(profile),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: AnimatedListItem(
                      index: 12,
                      child: _buildEditableChipsCard(
                        'Favorite Cuisines',
                        profile.preferredCuisines.isEmpty ? ['Not set'] : profile.preferredCuisines,
                        Icons.public_rounded,
                        AppTheme.accentPurple,
                        onTap: () => _editCuisines(profile),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditablePreferenceCard(String title, String value, IconData icon, LinearGradient gradient, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                    const SizedBox(height: 2),
                    Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.edit_rounded, color: AppTheme.primaryOrange, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableChipsCard(String title, List<String> items, IconData icon, Color color, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppTheme.primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.edit_rounded, color: AppTheme.primaryOrange, size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(item, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                )).toList(),
              ),
            ],
          ),
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
