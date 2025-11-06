import 'package:hooks_riverpod/legacy.dart';
import 'package:flutter/material.dart';
import 'package:muscyou/l10n/app_localizations.dart';

/// Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (_) => LocaleNotifier(),
);

/// Notifier
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(Locale('en'));

  void changeLocale(Locale locale) {
    if (state != locale && AppLocalizations.supportedLocales.contains(locale)) {
      state = locale;
    }
  }
}
