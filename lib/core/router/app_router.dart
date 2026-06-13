import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analysis/presentation/scan_result_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/onboarding/presentation/profile_edit_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/providers/health_profile_providers.dart';
import '../../features/scanner/presentation/scanner_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final refreshNotifier = RouterRefreshNotifier();

  ref.listen(currentAuthSessionProvider, (_, __) {
    refreshNotifier.refresh();
  });

  ref.listen(healthProfileControllerProvider, (_, __) {
    refreshNotifier.refresh();
  });

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isAuthenticated =
          repository.currentSession?.isAuthenticated ?? false;
      final hasSavedProfile = ref.read(hasSavedHealthProfileProvider);
      final location = state.matchedLocation;
      final isAuthRoute = location == '/';
      final isOnboardingRoute = location == '/onboarding/profile';

      if (!isAuthenticated && !isAuthRoute) {
        return '/';
      }

      if (isAuthenticated && !hasSavedProfile && !isOnboardingRoute) {
        return '/onboarding/profile';
      }

      if (isAuthenticated &&
          hasSavedProfile &&
          (isAuthRoute || isOnboardingRoute)) {
        return '/scanner';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/onboarding/profile',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/result',
        builder: (context, state) =>
            ScanResultScreen(payload: state.extra as dynamic),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}
