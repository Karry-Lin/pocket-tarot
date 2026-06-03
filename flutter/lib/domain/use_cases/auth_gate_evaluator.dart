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
    // ignore: avoid_print
    print('DEBUG: AuthGateEvaluator.evaluate() started');
    
    // ignore: avoid_print
    print('DEBUG: AuthGateEvaluator -> _networkChecker() starting...');
    final networkAvailable = await _networkChecker();
    // ignore: avoid_print
    print('DEBUG: AuthGateEvaluator -> _networkChecker() finished. Available: $networkAvailable');
    if (!networkAvailable) {
      return const AuthGateResult(destination: AuthGateDestination.splashNetworkBlocked);
    }

    // ignore: avoid_print
    print('DEBUG: AuthGateEvaluator -> _authSessionLoader() starting...');
    final session = await _authSessionLoader();
    // ignore: avoid_print
    print('DEBUG: AuthGateEvaluator -> _authSessionLoader() finished. isSignedIn: ${session.isSignedIn}');
    if (!session.isSignedIn) {
      return const AuthGateResult(destination: AuthGateDestination.login);
    }

    if (session.requiresEmailVerification) {
      // ignore: avoid_print
      print('DEBUG: AuthGateEvaluator -> requiresEmailVerification is true');
      return const AuthGateResult(destination: AuthGateDestination.verifyEmail);
    }

    // ignore: avoid_print
    print('DEBUG: AuthGateEvaluator -> _profileLoader() starting...');
    final lookup = await _profileLoader();
    // ignore: avoid_print
    print('DEBUG: AuthGateEvaluator -> _profileLoader() finished. isDeleted: ${lookup.isDeleted}, hasProfile: ${lookup.profile != null}');
    if (lookup.isDeleted) {
      return const AuthGateResult(destination: AuthGateDestination.accountDeleted);
    }

    // ignore: avoid_print
    print('DEBUG: AuthGateEvaluator -> profile resolving...');
    final profile = lookup.profile ?? await _profileRegistrar();
    // ignore: avoid_print
    print('DEBUG: AuthGateEvaluator -> profile resolved. isActive: ${profile.isActive}');

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
  const ProfileLookup.found(this.profile) : isDeleted = false;

  const ProfileLookup.missing()
      : profile = null,
        isDeleted = false;

  const ProfileLookup.deleted()
      : profile = null,
        isDeleted = true;

  final UserProfile? profile;
  final bool isDeleted;
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
