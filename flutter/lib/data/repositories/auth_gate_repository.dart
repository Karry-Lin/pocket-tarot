import 'package:pocket_tarot/data/repositories/profile_repository.dart';
import 'package:pocket_tarot/data/services/api_client.dart';
import 'package:pocket_tarot/data/services/firebase_auth_service.dart';
import 'package:pocket_tarot/domain/models/profile_models.dart';
import 'package:pocket_tarot/domain/use_cases/auth_gate_evaluator.dart';

class AuthGateRepository {
  const AuthGateRepository({
    required FirebaseAuthService authService,
    required ProfileRepository profileRepository,
  })  : _authService = authService,
        _profileRepository = profileRepository;

  final FirebaseAuthService _authService;
  final ProfileRepository _profileRepository;

  Future<AuthSession> loadSession({bool reload = false}) {
    return _authService.loadSession(reload: reload);
  }

  Future<ProfileLookup> loadProfile() async {
    try {
      final snapshot = await _profileRepository.fetchMe();
      return ProfileLookup.found(snapshot.user);
    } on ApiException catch (error) {
      return switch (error.code) {
        'PROFILE_NOT_FOUND' => const ProfileLookup.missing(),
        'ACCOUNT_DELETED' => const ProfileLookup.deleted(),
        _ => throw error,
      };
    }
  }

  Future<UserProfile> registerProfile() async {
    final session = await _authService.loadSession(reload: true);
    if (!session.isSignedIn) {
      throw StateError('Cannot register profile without a signed-in Firebase user.');
    }

    return _profileRepository.registerProfile(
      displayName: _displayNameFromSession(session),
      providerIds: session.providerIds.isEmpty ? const ['password'] : session.providerIds,
    );
  }

  String _displayNameFromSession(AuthSession session) {
    final displayName = session.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return _capDisplayName(displayName);
    }

    final emailPrefix = session.email?.split('@').first.trim();
    if (emailPrefix != null && emailPrefix.isNotEmpty) {
      return _capDisplayName(emailPrefix);
    }

    return 'Pocket Tarot';
  }

  String _capDisplayName(String value) {
    return value.length <= 16 ? value : value.substring(0, 16);
  }
}
