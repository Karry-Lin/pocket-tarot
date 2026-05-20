import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_tarot/app/app_providers.dart';
import 'package:pocket_tarot/domain/models/api_reading_models.dart';
import 'package:pocket_tarot/data/repositories/tarot_catalog_repository.dart';
import 'package:pocket_tarot/domain/models/local_settings.dart';
import 'package:pocket_tarot/domain/models/tarot_card.dart';
import 'package:pocket_tarot/domain/use_cases/app_startup_controller.dart';
import 'package:pocket_tarot/domain/use_cases/auth_form_validator.dart';
import 'package:pocket_tarot/domain/use_cases/daily_reading_controller.dart';
import 'package:pocket_tarot/domain/use_cases/deep_reading_controller.dart';
import 'package:pocket_tarot/domain/use_cases/profile_controller.dart';
import 'package:pocket_tarot/l10n/generated/app_localizations.dart';
import 'package:pocket_tarot/ui/core/widgets/safe_markdown_body.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PocketTarotApp()));
}

final tarotCatalogRepositoryProvider = Provider<TarotCatalogRepository>((ref) {
  return TarotCatalogRepository(rootBundle);
});
final tarotCardsProvider = FutureProvider<List<TarotCard>>((ref) {
  return ref.watch(tarotCatalogRepositoryProvider).loadCards();
});

class PocketTarotApp extends ConsumerStatefulWidget {
  const PocketTarotApp({super.key, this.initialLocation = '/splash'});

  final String initialLocation;

  @override
  ConsumerState<PocketTarotApp> createState() => _PocketTarotAppState();
}

class _PocketTarotAppState extends ConsumerState<PocketTarotApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(initialLocation: widget.initialLocation);
  }

  @override
  void didUpdateWidget(PocketTarotApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLocation != widget.initialLocation) {
      _router.dispose();
      _router = createRouter(initialLocation: widget.initialLocation);
    }
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocale = ref.watch(appLocaleProvider).asData?.value;

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: appLocale,
      theme: buildTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}

GoRouter createRouter({String initialLocation = '/splash'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const StartupScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/pending',
        builder: (context, state) => const PendingActivationScreen(),
      ),
      GoRoute(
        path: '/account-deleted',
        builder: (context, state) => const AccountDeletedScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/divination',
                builder: (context, state) => const DivinationScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

ThemeData buildTheme() {
  const ink = Color(0xFF151416);
  const paper = Color(0xFFFFFAF1);
  const brass = Color(0xFFE7B75F);
  const teal = Color(0xFF68B7A1);
  const coral = Color(0xFFE87461);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ink,
    colorScheme: const ColorScheme.dark(
      primary: brass,
      secondary: teal,
      tertiary: coral,
      surface: Color(0xFF232025),
      onSurface: paper,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      bodyMedium: TextStyle(fontSize: 15, height: 1.45, letterSpacing: 0),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1C1A1F),
      indicatorColor: brass.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF242127),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: paper.withValues(alpha: 0.08)),
      ),
    ),
  );
}

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkStartup());
  }

  Future<void> _checkStartup() async {
    setState(
      () => _state = const AppStartupState(status: AppStartupStatus.checking),
    );

    final controller = ref.read(appStartupControllerProvider);
    await controller.check();

    if (!mounted) {
      return;
    }

    final nextState = controller.state;
    if (nextState.status == AppStartupStatus.ready &&
        nextState.targetRoute != null) {
      context.go(nextState.targetRoute!);
      return;
    }

    setState(() => _state = nextState);
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

    return AppBackdrop(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/pocket-tarot-logo.png',
                  height: 108,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.startupCheckingTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.startupCheckingMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ),
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

    return AppBackdrop(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/pocket-tarot-logo.png',
                  height: 108,
                ),
              ),
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
    );
  }
}

enum EmailAuthMode { signIn, register, resetPassword }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  EmailAuthMode _mode = EmailAuthMode.signIn;
  Map<AuthFormField, String> _errors = const {};
  String? _formError;
  String? _formMessage;
  bool _submitting = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBackdrop(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 42),
              Center(
                child: Image.asset(
                  'assets/images/pocket-tarot-logo.png',
                  height: 112,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pocket Tarot',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.loginTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              if (_mode == EmailAuthMode.register) ...[
                AuthField(
                  label: l10n.displayNameLabel,
                  controller: _displayNameController,
                  errorText: _errors[AuthFormField.displayName],
                ),
                const SizedBox(height: 12),
              ],
              AuthField(
                label: 'Email',
                controller: _emailController,
                errorText: _errors[AuthFormField.email],
              ),
              const SizedBox(height: 12),
              if (_mode != EmailAuthMode.resetPassword)
                AuthField(
                  label: l10n.passwordLabel,
                  controller: _passwordController,
                  obscureText: true,
                  errorText: _errors[AuthFormField.password],
                ),
              if (_mode == EmailAuthMode.register) ...[
                const SizedBox(height: 12),
                AuthField(
                  label: l10n.confirmPasswordLabel,
                  controller: _confirmPasswordController,
                  obscureText: true,
                  errorText: _errors[AuthFormField.confirmPassword],
                ),
              ],
              const SizedBox(height: 16),
              if (_formError != null || _formMessage != null) ...[
                Text(
                  _formError ?? _formMessage!,
                  style: TextStyle(
                    color: _formError == null
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
              ],
              _PrimaryEmailAuthButton(
                mode: _mode,
                onPressed: _submitting ? null : _submit,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _submitting ? null : _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata),
                label: Text(l10n.googleLogin),
              ),
              const SizedBox(height: 4),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  if (_mode != EmailAuthMode.signIn)
                    TextButton(
                      onPressed: () => _switchMode(EmailAuthMode.signIn),
                      child: Text(l10n.loginAction),
                    ),
                  if (_mode != EmailAuthMode.register)
                    TextButton(
                      onPressed: () => _switchMode(EmailAuthMode.register),
                      child: Text(l10n.registerAction),
                    ),
                  if (_mode != EmailAuthMode.resetPassword)
                    TextButton(
                      onPressed: () => _switchMode(EmailAuthMode.resetPassword),
                      child: Text(l10n.forgotPassword),
                    ),
                ],
              ),
              const SizedBox(height: 42),
            ],
          ),
        ),
      ),
    );
  }

  void _switchMode(EmailAuthMode mode) {
    setState(() {
      _mode = mode;
      _errors = const {};
      _formError = null;
      _formMessage = null;
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final validationMessages = AuthFormValidationMessages(
      emailInvalid: l10n.emailInvalid,
      passwordInvalid: l10n.passwordInvalid,
      displayNameInvalid: l10n.displayNameInvalid,
      confirmPasswordMismatch: l10n.confirmPasswordMismatch,
    );
    final result = switch (_mode) {
      EmailAuthMode.signIn => AuthFormValidator.validateEmailSignIn(
        email: _emailController.text,
        password: _passwordController.text,
        messages: validationMessages,
      ),
      EmailAuthMode.register => AuthFormValidator.validateEmailRegistration(
        displayName: _displayNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        messages: validationMessages,
      ),
      EmailAuthMode.resetPassword => AuthFormValidator.validatePasswordReset(
        email: _emailController.text,
        messages: validationMessages,
      ),
    };

    if (!result.isValid) {
      setState(() {
        _errors = result.errors;
        _formError = null;
        _formMessage = null;
      });
      return;
    }

    setState(() {
      _errors = const {};
      _formError = null;
      _formMessage = null;
      _submitting = true;
    });

    try {
      final authActions = ref.read(authActionsProvider);
      switch (_mode) {
        case EmailAuthMode.signIn:
          await authActions.signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          if (mounted) {
            context.go('/splash');
          }
        case EmailAuthMode.register:
          await authActions.registerWithEmail(
            displayName: _displayNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          if (mounted) {
            context.go('/verify-email');
          }
        case EmailAuthMode.resetPassword:
          await authActions.sendPasswordResetEmail(
            _emailController.text.trim(),
          );
          if (mounted) {
            setState(() => _formMessage = l10n.passwordResetSent);
          }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _formError = l10n.formFailure;
          _formMessage = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _formError = null;
      _formMessage = null;
      _submitting = true;
    });

    try {
      await ref.read(authActionsProvider).signInWithGoogle();
      if (mounted) {
        context.go('/splash');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _formError = l10n.googleFailure;
          _formMessage = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _PrimaryEmailAuthButton extends StatelessWidget {
  const _PrimaryEmailAuthButton({required this.mode, required this.onPressed});

  final EmailAuthMode mode;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (mode) {
      EmailAuthMode.signIn => l10n.emailLogin,
      EmailAuthMode.register => l10n.createAccount,
      EmailAuthMode.resetPassword => l10n.sendPasswordReset,
    };
    final icon = switch (mode) {
      EmailAuthMode.signIn => Icons.login,
      EmailAuthMode.register => Icons.person_add,
      EmailAuthMode.resetPassword => Icons.mark_email_read,
    };

    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GateScaffold(
      icon: Icons.mark_email_unread,
      title: l10n.verifyEmailTitle,
      message: l10n.verifyEmailMessage,
      actionLabel: l10n.verifyEmailAction,
      onAction: () => context.go('/splash'),
    );
  }
}

class PendingActivationScreen extends StatelessWidget {
  const PendingActivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GateScaffold(
      icon: Icons.hourglass_bottom,
      title: l10n.pendingTitle,
      message: l10n.pendingMessage,
      actionLabel: l10n.retryCheck,
      onAction: () => context.go('/splash'),
    );
  }
}

class AccountDeletedScreen extends StatelessWidget {
  const AccountDeletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GateScaffold(
      icon: Icons.no_accounts,
      title: l10n.accountDeletedTitle,
      message: l10n.accountDeletedMessage,
      actionLabel: l10n.accountDeletedAction,
      onAction: () => context.go('/login'),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view),
            label: l10n.navDivination,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book),
            label: l10n.navLibrary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DailyReadingState _dailyState = const DailyReadingState.initial();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadToday());
  }

  Future<void> _loadToday() async {
    final controller = await ref.read(dailyReadingControllerProvider.future);
    await controller.loadToday();
    if (mounted) {
      setState(() => _dailyState = controller.state);
    }
  }

  Future<void> _drawToday() async {
    final controller = await ref.read(dailyReadingControllerProvider.future);
    await controller.drawToday();
    if (mounted) {
      setState(() => _dailyState = controller.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerAsync = ref.watch(dailyReadingControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return ScreenFrame(
      title: l10n.homeTitle,
      trailing: 'Asia/Taipei',
      child: controllerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            _DailyErrorPanel(message: error.toString(), onRetry: _loadToday),
        data: (_) => _dailyContent(context),
      ),
    );
  }

  Widget _dailyContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return switch (_dailyState.status) {
      DailyReadingStatus.initial || DailyReadingStatus.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      DailyReadingStatus.empty => _DailyEmptyState(onDraw: _drawToday),
      DailyReadingStatus.creating => const Center(
        child: CircularProgressIndicator(),
      ),
      DailyReadingStatus.loaded => DailyResultCard(
        reading: _dailyState.reading!,
      ),
      DailyReadingStatus.error => _DailyErrorPanel(
        message: _dailyState.errorMessage ?? l10n.dailyLoadFailed,
        onRetry: _loadToday,
      ),
    };
  }
}

class DailyResultCard extends StatelessWidget {
  const DailyResultCard({super.key, required this.reading});

  final DailyReading reading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardPreview(
          imagePath: _imageForCardId(reading.card.cardId),
          title:
              '${reading.card.cardId} / ${_orientationLabel(reading.card.orientation, l10n)}',
        ),
        const SizedBox(height: 18),
        InfoPanel(
          title: l10n.dailyReadingPanelTitle,
          child: SafeMarkdownBody(data: reading.markdownResult),
        ),
        const SizedBox(height: 12),
        SummaryStrip(text: reading.summary),
      ],
    );
  }
}

class _DailyEmptyState extends StatelessWidget {
  const _DailyEmptyState({required this.onDraw});

  final VoidCallback onDraw;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardPreview(
          imagePath: 'assets/images/card-back.png',
          title: l10n.dailyEmptyTitle,
        ),
        const SizedBox(height: 18),
        Text(
          l10n.dailyEmptyMessage,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onDraw,
          icon: const Icon(Icons.style),
          label: Text(l10n.dailyDrawButton),
        ),
      ],
    );
  }
}

class _DailyErrorPanel extends StatelessWidget {
  const _DailyErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InfoPanel(
      title: l10n.dailyLoadFailed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(message),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retryLoad),
          ),
        ],
      ),
    );
  }
}

class DivinationScreen extends ConsumerStatefulWidget {
  const DivinationScreen({super.key});

  @override
  ConsumerState<DivinationScreen> createState() => _DivinationScreenState();
}

class _DivinationScreenState extends ConsumerState<DivinationScreen> {
  final TextEditingController _questionController = TextEditingController();
  DeepReadingState _deepState = const DeepReadingState.initial();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _startDraft() async {
    final controller = await ref.read(deepReadingControllerProvider.future);
    await controller.startDraft(_questionController.text);
    if (mounted) {
      setState(() => _deepState = controller.state);
    }
  }

  Future<void> _createResult() async {
    final controller = await ref.read(deepReadingControllerProvider.future);
    await controller.createResult();
    if (mounted) {
      setState(() => _deepState = controller.state);
    }
  }

  Future<void> _toggleCard(int index) async {
    final controller = await ref.read(deepReadingControllerProvider.future);
    controller.toggleSelection(index);
    if (mounted) {
      setState(() => _deepState = controller.state);
    }
  }

  Future<void> _updateHistoryVisibility(bool isSavedForHistory) async {
    final controller = await ref.read(deepReadingControllerProvider.future);
    await controller.updateHistoryVisibility(isSavedForHistory);
    if (mounted) {
      setState(() => _deepState = controller.state);
    }
  }

  Future<void> _loadHistory() async {
    final controller = await ref.read(deepReadingControllerProvider.future);
    await controller.loadHistory();
    if (mounted) {
      setState(() => _deepState = controller.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerAsync = ref.watch(deepReadingControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return ScreenFrame(
      title: l10n.divinationTitle,
      trailing: '${_deepState.selectedIndexes.length}/3',
      child: controllerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => InfoPanel(
          title: l10n.divinationLoadFailed,
          child: Text(error.toString()),
        ),
        data: (_) => _deepContent(context),
      ),
    );
  }

  Widget _deepContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthField(
          label: l10n.questionLabel,
          controller: _questionController,
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PromptChip(
              text: l10n.promptWork,
              onPressed: () => _applyQuestionTemplate(l10n.promptWork),
            ),
            PromptChip(
              text: l10n.promptLove,
              onPressed: () => _applyQuestionTemplate(l10n.promptLove),
            ),
            PromptChip(
              text: l10n.promptNextStep,
              onPressed: () => _applyQuestionTemplate(l10n.promptNextStep),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (_deepState.status == DeepReadingStatus.initial)
          FilledButton.icon(
            onPressed: _startDraft,
            icon: const Icon(Icons.grid_3x3),
            label: Text(l10n.startDraft),
          )
        else if (_deepState.status == DeepReadingStatus.drafting ||
            _deepState.status == DeepReadingStatus.creating)
          const Center(child: CircularProgressIndicator())
        else ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.68,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _deepState.draftCards.length,
            itemBuilder: (context, index) => SelectableCardBack(
              selected: _deepState.selectedIndexes.contains(index),
              order: _deepState.selectedIndexes.indexOf(index) + 1,
              onTap: () => _toggleCard(index),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _deepState.selectedIndexes.length == 3
                ? _createResult
                : null,
            icon: const Icon(Icons.auto_fix_high),
            label: Text(l10n.createReading),
          ),
          if (_deepState.reading != null) ...[
            const SizedBox(height: 18),
            DeepResultPanel(
              reading: _deepState.reading!,
              isSavedForHistory: _deepState.isResultSavedForHistory,
              onHistoryVisibilityChanged: _updateHistoryVisibility,
            ),
          ],
          if (_deepState.status == DeepReadingStatus.error &&
              _deepState.errorMessage != null) ...[
            const SizedBox(height: 12),
            InfoPanel(
              title: l10n.readingCreateFailed,
              child: Text(_deepState.errorMessage!),
            ),
          ],
        ],
        const SizedBox(height: 18),
        DeepHistoryPanel(state: _deepState, onLoadHistory: _loadHistory),
      ],
    );
  }

  void _applyQuestionTemplate(String question) {
    _questionController.text = question;
    _questionController.selection = TextSelection.collapsed(
      offset: question.length,
    );
  }
}

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  TarotCategory _category = TarotCategory.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(tarotCardsProvider);
    final repository = ref.watch(tarotCatalogRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    return ScreenFrame(
      title: l10n.libraryTitle,
      trailing: '78',
      child: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            InfoPanel(title: l10n.libraryLoadFailed, child: Text('$error')),
        data: (cards) {
          final categorized = repository.filterByCategory(cards, _category);
          final filtered = repository.search(categorized, _query);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  labelText: l10n.searchCardsLabel,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close),
                        ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in TarotCategory.values)
                    ChoiceChip(
                      label: Text(_categoryLabel(category, l10n)),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.cardsCount(filtered.length),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              for (final card in filtered)
                Card(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        _imageForCard(card),
                        width: 42,
                        height: 58,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(card.zhName),
                    subtitle: Text('${card.enName}\n${card.id}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      builder: (context) => CardDetailSheet(
                        card: card,
                        imagePath: _imageForCard(card),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ProfileState _profileState = const ProfileState.initial();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final controller = await ref.read(profileControllerProvider.future);
    await controller.load();
    if (mounted) {
      setState(() => _profileState = controller.state);
    }
  }

  Future<void> _setLocaleMode(LocaleMode localeMode) async {
    final controller = await ref.read(profileControllerProvider.future);
    await controller.setLocaleMode(localeMode);
    ref.invalidate(appLocaleProvider);
    if (mounted) {
      setState(() => _profileState = controller.state);
    }
  }

  Future<void> _setWeatherEnabled(bool weatherEnabled) async {
    final controller = await ref.read(profileControllerProvider.future);
    await controller.setWeatherEnabled(weatherEnabled);
    if (mounted) {
      setState(() => _profileState = controller.state);
    }
  }

  Future<void> _updateDisplayName(String displayName) async {
    final controller = await ref.read(profileControllerProvider.future);
    await controller.updateDisplayName(displayName);
    if (mounted) {
      setState(() => _profileState = controller.state);
    }
  }

  Future<void> _signOut() async {
    final controller = await ref.read(profileControllerProvider.future);
    await controller.signOut();
    if (!mounted) {
      return;
    }

    setState(() => _profileState = controller.state);
    if (controller.state.status == ProfileStatus.signedOut) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerAsync = ref.watch(profileControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return ScreenFrame(
      title: l10n.profileTitle,
      trailing: _profileState.snapshot?.user.displayName,
      child: controllerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => InfoPanel(
          title: l10n.profileLoadFailed,
          child: Text(error.toString()),
        ),
        data: (_) => _profileContent(context),
      ),
    );
  }

  Widget _profileContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final snapshot = _profileState.snapshot;
    final settings =
        _profileState.settings ??
        const LocalSettings(
          localeMode: LocaleMode.system,
          weatherEnabled: true,
        );

    if (_profileState.status == ProfileStatus.initial ||
        _profileState.status == ProfileStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot == null) {
      return InfoPanel(
        title: l10n.profileLoadFailed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_profileState.errorMessage ?? l10n.profileLoadFallback),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryLoad),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoPanel(
          title: snapshot.user.displayName,
          child: Text(
            '${snapshot.user.email}\n${l10n.profileStats(snapshot.stats.dailyReadingCount, snapshot.stats.deepReadingCount)}',
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<LocaleMode>(
          segments: [
            ButtonSegment(
              value: LocaleMode.system,
              label: Text(l10n.localeSystem),
            ),
            ButtonSegment(value: LocaleMode.zhTw, label: Text(l10n.localeZh)),
            ButtonSegment(value: LocaleMode.en, label: Text(l10n.localeEn)),
          ],
          selected: {settings.localeMode},
          onSelectionChanged: (value) => _setLocaleMode(value.first),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: settings.weatherEnabled,
          onChanged: _setWeatherEnabled,
          title: Text(l10n.weatherToggle),
          secondary: const Icon(Icons.cloud),
        ),
        OutlinedButton.icon(
          onPressed: () => _showNameDialog(context, _updateDisplayName),
          icon: const Icon(Icons.edit),
          label: Text(l10n.editDisplayName),
        ),
        TextButton.icon(
          onPressed: _signOut,
          icon: const Icon(Icons.logout),
          label: Text(l10n.signOut),
        ),
      ],
    );
  }
}

class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final String? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppBackdrop(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    if (trailing != null) Badge(label: Text(trailing!)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 112),
              sliver: SliverToBoxAdapter(child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF151416), Color(0xFF232025), Color(0xFF102A2A)],
          ),
        ),
        child: child,
      ),
    );
  }
}

class GateScaffold extends ConsumerWidget {
  const GateScaffold({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AppBackdrop(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                icon,
                size: 54,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(onPressed: onAction, child: Text(actionLabel)),
              TextButton(
                onPressed: () async {
                  try {
                    await ref.read(authActionsProvider).signOut();
                  } finally {
                    if (context.mounted) {
                      context.go('/login');
                    }
                  }
                },
                child: Text(l10n.signOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.maxLines = 1,
    this.errorText,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final int maxLines;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class CardPreview extends StatelessWidget {
  const CardPreview({super.key, required this.imagePath, required this.title});

  final String imagePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(imagePath, height: 260, fit: BoxFit.cover),
            ),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class SummaryStrip extends StatelessWidget {
  const SummaryStrip({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class PromptChip extends StatelessWidget {
  const PromptChip({super.key, required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.add, size: 16),
      label: Text(text),
      onPressed: onPressed,
    );
  }
}

class SelectableCardBack extends StatelessWidget {
  const SelectableCardBack({
    super.key,
    required this.selected,
    required this.order,
    required this.onTap,
  });

  final bool selected;
  final int order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/card-back.png',
              fit: BoxFit.cover,
            ),
          ),
          if (selected)
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                color: Colors.black.withValues(alpha: 0.18),
              ),
              child: Center(
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '$order',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DeepResultPanel extends StatelessWidget {
  const DeepResultPanel({
    super.key,
    required this.reading,
    required this.isSavedForHistory,
    required this.onHistoryVisibilityChanged,
  });

  final DeepReading reading;
  final bool isSavedForHistory;
  final ValueChanged<bool> onHistoryVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoPanel(
          title: l10n.deepResultTitle,
          child: SafeMarkdownBody(data: reading.markdownResult),
        ),
        const SizedBox(height: 10),
        SummaryStrip(text: reading.summary),
        const SizedBox(height: 10),
        SwitchListTile(
          value: isSavedForHistory,
          onChanged: onHistoryVisibilityChanged,
          title: Text(l10n.saveToHistory),
          secondary: const Icon(Icons.bookmark_add),
        ),
        const SizedBox(height: 10),
        InfoPanel(
          title: l10n.selectedCardsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final card in reading.selectedCards)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${card.positionLabel} · ${card.cardId} · ${_orientationLabel(card.orientation, l10n)}',
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class DeepHistoryPanel extends StatelessWidget {
  const DeepHistoryPanel({
    super.key,
    required this.state,
    required this.onLoadHistory,
  });

  final DeepReadingState state;
  final VoidCallback onLoadHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InfoPanel(
      title: l10n.historyTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: onLoadHistory,
            icon: const Icon(Icons.history),
            label: Text(l10n.loadHistory),
          ),
          if (state.status == DeepReadingStatus.historyLoading) ...[
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator()),
          ] else if (state.status == DeepReadingStatus.historyReady &&
              state.history.isEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.emptyHistory),
          ] else if (state.history.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final item in state.history)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item.question.isEmpty ? l10n.unnamedQuestion : item.question,
                ),
                subtitle: Text(item.summary),
                trailing: const Icon(Icons.chevron_right),
              ),
          ],
        ],
      ),
    );
  }
}

class CardDetailSheet extends StatelessWidget {
  const CardDetailSheet({
    super.key,
    required this.card,
    required this.imagePath,
  });

  final TarotCard card;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Image.asset(imagePath, height: 220, fit: BoxFit.cover)),
          const SizedBox(height: 16),
          Text(card.zhName, style: Theme.of(context).textTheme.headlineSmall),
          Text(card.enName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.cardMeaningText(card.uprightMeaning, card.reversedMeaning)),
        ],
      ),
    );
  }
}

String _imageForCard(TarotCard card) {
  return _imageForCardId(card.id);
}

String _imageForCardId(String cardId) {
  return switch (cardId) {
    'major-18-moon' => 'assets/images/cards/moon.jpg',
    'major-17-star' => 'assets/images/cards/star.jpg',
    'major-14-temperance' => 'assets/images/cards/temperance.jpg',
    _ => 'assets/images/card-back.png',
  };
}

String _categoryLabel(TarotCategory category, AppLocalizations l10n) {
  return switch (category) {
    TarotCategory.all => l10n.categoryAll,
    TarotCategory.major => l10n.categoryMajor,
    TarotCategory.wands => l10n.categoryWands,
    TarotCategory.cups => l10n.categoryCups,
    TarotCategory.swords => l10n.categorySwords,
    TarotCategory.pentacles => l10n.categoryPentacles,
  };
}

String _orientationLabel(String orientation, AppLocalizations l10n) {
  return switch (orientation) {
    'upright' => l10n.upright,
    'reversed' => l10n.reversed,
    _ => orientation,
  };
}

Future<void> _showNameDialog(
  BuildContext context,
  Future<void> Function(String displayName) onSave,
) async {
  final l10n = AppLocalizations.of(context)!;
  final textController = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.editNameTitle),
      content: TextField(
        controller: textController,
        maxLength: 16,
        decoration: InputDecoration(labelText: l10n.nicknameLabel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () async {
            await onSave(textController.text);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}
