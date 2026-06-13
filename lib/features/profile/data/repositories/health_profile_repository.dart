import '../../domain/models/health_profile.dart';
import '../services/health_profile_service.dart';

class HealthProfileRepository {
  const HealthProfileRepository(this._service);

  final HealthProfileService _service;

  HealthProfile? get currentProfile {
    final metadata = _service.currentProfileMetadata;
    if (metadata == null) {
      return null;
    }

    return HealthProfile.fromMetadata(metadata);
  }

  bool get hasSavedProfile => currentProfile != null;

  Future<HealthProfile?> loadProfile() async {
    final metadata = await _service.loadProfile();
    if (metadata == null) {
      return null;
    }

    return HealthProfile.fromMetadata(metadata);
  }

  Future<HealthProfile> saveProfile(HealthProfile profile) async {
    final saved = await _service.saveProfile(profile.toMetadata());
    return HealthProfile.fromMetadata(saved);
  }
}
