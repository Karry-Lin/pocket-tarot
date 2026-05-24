import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_auth_games_services/firebase_auth_games_services.dart';

Future<firebase.UserCredential> signInWithPlayGames(
  firebase.FirebaseAuth auth,
) {
  if (!Platform.isAndroid) {
    throw UnsupportedError('Play Games sign-in is only available on Android.');
  }

  return auth.signInWithPlayGames();
}
