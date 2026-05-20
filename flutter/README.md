# Pocket Tarot Flutter

Android-first Flutter app for Pocket Tarot. Development checks use Flutter Web.

## Run

```bash
flutter run -d web-server --web-port 3000 --dart-define=API_BASE_URL=http://127.0.0.1:4000/api/v1
```

## Verify

```bash
flutter analyze
flutter test
flutter build web --release
```

## Local Tarot Catalog

The library tab reads the complete 78-card catalog from `assets/data/tarot_cards.json`. The catalog is local-only and is covered by `test/tarot_catalog_test.dart`.

## API Data Layer

`lib/data/services/api_client.dart` wraps Dio with Firebase Bearer token support. Profile, daily reading, and deep reading repositories live under `lib/data/repositories/` and are covered by `test/api_repositories_test.dart`.

`lib/domain/use_cases/daily_reading_controller.dart` owns the homepage daily reading state transition for loading today's result, empty state, and creating a reading with locale/weather request inputs.

## Auth Gate

`lib/domain/use_cases/auth_gate_evaluator.dart` contains the tested auth gate decision chain from splash/network check through login, email verification, profile registration, pending activation, deleted account, and app shell routing.

`lib/data/repositories/auth_gate_repository.dart` adapts Firebase session state and profile API errors into that auth gate contract, including `PROFILE_NOT_FOUND` and `ACCOUNT_DELETED`.

## Firebase Auth Service

`lib/data/services/firebase_auth_service.dart` wraps Firebase Auth and Google Sign-In behind testable gateways. It supports Email login/registration, verification email, password reset, Google web popup, Google mobile id-token login, Firebase ID token loading, and sign-out without calling Google Sign-In on web.

`lib/domain/use_cases/auth_form_validator.dart` owns Email login, registration, and password-reset form validation rules.

## Local Settings

`lib/data/repositories/local_settings_repository.dart` stores language mode and weather toggle in SharedPreferences. These settings are local-only and covered by `test/local_settings_test.dart`.

## Safe Markdown

LLM reading output is rendered through `lib/ui/core/widgets/safe_markdown_body.dart`. The renderer keeps headings, paragraphs, emphasis, lists, blockquotes, and horizontal rules, while stripping HTML, images, tables, and code blocks before display.
