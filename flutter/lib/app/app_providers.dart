import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pocket_tarot/data/repositories/auth_gate_repository.dart';
import 'package:pocket_tarot/data/repositories/profile_repository.dart';
import 'package:pocket_tarot/data/services/api_client.dart';
import 'package:pocket_tarot/data/services/api_health_service.dart';
import 'package:pocket_tarot/data/services/firebase_auth_service.dart';
import 'package:pocket_tarot/domain/use_cases/app_startup_controller.dart';
import 'package:pocket_tarot/domain/use_cases/auth_gate_evaluator.dart';

final firebaseInitializationProvider = FutureProvider<void>((ref) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
});

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final apiClientProvider = Provider<PocketTarotApiClient>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return PocketTarotApiClient(tokenProvider: authService.getIdToken);
});

final apiHealthServiceProvider = Provider<ApiHealthService>((ref) {
  return ApiHealthService();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});

final authGateRepositoryProvider = Provider<AuthGateRepository>((ref) {
  return AuthGateRepository(
    authService: ref.watch(firebaseAuthServiceProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
  );
});

final authGateEvaluatorProvider = Provider<AuthGateEvaluator>((ref) {
  final apiHealthService = ref.watch(apiHealthServiceProvider);

  return AuthGateEvaluator(
    networkChecker: apiHealthService.isAvailable,
    authSessionLoader: () async {
      await ref.read(firebaseInitializationProvider.future);
      return ref.read(authGateRepositoryProvider).loadSession();
    },
    profileLoader: () => ref.read(authGateRepositoryProvider).loadProfile(),
    profileRegistrar: () =>
        ref.read(authGateRepositoryProvider).registerProfile(),
  );
});

final appStartupControllerProvider = Provider<AppStartupController>((ref) {
  return AppStartupController(
    evaluateAuthGate: ref.watch(authGateEvaluatorProvider).evaluate,
  );
});
