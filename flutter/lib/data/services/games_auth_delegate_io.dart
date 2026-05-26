import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/services.dart';

Future<firebase.UserCredential> signInWithPlayGames(
  firebase.FirebaseAuth auth,
) async {
  if (!Platform.isAndroid) {
    throw UnsupportedError('Play Games sign-in is only available on Android.');
  }

  final authCode = await _playGamesAuthChannel.invokeMethod<String>('signIn');
  if (authCode == null || authCode.isEmpty) {
    throw StateError('Play Games did not return a server auth code.');
  }

  final credential = firebase.PlayGamesAuthProvider.credential(
    serverAuthCode: authCode,
  );
  return auth.signInWithCredential(credential);
}

const _playGamesAuthChannel = MethodChannel('pocket_tarot/play_games_auth');
