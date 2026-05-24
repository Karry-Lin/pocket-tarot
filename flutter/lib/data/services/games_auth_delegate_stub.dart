import 'package:firebase_auth/firebase_auth.dart' as firebase;

Future<firebase.UserCredential> signInWithPlayGames(
  firebase.FirebaseAuth auth,
) {
  throw UnsupportedError('Play Games sign-in is only available on Android.');
}
