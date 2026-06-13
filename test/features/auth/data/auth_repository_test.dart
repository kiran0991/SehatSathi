import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_sathi/features/auth/data/repositories/auth_repository.dart';
import 'package:sehat_sathi/features/auth/data/services/auth_service.dart';
import 'package:sehat_sathi/features/auth/domain/models/auth_session.dart';
import 'package:sehat_sathi/features/auth/domain/models/auth_user.dart';

void main() {
  group('AuthRepository', () {
    test('proxies sign in and exposes current session', () async {
      const session = AuthSession(
        user: AuthUser(
          id: 'user-1',
          email: 'user@example.com',
          isEmailVerified: true,
        ),
        accessToken: 'token-1',
        requiresEmailConfirmation: false,
      );

      final service = FakeAuthService(currentSessionValue: session);
      final repository = AuthRepository(service);

      final result = await repository.signIn(
        email: 'user@example.com',
        password: 'password123',
      );

      expect(result.isAuthenticated, isTrue);
      expect(repository.currentSession?.user?.email, 'user@example.com');
      expect(service.lastSignInEmail, 'user@example.com');
    });

    test('forwards auth state changes', () async {
      final controller = StreamController<AuthSession?>();
      final service = FakeAuthService(streamController: controller);
      final repository = AuthRepository(service);

      addTearDown(controller.close);

      const session = AuthSession(
        user: AuthUser(
          id: 'user-2',
          email: 'watcher@example.com',
          isEmailVerified: true,
        ),
        accessToken: 'token-2',
        requiresEmailConfirmation: false,
      );

      expectLater(repository.authStateChanges(), emits(session));
      controller.add(session);
    });
  });
}

class FakeAuthService implements AuthService {
  FakeAuthService({
    AuthSession? currentSessionValue,
    StreamController<AuthSession?>? streamController,
  }) : _currentSession = currentSessionValue,
       _controller =
           streamController ?? StreamController<AuthSession?>.broadcast();

  final AuthSession? _currentSession;
  final StreamController<AuthSession?> _controller;
  String? lastSignInEmail;

  @override
  AuthSession? get currentSession => _currentSession;

  @override
  Stream<AuthSession?> authStateChanges() => _controller.stream;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    lastSignInEmail = email;
    return _currentSession ?? AuthSession.unauthenticated;
  }

  @override
  Future<AuthSession> signUp({
    required String email,
    required String password,
  }) async {
    return _currentSession ?? AuthSession.unauthenticated;
  }

  @override
  Future<void> signOut() async {}
}
