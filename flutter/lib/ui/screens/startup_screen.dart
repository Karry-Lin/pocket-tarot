part of '../../main.dart';

class StartupScreen extends ConsumerStatefulWidget {
  const StartupScreen({super.key});

  @override
  ConsumerState<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends ConsumerState<StartupScreen> {
  AppStartupState _state = const AppStartupState(
    status: AppStartupStatus.initial,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playBgm();
      _checkStartup();
    });
  }

  Future<void> _checkStartup() async {
    // ignore: avoid_print
    print('DEBUG: _checkStartup() started');
    setState(
      () => _state = const AppStartupState(status: AppStartupStatus.checking),
    );

    // ignore: avoid_print
    print('DEBUG: Reading appStartupControllerProvider...');
    final controller = ref.read(appStartupControllerProvider);
    // ignore: avoid_print
    print('DEBUG: AppStartupController.check() starting...');
    await controller.check();
    // ignore: avoid_print
    print('DEBUG: AppStartupController.check() finished');

    if (!mounted) {
      // ignore: avoid_print
      print('DEBUG: StartupScreen is not mounted after check');
      return;
    }

    final nextState = controller.state;
    // ignore: avoid_print
    print('DEBUG: StartupScreen nextState status: ${nextState.status}, route: ${nextState.targetRoute}');
    if (nextState.status == AppStartupStatus.ready &&
        nextState.targetRoute != null) {
      // ignore: avoid_print
      print('DEBUG: Navigating to ${nextState.targetRoute}');
      context.go(nextState.targetRoute!);
      return;
    }

    setState(() => _state = nextState);
    // ignore: avoid_print
    print('DEBUG: _checkStartup() finished');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return switch (_state.status) {
      AppStartupStatus.initial ||
      AppStartupStatus.checking => const SplashCheckingScreen(),
      AppStartupStatus.networkBlocked => SplashNetworkBlockedScreen(
        onRetry: _checkStartup,
      ),
      AppStartupStatus.error => SplashNetworkBlockedScreen(
        title: l10n.startupFailedTitle,
        message: _state.errorMessage ?? l10n.tryAgainLater,
        onRetry: _checkStartup,
      ),
      AppStartupStatus.ready => const SplashCheckingScreen(),
    };
  }
}

class SplashCheckingScreen extends StatelessWidget {
  const SplashCheckingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usesChinese = _usesChineseCardText(l10n);

    return AppBackdrop(
      child: SafeArea(
        child: _AppLoadingIndicator(
          message: usesChinese ? '啟動中，請稍候...' : 'Initializing Pocket Tarot...',
        ),
      ),
    );
  }
}

class SplashNetworkBlockedScreen extends StatelessWidget {
  const SplashNetworkBlockedScreen({
    super.key,
    this.title,
    this.message,
    this.onRetry,
  });

  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resolvedTitle = title ?? l10n.networkBlockedTitle;
    final resolvedMessage = message ?? l10n.networkBlockedMessage;

    return _RootBackExitGuard(
      child: AppBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: const BrandMark(size: 116, radius: 32)),
                const SizedBox(height: 24),
                Text(
                  resolvedTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  resolvedMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retryCheck),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum EmailAuthMode { signIn, register, resetPassword }
