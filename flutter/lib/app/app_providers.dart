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
import 'package:pocket_tarot/domain/models/api_reading_models.dart';
import 'package:pocket_tarot/domain/models/local_settings.dart';
import 'package:pocket_tarot/domain/models/profile_models.dart';
import 'package:pocket_tarot/domain/use_cases/app_startup_controller.dart';
import 'package:pocket_tarot/domain/use_cases/auth_gate_evaluator.dart';
import 'package:pocket_tarot/domain/use_cases/daily_reading_controller.dart';
import 'package:pocket_tarot/domain/use_cases/deep_reading_controller.dart';
import 'package:pocket_tarot/domain/use_cases/profile_controller.dart';
import 'package:pocket_tarot/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

const visualFixtureMode = bool.fromEnvironment('VISUAL_FIXTURE');

final firebaseInitializationProvider = FutureProvider<void>((ref) async {
  if (visualFixtureMode) {
    return;
  }

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
  if (visualFixtureMode) {
    return AuthActions(
      signInWithEmail: ({required email, required password}) async {},
      registerWithEmail:
          ({required displayName, required email, required password}) async {},
      signInWithGoogle: () async {},
      sendPasswordResetEmail: (_) async {},
      signOut: () async {},
    );
  }

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
  if (visualFixtureMode) {
    return const Locale('zh', 'TW');
  }

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
  if (visualFixtureMode) {
    return DailyReadingController(
      fetchToday: () async => null,
      createToday: (_) => _delayedVisualFixture(_visualFixtureDailyReading),
      loadSettings: _visualFixtureSettings,
      requestLocation: () async =>
          const DailyReadingLocationResult.permissionDenied(),
      systemLocaleCode: () => 'zh-TW',
    );
  }

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
  if (visualFixtureMode) {
    return DeepReadingController(
      createDraft: () => _delayedVisualFixture(_visualFixtureDraftCards),
      createReading: (_) => _delayedVisualFixture(_visualFixtureDeepReading),
      fetchHistory: () async => _visualFixtureHistory,
      fetchSavedReading: (_) async => _visualFixtureSavedDeepReading,
      setHistoryVisibility: ({required id, required isSavedForHistory}) async =>
          HistoryVisibility(id: id, isSavedForHistory: isSavedForHistory),
      loadSettings: _visualFixtureSettings,
      systemLocaleCode: () => 'zh-TW',
    );
  }

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
  if (visualFixtureMode) {
    return ProfileController(
      fetchProfile: () async => _visualFixtureProfile,
      updateDisplayName: (displayName) async => UserProfile(
        id: _visualFixtureProfile.user.id,
        email: _visualFixtureProfile.user.email,
        displayName: displayName,
        providerIds: _visualFixtureProfile.user.providerIds,
        isActive: _visualFixtureProfile.user.isActive,
        createdAt: _visualFixtureProfile.user.createdAt,
        activatedAt: _visualFixtureProfile.user.activatedAt,
        lastLoginAt: _visualFixtureProfile.user.lastLoginAt,
        deletedAt: _visualFixtureProfile.user.deletedAt,
      ),
      loadSettings: _visualFixtureSettings,
      saveSettings: (_) async {},
      signOut: () async {},
    );
  }

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
  if (visualFixtureMode) {
    return AppStartupController(
      evaluateAuthGate: () async =>
          const AuthGateResult(destination: AuthGateDestination.appShell),
    );
  }

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

Future<LocalSettings> _visualFixtureSettings() async {
  return const LocalSettings(localeMode: LocaleMode.zhTw, weatherEnabled: true);
}

Future<T> _delayedVisualFixture<T>(T value) async {
  await Future<void>.delayed(const Duration(milliseconds: 850));
  return value;
}

final _visualFixtureDailyReading = DailyReading(
  id: 'visual-daily',
  localDate: '2026-05-22',
  card: const CardDraw(cardId: 'major-18-moon', orientation: 'reversed'),
  markdownResult: '''
### 今日心靈天氣
月亮逆位把藏在心底的猜測照亮。今天你可能會想從一句話、一次延遲或一個已讀裡找答案，但真正的訊息還沒有完全抵達。

### 牌義與天氣的交會
- **月亮逆位：**把想像與事實分開，別讓焦慮替你下結論。
- **小雨：**情緒會變得黏稠，適合慢慢整理，不適合立刻對抗。
- **今天的提醒：**一次只確認一件事，讓直覺回到安靜的位置。

### 給你的建議
傍晚前先不要追問答案。寫下三個你確定知道的事，再寫下一個你還不知道的事。當界線清楚，直覺就會回到安靜的位置。
''',
  summary: '把想像與事實分開。今天不急著替沉默補上答案，先確認你真正知道的事。',
  resultLocale: 'zh-TW',
  createdAt: DateTime.utc(2026, 5, 22),
);

const _visualFixtureDraftCards = [
  CardDraw(cardId: 'major-18-moon', orientation: 'upright'),
  CardDraw(cardId: 'major-14-temperance', orientation: 'upright'),
  CardDraw(cardId: 'major-17-star', orientation: 'upright'),
  CardDraw(cardId: 'cups-02-two', orientation: 'reversed'),
  CardDraw(cardId: 'swords-06-six', orientation: 'upright'),
  CardDraw(cardId: 'major-16-tower', orientation: 'upright'),
  CardDraw(cardId: 'major-00-fool', orientation: 'upright'),
  CardDraw(cardId: 'major-11-justice', orientation: 'upright'),
  CardDraw(cardId: 'major-09-hermit', orientation: 'reversed'),
];

final _visualFixtureDeepReading = DeepReading(
  id: 'visual-reading',
  question: '關係中的沉默',
  selectedCards: const [
    SelectedReadingCard(
      position: 'core',
      positionLabel: '問題核心',
      cardId: 'major-18-moon',
      orientation: 'upright',
    ),
    SelectedReadingCard(
      position: 'hiddenInfluence',
      positionLabel: '隱藏影響',
      cardId: 'major-14-temperance',
      orientation: 'upright',
    ),
    SelectedReadingCard(
      position: 'advice',
      positionLabel: '行動建議',
      cardId: 'major-17-star',
      orientation: 'upright',
    ),
  ],
  markdownResult: '### 問題核心\n先辨識沉默背後的情緒，再決定要不要靠近。',
  summary: '月亮、節制、星星，等待保存完整解讀',
  resultLocale: 'zh-TW',
  isSavedForHistory: false,
  createdAt: DateTime.utc(2026, 5, 22),
);

final _visualFixtureSavedDeepReading = _visualFixtureDeepReading.copyWith(
  summary: '月亮、節制、星星，已保存完整解讀',
  isSavedForHistory: true,
);

final _visualFixtureHistory = [
  DeepReadingHistoryItem(
    id: 'visual-reading',
    question: '關係中的沉默',
    summary: '月亮、節制、星星，已保存完整解讀',
    resultLocale: 'zh-TW',
    createdAt: DateTime.utc(2026, 5, 21),
  ),
  DeepReadingHistoryItem(
    id: 'visual-reading-2',
    question: '新的職務邀請',
    summary: '權杖二、正義、隱者，風險與下一步',
    resultLocale: 'zh-TW',
    createdAt: DateTime.utc(2026, 5, 20),
  ),
];

final _visualFixtureProfile = ProfileSnapshot(
  user: UserProfile(
    id: 'visual-user',
    email: 'bigmoon@example.com',
    displayName: '王大明',
    providerIds: const ['google.com'],
    isActive: true,
    createdAt: DateTime.utc(2026, 5, 22),
    activatedAt: DateTime.utc(2026, 5, 22),
    lastLoginAt: DateTime.utc(2026, 5, 22),
    deletedAt: null,
  ),
  stats: const UserStats(dailyReadingCount: 7, deepReadingCount: 3),
);
