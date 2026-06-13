import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/supabase/supabase_bootstrap.dart';
import '../../domain/models/auth_session.dart';
import '../../domain/models/auth_user.dart';

abstract class AuthService {
  AuthSession? get currentSession;

  Stream<AuthSession?> authStateChanges();

  Future<AuthSession> signIn({required String email, required String password});

  Future<AuthSession> signUp({required String email, required String password});

  Future<void> signOut();
}

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client);

  final supabase.SupabaseClient _client;

  @override
  AuthSession? get currentSession => _mapSession(
    _client.auth.currentSession,
    fallbackUser: _client.auth.currentUser,
  );

  @override
  Stream<AuthSession?> authStateChanges() {
    return _client.auth.onAuthStateChange.map(
      (event) => _mapSession(event.session, fallbackUser: event.session?.user),
    );
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return _mapSession(
          response.session,
          fallbackUser: response.user ?? _client.auth.currentUser,
        ) ??
        AuthSession.unauthenticated;
  }

  @override
  Future<AuthSession> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    return _mapSession(response.session, fallbackUser: response.user) ??
        AuthSession.unauthenticated;
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut();
  }

  AuthSession? _mapSession(
    supabase.Session? session, {
    supabase.User? fallbackUser,
  }) {
    final user = session?.user ?? fallbackUser;
    if (user == null) {
      return null;
    }

    final appUser = AuthUser(
      id: user.id,
      email: user.email ?? '',
      isEmailVerified: user.emailConfirmedAt != null,
    );

    return AuthSession(
      user: appUser,
      accessToken: session?.accessToken,
      requiresEmailConfirmation:
          session == null && user.emailConfirmedAt == null,
    );
  }
}

class UnconfiguredAuthService implements AuthService {
  static const _message =
      'Supabase Authentication is not configured. Pass '
      '`--dart-define=SUPABASE_URL=...` and '
      '`--dart-define=SUPABASE_ANON_KEY=...` when running the app.';

  @override
  AuthSession? get currentSession => null;

  @override
  Stream<AuthSession?> authStateChanges() => const Stream.empty();

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) {
    throw StateError(_message);
  }

  @override
  Future<AuthSession> signUp({
    required String email,
    required String password,
  }) {
    throw StateError(_message);
  }

  @override
  Future<void> signOut() {
    throw StateError(_message);
  }

  bool get isConfigured => SupabaseBootstrapConfig.isConfigured;
}
