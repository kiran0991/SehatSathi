import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_bootstrap.dart';
import '../../data/repositories/health_profile_repository.dart';
import '../../data/services/health_profile_service.dart';
import '../../domain/models/health_profile.dart';

final healthProfileServiceProvider = Provider<HealthProfileService>((ref) {
  if (!SupabaseBootstrapConfig.isConfigured) {
    return UnconfiguredHealthProfileService();
  }

  return SupabaseHealthProfileService(Supabase.instance.client);
});

final healthProfileRepositoryProvider = Provider<HealthProfileRepository>((
  ref,
) {
  return HealthProfileRepository(ref.watch(healthProfileServiceProvider));
});

final hasSavedHealthProfileProvider = Provider<bool>((ref) {
  final profile = ref.watch(healthProfileControllerProvider).value;
  return profile?.isSaved ?? false;
});

final healthProfileControllerProvider =
    AsyncNotifierProvider<HealthProfileController, HealthProfile>(
      HealthProfileController.new,
    );

class HealthProfileController extends AsyncNotifier<HealthProfile> {
  HealthProfileRepository get _repository =>
      ref.read(healthProfileRepositoryProvider);

  @override
  FutureOr<HealthProfile> build() async {
    return await _repository.loadProfile() ?? HealthProfile.initial();
  }

  void toggleCondition(String condition, bool selected) {
    final current = state.value ?? HealthProfile.initial();
    final updated = Set<String>.from(current.conditions);

    if (condition == HealthProfile.none) {
      state = AsyncData(
        current.copyWith(
          conditions: const [HealthProfile.none],
          customCondition: '',
        ),
      );
      return;
    }

    updated.remove(HealthProfile.none);

    if (selected) {
      updated.add(condition);
    } else {
      updated.remove(condition);
    }

    state = AsyncData(
      current.copyWith(
        conditions: updated.isEmpty
            ? const [HealthProfile.none]
            : updated.toList(),
      ),
    );
  }

  void updateCustomCondition(String value) {
    final current = state.value ?? HealthProfile.initial();
    final trimmed = value.trim();

    state = AsyncData(
      current.copyWith(
        customCondition: trimmed,
        conditions: trimmed.isNotEmpty
            ? current.conditions
                  .where((value) => value != HealthProfile.none)
                  .toList()
            : current.conditions,
      ),
    );
  }

  void toggleAllergy(String allergy, bool selected) {
    final current = state.value ?? HealthProfile.initial();
    final updated = Set<String>.from(current.allergies);

    if (allergy == HealthProfile.none) {
      state = AsyncData(
        current.copyWith(
          allergies: const [HealthProfile.none],
          customAllergy: '',
        ),
      );
      return;
    }

    updated.remove(HealthProfile.none);

    if (selected) {
      updated.add(allergy);
    } else {
      updated.remove(allergy);
    }

    state = AsyncData(
      current.copyWith(
        allergies: updated.isEmpty
            ? const [HealthProfile.none]
            : updated.toList(),
      ),
    );
  }

  void updateCustomAllergy(String value) {
    final current = state.value ?? HealthProfile.initial();
    final trimmed = value.trim();

    state = AsyncData(
      current.copyWith(
        customAllergy: trimmed,
        allergies: trimmed.isNotEmpty
            ? current.allergies
                  .where((value) => value != HealthProfile.none)
                  .toList()
            : current.allergies,
      ),
    );
  }

  void selectGoal(String goal) {
    final current = state.value ?? HealthProfile.initial();
    state = AsyncData(current.copyWith(goal: goal));
  }

  Future<HealthProfile> save() async {
    final current = state.value ?? HealthProfile.initial();
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      return _repository.saveProfile(_normalized(current));
    });
    state = nextState;

    if (nextState.hasError) {
      throw nextState.error!;
    }

    return nextState.requireValue;
  }

  HealthProfile _normalized(HealthProfile profile) {
    final normalizedConditions = profile.conditions
        .where((value) => value != HealthProfile.none)
        .toList();
    final normalizedAllergies = profile.allergies
        .where((value) => value != HealthProfile.none)
        .toList();

    return profile.copyWith(
      conditions: normalizedConditions.isEmpty
          ? const [HealthProfile.none]
          : normalizedConditions,
      allergies: normalizedAllergies.isEmpty
          ? const [HealthProfile.none]
          : normalizedAllergies,
      goal: HealthProfile.availableGoals.contains(profile.goal)
          ? profile.goal
          : HealthProfile.none,
    );
  }
}
