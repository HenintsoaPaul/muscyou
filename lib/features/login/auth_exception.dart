import 'package:muscyou/l10n/app_localizations.dart';

class AuthException implements Exception {
  String message(AppLocalizations l10n) => l10n.authFailure;
}