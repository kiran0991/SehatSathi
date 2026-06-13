import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sehat_sathi/features/auth/data/repositories/auth_repository.dart';
import 'package:sehat_sathi/features/auth/data/services/auth_service.dart';
import 'package:sehat_sathi/features/auth/domain/models/auth_session.dart';
import 'package:sehat_sathi/features/auth/domain/models/auth_user.dart';
import 'package:sehat_sathi/features/auth/presentation/providers/auth_providers.dart';

void main() {
  group('AuthController', () {
    test('signIn returns scanner redirect for authenticated session', () async {
      final service = FakeAuthService(
        signInResult: const AuthSession(
          user: AuthUser(
            id: 'auth-1',
            email: 'user@example.com',
            isEmailVerified: true,
          ),
          accessToken: 'token',
          requiresEmailConfirmation: false,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(AuthRepository(service)),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.signIn(
        email: 'user@example.com',
        password: 'password123',
      );

      expect(result.redirectTo, '/scanner');
      expect(result.requiresEmailConfirmation, isFalse);
    });

    test(
      'signUp returns verification message when session is pending',
      () async {
        final service = FakeAuthService(
          signUpResult: const AuthSession(
            user: AuthUser(
              id: 'auth-2',
              email: 'pending@example.com',
              isEmailVerified: false,
            ),
            accessToken: null,
            requiresEmailConfirmation: true,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(AuthRepository(service)),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(authControllerProvider.notifier);
        final result = await controller.signUp(
          email: 'pending@example.com',
          password: 'password123',
        );

        expect(result.requiresEmailConfirmation, isTrue);
        expect(result.redirectTo, isNull);
      },
    );
  });
}

class FakeAuthService implements AuthService {
  FakeAuthService({
    this.signInResult = AuthSession.unauthenticated,
    this.signUpResult = AuthSession.unauthenticated,
  });

  final AuthSession signInResult;
  final AuthSession signUpResult;
  bool signOutCalled = false;

  @override
  AuthSession? get currentSession =>
      signInResult.isAuthenticated ? signInResult : null;

  @override
  Stream<AuthSession?> authStateChanges() => const Stream.empty();

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    return signInResult;
  }

  @override
  Future<AuthSession> signUp({
    required String email,
    required String password,
  }) async {
    return signUpResult;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}
