import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_sathi/features/profile/domain/models/health_profile.dart';

void main() {
  group('HealthProfile', () {
    test('initial profile selects none by default', () {
      final profile = HealthProfile.initial();

      expect(profile.conditions, [HealthProfile.none]);
      expect(profile.allergies, [HealthProfile.none]);
      expect(profile.goal, HealthProfile.none);
    });

    test('metadata parsing keeps none exclusive', () {
      final profile = HealthProfile.fromMetadata({
        'conditions': ['None', 'Diabetes'],
        'allergies': ['None', 'Dairy'],
        'goal': 'Healthy Eating',
      });

      expect(profile.conditions, [HealthProfile.none]);
      expect(profile.allergies, [HealthProfile.none]);
      expect(profile.goal, HealthProfile.healthyEating);
    });
  });
}
