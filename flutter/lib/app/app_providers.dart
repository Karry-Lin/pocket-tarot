import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_tarot/data/repositories/auth_gate_repository.dart';
import 'package:pocket_tarot/data/repositories/daily_reading_repository.dart';
import 'package:pocket_tarot/data/repositories/deep_reading_repository.dart';
import 'package:pocket_tarot/data/repositories/local_settings_repository.dart';
import 'package:pocket_tarot/data/repositories/profile_repository.dart';
import 'package:pocket_tarot/data/services/api_client.dart';
import 'package:pocket_tarot/data/services/api_health_service.dart';
import 'package:pocket_tarot/data/services/device_location_service.dart';
import 'package:pocket_tarot/data/services/firebase_auth_service.dart';
import 'package:pocket_tarot/domain/models/local_settings.dart';
import 'package:pocket_tarot/domain/use_cases/app_startup_controller.dart';
import 'package:pocket_tarot/domain/use_cases/auth_gate_evaluator.dart';
import 'package:pocket_tarot/domain/use_cases/daily_reading_controller.dart';
import 'package:pocket_tarot/domain/use_cases/deep_reading_controller.dart';
import 'package:pocket_tarot/domain/use_cases/profile_controller.dart';
import 'package:pocket_tarot/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

final firebaseInitializationProvider = FutureProvider<void>((ref) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
});

final firebaseAuthServiceProvider = FutureProvider<FirebaseAuthService>((
  ref,
) async {
  await ref.watch(firebaseInitializationProvider.future);
  return FirebaseAuthService();
});

final authActionsProvider = Provider<AuthActions>((ref) {
  Future<FirebaseAuthService> authService() {
    return ref.read(firebaseAuthServiceProvider.future);
  }

  return AuthActions(
    signInWithEmail: ({required email, required password}) async {
      final service = await authService();
      await service.signInWithEmail(email: email, password: password);
    },
    registerWithEmail:
        ({required displayName, required email, required password}) async {
          final service = await authService();
          await service.registerWithEmail(
            displayName: displayName,
            email: email,
            password: password,
          );
        },
    signInWithGoogle: () async {
      final service = await authService();
      await service.signInWithGoogle();
    },
    sendPasswordResetEmail: (email) async {
      final service = await authService();
      await service.sendPasswordResetEmail(email);
    },
    signOut: () async {
      final service = await authService();
      await service.signOut();
    },
  );
});

final apiClientProvider = Provider<PocketTarotApiClient>((ref) {
  return PocketTarotApiClient(
    tokenProvider: () async {
      final authService = await ref.read(firebaseAuthServiceProvider.future);
      return authService.getIdToken();
    },
  );
});

final apiHealthServiceProvider = Provider<ApiHealthService>((ref) {
  return ApiHealthService();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});

final dailyReadingRepositoryProvider = Provider<DailyReadingRepository>((ref) {
  return DailyReadingRepository(ref.watch(apiClientProvider));
});

final deepReadingRepositoryProvider = Provider<DeepReadingRepository>((ref) {
  return DeepReadingRepository(ref.watch(apiClientProvider));
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final localSettingsRepositoryProvider = FutureProvider<LocalSettingsRepository>(
  (ref) async {
    return LocalSettingsRepository(
      await ref.watch(sharedPreferencesProvider.future),
    );
  },
);

final systemLocaleCodeProvider = Provider<String Function()>((ref) {
  return () => PlatformDispatcher.instance.locale.toLanguageTag();
});

final appLocaleProvider = FutureProvider<Locale?>((ref) async {
  final localSettingsRepository = await ref.watch(
    localSettingsRepositoryProvider.future,
  );
  final settings = await localSettingsRepository.load();
  return switch (settings.localeMode) {
    LocaleMode.system => null,
    LocaleMode.zhTw => const Locale('zh', 'TW'),
    LocaleMode.en => const Locale('en'),
  };
});

final deviceLocationServiceProvider = Provider<DeviceLocationService>((ref) {
  return DeviceLocationService();
});

final dailyReadingLocationLoaderProvider = Provider<DailyReadingLocationLoader>(
  (ref) {
    return ref.watch(deviceLocationServiceProvider).loadDailyReadingLocation;
  },
);

final dailyReadingControllerProvider = FutureProvider<DailyReadingController>((
  ref,
) async {
  final localSettingsRepository = await ref.watch(
    localSettingsRepositoryProvider.future,
  );
  final dailyReadingRepository = ref.watch(dailyReadingRepositoryProvider);

  return DailyReadingController(
    fetchToday: dailyReadingRepository.fetchToday,
    createToday: dailyReadingRepository.createTodayFromRequest,
    loadSettings: localSettingsRepository.load,
    requestLocation: ref.watch(dailyReadingLocationLoaderProvider),
    systemLocaleCode: ref.watch(systemLocaleCodeProvider),
  );
});

final deepReadingControllerProvider = FutureProvider<DeepReadingController>((
  ref,
) async {
  final localSettingsRepository = await ref.watch(
    localSettingsRepositoryProvider.future,
  );
  final deepReadingRepository = ref.watch(deepReadingRepositoryProvider);

  return DeepReadingController(
    createDraft: deepReadingRepository.createDraft,
    createReading: deepReadingRepository.createReadingFromRequest,
    fetchHistory: deepReadingRepository.fetchHistory,
    fetchSavedReading: deepReadingRepository.fetchById,
    setHistoryVisibility: deepReadingRepository.setHistoryVisibility,
    loadSettings: localSettingsRepository.load,
    systemLocaleCode: ref.watch(systemLocaleCodeProvider),
  );
});

final profileControllerProvider = FutureProvider<ProfileController>((
  ref,
) async {
  final localSettingsRepository = await ref.watch(
    localSettingsRepositoryProvider.future,
  );
  final profileRepository = ref.watch(profileRepositoryProvider);
  final authActions = ref.watch(authActionsProvider);

  return ProfileController(
    fetchProfile: profileRepository.fetchMe,
    updateDisplayName: profileRepository.updateDisplayName,
    loadSettings: localSettingsRepository.load,
    saveSettings: localSettingsRepository.save,
    signOut: authActions.signOut,
  );
});

final authGateRepositoryProvider = FutureProvider<AuthGateRepository>((
  ref,
) async {
  return AuthGateRepository(
    authService: await ref.watch(firebaseAuthServiceProvider.future),
    profileRepository: ref.watch(profileRepositoryProvider),
  );
});

final authGateEvaluatorProvider = Provider<AuthGateEvaluator>((ref) {
  final apiHealthService = ref.watch(apiHealthServiceProvider);

  return AuthGateEvaluator(
    networkChecker: apiHealthService.isAvailable,
    authSessionLoader: () async {
      final repository = await ref.read(authGateRepositoryProvider.future);
      return repository.loadSession(reload: true);
    },
    profileLoader: () async {
      final repository = await ref.read(authGateRepositoryProvider.future);
      return repository.loadProfile();
    },
    profileRegistrar: () async {
      final repository = await ref.read(authGateRepositoryProvider.future);
      return repository.registerProfile();
    },
  );
});

final appStartupControllerProvider = Provider<AppStartupController>((ref) {
  return AppStartupController(
    evaluateAuthGate: ref.watch(authGateEvaluatorProvider).evaluate,
  );
});

class AuthActions {
  const AuthActions({
    required this.signInWithEmail,
    required this.registerWithEmail,
    required this.signInWithGoogle,
    required this.sendPasswordResetEmail,
    required this.signOut,
  });

  final Future<void> Function({required String email, required String password})
  signInWithEmail;
  final Future<void> Function({
    required String displayName,
    required String email,
    required String password,
  })
  registerWithEmail;
  final Future<void> Function() signInWithGoogle;
  final Future<void> Function(String email) sendPasswordResetEmail;
  final Future<void> Function() signOut;
}
