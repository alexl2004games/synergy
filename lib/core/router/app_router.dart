import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/application/auth_notifier.dart';
import '../auth/application/auth_service.dart';
import 'app_shell.dart';
import '../../features/tasks/presentation/screens/inbox_screen.dart';
import '../../features/tasks/presentation/screens/upcoming_screen.dart';
import '../../features/tasks/presentation/screens/calendar_screen.dart';
import '../../features/tasks/presentation/screens/spaces_screen.dart';
import '../../features/tasks/presentation/screens/today_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/checkin/presentation/screens/check_in_screen.dart';
import '../../features/search/presentation/task_search_screen.dart';
import '../../features/ai_engine/presentation/screens/gemma_diagnostic_screen.dart';
import 'route_placeholders.dart';
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);
  return GoRouter(
    initialLocation: '/today',
    refreshListenable: refreshNotifier,
    redirect: (context, state) async {
      final path = state.uri.path;
      final isOnboardingRoute = path == '/onboarding';
      final isLockRoute = path == '/lock';
      final authService = ref.read(authServiceProvider);
      final authState = ref.read(authNotifierProvider);
      final onboardingCompleted = await authService.isOnboardingCompleted();
      if (!onboardingCompleted) {
        return isOnboardingRoute ? null : '/onboarding';
      }
      final hasPin = await authService.hasPin();
      if (!hasPin) {
        if (isOnboardingRoute || isLockRoute) {
          return '/today';
        }
        return null;
      }
      if (authState != AuthState.authenticated && !isLockRoute) {
        return '/lock';
      }
      if (authState == AuthState.authenticated &&
          (isOnboardingRoute || isLockRoute)) {
        return '/today';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockRouteScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingRouteScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/task/:id',
        builder: (context, state) =>
            TaskDetailsRouteScreen(taskId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          fullscreenDialog: true,
          child: const TaskSearchScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
              reverseCurve: Curves.easeInQuart,
            );
            return FadeTransition(
              opacity: curvedAnimation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(curvedAnimation),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, -0.05),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: '/checkin',
        pageBuilder: (context, state) => const MaterialPage<void>(
          fullscreenDialog: true,
          child: CheckInScreen(),
        ),
      ),
      GoRoute(
        path: '/gemma-diagnostic',
        builder: (context, state) => const GemmaDiagnosticScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbox',
                builder: (context, state) => const InboxScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/upcoming',
                builder: (context, state) => const UpcomingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/spaces',
                builder: (context, state) => const SpacesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(
      authNotifierProvider,
      (_, __) {
        notifyListeners();
      },
    );
  }
}
