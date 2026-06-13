import '../../domain/models/auth_session.dart';
import '../services/auth_service.dart';

class AuthRepository {
  const AuthRepository(this._authService);

  final AuthService _authService;

  AuthSession? get currentSession => _authService.currentSession;

  Stream<AuthSession?> authStateChanges() => _authService.authStateChanges();

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) {
    return _authService.signIn(email: email, password: password);
  }

  Future<AuthSession> signUp({
    required String email,
    required String password,
  }) {
    return _authService.signUp(email: email, password: password);
  }

  Future<void> signOut() => _authService.signOut();
}
