package com.karry.pocket_tarot

import android.content.pm.PackageManager
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.games.GamesSignInClient
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.PlayGamesSdk
import com.google.android.gms.tasks.Task
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PLAY_GAMES_AUTH_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "signIn" -> signInWithPlayGames(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun signInWithPlayGames(result: MethodChannel.Result) {
        PlayGamesSdk.initialize(this)
        val gamesSignInClient = PlayGames.getGamesSignInClient(this)

        gamesSignInClient.isAuthenticated()
            .addOnCompleteListener { authenticationTask ->
                val isAuthenticated =
                    authenticationTask.isSuccessful &&
                        authenticationTask.result.isAuthenticated

                if (isAuthenticated) {
                    requestServerAuthCode(gamesSignInClient, result)
                    return@addOnCompleteListener
                }

                gamesSignInClient.signIn()
                    .addOnCompleteListener { signInTask ->
                        val isSignedIn =
                            signInTask.isSuccessful &&
                                signInTask.result.isAuthenticated

                        if (!isSignedIn) {
                            result.error(
                                "play-games-sign-in-failed",
                                "Play Games sign-in failed.",
                                taskFailureDetails(signInTask)
                            )
                            return@addOnCompleteListener
                        }

                        requestServerAuthCode(gamesSignInClient, result)
                    }
            }
    }

    private fun requestServerAuthCode(
        gamesSignInClient: GamesSignInClient,
        result: MethodChannel.Result
    ) {
        val oAuthClientId = packageManager
            .getApplicationInfo(packageName, PackageManager.GET_META_DATA)
            .metaData
            ?.getString(OAUTH_2_WEB_CLIENT_ID_KEY)

        if (oAuthClientId.isNullOrBlank()) {
            result.error(
                "play-games-invalid-config",
                "Missing Play Games OAuth 2 web client id metadata.",
                OAUTH_2_WEB_CLIENT_ID_KEY
            )
            return
        }

        gamesSignInClient.requestServerSideAccess(oAuthClientId, false)
            .addOnCompleteListener { authCodeTask ->
                if (!authCodeTask.isSuccessful) {
                    result.error(
                        "play-games-auth-code-failed",
                        "Failed to retrieve Play Games server auth code.",
                        taskFailureDetails(authCodeTask)
                    )
                    return@addOnCompleteListener
                }

                val authCode = authCodeTask.result
                if (authCode.isNullOrBlank()) {
                    result.error(
                        "play-games-auth-code-empty",
                        "Play Games returned an empty server auth code.",
                        null
                    )
                    return@addOnCompleteListener
                }

                result.success(authCode)
            }
    }

    private fun taskFailureDetails(task: Task<*>): String? {
        val exception = task.exception ?: return null
        if (exception is ApiException) {
            return "statusCode=${exception.statusCode}, message=${exception.statusMessage}"
        }
        return exception.message
    }

    private companion object {
        const val PLAY_GAMES_AUTH_CHANNEL = "pocket_tarot/play_games_auth"
        const val OAUTH_2_WEB_CLIENT_ID_KEY =
            "com.chunkytofustudios.firebase_auth_games_services.OAUTH_2_WEB_CLIENT_ID"
    }
}
