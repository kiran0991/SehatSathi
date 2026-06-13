import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_bootstrap.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/auth_service.dart';
import '../../domain/models/auth_action_result.dart';
import '../../domain/models/auth_session.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  if (!SupabaseBootstrapConfig.isConfigured) {
    return UnconfiguredAuthService();
  }

  return SupabaseAuthService(Supabase.instance.client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(authServiceProvider));
});

final authSessionProvider = StreamProvider<AuthSession?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

final currentAuthSessionProvider = Provider<AuthSession?>((ref) {
  final sessionAsync = ref.watch(authSessionProvider);
  return sessionAsync.maybeWhen(
    data: (session) => session,
    orElse: () => ref.watch(authRepositoryProvider).currentSession,
  );
});

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  FutureOr<void> build() {}

  Future<AuthActionResult> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      final session = await _repository.signIn(
        email: email.trim(),
        password: password.trim(),
      );

      if (!session.isAuthenticated) {
        throw StateError('Unable to establish a session. Please try again.');
      }
    });
    state = nextState;

    if (nextState.hasError) {
      throw nextState.error!;
    }

    return const AuthActionResult(
      message: 'Welcome back to Sehat Sathi.',
      redirectTo: '/scanner',
    );
  }

  Future<AuthActionResult> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    late final AuthSession session;

    final nextState = await AsyncValue.guard(() async {
      session = await _repository.signUp(
        email: email.trim(),
        password: password.trim(),
      );
    });
    state = nextState;

    if (nextState.hasError) {
      throw nextState.error!;
    }

    if (session.requiresEmailConfirmation) {
      return const AuthActionResult(
        message: 'Account created. Please verify your email before logging in.',
        requiresEmailConfirmation: true,
      );
    }

    return const AuthActionResult(
      message: 'Account created. Let’s personalize your profile.',
      redirectTo: '/onboarding/profile',
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(_repository.signOut);
    state = nextState;

    if (nextState.hasError) {
      throw nextState.error!;
    }
  }
}

class AuthRouterRefreshNotifier extends ChangeNotifier {
  AuthRouterRefreshNotifier(Stream<AuthSession?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthSession?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
