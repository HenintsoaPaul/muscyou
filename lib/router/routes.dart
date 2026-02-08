import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:muscyou/features/home/home_screen.dart';
import 'package:muscyou/features/login/login_screen.dart';
import 'package:muscyou/features/dashboard/dashboard_screen.dart';
import 'package:muscyou/features/exercises/exercise_list_screen.dart';
import 'package:muscyou/features/session/active_session_screen.dart';
import 'package:muscyou/features/settings/settings_screen.dart';

/// Provider
final routesProvider = Provider<List<GoRoute>>((_) => routes);

/// Routes
final routes = <GoRoute>[
  /// Login
  GoRoute(
    path: LoginScreen.path,
    name: LoginScreen.name,
    builder: (context, state) {
      return const LoginScreen();
    },
  ),

  /// Home
  GoRoute(
    path: HomeScreen.path,
    name: HomeScreen.name,
    builder: (context, state) {
      return const HomeScreen();
    },
  ),

  /// Dashboard
  GoRoute(
    path: DashboardScreen.path,
    name: DashboardScreen.name,
    builder: (context, state) {
      return const DashboardScreen();
    },
  ),

  /// Exercises
  GoRoute(
    path: ExerciseListScreen.path,
    name: ExerciseListScreen.name,
    builder: (context, state) {
      return const ExerciseListScreen();
    },
  ),

  /// Active Session
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
];
