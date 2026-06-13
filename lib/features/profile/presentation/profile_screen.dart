import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sehat_sathi/core/localization/app_localizations.dart';
import 'package:sehat_sathi/core/localization/language_switcher.dart';
import 'package:sehat_sathi/core/localization/locale_providers.dart';
import 'package:sehat_sathi/core/theme/app_theme.dart';
import 'package:sehat_sathi/features/auth/presentation/providers/auth_providers.dart';
import 'package:sehat_sathi/features/profile/domain/models/health_profile.dart';
import 'package:sehat_sathi/features/profile/presentation/providers/health_profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentAuthSessionProvider);
    final profileState = ref.watch(healthProfileControllerProvider);
    final profile = profileState.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
          onPressed: () => context.go('/scanner'),
        ),
        title: Text(
          context.l10n.text('appTitle'),
          style: const TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textPrimary),
            onPressed: () async {
              try {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/');
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.text('profileLogoutFailed')),
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              _AvatarSection(email: session?.user?.email),
              const SizedBox(height: 32),
              _ProfileSummaryCard(profile: profile),
              const SizedBox(height: 24),
              const _HealthImpactCard(),
              const SizedBox(height: 32),
              const _HealthGoalsSection(),
              const SizedBox(height: 32),
              const _AccountDetailsSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            context.go('/scanner');
          }
        },
        selectedLabelStyle: const TextStyle(
          fontFamily: AppStyles.fontFamily,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: AppStyles.fontFamily,
          fontWeight: FontWeight.w500,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt_outlined),
            label: context.l10n.text('navScan'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: context.l10n.text('navHistory'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: context.l10n.text('navProfile'),
          ),
        ],
      ),
    );
  }
}

class _AvatarSection extends ConsumerWidget {
  const _AvatarSection({required this.email});

  final String? email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6EE7B7), width: 3),
              ),
              child: const CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=11',
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: AppColors.surface,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.text('profileYourProfile'),
          style: const TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email ?? context.l10n.text('profileSignedInWithSupabase'),
          style: const TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.text(
            'profileLanguagePrefix',
            params: {
              'language': context.l10n.languageLabel(locale.languageCode),
            },
          ),
          style: const TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        const LanguageSwitcher(),
      ],
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.profile});

  final HealthProfile? profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final conditionText = _displayValue(l10n, profile?.displayConditions);
    final allergyText = _displayValue(l10n, profile?.displayAllergies);
    final goalText = _displayValue(l10n, profile?.displayGoals);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              Expanded(
                child: Text(
                  l10n.text('profileHealthProfile'),
                  style: const TextStyle(
                    fontFamily: AppStyles.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/onboarding/profile'),
                child: Text(l10n.text('profileEdit')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProfileDetailRow(
            label: l10n.text('profileConditions'),
            value: conditionText,
          ),
          const SizedBox(height: 12),
          _ProfileDetailRow(
            label: l10n.text('profileAllergies'),
            value: allergyText,
          ),
          const SizedBox(height: 12),
          _ProfileDetailRow(label: l10n.text('profileGoals'), value: goalText),
        ],
      ),
    );
  }

  String _displayValue(AppLocalizations l10n, List<String>? values) {
    if (values == null || values.isEmpty) {
      return l10n.text('profileNotSet');
    }
    return values.map(l10n.healthOptionLabel).join(', ');
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _HealthImpactCard extends StatelessWidget {
  const _HealthImpactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppStyles.cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white70, size: 24),
              const SizedBox(width: 8),
              Text(
                context.l10n.text('profileHealthImpact'),
                style: const TextStyle(
                  fontFamily: AppStyles.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '12',
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surface,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.text('profileHarmfulChoicesAvoided'),
                    style: const TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '84%',
                    style: TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.text('profileCleanScore'),
                    style: const TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthGoalsSection extends StatelessWidget {
  const _HealthGoalsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.text('profileHealthGoals'),
              style: const TextStyle(
                fontFamily: AppStyles.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    context.l10n.text('profileAdjust'),
                    style: const TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _GoalChip(
                icon: Icons.no_meals_outlined,
                label: context.l10n.text('profileLowSugar'),
                iconColor: Colors.brown[600]!,
              ),
              const SizedBox(width: 12),
              _GoalChip(
                icon: Icons.eco_outlined,
                label: context.l10n.text('profileVegan'),
                iconColor: AppColors.success,
              ),
              const SizedBox(width: 12),
              _GoalChip(
                icon: Icons.favorite_border,
                label: context.l10n.text('profileHeartHealthy'),
                iconColor: Colors.orange[800]!,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(AppStyles.pillRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountDetailsSection extends StatelessWidget {
  const _AccountDetailsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.text('profileAccountDetails'),
          style: const TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppStyles.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _ProfileListTile(
                icon: Icons.person_outline,
                title: context.l10n.text('profileEditInfo'),
                showChevron: true,
              ),
              const Divider(
                height: 1,
                color: AppColors.divider,
                indent: 16,
                endIndent: 16,
              ),
              _ProfileListTile(
                icon: Icons.receipt_long_outlined,
                title: context.l10n.text('profileSubscriptionBilling'),
                showChevron: true,
              ),
              const Divider(
                height: 1,
                color: AppColors.divider,
                indent: 16,
                endIndent: 16,
              ),
              _ProfileListTile(
                icon: Icons.privacy_tip_outlined,
                title: context.l10n.text('profilePrivacySecurity'),
                showChevron: true,
              ),
              const Divider(
                height: 1,
                color: AppColors.divider,
                indent: 16,
                endIndent: 16,
              ),
              _ProfileListTile(
                icon: Icons.notifications_none,
                title: context.l10n.text('profileNotifications'),
                showChevron: true,
              ),
              const Divider(
                height: 1,
                color: AppColors.divider,
                indent: 16,
                endIndent: 16,
              ),
              _ProfileListTile(
                icon: Icons.help_outline,
                title: context.l10n.text('profileHelpSupport'),
                showChevron: true,
              ),
              const Divider(
                height: 1,
                color: AppColors.divider,
                indent: 16,
                endIndent: 16,
              ),
              _ProfileListTile(
                icon: Icons.logout,
                title: context.l10n.text('profileLogout'),
                titleColor: AppColors.error,
                iconColor: AppColors.error,
                showChevron: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileListTile extends StatelessWidget {
  const _ProfileListTile({
    required this.icon,
    required this.title,
    required this.showChevron,
    this.titleColor = AppColors.textPrimary,
    this.iconColor = AppColors.textSecondary,
  });

  final IconData icon;
  final String title;
  final bool showChevron;
  final Color titleColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: AppStyles.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      trailing: showChevron
          ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
          : null,
      onTap: () {},
    );
  }
}
