import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:muscyou/features/home/home_screen.dart';
import 'package:muscyou/features/login/auth_state.dart';
import 'package:muscyou/features/login/login_screen.dart';
import 'package:muscyou/l10n/locale_provider.dart';
import 'package:muscyou/router/routes.dart';

/// ChangeNotifier that defines when GoRouter should refresh
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    // listen to dependencies change here...
    ref.listen(localeProvider, (_, _) => notifyListeners());
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}

final _routerNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "router");

/// Provider
final routerProvider = Provider<GoRouter>((ref) {
  final routerRefresh = _RouterRefreshNotifier(ref);
  final routes = ref.read(routesProvider);

  // On init
  // final initialLocation = LoginScreen.path;
  final initialLocation = HomeScreen.path;

  // On each redirection
  String? redirectFn(BuildContext context, GoRouterState state) {
    final loc = state.matchedLocation;

    final authenticated = ref.read(authProvider).isLoggedIn;

    final loggingIn = loc == LoginScreen.path;

    if (!authenticated && !loggingIn) return LoginScreen.path;
    if (authenticated && loggingIn) return HomeScreen.path;

    return null;
  }

  final goRouter = GoRouter(
    navigatorKey: _routerNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: routerRefresh,
    redirect: redirectFn,
    routes: routes,
  );

  return goRouter;
});
