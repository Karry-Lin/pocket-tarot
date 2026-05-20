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
