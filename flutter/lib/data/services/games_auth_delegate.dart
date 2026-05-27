import 'package:firebase_auth/firebase_auth.dart' as firebase;

import 'games_auth_delegate_stub.dart'
    if (dart.library.io) 'games_auth_delegate_io.dart'
    as delegate;

Future<firebase.UserCredential> signInWithPlayGames(
  firebase.FirebaseAuth auth,
) {
  return delegate.signInWithPlayGames(auth);
}
