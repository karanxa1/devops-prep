import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../models/user_profile.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form fields
  final TextEditingController _nameController = TextEditingController();
  DateTime _birthDate = DateTime(2000, 1, 1);
  Gender _gender = Gender.male;
  double _heightCm = 170;
  double _weightKg = 70;
  WeightGoal _primaryGoal = WeightGoal.maintain;
  double _targetWeight = 70;
  String _weightLossSpeed = 'moderate';
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  DietType _dietType = DietType.nonVeg;
  final List<String> _allergies = [];
  final List<String> _dislikedFoods = [];
  final List<String> _preferredCuisines = [];
  String _healthGoal = 'general';
  int _cookingTimeMinutes = 30;
  String _kitchenSetup = 'intermediate';
  int _cookingDaysPerWeek = 5;
  final List<int> _vegDays = [];
  double _weeklyBudget = 100;
  CookingLevel _cookingLevel = CookingLevel.intermediate;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _stepData = const [
    {'title': 'Welcome! 👋', 'subtitle': 'Let\'s personalize your meal planning experience', 'icon': Icons.restaurant_rounded, 'gradient': AppTheme.primaryGradient},
    {'title': 'About You 📋', 'subtitle': 'Tell us a bit about yourself', 'icon': Icons.person_rounded, 'gradient': AppTheme.purpleGradient},
    {'title': 'Measurements 📏', 'subtitle': 'Your height and weight for accurate calculations', 'icon': Icons.height_rounded, 'gradient': AppTheme.blueGradient},
    {'title': 'Your Goals 🎯', 'subtitle': 'What would you like to achieve?', 'icon': Icons.flag_rounded, 'gradient': AppTheme.tealGradient},
    {'title': 'Activity Level 🏃', 'subtitle': 'How active are you on a daily basis?', 'icon': Icons.directions_run_rounded, 'gradient': AppTheme.sunsetGradient},
    {'title': 'Diet Preference 🥗', 'subtitle': 'Choose your dietary lifestyle', 'icon': Icons.eco_rounded, 'gradient': AppTheme.primaryGradient},
    {'title': 'Allergies & Dislikes ⚠️', 'subtitle': 'Foods to avoid in your meal plans', 'icon': Icons.warning_rounded, 'gradient': AppTheme.purpleGradient},
    {'title': 'Favorite Cuisines 🌍', 'subtitle': 'What flavors do you love?', 'icon': Icons.public_rounded, 'gradient': AppTheme.blueGradient},
    {'title': 'Cooking Habits 👨‍🍳', 'subtitle': 'Your kitchen preferences', 'icon': Icons.restaurant_menu_rounded, 'gradient': AppTheme.tealGradient},
    {'title': 'Budget 💰', 'subtitle': 'Set your weekly meal budget', 'icon': Icons.savings_rounded, 'gradient': AppTheme.sunsetGradient},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 9) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final profile = UserProfile(
      name: _nameController.text,
      gender: _gender,
      birthDate: _birthDate,
      heightCm: _heightCm,
      weightKg: _weightKg,
      primaryGoal: _primaryGoal,
      targetWeight: _targetWeight,
      weightLossSpeed: _weightLossSpeed,
      activityLevel: _activityLevel,
      dietType: _dietType,
      allergies: _allergies,
      dislikedFoods: _dislikedFoods,
      preferredCuisines: _preferredCuisines,
      healthGoal: _healthGoal,
      cookingTimeMinutes: _cookingTimeMinutes,
      kitchenSetup: _kitchenSetup,
      cookingDaysPerWeek: _cookingDaysPerWeek,
      vegDays: _vegDays,
      weeklyBudget: _weeklyBudget,
      cookingLevel: _cookingLevel,
      onboardingComplete: true,
    );

    await context.read<AppProvider>().saveUserProfile(profile);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        AppTheme.slideUpRoute(const HomeScreen()),
      );
    }
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
              // Progress and back button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      IconButton(
                        onPressed: _previousPage,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_rounded, size: 20),
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: _buildProgressIndicator(),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _animController.reset();
                      _animController.forward();
                    },
                    children: [
                      _buildWelcomePage(),
                      _buildAboutPage(),
                      _buildMeasurementsPage(),
                      _buildGoalsPage(),
                      _buildActivityPage(),
                      _buildDietPage(),
                      _buildAllergiesPage(),
                      _buildCuisinePage(),
                      _buildCookingPage(),
                      _buildBudgetPage(),
                    ],
                  ),
                ),
              ),

              // Next button
              Padding(
                padding: const EdgeInsets.all(20),
                child: _buildNextButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(10, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: index == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: index <= _currentPage ? AppTheme.primaryGradient : null,
            color: index > _currentPage ? Colors.grey.shade300 : null,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildStepHeader(Map<String, dynamic> step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: step['gradient'] as LinearGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (step['gradient'] as LinearGradient).colors.first.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(step['icon'] as IconData, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            step['title'] as String,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step['subtitle'] as String,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _stepData[_currentPage]['gradient'] as LinearGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (_stepData[_currentPage]['gradient'] as LinearGradient).colors.first.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentPage == 9 ? 'Start Planning!' : 
                _currentPage == 0 ? 'Let\'s Go!' : 'Continue',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Icon(_currentPage == 9 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    );
  }

  // Page builders
  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildStepHeader(_stepData[0]),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
            ),
            child: Column(
              children: [
                const Text('👨‍🍳', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'What\'s your name?',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildStepHeader(_stepData[1]),
          const SizedBox(height: 24),
          // Gender selection
          Row(
            children: [
              Expanded(child: _buildGenderCard('Male', '👨', Gender.male)),
              const SizedBox(width: 12),
              Expanded(child: _buildGenderCard('Female', '👩', Gender.female)),
              const SizedBox(width: 12),
              Expanded(child: _buildGenderCard('Other', '🧑', Gender.other)),
            ],
          ),
          const SizedBox(height: 24),
          // Birth date
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
            ),
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _birthDate,
                  firstDate: DateTime(1920),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _birthDate = date);
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.purpleGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cake_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Birth Date', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      Text(
                        '${_birthDate.day}/${_birthDate.month}/${_birthDate.year}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard(String label, String emoji, Gender gender) {
    final isSelected = _gender == gender;
    return GestureDetector(
      onTap: () => setState(() => _gender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.purpleGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppTheme.accentPurple.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildStepHeader(_stepData[2]),
          const SizedBox(height: 24),
          // Height
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.blueGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.height_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('Height', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(
                      '${_heightCm.round()} cm',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accentBlue),
                    ),
                  ],
                ),
                Slider(
                  value: _heightCm,
                  min: 100,
                  max: 250,
                  divisions: 150,
                  activeColor: AppTheme.accentBlue,
                  onChanged: (v) => setState(() => _heightCm = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Weight
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.tealGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.monitor_weight_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('Weight', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(
                      '${_weightKg.round()} kg',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
                    ),
                  ],
                ),
                Slider(
                  value: _weightKg,
                  min: 30,
                  max: 200,
                  divisions: 170,
                  activeColor: AppTheme.accentTeal,
                  onChanged: (v) => setState(() => _weightKg = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    final goals = [
      {'goal': WeightGoal.lose, 'label': 'Lose Weight', 'emoji': '📉', 'desc': 'Shed extra pounds'},
      {'goal': WeightGoal.maintain, 'label': 'Maintain', 'emoji': '⚖️', 'desc': 'Keep current weight'},
      {'goal': WeightGoal.gain, 'label': 'Gain Weight', 'emoji': '💪', 'desc': 'Build muscle mass'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildStepHeader(_stepData[3]),
          const SizedBox(height: 24),
          ...goals.map((g) => _buildGoalCard(g)),
          const SizedBox(height: 24),
          // Target weight
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    const Text('Target Weight', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(
                      '${_targetWeight.round()} kg',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
                    ),
                  ],
                ),
                Slider(
                  value: _targetWeight,
                  min: 30,
                  max: 200,
                  divisions: 170,
                  activeColor: AppTheme.primaryOrange,
                  onChanged: (v) => setState(() => _targetWeight = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final isSelected = _primaryGoal == goal['goal'];
    return GestureDetector(
      onTap: () => setState(() => _primaryGoal = goal['goal'] as WeightGoal),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.tealGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppTheme.accentTeal.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
            ),
          ],
        ),
        child: Row(
          children: [
            Text(goal['emoji'] as String, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal['label'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  goal['desc'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityPage() {
    final levels = [
      {'level': ActivityLevel.sedentary, 'label': 'Sedentary', 'emoji': '🪑', 'desc': 'Little or no exercise'},
      {'level': ActivityLevel.light, 'label': 'Light', 'emoji': '🚶', 'desc': 'Exercise 1-3 days/week'},
      {'level': ActivityLevel.moderate, 'label': 'Moderate', 'emoji': '🏃', 'desc': 'Exercise 3-5 days/week'},
      {'level': ActivityLevel.active, 'label': 'Active', 'emoji': '💪', 'desc': 'Exercise 6-7 days/week'},
      {'level': ActivityLevel.veryActive, 'label': 'Very Active', 'emoji': '🔥', 'desc': 'Intense daily exercise'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildStepHeader(_stepData[4]),
          const SizedBox(height: 24),
          ...levels.map((l) => _buildActivityCard(l)),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> level) {
    final isSelected = _activityLevel == level['level'];
    return GestureDetector(
      onTap: () => setState(() => _activityLevel = level['level'] as ActivityLevel),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.sunsetGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Text(level['emoji'] as String, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level['label'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    level['desc'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildDietPage() {
    final diets = [
      {'diet': DietType.nonVeg, 'label': 'Non-Vegetarian', 'emoji': '🥩'},
      {'diet': DietType.vegetarian, 'label': 'Vegetarian', 'emoji': '🥬'},
      {'diet': DietType.vegan, 'label': 'Vegan', 'emoji': '🌱'},
      {'diet': DietType.eggetarian, 'label': 'Eggetarian', 'emoji': '🥚'},
      {'diet': DietType.pescatarian, 'label': 'Pescatarian', 'emoji': '🐟'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildStepHeader(_stepData[5]),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: diets.map((d) {
              final isSelected = _dietType == d['diet'];
              return GestureDetector(
                onTap: () => setState(() => _dietType = d['diet'] as DietType),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.primaryGradient : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(d['emoji'] as String, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        d['label'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesPage() {
    final commonAllergies = ['Nuts', 'Dairy', 'Gluten', 'Eggs', 'Soy', 'Shellfish', 'Fish', 'Wheat'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildStepHeader(_stepData[6]),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️ Allergies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: commonAllergies.map((a) {
                    final isSelected = _allergies.contains(a);
                    return GestureDetector(
                      onTap: () => setState(() {
                        isSelected ? _allergies.remove(a) : _allergies.add(a);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.errorRed.withValues(alpha: 0.1) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.errorRed : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          a,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppTheme.errorRed : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisinePage() {
    final cuisines = ['Indian', 'Italian', 'Mexican', 'Chinese', 'Japanese', 'Thai', 'Mediterranean', 'American', 'Korean', 'French'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildStepHeader(_stepData[7]),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: cuisines.map((c) {
              final isSelected = _preferredCuisines.contains(c);
              return GestureDetector(
                onTap: () => setState(() {
                  isSelected ? _preferredCuisines.remove(c) : _preferredCuisines.add(c);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.blueGradient : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCookingPage() {
    final skills = [
      {'level': CookingLevel.beginner, 'label': 'Beginner', 'emoji': '👶', 'desc': 'Just starting out'},
      {'level': CookingLevel.intermediate, 'label': 'Intermediate', 'emoji': '👨‍🍳', 'desc': 'Comfortable cooking'},
      {'level': CookingLevel.advanced, 'label': 'Advanced', 'emoji': '🌟', 'desc': 'Expert level'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildStepHeader(_stepData[8]),
          const SizedBox(height: 24),
          ...skills.map((s) {
            final isSelected = _cookingLevel == s['level'];
            return GestureDetector(
              onTap: () => setState(() => _cookingLevel = s['level'] as CookingLevel),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.tealGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Text(s['emoji'] as String, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['label'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          s['desc'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (isSelected) const Icon(Icons.check_circle_rounded, color: Colors.white),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          // Cooking time
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('⏱️', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    const Text('Cooking Time', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(
                      '$_cookingTimeMinutes min',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
                    ),
                  ],
                ),
                Slider(
                  value: _cookingTimeMinutes.toDouble(),
                  min: 10,
                  max: 120,
                  divisions: 22,
                  activeColor: AppTheme.accentTeal,
                  onChanged: (v) => setState(() => _cookingTimeMinutes = v.round()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildStepHeader(_stepData[9]),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.sunsetGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('💰', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  '\$${_weeklyBudget.round()}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'per week',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _weeklyBudget,
                  min: 25,
                  max: 500,
                  divisions: 19,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                  onChanged: (v) => setState(() => _weeklyBudget = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    const Text('Cooking Days/Week', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(
                      '$_cookingDaysPerWeek days',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
                    ),
                  ],
                ),
                Slider(
                  value: _cookingDaysPerWeek.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  activeColor: AppTheme.primaryOrange,
                  onChanged: (v) => setState(() => _cookingDaysPerWeek = v.round()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
