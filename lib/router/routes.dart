import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:muscyou/features/home/home_screen.dart';
import 'package:muscyou/features/login/login_screen.dart';
import 'package:muscyou/features/dashboard/dashboard_screen.dart';
import 'package:muscyou/features/exercises/exercise_list_screen.dart';
import 'package:muscyou/features/session/active_session_screen.dart';
import 'package:muscyou/features/settings/settings_screen.dart';
import 'package:muscyou/main_scaffold.dart';

/// Provider
final routesProvider = Provider<List<RouteBase>>((_) => routes);

/// Routes
final routes = <RouteBase>[
  /// Login
  GoRoute(
    path: LoginScreen.path,
    name: LoginScreen.name,
    builder: (context, state) {
      return const LoginScreen();
    },
  ),

  /// Active Session (Fullscreen)
  GoRoute(
    path: ActiveSessionScreen.path,
    name: ActiveSessionScreen.name,
    builder: (context, state) {
      return const ActiveSessionScreen();
    },
  ),

  /// Settings
  GoRoute(
    path: SettingsScreen.path,
    name: SettingsScreen.name,
    builder: (context, state) {
      return const SettingsScreen();
    },
  ),

  /// Bottom Navigation Shell
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return MainScaffold(navigationShell: navigationShell);
    },
    branches: [
      /// Home Branch
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: HomeScreen.path,
            name: HomeScreen.name,
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      ),

      /// Session Branch (Dashboard repurpose)
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: DashboardScreen.path,
            name: DashboardScreen.name,
            builder: (context, state) => const DashboardScreen(),
          ),
        ],
      ),

      /// Exercises Branch
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: ExerciseListScreen.path,
            name: ExerciseListScreen.name,
            builder: (context, state) => const ExerciseListScreen(),
          ),
        ],
      ),
    ],
  ),
];
