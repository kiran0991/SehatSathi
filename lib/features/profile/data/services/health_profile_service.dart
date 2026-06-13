import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract class HealthProfileService {
  Map<String, dynamic>? get currentProfileMetadata;

  Future<Map<String, dynamic>?> loadProfile();

  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> profile);
}

class SupabaseHealthProfileService implements HealthProfileService {
  SupabaseHealthProfileService(this._client);

  final supabase.SupabaseClient _client;

  @override
  Map<String, dynamic>? get currentProfileMetadata {
    final metadata = _client.auth.currentUser?.userMetadata?['health_profile'];
    return _asMap(metadata);
  }

  @override
  Future<Map<String, dynamic>?> loadProfile() async {
    return currentProfileMetadata;
  }

  @override
  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> profile) async {
    final currentMetadata = Map<String, dynamic>.from(
      _client.auth.currentUser?.userMetadata ?? const {},
    );

    currentMetadata['health_profile'] = profile;

    final response = await _client.auth.updateUser(
      supabase.UserAttributes(data: currentMetadata),
    );

    final savedProfile = _asMap(response.user?.userMetadata?['health_profile']);

    if (savedProfile == null) {
      throw StateError('Unable to save your health profile right now.');
    }

    return savedProfile;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }

    return null;
  }
}

class UnconfiguredHealthProfileService implements HealthProfileService {
  static const _message =
      'Supabase is not configured. Pass `SUPABASE_URL` and '
      '`SUPABASE_ANON_KEY` when running the app.';

  @override
  Map<String, dynamic>? get currentProfileMetadata => null;

  @override
  Future<Map<String, dynamic>?> loadProfile() async => null;

  @override
  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> profile) {
    throw StateError(_message);
  }
}
