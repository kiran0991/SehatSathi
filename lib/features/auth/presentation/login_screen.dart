import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/language_switcher.dart';
import '../../../core/theme/app_theme.dart';
import 'providers/auth_providers.dart';

enum AuthScreenMode { signIn, signUp }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthScreenMode _mode = AuthScreenMode.signIn;

  bool get _isSignIn => _mode == AuthScreenMode.signIn;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(authControllerProvider.notifier);

    try {
      final result = _isSignIn
          ? await controller.signIn(
              email: _emailController.text,
              password: _passwordController.text,
            )
          : await controller.signUp(
              email: _emailController.text,
              password: _passwordController.text,
            );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));

      if (result.redirectTo != null) {
        context.go(result.redirectTo!);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = _authErrorMessage(error);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message.toString())));
    }
  }

  String _authErrorMessage(Object error) {
    if (error is AuthException) {
      return error.message;
    }

    if (error is StateError) {
      return error.message.toString();
    }

    return context.l10n.text('authFailed');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isSubmitting = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HeaderSection(isSignIn: _isSignIn),
                          const SizedBox(height: 24),
                          const Center(child: LanguageSwitcher()),
                          const SizedBox(height: 24),
                          _ModeToggle(
                            mode: _mode,
                            onChanged: (mode) {
                              setState(() => _mode = mode);
                            },
                          ),
                          const SizedBox(height: 32),
                          _FormSection(
                            emailController: _emailController,
                            passwordController: _passwordController,
                          ),
                          const SizedBox(height: 16),
                          if (_isSignIn) const _ForgotPasswordLink(),
                          if (_isSignIn) const SizedBox(height: 24),
                          _ActionSection(
                            isSignIn: _isSignIn,
                            isSubmitting: isSubmitting,
                            onPressed: isSubmitting ? null : _submit,
                          ),
                          const Spacer(),
                          const SizedBox(height: 48),
                          _FooterSection(
                            isSignIn: _isSignIn,
                            onTap: () {
                              setState(() {
                                _mode = _isSignIn
                                    ? AuthScreenMode.signUp
                                    : AuthScreenMode.signIn;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.isSignIn});

  final bool isSignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.eco_outlined,
            color: AppColors.surface,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.text('appTitle'),
          style: TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 40),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            isSignIn
                ? context.l10n.text('authWelcomeBack')
                : context.l10n.text('authCreateAccount'),
            style: const TextStyle(
              fontFamily: AppStyles.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isSignIn
              ? context.l10n.text('authSignInSubtitle')
              : context.l10n.text('authSignUpSubtitle'),
          style: const TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final AuthScreenMode mode;
  final ValueChanged<AuthScreenMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyles.inputRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _ModeTab(
            label: context.l10n.text('authLogin'),
            isActive: mode == AuthScreenMode.signIn,
            onTap: () => onChanged(AuthScreenMode.signIn),
          ),
          _ModeTab(
            label: context.l10n.text('authSignUp'),
            isActive: mode == AuthScreenMode.signUp,
            onTap: () => onChanged(AuthScreenMode.signUp),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.inputRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppStyles.inputRadius),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.surface : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.text('authEmailLabel'),
          style: TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty || !trimmed.contains('@')) {
              return context.l10n.text('authInvalidEmail');
            }
            return null;
          },
          decoration: _inputDecoration(
            hintText: context.l10n.text('authEmailHint'),
            icon: Icons.mail_outline,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          context.l10n.text('authPasswordLabel'),
          style: TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.length < 6) {
              return context.l10n.text('authInvalidPassword');
            }
            return null;
          },
          decoration:
              _inputDecoration(
                hintText: context.l10n.text('authPasswordHint'),
                icon: Icons.lock_outline,
              ).copyWith(
                suffixIcon: const Icon(
                  Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: AppStyles.fontFamily,
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppStyles.inputRadius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppStyles.inputRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppStyles.inputRadius),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppStyles.inputRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }
}

class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        context.l10n.text('authForgotPassword'),
        style: const TextStyle(
          fontFamily: AppStyles.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  const _ActionSection({
    required this.isSignIn,
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool isSignIn;
  final bool isSubmitting;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.surface,
                    ),
                  )
                : Text(
                    isSignIn
                        ? context.l10n.text('authLogin')
                        : context.l10n.text('authCreateButton'),
                    style: const TextStyle(
                      fontFamily: AppStyles.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection({required this.isSignIn, required this.onTap});

  final bool isSignIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          isSignIn
              ? context.l10n.text('authNoAccount')
              : context.l10n.text('authAlreadyAccount'),
          style: const TextStyle(
            fontFamily: AppStyles.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onTap,
          child: Text(
            isSignIn
                ? context.l10n.text('authSignUp')
                : context.l10n.text('authLogin'),
            style: const TextStyle(
              fontFamily: AppStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
