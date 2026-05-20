import 'package:pocket_tarot/domain/models/profile_models.dart';

typedef NetworkChecker = Future<bool> Function();
typedef AuthSessionLoader = Future<AuthSession> Function();
typedef ProfileLoader = Future<ProfileLookup> Function();
typedef ProfileRegistrar = Future<UserProfile> Function();

enum AuthGateDestination {
  splashNetworkBlocked,
  login,
  verifyEmail,
  accountDeleted,
  pendingActivation,
  appShell,
}

class AuthGateEvaluator {
  const AuthGateEvaluator({
    required NetworkChecker networkChecker,
    required AuthSessionLoader authSessionLoader,
    required ProfileLoader profileLoader,
    required ProfileRegistrar profileRegistrar,
  })  : _networkChecker = networkChecker,
        _authSessionLoader = authSessionLoader,
        _profileLoader = profileLoader,
        _profileRegistrar = profileRegistrar;

  final NetworkChecker _networkChecker;
  final AuthSessionLoader _authSessionLoader;
  final ProfileLoader _profileLoader;
  final ProfileRegistrar _profileRegistrar;

  Future<AuthGateResult> evaluate() async {
    final networkAvailable = await _networkChecker();
    if (!networkAvailable) {
      return const AuthGateResult(destination: AuthGateDestination.splashNetworkBlocked);
    }

    final session = await _authSessionLoader();
    if (!session.isSignedIn) {
      return const AuthGateResult(destination: AuthGateDestination.login);
    }

    if (session.requiresEmailVerification) {
      return const AuthGateResult(destination: AuthGateDestination.verifyEmail);
    }

    final lookup = await _profileLoader();
    final profile = lookup.profile ?? await _profileRegistrar();

    return _destinationForProfile(profile);
  }

  AuthGateResult _destinationForProfile(UserProfile profile) {
    if (profile.deletedAt != null) {
      return AuthGateResult(destination: AuthGateDestination.accountDeleted, profile: profile);
    }

    if (!profile.isActive) {
      return AuthGateResult(destination: AuthGateDestination.pendingActivation, profile: profile);
    }

    return AuthGateResult(destination: AuthGateDestination.appShell, profile: profile);
  }
}

class AuthGateResult {
  const AuthGateResult({
    required this.destination,
    this.profile,
  });

  final AuthGateDestination destination;
  final UserProfile? profile;
}

class AuthSession {
  const AuthSession.signedOut()
      : uid = null,
        email = null,
        emailVerified = false,
        providerIds = const [],
        displayName = null;

  const AuthSession.signedIn({
    required this.uid,
    required this.email,
    required this.emailVerified,
    required this.providerIds,
    required this.displayName,
  });

  final String? uid;
  final String? email;
  final bool emailVerified;
  final List<String> providerIds;
  final String? displayName;

  bool get isSignedIn => uid != null;

  bool get requiresEmailVerification {
    return providerIds.contains('password') && !emailVerified;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AuthSession &&
            other.uid == uid &&
            other.email == email &&
            other.emailVerified == emailVerified &&
            _sameStringList(other.providerIds, providerIds) &&
            other.displayName == displayName;
  }

  @override
  int get hashCode {
    return Object.hash(uid, email, emailVerified, Object.hashAll(providerIds), displayName);
  }
}

class ProfileLookup {
  const ProfileLookup.found(this.profile);

  const ProfileLookup.missing() : profile = null;

  final UserProfile? profile;
}

bool _sameStringList(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }

  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }

  return true;
}
