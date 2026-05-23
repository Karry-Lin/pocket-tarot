# Pocket Tarot Flutter

Android-first Flutter app for Pocket Tarot. Development checks use Flutter Web.

## Run

```bash
flutter run -d web-server --web-port 3000 --dart-define=API_BASE_URL=http://127.0.0.1:4000/api/v1
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1
```

## Verify

```bash
flutter analyze
flutter test
flutter build web --release
```

## Build APK

For Android emulator testing against the local backend, use `10.0.2.2` so the emulator can reach the host machine:

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1
```

The generated APK is written to:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For a physical device or deployed environment, replace `API_BASE_URL` with a backend URL reachable from that device.

## Local Tarot Catalog

The library tab reads the complete 78-card catalog from `assets/data/tarot_cards.json`. The catalog is local-only and is covered by `test/tarot_catalog_test.dart`.

## API Data Layer

`lib/data/services/api_client.dart` wraps Dio with Firebase Bearer token support. Profile, daily reading, and deep reading repositories live under `lib/data/repositories/` and are covered by `test/api_repositories_test.dart`.

Daily and deep reading repositories expose controller-request adapter methods so UI controllers can pass their create request objects directly to the API layer.

`lib/data/services/api_health_service.dart` checks the server `/healthz` endpoint derived from `API_BASE_URL`, so startup can block when the API is unavailable.

`lib/domain/use_cases/daily_reading_controller.dart` owns the homepage daily reading state transition for loading today's result, empty state, and creating a reading with locale/weather request inputs.

`HomeScreen` loads and draws through `dailyReadingControllerProvider`; rendered card markdown and summary come from the API reading model instead of static demo content.

`lib/data/services/device_location_service.dart` wraps Geolocator permission checks and current-position loading for daily reading weather requests. Location failures fall back to a permission-denied weather request so drawing can continue.

`lib/domain/use_cases/deep_reading_controller.dart` owns the divination room state transition for draft creation, three-card selection, result creation, saved-history loading, and history visibility toggles.

`DivinationScreen` starts drafts, fills question prompt chips into the question field, records three-card selection, renders result markdown/summary plus selected card positions/orientations, toggles saved-history visibility, and loads saved history through `deepReadingControllerProvider`.

`lib/domain/use_cases/profile_controller.dart` owns profile snapshot loading, display name edits, local language/weather settings, and sign-out state transitions.

`ProfileScreen` displays profile stats and persists language/weather/name/sign-out actions through `profileControllerProvider`.

## Auth Gate

Run `flutterfire configure` before testing signed-in auth flows so platform Firebase options are available.

`lib/app/app_providers.dart` wires the startup composition layer: API health check, lazy Firebase initialization, Firebase Auth service, API client bearer token loading, profile repository, auth gate repository, auth gate evaluator, and app startup controller. Startup checks API health before touching Firebase so local offline/API-down states can still render a retryable splash screen.

`lib/domain/use_cases/app_startup_controller.dart` maps splash/auth gate outcomes into app startup states and target routes, including blocked network/API and deleted-account routing.

`lib/domain/use_cases/auth_gate_evaluator.dart` contains the tested auth gate decision chain from splash/network check through login, email verification, profile registration, pending activation, deleted account, and app shell routing.

The app router starts at `/splash`; `StartupScreen` runs the startup controller, routes ready states, and keeps the user on a retryable blocked screen when network/API checks fail. The router also includes blocked-state routes for `/account-deleted`, `/verify-email`, and `/pending`.

Verify-email and pending-activation actions route back through `/splash` so auth/profile state is rechecked. Gate sign-out buttons delegate through `authActionsProvider`.

`lib/data/repositories/auth_gate_repository.dart` adapts Firebase session state and profile API errors into that auth gate contract, including `PROFILE_NOT_FOUND` and `ACCOUNT_DELETED`.

## Firebase Auth Service

`lib/data/services/firebase_auth_service.dart` wraps Firebase Auth and Google Sign-In behind testable gateways. It supports Email login/registration, verification email, password reset, Google web popup, Google mobile id-token login, Firebase ID token loading, and sign-out without calling Google Sign-In on web.

`lib/domain/use_cases/auth_form_validator.dart` owns Email login, registration, and password-reset form validation rules.

`LoginScreen` exposes Email sign-in, registration, password-reset, and Google sign-in modes with widget-tested validation. Submit actions delegate through `authActionsProvider`; successful sign-in returns to `/splash` for auth gate routing, registration routes to `/verify-email`, and password reset shows an inline confirmation.

## Local Settings

`lib/data/repositories/local_settings_repository.dart` stores language mode and weather toggle in SharedPreferences. These settings are local-only and covered by `test/local_settings_test.dart`.

`appLocaleProvider` loads the stored language mode into `MaterialApp.locale`; profile language changes invalidate the provider so the shell can switch between system language, `zh-TW`, and `en`. Main app UI strings in `main.dart` use generated l10n strings.

## Safe Markdown

LLM reading output is rendered through `lib/ui/core/widgets/safe_markdown_body.dart`. The renderer keeps headings, paragraphs, emphasis, lists, blockquotes, and horizontal rules, while stripping HTML, images, tables, and code blocks before display.
Links are also stripped so rendered readings stay within the documented safe subset.
