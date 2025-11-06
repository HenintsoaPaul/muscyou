import 'package:go_router/go_router.dart';
import 'package:muscyou/features/home/home_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:muscyou/features/login/login_screen.dart';

/// Provider
final routesProvider = Provider<List<GoRoute>>((_) => routes);

/// Routes
final routes = <GoRoute>[
  /// Login
  GoRoute(
    path: LoginScreen.path,
    name: LoginScreen.name,
    builder: (context, state) {
      return LoginScreen();
    },
  ),

  /// Home
  GoRoute(
    path: HomeScreen.path,
    name: HomeScreen.name,
    builder: (context, state) {
      return HomeScreen();
    },
  ),
];
