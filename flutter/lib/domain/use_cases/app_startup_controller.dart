import 'package:pocket_tarot/domain/use_cases/auth_gate_evaluator.dart';

typedef AuthGateRunner = Future<AuthGateResult> Function();

enum AppStartupStatus {
  initial,
  checking,
  networkBlocked,
  ready,
  error,
}

class AppStartupState {
  const AppStartupState({
    required this.status,
    this.targetRoute,
    this.errorMessage,
  });

  const AppStartupState.initial() : this(status: AppStartupStatus.initial);

  final AppStartupStatus status;
  final String? targetRoute;
  final String? errorMessage;
}

class AppStartupController {
  AppStartupController({
    required AuthGateRunner evaluateAuthGate,
  }) : _evaluateAuthGate = evaluateAuthGate;

  final AuthGateRunner _evaluateAuthGate;

  AppStartupState _state = const AppStartupState.initial();

  AppStartupState get state => _state;

  Future<void> check() async {
    _state = const AppStartupState(status: AppStartupStatus.checking);

    try {
      final result = await _evaluateAuthGate();
      final route = _routeFor(result.destination);

      _state = route == null
          ? const AppStartupState(status: AppStartupStatus.networkBlocked)
          : AppStartupState(status: AppStartupStatus.ready, targetRoute: route);
    } catch (error) {
      _state = AppStartupState(status: AppStartupStatus.error, errorMessage: error.toString());
    }
  }

  String? _routeFor(AuthGateDestination destination) {
    return switch (destination) {
      AuthGateDestination.splashNetworkBlocked => null,
      AuthGateDestination.login => '/login',
      AuthGateDestination.verifyEmail => '/verify-email',
      AuthGateDestination.accountDeleted => '/account-deleted',
      AuthGateDestination.pendingActivation => '/pending',
      AuthGateDestination.appShell => '/home',
    };
  }
}
