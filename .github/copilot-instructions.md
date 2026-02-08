## Purpose

This project is a small Flutter app (muscyou) that uses Riverpod, GoRouter, and Flutter's generated localization. These instructions give an AI coding agent the minimal, actionable context to be productive: architecture, developer workflows, project conventions, and integration points.

## Quick commands (PowerShell)

Run once:

```
flutter pub get
```

Run/debug on a device:

```
flutter run -d <device-id>    # e.g. flutter run -d windows or flutter run -d emulator-5554
```

Run tests and static checks:

```
flutter test 
flutter analyze
```

Notes: `flutter` is the canonical tool. The pubspec uses `flutter.generate: true` so localization is generated when running `flutter pub get` or `flutter run`.

## Big-picture architecture

- Single Flutter application rooted at `lib/main.dart`.
- Navigation is handled with `go_router`. Routes are declared in `lib/router/routes.dart` and the runtime router provider is in `lib/router/router.dart` (see `routerProvider`).
- State management uses Riverpod (hooks_riverpod). Providers live next to the feature code; example: `lib/l10n/locale_provider.dart` exposes `localeProvider` (a StateNotifierProvider).
- UI is organized under `lib/features/` (e.g. `lib/features/home/`, `lib/features/login/`). Screens follow a small convention (see below).
- Localization uses Flutter's gen-l10n. Generated files are in `lib/l10n/` (`app_localizations.dart`, `app_localizations_en.dart`, ...).

Localization uses Flutter's gen-l10n. Generated files are in `lib/l10n/` (`app_localizations.dart`, `app_localizations_en.dart`, ...).

## Owner preferences & project specifics

- Primary goal: Mobile-only app (Android + iOS) to track users' daily workouts (register, dashboard, review, etc.).
- Maintainer: single developer (you). Treat the repo as a prototype.
- Entry point: `lib/main.dart` is the canonical app entry and should remain the root for wiring router & top-level providers.
- Firebase: planned for future integration; the app will rely heavily on offline support. Do not add production Firebase wiring without confirmation.
- Routing: `go_router` is the fixed routing solution. Deep linking is planned later but not required now.
- Authentication: Local/auth-provider based authentication (mocked during early development). Implement redirect logic in `lib/router/router.dart` once a provider exposes persisted auth state.
- Providers: prefer colocating feature-specific providers inside the feature folder (e.g. `lib/features/<feature>/`). Global providers (theme, locale, auth) exist but the owner will manage them initially.
- Localization: gen-l10n is used and only English (`en`) and French (`fr`) are supported for now.
- Networking: `dio` will be used. Plan a top-level `lib/api/` folder to hold repositories, DTOs, services, and API clients when network features are added.

## Project-specific conventions and patterns

- Screen classes expose static `name` and `path` fields used by routing. Examples:
  - `HomeScreen` in `lib/features/home/home_screen.dart` defines `static String name = "home"` and `static String path = "/home"`.
  - `LoginScreen` is referenced the same way in `lib/router/routes.dart`.

- Routes are provided via a provider: `routesProvider` in `lib/router/routes.dart` returns `List<GoRoute>`. The app's runtime `GoRouter` is created from `routerProvider` in `lib/router/router.dart` which also wires a `_RouterRefreshNotifier` that listens to `localeProvider` (so changing locale triggers router refresh).

- Localization pattern: prefer using `AppLocalizations.of(context)` (generated in `lib/l10n/app_localizations.dart`). Supported locales are declared in that generated file (currently `en` and `fr`). The project-level locale state is in `lib/l10n/locale_provider.dart`.

- State providers use Riverpod; prefer `StateNotifierProvider` for mutable application state (see `LocaleNotifier`). The codebase includes `hooks_riverpod` and `flutter_hooks` as dependencies — idiomatic widgets may be `HookWidget`/`ConsumerWidget`.

- Networking dependency: `dio` is present in `pubspec.yaml` indicating HTTP clients/use of service classes; search for `dio` usages when implementing network features.

## Key files to inspect when changing behavior

- `pubspec.yaml` — dependencies, generate:true for Flutter l10n.
- `lib/main.dart` — app entrypoint (currently a minimal placeholder). Update this to wire `routerProvider`/Root providers if needed.
- `lib/router/router.dart` — router provider and redirect logic placeholder.
- `lib/router/routes.dart` — canonical place to add/remove app routes.
- `lib/l10n/` — localization source and generated artifacts.
- `lib/features/*` — feature directories; keep UI + small local state/providers together.

## Typical edits and where to make them

- Add a new screen: create `lib/features/<feature>/<feature>_screen.dart` with static `name`/`path`, then add a `GoRoute` entry in `lib/router/routes.dart` referencing the screen.
- Add state: create a `StateNotifier` and expose it with a `StateNotifierProvider` (pattern shown in `locale_provider.dart`).
- Add translations: update ARB files under `l10n/` (not included in this README) and run `flutter pub get` / `flutter run` to regenerate.

## Lints, code style, and CI hints

- Dev dependencies include `flutter_lints`, `custom_lint`, and `riverpod_lint`. Follow existing lint rules; run `flutter analyze` before submitting changes.

## Integration points and external services

- HTTP: `dio` is available. Look for service or repository classes — if not present, follow the pattern of centralizing API calls in a `lib/services/` or `lib/repositories/` module and inject via providers.
- Auth/redirect: router has a commented-out redirect skeleton in `lib/router/router.dart`. Authentication state (not currently implemented) should be read via providers in the redirect function.

## What I didn't find (places to check with developers)

- No CI workflows or `.github` agent guidance file existed before this addition.
- `lib/main.dart` currently contains a placeholder app; confirm the real app root or if `routerProvider` should be wired there.

## Quick checklist for an AI agent before editing

1. Open `lib/router/routes.dart` and `lib/router/router.dart` to understand routing impact.
2. Check `lib/l10n/app_localizations.dart` for supported locales and string keys.
3. Search for existing providers for the feature you are editing; prefer extending providers over global singletons.
4. Run `flutter analyze` and `flutter test` locally after edits.

If anything here is unclear or you want extra examples (e.g., a canonical test file, a sample service using `dio`, or a full `main.dart` wiring the router and providers), tell me which example you want and I will add it.
