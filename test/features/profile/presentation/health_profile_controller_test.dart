import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sehat_sathi/features/profile/data/repositories/health_profile_repository.dart';
import 'package:sehat_sathi/features/profile/data/services/health_profile_service.dart';
import 'package:sehat_sathi/features/profile/domain/models/health_profile.dart';
import 'package:sehat_sathi/features/profile/presentation/providers/health_profile_providers.dart';

void main() {
  group('HealthProfileController', () {
    test('loads first-time defaults when no saved profile exists', () async {
      final container = ProviderContainer(
        overrides: [
          healthProfileRepositoryProvider.overrideWithValue(
            HealthProfileRepository(FakeHealthProfileService()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final profile = await container.read(
        healthProfileControllerProvider.future,
      );

      expect(profile.conditions, [HealthProfile.none]);
      expect(profile.allergies, [HealthProfile.none]);
      expect(profile.goal, HealthProfile.none);
    });

    test(
      'custom condition removes none and save persists normalized profile',
      () async {
        final service = FakeHealthProfileService();
        final container = ProviderContainer(
          overrides: [
            healthProfileRepositoryProvider.overrideWithValue(
              HealthProfileRepository(service),
            ),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          healthProfileControllerProvider.notifier,
        );
        await container.read(healthProfileControllerProvider.future);

        controller.updateCustomCondition('PCOS');
        controller.selectGoal(HealthProfile.weightLoss);
        final saved = await controller.save();

        expect(saved.conditions, [HealthProfile.none]);
        expect(saved.customCondition, 'PCOS');
        expect(saved.goal, HealthProfile.weightLoss);
        expect(service.savedProfile?['custom_condition'], 'PCOS');
      },
    );

    test('selecting a condition clears none', () async {
      final container = ProviderContainer(
        overrides: [
          healthProfileRepositoryProvider.overrideWithValue(
            HealthProfileRepository(FakeHealthProfileService()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        healthProfileControllerProvider.notifier,
      );
      await container.read(healthProfileControllerProvider.future);

      controller.toggleCondition(HealthProfile.diabetes, true);

      final state = container
          .read(healthProfileControllerProvider)
          .requireValue;
      expect(state.conditions, [HealthProfile.diabetes]);
    });
  });
}

class FakeHealthProfileService implements HealthProfileService {
  FakeHealthProfileService({this.initialProfile});

  final Map<String, dynamic>? initialProfile;
  Map<String, dynamic>? savedProfile;

  @override
  Map<String, dynamic>? get currentProfileMetadata =>
      savedProfile ?? initialProfile;

  @override
  Future<Map<String, dynamic>?> loadProfile() async => initialProfile;

  @override
  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> profile) async {
    savedProfile = Map<String, dynamic>.from(profile);
    return savedProfile!;
  }
}
