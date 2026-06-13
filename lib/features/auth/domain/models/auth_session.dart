import 'auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.requiresEmailConfirmation,
  });

  final AuthUser? user;
  final String? accessToken;
  final bool requiresEmailConfirmation;

  bool get isAuthenticated => user != null && accessToken != null;

  static const unauthenticated = AuthSession(
    user: null,
    accessToken: null,
    requiresEmailConfirmation: false,
  );
}
