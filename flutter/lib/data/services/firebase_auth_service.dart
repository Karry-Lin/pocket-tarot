import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pocket_tarot/data/services/games_auth_delegate.dart'
    as games_auth;
import 'package:pocket_tarot/domain/use_cases/auth_gate_evaluator.dart';

class FirebaseAuthService {
  FirebaseAuthService({
    FirebaseAuthGateway? firebaseAuth,
    GoogleSignInGateway? googleSignIn,
    bool isWeb = kIsWeb,
  }) : _firebaseAuth =
           firebaseAuth ??
           FirebaseAuthSdkGateway(firebase.FirebaseAuth.instance),
       _googleSignIn = googleSignIn ?? GoogleSignInSdkGateway(),
       _isWeb = isWeb;

  final FirebaseAuthGateway _firebaseAuth;
  final GoogleSignInGateway _googleSignIn;
  final bool _isWeb;

  Stream<AuthSession> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_toSession);
  }

  Future<AuthSession> loadSession({bool reload = false}) async {
    try {
      final user = reload
          ? await _firebaseAuth.reloadCurrentUser().timeout(const Duration(seconds: 5))
          : _firebaseAuth.currentUser;
      return _toSession(user);
    } catch (_) {
      final user = _firebaseAuth.currentUser;
      return _toSession(user);
    }
  }

  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final user = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toSession(user);
  }

  Future<AuthSession> registerWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final normalizedDisplayName = _normalizeDisplayName(displayName);
    final createdUser = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firebaseAuth.updateCurrentUserDisplayName(normalizedDisplayName);
    await _firebaseAuth.sendCurrentUserEmailVerification();

    final reloadedUser = await _firebaseAuth.reloadCurrentUser();
    return _toSession(
      reloadedUser ?? createdUser.copyWith(displayName: normalizedDisplayName),
    );
  }

  Future<AuthSession> signInWithGoogle() async {
    if (_isWeb) {
      return _toSession(await _firebaseAuth.signInWithGooglePopup());
    }

    await _googleSignIn.initialize();
    final idToken = await _googleSignIn.authenticateIdToken();
    return _toSession(await _firebaseAuth.signInWithGoogleIdToken(idToken));
  }

  Future<AuthSession> signInWithPlayGames() async {
    return _toSession(await _firebaseAuth.signInWithPlayGames());
  }

  Future<AuthSession> signInWithGithub() async {
    try {
      return _toSession(await _firebaseAuth.signInWithGithub());
    } on firebase.FirebaseAuthException catch (e) {
      if (e.code != 'account-exists-with-different-credential' ||
          e.credential == null) {
        rethrow;
      }

      throw AccountLinkingRequired(
        email: e.email ?? '',
        pendingCredential: e.credential!,
      );
    }
  }

  Future<AuthSession> linkPendingCredential(
    firebase.AuthCredential credential,
  ) async {
    return _toSession(
      await _firebaseAuth.linkCurrentUserWithCredential(credential),
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email);
  }

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await _firebaseAuth
          .getCurrentUserIdToken(forceRefresh: forceRefresh)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!_isWeb) {
      await _googleSignIn.signOut();
    }
    await _firebaseAuth.signOut();
  }

  AuthSession _toSession(FirebaseUserSnapshot? user) {
    if (user == null) {
      return const AuthSession.signedOut();
    }

    return AuthSession.signedIn(
      uid: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
      providerIds: user.providerIds,
      displayName: user.displayName,
    );
  }

  String _normalizeDisplayName(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.length > 16) {
      throw ArgumentError.value(
        value,
        'displayName',
        'Display name must be 1-16 characters after trim.',
      );
    }
    return normalized;
  }
}

abstract interface class FirebaseAuthGateway {
  FirebaseUserSnapshot? get currentUser;

  Stream<FirebaseUserSnapshot?> authStateChanges();

  Future<FirebaseUserSnapshot?> reloadCurrentUser();

  Future<FirebaseUserSnapshot> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<FirebaseUserSnapshot> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<FirebaseUserSnapshot> signInWithGooglePopup();

  Future<FirebaseUserSnapshot> signInWithGoogleIdToken(String idToken);

  Future<FirebaseUserSnapshot> signInWithPlayGames();

  Future<FirebaseUserSnapshot> signInWithGithub();

  Future<FirebaseUserSnapshot> linkCurrentUserWithCredential(
    firebase.AuthCredential credential,
  );

  Future<void> updateCurrentUserDisplayName(String displayName);

  Future<void> sendCurrentUserEmailVerification();

  Future<void> sendPasswordResetEmail(String email);

  Future<String?> getCurrentUserIdToken({required bool forceRefresh});

  Future<void> signOut();
}

abstract interface class GoogleSignInGateway {
  Future<void> initialize();

  Future<String> authenticateIdToken();

  Future<void> signOut();
}

class FirebaseUserSnapshot {
  const FirebaseUserSnapshot({
    required this.uid,
    required this.email,
    required this.emailVerified,
    required this.providerIds,
    required this.displayName,
  });

  final String uid;
  final String? email;
  final bool emailVerified;
  final List<String> providerIds;
  final String? displayName;

  FirebaseUserSnapshot copyWith({
    String? uid,
    String? email,
    bool? emailVerified,
    List<String>? providerIds,
    String? displayName,
  }) {
    return FirebaseUserSnapshot(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      providerIds: providerIds ?? this.providerIds,
      displayName: displayName ?? this.displayName,
    );
  }
}

class FirebaseAuthSdkGateway implements FirebaseAuthGateway {
  FirebaseAuthSdkGateway(this._auth);

  final firebase.FirebaseAuth _auth;

  @override
  FirebaseUserSnapshot? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : _snapshot(user);
  }

  @override
  Stream<FirebaseUserSnapshot?> authStateChanges() {
    return _auth.authStateChanges().map(
      (user) => user == null ? null : _snapshot(user),
    );
  }

  @override
  Future<FirebaseUserSnapshot> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _snapshotCredential(credential);
  }

  @override
  Future<String?> getCurrentUserIdToken({required bool forceRefresh}) {
    return _requireCurrentUser().getIdToken(forceRefresh);
  }

  @override
  Future<FirebaseUserSnapshot?> reloadCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    await user.reload();
    final reloadedUser = _auth.currentUser;
    return reloadedUser == null ? null : _snapshot(reloadedUser);
  }

  @override
  Future<void> sendCurrentUserEmailVerification() {
    return _requireCurrentUser().sendEmailVerification();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<FirebaseUserSnapshot> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _snapshotCredential(credential);
  }

  @override
  Future<FirebaseUserSnapshot> signInWithGoogleIdToken(String idToken) async {
    final credential = firebase.GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _auth.signInWithCredential(credential);
    return _snapshotCredential(userCredential);
  }

  @override
  Future<FirebaseUserSnapshot> signInWithGooglePopup() async {
    final credential = await _auth.signInWithPopup(
      firebase.GoogleAuthProvider(),
    );
    return _snapshotCredential(credential);
  }

  @override
  Future<FirebaseUserSnapshot> signInWithPlayGames() async {
    final credential = await games_auth.signInWithPlayGames(_auth);
    return _snapshotCredential(credential);
  }

  @override
  Future<FirebaseUserSnapshot> signInWithGithub() async {
    final provider = firebase.GithubAuthProvider();
    final credential = kIsWeb
        ? await _auth.signInWithPopup(provider)
        : await _auth.signInWithProvider(provider);
    return _snapshotCredential(credential);
  }

  @override
  Future<FirebaseUserSnapshot> linkCurrentUserWithCredential(
    firebase.AuthCredential credential,
  ) async {
    final user = _requireCurrentUser();
    final linked = await user.linkWithCredential(credential);
    return _snapshotCredential(linked);
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  Future<void> updateCurrentUserDisplayName(String displayName) {
    return _requireCurrentUser().updateDisplayName(displayName);
  }

  firebase.User _requireCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Firebase auth has no current user.');
    }
    return user;
  }

  FirebaseUserSnapshot _snapshotCredential(firebase.UserCredential credential) {
    final user = credential.user ?? _auth.currentUser;
    if (user == null) {
      throw StateError('Firebase auth did not return a user.');
    }
    return _snapshot(user);
  }

  FirebaseUserSnapshot _snapshot(firebase.User user) {
    return FirebaseUserSnapshot(
      uid: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
      providerIds: user.providerData
          .map((provider) => provider.providerId)
          .where((providerId) => providerId.isNotEmpty)
          .toList(growable: false),
      displayName: user.displayName,
    );
  }
}

class GoogleSignInSdkGateway implements GoogleSignInGateway {
  bool _initialized = false;

  @override
  Future<String> authenticateIdToken() async {
    final googleUser = await GoogleSignIn.instance.authenticate();
    final idToken = googleUser.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw StateError('Google Sign-In did not return an idToken.');
    }

    return idToken;
  }

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await GoogleSignIn.instance.initialize();
    _initialized = true;
  }

  @override
  Future<void> signOut() {
    return GoogleSignIn.instance.signOut();
  }
}

class AccountLinkingRequired implements Exception {
  const AccountLinkingRequired({
    required this.email,
    required this.pendingCredential,
  });

  final String email;
  final firebase.AuthCredential pendingCredential;
}
