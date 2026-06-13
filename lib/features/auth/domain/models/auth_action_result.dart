class AuthActionResult {
  const AuthActionResult({
    required this.message,
    this.redirectTo,
    this.requiresEmailConfirmation = false,
  });

  final String message;
  final String? redirectTo;
  final bool requiresEmailConfirmation;
}
