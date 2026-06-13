import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/domain/models/health_profile.dart';
import '../../profile/presentation/providers/health_profile_providers.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _customConditionController = TextEditingController();
  final _customAllergyController = TextEditingController();

  @override
  void dispose() {
    _customConditionController.dispose();
    _customAllergyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await ref.read(healthProfileControllerProvider.notifier).save();
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.text('profileSaved'))),
      );
      context.go('/scanner');
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(healthProfileControllerProvider);
    final profile = profileState.value ?? HealthProfile.initial();

    if (_customConditionController.text != profile.customCondition) {
      _customConditionController.text = profile.customCondition;
    }

    if (_customAllergyController.text != profile.customAllergy) {
      _customAllergyController.text = profile.customAllergy;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/profile'),
        ),
        title: Text(
          context.l10n.text('profileEditTitle'),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: AppStyles.fontFamily,
          ),
        ),
        centerTitle: true,
      ),
      body: profileState.isLoading && profileState.value == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.text('profileEditHeader'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: AppStyles.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.text('profileEditSubtitle'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontFamily: AppStyles.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _SectionCard(
                    title: context.l10n.text('profileConditions'),
                    icon: Icons.medical_services_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 12,
                          children: HealthProfile.availableConditions.map((
                            condition,
                          ) {
                            return _SelectableChip(
                              label: context.l10n.healthOptionLabel(condition),
                              isSelected: profile.conditions.contains(
                                condition,
                              ),
                              onTap: () {
                                ref
                                    .read(
                                      healthProfileControllerProvider.notifier,
                                    )
                                    .toggleCondition(
                                      condition,
                                      !profile.conditions.contains(condition),
                                    );
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _customConditionController,
                          onChanged: ref
                              .read(healthProfileControllerProvider.notifier)
                              .updateCustomCondition,
                          decoration: InputDecoration(
                            labelText: context.l10n.text(
                              'profileAddConditionLabel',
                            ),
                            hintText: context.l10n.text(
                              'profileAddConditionHint',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionCard(
                    title: context.l10n.text('profileAllergies'),
                    icon: Icons.warning_amber_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 12,
                          children: HealthProfile.availableAllergies.map((
                            allergy,
                          ) {
                            return _SelectableChip(
                              label: context.l10n.healthOptionLabel(allergy),
                              isSelected: profile.allergies.contains(allergy),
                              onTap: () {
                                ref
                                    .read(
                                      healthProfileControllerProvider.notifier,
                                    )
                                    .toggleAllergy(
                                      allergy,
                                      !profile.allergies.contains(allergy),
                                    );
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _customAllergyController,
                          onChanged: ref
                              .read(healthProfileControllerProvider.notifier)
                              .updateCustomAllergy,
                          decoration: InputDecoration(
                            labelText: context.l10n.text(
                              'profileAddAllergyLabel',
                            ),
                            hintText: context.l10n.text(
                              'profileAddAllergyHint',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionCard(
                    title: context.l10n.text('profileGoals'),
                    icon: Icons.star_outline,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 12,
                      children: HealthProfile.availableGoals.map((goal) {
                        return _SelectableChip(
                          label: context.l10n.healthOptionLabel(goal),
                          isSelected: profile.goal == goal,
                          onTap: () {
                            ref
                                .read(healthProfileControllerProvider.notifier)
                                .selectGoal(goal);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: ElevatedButton(
          onPressed: profileState.isLoading ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.inputRadius),
            ),
            elevation: 0,
          ),
          child: profileState.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.surface,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  context.l10n.text('profileSaveContinue'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppStyles.fontFamily,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyles.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: AppStyles.fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.pillRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppStyles.pillRadius),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.surface : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontFamily: AppStyles.fontFamily,
          ),
        ),
      ),
    );
  }
}
