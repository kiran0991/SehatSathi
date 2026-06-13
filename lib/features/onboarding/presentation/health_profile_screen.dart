import 'package:flutter/material.dart';

// --- Design Tokens ---
class AppColors {
  static const Color primary = Color(0xFF064E3B); // Deep Emerald
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0A0A0A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color border = Color(0xFFE5E7EB);
}

class AppRadii {
  static const double card = 12.0;
  static const double input = 8.0;
  static const double pill = 100.0;
}

class AppFonts {
  static const String family = 'Inter';
}

// --- Constants & Strings ---
class AppStrings {
  static const String appBarTitle = 'Personalize Profile';
  static const String headerTitle = 'Tailor Your Experience';
  static const String headerSubtitle =
      'We\'ll use this information to highlight potential allergens and nutrient risks specifically for your needs.';
  static const String conditionsTitle = 'Health Conditions';
  static const String otherPlaceholder = '+ Other';
  static const String allergiesTitle = 'Allergies';
  static const String goalsTitle = 'Health Goals';
  static const String saveButton = 'Save & Continue →';

  static const List<String> conditions = [
    'Low Sugar',
    'High BP',
    'Diabetes',
    'Hypertension',
    'PCOS',
  ];

  static const List<String> allergies = [
    'Peanuts',
    'Soy',
    'Gluten',
    'Dairy',
    'Shellfish',
    'Eggs',
  ];
}

class GoalItem {
  final String title;
  final String description;
  final IconData icon;

  const GoalItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

const List<GoalItem> appGoals = [
  GoalItem(
    title: 'Weight Loss',
    description: 'Burn fat effectively',
    icon: Icons.fitness_center,
  ),
  GoalItem(
    title: 'Muscle Gain',
    description: 'Build strength',
    icon: Icons.sports_gymnastics,
  ),
  GoalItem(
    title: 'Low Sodium Diet',
    description: 'Manage BP',
    icon: Icons.water_drop_outlined,
  ),
  GoalItem(
    title: 'Clean Eating',
    description: 'Whole foods focus',
    icon: Icons.restaurant,
  ),
];

// --- Main Screen ---
class ProfileOnboardingScreen extends StatelessWidget {
  ProfileOnboardingScreen({Key? key}) : super(key: key);

  // State holders for UI interactivity
  final ValueNotifier<Set<String>> _selectedConditions = ValueNotifier({});
  final ValueNotifier<Set<String>> _selectedAllergies = ValueNotifier({});
  final ValueNotifier<String?> _selectedGoal = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        title: const Text(
          AppStrings.appBarTitle,
          style: TextStyle(
            fontFamily: AppFonts.family,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              radius: 16,
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.headerTitle,
                      style: TextStyle(
                        fontFamily: AppFonts.family,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      AppStrings.headerSubtitle,
                      style: TextStyle(
                        fontFamily: AppFonts.family,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildHealthConditionsSection(),
                    const SizedBox(height: 20),
                    _buildAllergiesSection(),
                    const SizedBox(height: 20),
                    _buildHealthGoalsSection(),
                    const SizedBox(height: 40), // Bottom padding
                  ],
                ),
              ),
            ),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppFonts.family,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthConditionsSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            AppStrings.conditionsTitle,
            Icons.medical_services_outlined,
            AppColors.primary,
          ),
          ValueListenableBuilder<Set<String>>(
            valueListenable: _selectedConditions,
            builder: (context, selected, _) {
              return Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: AppStrings.conditions.map((condition) {
                  final isSelected = selected.contains(condition);
                  return ChoiceChip(
                    label: Text(
                      condition,
                      style: TextStyle(
                        fontFamily: AppFonts.family,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.surface
                            : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      final newSet = Set<String>.from(
                        _selectedConditions.value,
                      );
                      if (selected) {
                        newSet.add(condition);
                      } else {
                        newSet.remove(condition);
                      }
                      _selectedConditions.value = newSet;
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.input),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              AppStrings.otherPlaceholder,
              style: TextStyle(
                fontFamily: AppFonts.family,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            AppStrings.allergiesTitle,
            Icons.warning_amber_rounded,
            AppColors.error,
          ),
          ValueListenableBuilder<Set<String>>(
            valueListenable: _selectedAllergies,
            builder: (context, selected, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  // 2-column layout for checkboxes matching the design
                  final itemWidth = (constraints.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: AppStrings.allergies.map((allergy) {
                      final isSelected = selected.contains(allergy);
                      return GestureDetector(
                        onTap: () {
                          final newSet = Set<String>.from(
                            _selectedAllergies.value,
                          );
                          if (isSelected) {
                            newSet.remove(allergy);
                          } else {
                            newSet.add(allergy);
                          }
                          _selectedAllergies.value = newSet;
                        },
                        child: Container(
                          width: itemWidth,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadii.input),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    final newSet = Set<String>.from(
                                      _selectedAllergies.value,
                                    );
                                    if (value == true) {
                                      newSet.add(allergy);
                                    } else {
                                      newSet.remove(allergy);
                                    }
                                    _selectedAllergies.value = newSet;
                                  },
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  allergy,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.family,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHealthGoalsSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            AppStrings.goalsTitle,
            Icons.track_changes,
            AppColors.primary,
          ),
          ValueListenableBuilder<String?>(
            valueListenable: _selectedGoal,
            builder: (context, selectedTitle, _) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2, // Adjust based on title + description
                ),
                itemCount: appGoals.length,
                itemBuilder: (context, index) {
                  final goal = appGoals[index];
                  final isSelected = selectedTitle == goal.title;

                  return GestureDetector(
                    onTap: () {
                      _selectedGoal.value = goal.title;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.input),
                        border: Border(
                          left: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 4.0 : 1.0,
                          ),
                          top: const BorderSide(color: AppColors.border),
                          right: const BorderSide(color: AppColors.border),
                          bottom: const BorderSide(color: AppColors.border),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            goal.icon,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            goal.title,
                            style: const TextStyle(
                              fontFamily: AppFonts.family,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal.description,
                            style: const TextStyle(
                              fontFamily: AppFonts.family,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              // TODO: wire _selectedConditions.value, _selectedAllergies.value, _selectedGoal.value to profileController
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
            child: const Text(
              AppStrings.saveButton,
              style: TextStyle(
                fontFamily: AppFonts.family,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
