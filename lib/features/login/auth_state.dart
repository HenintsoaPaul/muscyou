import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:muscyou/data/local/model/user.dart';
import 'package:muscyou/data/local/repository/user_repository.dart';
import 'package:muscyou/features/login/auth_exception.dart';

/// Provider
final authProvider = StateNotifierProvider((ref) {
  final repo = ref.read(userRepositoryProvider);
  return AuthNotifier(userRepository: repo);
});

/// Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({required this.userRepository})
    : super(AuthState(user: null, loggedAt: null));

  final UserRepository userRepository;

  bool get isLoggedIn => state.isLoggedIn;

  Future<void> authenticate(String username, String password) async {
    User? user = await userRepository.authenticateUser(username, password);
    if (user == null) {
      throw AuthException();
    } else {
      state = state.copyWith(user: user, loggedAt: DateTime.now());
    }
  }
}

/// State
@immutable
class AuthState {
  final User? user;
  final DateTime? loggedAt;

  const AuthState({required this.user, required this.loggedAt});

  bool get isLoggedIn => user != null;

  AuthState copyWith({required User? user, required DateTime? loggedAt}) =>
      AuthState(user: user ?? user, loggedAt: loggedAt ?? loggedAt);
}
