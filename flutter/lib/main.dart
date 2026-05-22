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
      GoRoute(path: '/draw', builder: (context, state) => const DrawScreen()),
      GoRoute(
        path: '/result',
        builder: (context, state) => const ReadingResultScreen(),
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

const _kAppFrameMaxWidth = 430.0;

class _ArcanaColors {
  static const ink = Color(0xFF090613);
  static const ink2 = Color(0xFF10091E);
  static const plum = Color(0xFF20102F);
  static const wine = Color(0xFF4B193F);
  static const peacock = Color(0xFF1F6B72);
  static const gold = Color(0xFFD7B26D);
  static const gold2 = Color(0xFFF2D896);
  static const ivory = Color(0xFFF7EFD7);
  static const muted = Color(0xFFB8A9C8);
  static const subtle = Color(0xFF7F7190);
  static const error = Color(0xFFFFA29A);
}

TextStyle _displayTextStyle({
  required double fontSize,
  FontWeight fontWeight = FontWeight.w600,
  double height = 1.08,
}) {
  return TextStyle(
    color: _ArcanaColors.ivory,
    fontFamily: 'Noto Serif TC',
    fontFamilyFallback: const [
      'Source Han Serif TC',
      'Iowan Old Style',
      'Georgia',
      'serif',
    ],
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: 0,
  );
}

TextStyle _bodyTextStyle({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w500,
  Color color = _ArcanaColors.muted,
  double height = 1.55,
}) {
  return TextStyle(
    color: color,
    fontFamily: 'Noto Sans TC',
    fontFamilyFallback: const ['Microsoft JhengHei', 'Segoe UI', 'sans-serif'],
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: 0,
  );
}

ThemeData buildTheme() {
  final textTheme = TextTheme(
    displaySmall: _displayTextStyle(fontSize: 38, height: 1),
    headlineSmall: _displayTextStyle(fontSize: 27),
    titleLarge: _displayTextStyle(fontSize: 27),
    titleMedium: _bodyTextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w800,
      color: _ArcanaColors.ivory,
      height: 1.24,
    ),
    bodyLarge: _bodyTextStyle(fontSize: 15),
    bodyMedium: _bodyTextStyle(),
    bodySmall: _bodyTextStyle(fontSize: 12, color: _ArcanaColors.subtle),
    labelLarge: _bodyTextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: _ArcanaColors.ink2,
      height: 1,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _ArcanaColors.ink,
    colorScheme: const ColorScheme.dark(
      primary: _ArcanaColors.gold,
      secondary: _ArcanaColors.peacock,
      tertiary: _ArcanaColors.wine,
      error: _ArcanaColors.error,
      surface: _ArcanaColors.plum,
      onSurface: _ArcanaColors.ivory,
    ),
    textTheme: textTheme,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _ArcanaColors.ink.withValues(alpha: 0.86),
      indicatorColor: _ArcanaColors.gold.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        foregroundColor: _ArcanaColors.ink2,
        backgroundColor: _ArcanaColors.gold2,
        disabledForegroundColor: _ArcanaColors.subtle,
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
        textStyle: _bodyTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: _ArcanaColors.ink2,
          height: 1,
        ),
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: _ArcanaColors.ivory,
        side: BorderSide(color: _ArcanaColors.gold2.withValues(alpha: 0.52)),
        textStyle: _bodyTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: _ArcanaColors.ivory,
          height: 1,
        ),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _ArcanaColors.gold2,
        textStyle: _bodyTextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: _ArcanaColors.gold2,
          height: 1,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _ArcanaColors.ink.withValues(alpha: 0.68),
      labelStyle: _bodyTextStyle(fontSize: 12, color: _ArcanaColors.muted),
      hintStyle: _bodyTextStyle(fontSize: 13, color: _ArcanaColors.subtle),
      errorStyle: _bodyTextStyle(fontSize: 12, color: _ArcanaColors.error),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: _ArcanaColors.muted.withValues(alpha: 0.24),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: _ArcanaColors.muted.withValues(alpha: 0.24),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _ArcanaColors.gold),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.035),
      selectedColor: _ArcanaColors.gold.withValues(alpha: 0.14),
      disabledColor: Colors.white.withValues(alpha: 0.04),
      side: BorderSide(color: _ArcanaColors.muted.withValues(alpha: 0.22)),
      labelStyle: _bodyTextStyle(fontSize: 12, color: _ArcanaColors.muted),
      secondaryLabelStyle: _bodyTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: _ArcanaColors.ivory,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    ),
    cardTheme: CardThemeData(
      color: _ArcanaColors.plum.withValues(alpha: 0.92),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: _ArcanaColors.gold.withValues(alpha: 0.2)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _ArcanaColors.ink2,
      modalBackgroundColor: _ArcanaColors.ink2,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _ArcanaColors.plum,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
              Center(child: const BrandMark(size: 116, radius: 32)),
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
  bool _showEmailForm = false;

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
    final usesChinese = _usesChineseCardText(l10n);

    if (visualFixtureMode && usesChinese && _showEmailForm) {
      return _VisualEmailLoginScreen(
        emailController: _emailController,
        passwordController: _passwordController,
        emailError: _errors[AuthFormField.email],
        passwordError: _errors[AuthFormField.password],
        formMessage: _formError ?? _formMessage,
        isError: _formError != null,
        submitting: _submitting,
        onSubmit: _submit,
      );
    }

    return AppBackdrop(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 28, 26, 34),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: _showEmailForm ? 88 : 242),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: BrandMark(size: 58, radius: 18),
                  ),
                  const SizedBox(height: 19),
                  const EyebrowText('Pocket Tarot'),
                  const SizedBox(height: 7),
                  Text(
                    usesChinese ? '登入口袋塔羅' : 'Sign in to Pocket Tarot',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(usesChinese ? '保存每日抽牌與占卜紀錄。' : l10n.loginTagline),
                  const SizedBox(height: 21),
                  if (!_showEmailForm)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _submitting ? null : _signInWithGoogle,
                          icon: const Text('G'),
                          label: Text(
                            usesChinese ? '使用 Google 繼續' : l10n.googleLogin,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (visualFixtureMode && usesChinese)
                          ArcanaPrimaryButton(
                            onPressed: _submitting
                                ? null
                                : () => setState(() => _showEmailForm = true),
                            child: const Text('使用 Email 登入'),
                          )
                        else
                          FilledButton(
                            onPressed: _submitting
                                ? null
                                : () => setState(() => _showEmailForm = true),
                            child: Text(l10n.emailLogin),
                          ),
                      ],
                    )
                  else
                    GlassPanel(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const EyebrowText('Email sign in'),
                          const SizedBox(height: 8),
                          Text(
                            usesChinese ? 'Email 登入' : 'Email sign in',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
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
                                    ? _ArcanaColors.gold2
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
                          const SizedBox(height: 6),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            children: [
                              if (_mode != EmailAuthMode.signIn)
                                TextButton(
                                  onPressed: () =>
                                      _switchMode(EmailAuthMode.signIn),
                                  child: Text(l10n.loginAction),
                                ),
                              if (_mode != EmailAuthMode.register)
                                TextButton(
                                  onPressed: () =>
                                      _switchMode(EmailAuthMode.register),
                                  child: Text(l10n.registerAction),
                                ),
                              if (_mode != EmailAuthMode.resetPassword)
                                TextButton(
                                  onPressed: () =>
                                      _switchMode(EmailAuthMode.resetPassword),
                                  child: Text(l10n.forgotPassword),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 42),
                ],
              ),
            ),
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

class _VisualEmailLoginScreen extends StatelessWidget {
  const _VisualEmailLoginScreen({
    required this.emailController,
    required this.passwordController,
    required this.emailError,
    required this.passwordError,
    required this.formMessage,
    required this.isError,
    required this.submitting,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final String? formMessage;
  final bool isError;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppBackdrop(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 84, 18, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  BrandMark(size: 58, radius: 18),
                  Spacer(),
                  TagPill(text: 'Member gate'),
                ],
              ),
              const SizedBox(height: 54),
              const EyebrowText('Enter the circle'),
              const SizedBox(height: 14),
              Text(
                '今晚，讓牌替你留一盞光。',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                '登入後保存每日抽牌、深度占卜紀錄與你的個人牌義筆記。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              GlassPanel(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const EyebrowText('Email sign in'),
                    const SizedBox(height: 8),
                    Text(
                      '輸入你的密語',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 18),
                    _VisualEmailField(
                      label: 'Email',
                      hintText: 'you@example.com',
                      controller: emailController,
                      errorText: emailError,
                    ),
                    const SizedBox(height: 14),
                    _VisualEmailField(
                      label: '密碼',
                      hintText: '至少 6 個字元',
                      controller: passwordController,
                      obscureText: true,
                      errorText: passwordError,
                    ),
                    if (formMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        formMessage!,
                        textAlign: TextAlign.center,
                        style: _bodyTextStyle(
                          fontSize: 12,
                          color: isError
                              ? _ArcanaColors.error
                              : _ArcanaColors.gold2,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    ArcanaPrimaryButton(
                      onPressed: submitting ? null : onSubmit,
                      child: const Text('進入口袋塔羅'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '註冊即代表你願意讓 Pocket Tarot 保存個人化占卜紀錄。所在地天氣只用於生成每日心靈天氣。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisualEmailField extends StatelessWidget {
  const _VisualEmailField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.errorText,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _bodyTextStyle(fontSize: 12, color: _ArcanaColors.muted),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: _ArcanaColors.ivory),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? _ArcanaColors.error : _ArcanaColors.gold2,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
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
    final usesChineseVisual = visualFixtureMode && _usesChineseCardText(l10n);

    return Scaffold(
      backgroundColor: _ArcanaColors.ink,
      extendBody: false,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(19, 0, 19, 13),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 392),
              child: DecoratedBox(
                key: const ValueKey('bottom-nav-glass'),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _ArcanaColors.gold.withValues(alpha: 0.28),
                  ),
                  color: _ArcanaColors.ink.withValues(alpha: 0.86),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.42),
                      blurRadius: 38,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      _BottomNavItem(
                        icon: Icons.auto_awesome,
                        symbol: usesChineseVisual ? '⌂' : null,
                        label: l10n.navHome,
                        selected: navigationShell.currentIndex == 0,
                        onTap: () => _goBranch(0),
                      ),
                      _BottomNavItem(
                        icon: Icons.grid_view,
                        symbol: usesChineseVisual ? '✦' : null,
                        label: l10n.navDivination,
                        selected: navigationShell.currentIndex == 1,
                        onTap: () => _goBranch(1),
                      ),
                      _BottomNavItem(
                        icon: Icons.menu_book,
                        symbol: usesChineseVisual ? '☽' : null,
                        label: l10n.navLibrary,
                        selected: navigationShell.currentIndex == 2,
                        onTap: () => _goBranch(2),
                      ),
                      _BottomNavItem(
                        icon: Icons.person,
                        symbol: usesChineseVisual ? '♙' : null,
                        label: usesChineseVisual ? '個人檔案' : l10n.navProfile,
                        selected: navigationShell.currentIndex == 3,
                        onTap: () => _goBranch(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.symbol,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? symbol;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _ArcanaColors.gold2 : _ArcanaColors.subtle;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 23,
                height: 23,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color),
                  color: selected
                      ? _ArcanaColors.gold.withValues(alpha: 0.13)
                      : Colors.transparent,
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _ArcanaColors.gold.withValues(alpha: 0.25),
                            blurRadius: 18,
                          ),
                        ]
                      : null,
                ),
                child: symbol == null
                    ? Icon(icon, size: 14, color: color)
                    : Center(
                        child: Text(
                          symbol!,
                          style: _displayTextStyle(
                            fontSize: 13,
                            height: 1,
                          ).copyWith(color: color),
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _bodyTextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
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
    final drawFuture = controller.drawToday();
    if (mounted) {
      setState(() => _dailyState = controller.state);
    }
    await drawFuture;
    if (mounted) {
      setState(() => _dailyState = controller.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerAsync = ref.watch(dailyReadingControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final usesChinese = _usesChineseCardText(l10n);
    final loaded = _dailyState.status == DailyReadingStatus.loaded;

    return ScreenFrame(
      title: usesChinese ? (loaded ? '今日抽牌結果' : '每日抽牌') : l10n.homeTitle,
      eyebrow: loaded ? 'Daily result' : 'Daily ritual',
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
      DailyReadingStatus.creating => const ArcanaLoadingView(
        title: '占卜中',
        message: '正在抽取今日牌面，並整理今天的心靈天氣。',
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
        GlassPanel(
          ornate: true,
          padding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: visualFixtureMode && _usesChineseCardText(l10n)
                  ? 224
                  : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TarotImageCard(
                  imagePath: _imageForCardId(reading.card.cardId),
                  width: visualFixtureMode && _usesChineseCardText(l10n)
                      ? 106
                      : 94,
                  height: visualFixtureMode && _usesChineseCardText(l10n)
                      ? 184
                      : 141,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const EyebrowText('Card of the day'),
                      const SizedBox(height: 8),
                      Text(
                        _dailyCardDisplayName(reading.card, l10n),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reading.summary,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (!(visualFixtureMode &&
                          _usesChineseCardText(l10n))) ...[
                        const SizedBox(height: 10),
                        TagPill(text: reading.card.cardId),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                radius: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EyebrowText('Weather'),
                    const SizedBox(height: 7),
                    Text(
                      _usesChineseCardText(l10n)
                          ? '台北 23° 小雨'
                          : 'Taipei 23° Light rain',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _usesChineseCardText(l10n)
                          ? '情緒容易放大細節，適合慢慢整理，不適合立刻對抗。'
                          : 'Slow reflection works better than immediate reaction.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                radius: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EyebrowText('Streak'),
                    const SizedBox(height: 7),
                    Text(
                      _usesChineseCardText(l10n) ? '連續 8 天' : '8-day streak',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _usesChineseCardText(l10n)
                          ? '你正在建立一種溫柔的觀察習慣。'
                          : 'You are building a gentle observation habit.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EyebrowText('Today guidance'),
              const SizedBox(height: 8),
              Text(
                _usesChineseCardText(l10n)
                    ? '今日完整解讀'
                    : l10n.dailyReadingPanelTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SafeMarkdownBody(data: reading.markdownResult),
            ],
          ),
        ),
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
        const SizedBox(height: 5),
        const Center(child: EyebrowText('One card today')),
        const SizedBox(height: 8),
        Text(
          _usesChineseCardText(l10n)
              ? '把今天的問題放在掌心，讓牌背先替你呼吸。'
              : l10n.dailyEmptyTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          _usesChineseCardText(l10n)
              ? '今日尚未抽牌。輕觸中央牌背，抽出只屬於今天的一張牌。'
              : l10n.dailyEmptyMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        const DailyDeckStage(),
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: 120,
            height: 50,
            child: visualFixtureMode && _usesChineseCardText(l10n)
                ? ArcanaPrimaryButton(
                    onPressed: onDraw,
                    child: Text(l10n.dailyDrawButton),
                  )
                : FilledButton(
                    onPressed: onDraw,
                    child: Text(l10n.dailyDrawButton),
                  ),
          ),
        ),
      ],
    );
  }
}

class DailyDeckStage extends StatelessWidget {
  const DailyDeckStage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('daily-ritual-deck'),
      height: 248,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.18,
            child: Container(
              width: 286,
              height: 286,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _ArcanaColors.gold.withValues(alpha: 0.24),
                ),
              ),
            ),
          ),
          Transform.rotate(
            angle: 0.24,
            child: Container(
              width: 222,
              height: 222,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _ArcanaColors.muted.withValues(alpha: 0.24),
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(-18, 12),
            child: const _DeckCard(rotation: -0.2),
          ),
          Transform.translate(
            offset: const Offset(16, 10),
            child: const _DeckCard(rotation: 0.18),
          ),
          const _DeckCard(),
        ],
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({this.rotation = 0});

  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 152,
        height: 214,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _ArcanaColors.gold2.withValues(alpha: 0.46),
          ),
          image: const DecorationImage(
            image: AssetImage('assets/images/card-back.png'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.44),
              blurRadius: 36,
              offset: const Offset(0, 22),
            ),
          ],
        ),
      ),
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
  bool _visualSubmittingQuestion = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _startDraft() async {
    final controller = await ref.read(deepReadingControllerProvider.future);
    final draftFuture = controller.startDraft(_questionController.text);
    if (mounted) {
      setState(() => _deepState = controller.state);
    }
    await draftFuture;
    if (mounted) {
      setState(() => _deepState = controller.state);
    }
  }

  Future<void> _createResult() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = await ref.read(deepReadingControllerProvider.future);
    final resultFuture = controller.createResult(
      messages: DeepReadingMessages(
        selectExactlyThreeCards: l10n.deepSelectExactlyThreeCards,
        noSavableResult: l10n.deepNoSavableResult,
      ),
    );
    if (mounted) {
      setState(() => _deepState = controller.state);
    }
    await resultFuture;
    if (mounted) {
      setState(() => _deepState = controller.state);
    }
  }

  Future<void> _openVisualDraw() async {
    setState(() => _visualSubmittingQuestion = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (mounted) {
      context.go('/draw');
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
    final l10n = AppLocalizations.of(context)!;
    final controller = await ref.read(deepReadingControllerProvider.future);
    await controller.updateHistoryVisibility(
      isSavedForHistory,
      messages: DeepReadingMessages(
        selectExactlyThreeCards: l10n.deepSelectExactlyThreeCards,
        noSavableResult: l10n.deepNoSavableResult,
      ),
    );
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

  Future<void> _openHistoryReading(String id) async {
    final controller = await ref.read(deepReadingControllerProvider.future);
    await controller.loadSavedReading(id);
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
      eyebrow: 'Reading room',
      trailing: visualFixtureMode && _usesChineseCardText(l10n)
          ? null
          : '${_deepState.selectedIndexes.length}/3',
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
    final usesChinese = _usesChineseCardText(l10n);

    if (_visualSubmittingQuestion) {
      return const ArcanaLoadingView(
        title: '占卜中',
        message: '正在替你的問題洗牌，準備進入三張牌陣。',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          ornate: true,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EyebrowText(
                    visualFixtureMode && usesChinese ? '占卜入口' : 'Reading entry',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    usesChinese
                        ? '把問題放進星盤。'
                        : 'Place your question on the table.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    usesChinese
                        ? '輸入正在面對的情境，或選擇一個常見主題，進入三張牌陣。'
                        : 'Describe the situation or choose a theme before entering the three-card spread.',
                  ),
                  const SizedBox(height: 16),
                  if (visualFixtureMode && usesChinese) ...[
                    Text('你想問什麼？'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 108,
                      child: TextField(
                        controller: _questionController,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _ArcanaColors.ivory,
                        ),
                        decoration: const InputDecoration(
                          hintText: '例如：這段關係裡，我需要看見什麼？',
                        ),
                      ),
                    ),
                  ] else
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
                        text: visualFixtureMode && usesChinese
                            ? '感情迷茫'
                            : l10n.promptWork,
                        showIcon: !(visualFixtureMode && usesChinese),
                        onPressed: () => _applyQuestionTemplate(
                          visualFixtureMode && usesChinese
                              ? '感情迷茫'
                              : l10n.promptWork,
                        ),
                      ),
                      PromptChip(
                        text: visualFixtureMode && usesChinese
                            ? '職場抉擇'
                            : l10n.promptLove,
                        showIcon: !(visualFixtureMode && usesChinese),
                        onPressed: () => _applyQuestionTemplate(
                          visualFixtureMode && usesChinese
                              ? '職場抉擇'
                              : l10n.promptLove,
                        ),
                      ),
                      PromptChip(
                        text: visualFixtureMode && usesChinese
                            ? '自我探索'
                            : l10n.promptNextStep,
                        showIcon: !(visualFixtureMode && usesChinese),
                        onPressed: () => _applyQuestionTemplate(
                          visualFixtureMode && usesChinese
                              ? '自我探索'
                              : l10n.promptNextStep,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (_deepState.status == DeepReadingStatus.initial)
                    if (visualFixtureMode && usesChinese)
                      ArcanaPrimaryButton(
                        onPressed: _openVisualDraw,
                        child: const Text('發送問題並抽牌'),
                      )
                    else
                      FilledButton.icon(
                        onPressed: _startDraft,
                        icon: const Icon(Icons.grid_3x3),
                        label: Text(l10n.startDraft),
                      ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (_deepState.status == DeepReadingStatus.initial)
          const SizedBox.shrink()
        else if (_deepState.status == DeepReadingStatus.drafting ||
            _deepState.status == DeepReadingStatus.creating)
          const ArcanaLoadingView(
            title: '占卜中',
            message: '正在整理牌陣與你的問題，解讀完成前請稍等。',
          )
        else ...[
          GlassPanel(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.selectedCardsTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TagPill(text: '${_deepState.selectedIndexes.length} / 3'),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _deepState.selectedIndexes.length == 3
                      ? _createResult
                      : null,
                  icon: const Icon(Icons.auto_fix_high),
                  label: Text(l10n.createReading),
                ),
                const SizedBox(height: 12),
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
              ],
            ),
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
        DeepHistoryPanel(
          state: _deepState,
          onLoadHistory: _loadHistory,
          onOpenHistory: _openHistoryReading,
        ),
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

class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key});

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  final Set<int> _selectedIndexes = {};
  bool _isCreatingResult = false;

  void _toggleCard(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else if (_selectedIndexes.length < 3) {
        _selectedIndexes.add(index);
      }
    });
  }

  Future<void> _showResult() async {
    setState(() => _isCreatingResult = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (mounted) {
      context.go('/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedIndexes.length;

    if (_isCreatingResult) {
      return const AppBackdrop(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 60, 24, 34),
            child: Center(
              child: ArcanaLoadingView(
                title: '占卜中',
                message: '正在解讀你選出的三張牌，整理成可以保存的紀錄。',
              ),
            ),
          ),
        ),
      );
    }

    return AppBackdrop(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _RoundBackButton(
                  onPressed: () => context.go('/divination'),
                ),
              ),
              const SizedBox(height: 0),
              const EyebrowText('Choose three'),
              const SizedBox(height: 18),
              Text(
                '不要急著找答案。讓手指先靠近有重量的那三張。',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              _ProgressLine(progress: selectedCount / 3),
              const SizedBox(height: 12),
              Text('$selectedCount / 3 已選。牌會在你點下後翻面，第三張完成後即可解讀。'),
              const SizedBox(height: 28),
              GridView.builder(
                key: const ValueKey('visual-draw-grid'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _drawCardLabels.length,
                itemBuilder: (context, index) => _VisualDrawCard(
                  label: _drawCardLabels[index],
                  selected: _selectedIndexes.contains(index),
                  onTap: () => _toggleCard(index),
                ),
              ),
              const SizedBox(height: 18),
              ArcanaPrimaryButton(
                onPressed: selectedCount == 3 ? _showResult : null,
                child: const Text('查看解讀'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReadingResultScreen extends StatelessWidget {
  const ReadingResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackdrop(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _RoundBackButton(
                  onPressed: () => context.go('/divination'),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Expanded(
                    child: TarotImageCard(
                      imagePath: 'assets/images/cards/moon.jpg',
                      height: 168,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TarotImageCard(
                      imagePath: 'assets/images/cards/temperance.jpg',
                      height: 168,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TarotImageCard(
                      imagePath: 'assets/images/cards/star.jpg',
                      height: 168,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '關於這個問題',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '你正在問的不是「該不該前進」，而是「我能否在不確定裡仍然照顧自己」。月亮讓情緒浮上來，節制要求你把步伐放慢，星星則指出仍有一條溫柔但清楚的路。',
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '三張牌的訊息',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    const _VisualBulletText('月亮：現在的模糊不是錯誤，它是在提醒你有些資訊還未被說出口。'),
                    const _VisualBulletText('節制：不要用一次談話解決全部。先確認界線，再確認期待。'),
                    const _VisualBulletText('星星：真正值得靠近的答案，會讓你感到更完整，而不是更緊縮。'),
                    const SizedBox(height: 14),
                    Text(
                      '今晚的建議',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    const Text('把問題拆成一個可行動的小句子：我明天可以多問一個問題，而不是立刻做一個決定。'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('回到首頁'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ArcanaPrimaryButton(
                      onPressed: () => context.go('/divination'),
                      child: const Text('保存紀錄'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back),
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        foregroundColor: _ArcanaColors.ivory,
        backgroundColor: _ArcanaColors.ink2.withValues(alpha: 0.7),
        side: BorderSide(color: _ArcanaColors.gold.withValues(alpha: 0.25)),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: ColoredBox(
        color: Colors.white.withValues(alpha: 0.08),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0, 1),
            child: const SizedBox(
              height: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_ArcanaColors.gold2, _ArcanaColors.peacock],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VisualDrawCard extends StatelessWidget {
  const _VisualDrawCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/card-back.png', fit: BoxFit.cover),
            if (selected)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: _ArcanaColors.gold2, width: 2),
                  color: _ArcanaColors.ink.withValues(alpha: 0.28),
                ),
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _ArcanaColors.ivory,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VisualBulletText extends StatelessWidget {
  const _VisualBulletText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

const _drawCardLabels = [
  '過去的霧',
  '現在的門',
  '尚未命名',
  '內在潮汐',
  '月下答案',
  '隱形代價',
  '需要放下',
  '可以靠近',
  '下一步',
];

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
    final usesChineseVisual = visualFixtureMode && _usesChineseCardText(l10n);

    return ScreenFrame(
      title: l10n.libraryTitle,
      eyebrow: 'Arcana library',
      trailing: usesChineseVisual ? null : '78',
      child: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            InfoPanel(title: l10n.libraryLoadFailed, child: Text('$error')),
        data: (cards) {
          final categoryOptions = usesChineseVisual
              ? const [
                  TarotCategory.all,
                  TarotCategory.major,
                  TarotCategory.cups,
                  TarotCategory.swords,
                ]
              : TarotCategory.values;
          final sourceCards = usesChineseVisual
              ? _referenceFeaturedCards(cards)
              : cards;
          final categorized = repository.filterByCategory(
            sourceCards,
            _category,
          );
          final filtered = repository.search(categorized, _query);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (usesChineseVisual) ...[
                Text(l10n.searchCardsLabel),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  labelText: usesChineseVisual ? null : l10n.searchCardsLabel,
                  hintText: usesChineseVisual ? '月亮、關係、修復' : null,
                  prefixIcon: usesChineseVisual
                      ? null
                      : const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in categoryOptions)
                    ChoiceChip(
                      label: Text(_categoryLabel(category, l10n)),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              SizedBox(height: usesChineseVisual ? 16 : 16),
              if (!usesChineseVisual) ...[
                Text(
                  l10n.cardsCount(filtered.length),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
              ],
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: usesChineseVisual ? 0.56 : 0.62,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final card = filtered[index];
                  return KnowledgeCard(
                    card: card,
                    imagePath: _imageForCard(card),
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (context) => CardDetailSheet(
                        card: card,
                        imagePath: _imageForCard(card),
                      ),
                    ),
                  );
                },
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
    final l10n = AppLocalizations.of(context)!;
    final controller = await ref.read(profileControllerProvider.future);
    await controller.updateDisplayName(
      displayName,
      messages: ProfileValidationMessages(
        displayNameInvalid: l10n.displayNameInvalid,
      ),
    );
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
    final usesChineseVisual = visualFixtureMode && _usesChineseCardText(l10n);

    return ScreenFrame(
      title: l10n.profileTitle,
      eyebrow: 'Profile',
      trailing: usesChineseVisual
          ? null
          : _profileState.snapshot?.user.displayName,
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
    final usesChinese = _usesChineseCardText(l10n);

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
        GlassPanel(
          child: Row(
            children: [
              const BrandMark(size: 68, radius: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.user.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      snapshot.user.email,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (!(visualFixtureMode && usesChinese)) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.profileStats(
                          snapshot.stats.dailyReadingCount,
                          snapshot.stats.deepReadingCount,
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showNameDialog(
                  context,
                  _updateDisplayName,
                  initialName: snapshot.user.displayName,
                ),
                icon: Icon(
                  visualFixtureMode && usesChinese
                      ? Icons.edit_outlined
                      : Icons.edit,
                ),
                tooltip: l10n.editDisplayName,
                style: visualFixtureMode && usesChinese
                    ? IconButton.styleFrom(
                        fixedSize: const Size(40, 40),
                        foregroundColor: _ArcanaColors.ivory,
                        backgroundColor: _ArcanaColors.ink2.withValues(
                          alpha: 0.7,
                        ),
                        side: BorderSide(
                          color: _ArcanaColors.gold.withValues(alpha: 0.25),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
        SizedBox(height: visualFixtureMode && usesChinese ? 18 : 12),
        Row(
          children: [
            Expanded(
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                radius: 18,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: visualFixtureMode && usesChinese ? 90 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EyebrowText(
                        visualFixtureMode && usesChinese
                            ? 'All-time daily'
                            : 'Daily draw',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        visualFixtureMode && usesChinese
                            ? '${snapshot.stats.dailyReadingCount} 次'
                            : '${snapshot.stats.dailyReadingCount}',
                        style: visualFixtureMode && usesChinese
                            ? Theme.of(context).textTheme.titleMedium
                            : Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        visualFixtureMode && usesChinese
                            ? '總每日一抽完成次數。'
                            : l10n.navHome,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                radius: 18,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: visualFixtureMode && usesChinese ? 90 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EyebrowText(
                        visualFixtureMode && usesChinese
                            ? 'All-time reading'
                            : 'Deep reading',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        visualFixtureMode && usesChinese
                            ? '${snapshot.stats.deepReadingCount} 次'
                            : '${snapshot.stats.deepReadingCount}',
                        style: visualFixtureMode && usesChinese
                            ? Theme.of(context).textTheme.titleMedium
                            : Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        visualFixtureMode && usesChinese
                            ? '總深度占卜完成次數。'
                            : l10n.navDivination,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (visualFixtureMode && usesChinese)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              EyebrowText('Settings'),
              SizedBox(height: 8),
              _SectionTitle('設定選項'),
              SizedBox(height: 14),
              _VisualSettingRow(
                title: '每日提醒',
                subtitle: '每天早上 8:30 提醒抽一張牌',
                toggled: true,
              ),
              SizedBox(height: 16),
              _VisualSettingRow(
                title: '使用所在地天氣',
                subtitle: '只用於生成今日心靈天氣',
                toggled: true,
              ),
              SizedBox(height: 16),
              _VisualSettingRow(title: '語言設定', subtitle: '繁體中文', action: '變更'),
            ],
          )
        else
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const EyebrowText('Settings'),
                const SizedBox(height: 8),
                Text(
                  usesChinese ? '設定選項' : 'Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                SegmentedButton<LocaleMode>(
                  segments: [
                    ButtonSegment(
                      value: LocaleMode.system,
                      label: Text(l10n.localeSystem),
                    ),
                    ButtonSegment(
                      value: LocaleMode.zhTw,
                      label: Text(l10n.localeZh),
                    ),
                    ButtonSegment(
                      value: LocaleMode.en,
                      label: Text(l10n.localeEn),
                    ),
                  ],
                  selected: {settings.localeMode},
                  onSelectionChanged: (value) => _setLocaleMode(value.first),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: settings.weatherEnabled,
                  onChanged: _setWeatherEnabled,
                  title: Text(l10n.weatherToggle),
                  subtitle: Text(
                    usesChinese
                        ? '只用於生成今日心靈天氣'
                        : 'Only used to generate daily spiritual weather.',
                  ),
                  secondary: const Icon(Icons.cloud),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _showNameDialog(
                    context,
                    _updateDisplayName,
                    initialName: snapshot.user.displayName,
                  ),
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.editDisplayName),
                ),
              ],
            ),
          ),
        SizedBox(height: visualFixtureMode && usesChinese ? 14 : 12),
        if (visualFixtureMode && usesChinese)
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const EyebrowText('Account'),
                const SizedBox(height: 8),
                Text('帳戶', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                const Text('目前使用 Google 帳號登入。登出後仍可保留本機原型資料。'),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('登出 Google 帳號'),
                ),
              ],
            ),
          )
        else
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const EyebrowText('Account'),
                const SizedBox(height: 8),
                Text(
                  usesChinese ? '帳戶' : 'Account',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.signOut),
                ),
              ],
            ),
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
    this.eyebrow,
    this.trailing,
  });

  final String title;
  final String? eyebrow;
  final String? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppBackdrop(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(26, 63, 26, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (eyebrow != null) ...[
                            EyebrowText(eyebrow!),
                            const SizedBox(height: 6),
                          ],
                          Text(
                            title,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null) TagPill(text: trailing!),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(26, 12, 26, 116),
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
      color: _ArcanaColors.ink,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kAppFrameMaxWidth),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF20102F),
                  Color(0xFF160C25),
                  Color(0xFF07030D),
                ],
                stops: [0, 0.42, 1],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const CustomPaint(painter: _CelestialBackdropPainter()),
                Positioned(
                  top: 13,
                  right: 12,
                  bottom: 13,
                  left: 12,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      key: const ValueKey('app-chrome-frame'),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(
                          color: _ArcanaColors.gold.withValues(alpha: 0.13),
                        ),
                      ),
                    ),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CelestialBackdropPainter extends CustomPainter {
  const _CelestialBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = _ArcanaColors.gold.withValues(alpha: 0.015)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 38) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 38) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final starPaint = Paint()
      ..color = _ArcanaColors.ivory.withValues(alpha: 0.22);
    const offsets = [
      Offset(0.12, 0.15),
      Offset(0.24, 0.31),
      Offset(0.42, 0.12),
      Offset(0.62, 0.22),
      Offset(0.78, 0.36),
      Offset(0.88, 0.16),
      Offset(0.18, 0.58),
      Offset(0.36, 0.72),
      Offset(0.58, 0.64),
      Offset(0.76, 0.82),
      Offset(0.91, 0.67),
    ];
    for (final offset in offsets) {
      canvas.drawCircle(
        Offset(size.width * offset.dx, size.height * offset.dy),
        0.8,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EyebrowText extends StatelessWidget {
  const EyebrowText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: _bodyTextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: _ArcanaColors.gold2,
        height: 1,
      ).copyWith(fontFamilyFallback: const ['JetBrains Mono', 'monospace']),
    );
  }
}

class ArcanaLoadingView extends StatelessWidget {
  const ArcanaLoadingView({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      ornate: true,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: _ArcanaColors.gold2,
                  backgroundColor: _ArcanaColors.gold.withValues(alpha: 0.12),
                ),
                const Icon(
                  Icons.auto_awesome,
                  color: _ArcanaColors.gold2,
                  size: 22,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const EyebrowText('Reading in progress'),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class ArcanaPrimaryButton extends StatelessWidget {
  const ArcanaPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(),
      child: Ink(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFFF5DA95), Color(0xFFB8832F)],
                )
              : null,
          color: enabled ? null : Colors.white.withValues(alpha: 0.08),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFFB8832F).withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          child: Center(
            child: DefaultTextStyle.merge(
              style: _bodyTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: _ArcanaColors.ink2,
                height: 1,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 76, this.radius = 24});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _ArcanaColors.gold2.withValues(alpha: 0.46)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/pocket-tarot-logo.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.ornate = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool ornate;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _ArcanaColors.gold.withValues(alpha: 0.25)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF241135).withValues(alpha: 0.94),
            const Color(0xFF0C0615).withValues(alpha: 0.94),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 46,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0),
                      ],
                      stops: const [0, 0.28],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.035),
                    ),
                  ),
                ),
              ),
            ),
            if (ornate)
              Positioned.fill(
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius - 6),
                        border: Border.all(
                          color: _ArcanaColors.gold2.withValues(alpha: 0.16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _VisualSettingRow extends StatelessWidget {
  const _VisualSettingRow({
    required this.title,
    required this.subtitle,
    this.toggled,
    this.action,
  });

  final String title;
  final String subtitle;
  final bool? toggled;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ArcanaColors.gold.withValues(alpha: 0.18)),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (action != null)
              TagPill(text: action!)
            else
              _VisualSwitch(toggled: toggled ?? false),
          ],
        ),
      ),
    );
  }
}

class _VisualSwitch extends StatelessWidget {
  const _VisualSwitch({required this.toggled});

  final bool toggled;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _ArcanaColors.muted.withValues(alpha: 0.26)),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: SizedBox(
        width: 44,
        height: 26,
        child: Align(
          alignment: toggled ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: toggled ? _ArcanaColors.gold2 : _ArcanaColors.subtle,
              ),
              child: const SizedBox.square(dimension: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class TagPill extends StatelessWidget {
  const TagPill({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _ArcanaColors.gold.withValues(alpha: 0.27)),
        color: _ArcanaColors.ink.withValues(alpha: 0.28),
      ),
      child: Text(
        text,
        style: _bodyTextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: _ArcanaColors.gold2,
          height: 1,
        ),
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
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: _ArcanaColors.ivory),
      decoration: InputDecoration(labelText: label, errorText: errorText),
    );
  }
}

class TarotImageCard extends StatelessWidget {
  const TarotImageCard({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.radius = 18,
    this.fit = BoxFit.cover,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _ArcanaColors.gold2.withValues(alpha: 0.38)),
        color: _ArcanaColors.ink2,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Image.asset(imagePath, fit: fit),
    );
  }
}

class CardPreview extends StatelessWidget {
  const CardPreview({super.key, required this.imagePath, required this.title});

  final String imagePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            TarotImageCard(imagePath: imagePath, height: 260),
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
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class KnowledgeCard extends StatelessWidget {
  const KnowledgeCard({
    super.key,
    required this.card,
    required this.imagePath,
    required this.onTap,
  });

  final TarotCard card;
  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usesChineseVisual = visualFixtureMode && _usesChineseCardText(l10n);

    return GlassPanel(
      padding: const EdgeInsets.all(10),
      radius: 18,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TarotImageCard(
                  imagePath: imagePath,
                  width: double.infinity,
                  radius: 16,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _primaryCardName(card, l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 6),
                  TagPill(text: _cardTagLabel(card, l10n)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                usesChineseVisual
                    ? _referenceCardSummary(card)
                    : '${_secondaryCardName(card, l10n)}\n${card.id}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: usesChineseVisual
                    ? Theme.of(context).textTheme.bodyMedium
                    : Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
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
        color: _ArcanaColors.peacock.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ArcanaColors.gold.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          text,
          style: _bodyTextStyle(
            fontWeight: FontWeight.w800,
            color: _ArcanaColors.ivory,
          ),
        ),
      ),
    );
  }
}

class PromptChip extends StatelessWidget {
  const PromptChip({
    super.key,
    required this.text,
    required this.onPressed,
    this.showIcon = true,
  });

  final String text;
  final VoidCallback onPressed;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: showIcon ? const Icon(Icons.add, size: 16) : null,
      label: Text(text),
      onPressed: onPressed,
      side: BorderSide(color: _ArcanaColors.muted.withValues(alpha: 0.22)),
      backgroundColor: Colors.white.withValues(alpha: 0.035),
      labelStyle: _bodyTextStyle(fontSize: 12, color: _ArcanaColors.muted),
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
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/card-back.png',
              fit: BoxFit.cover,
            ),
          ),
          if (selected)
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _ArcanaColors.gold2, width: 3),
                color: Colors.black.withValues(alpha: 0.18),
              ),
              child: Center(
                child: CircleAvatar(
                  backgroundColor: _ArcanaColors.gold2,
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
    required this.onOpenHistory,
  });

  final DeepReadingState state;
  final VoidCallback onLoadHistory;
  final ValueChanged<String> onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usesChineseVisual = visualFixtureMode && _usesChineseCardText(l10n);
    final previewHistory = usesChineseVisual && state.history.isEmpty
        ? _visualPreviewHistory
        : state.history;

    if (usesChineseVisual) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(child: EyebrowText('Saved readings')),
              Text('點擊查看詳細結果', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          Text('歷史紀錄', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          for (var index = 0; index < previewHistory.length; index++) ...[
            _VisualHistoryCard(item: previewHistory[index], index: index),
            if (index != previewHistory.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }

    return InfoPanel(
      title: l10n.historyTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!visualFixtureMode)
            OutlinedButton.icon(
              onPressed: onLoadHistory,
              icon: const Icon(Icons.history),
              label: Text(l10n.loadHistory),
            ),
          if (state.status == DeepReadingStatus.historyLoading) ...[
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator()),
          ] else if (state.status == DeepReadingStatus.historyReady &&
              previewHistory.isEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.emptyHistory),
          ] else if (previewHistory.isNotEmpty) ...[
            if (!visualFixtureMode) const SizedBox(height: 12),
            for (final item in previewHistory)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item.question.isEmpty ? l10n.unnamedQuestion : item.question,
                ),
                subtitle: Text(item.summary),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onOpenHistory(item.id),
              ),
          ],
        ],
      ),
    );
  }
}

class _VisualHistoryCard extends StatelessWidget {
  const _VisualHistoryCard({required this.item, required this.index});

  final DeepReadingHistoryItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tag = switch (index) {
      0 => '詳讀',
      1 => '復二',
      _ => '4/28',
    };

    return GlassPanel(
      padding: const EdgeInsets.all(14),
      radius: 18,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.question,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  item.summary,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TagPill(text: tag),
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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: TarotImageCard(imagePath: imagePath, height: 190)),
            const SizedBox(height: 16),
            const EyebrowText('Card meaning'),
            const SizedBox(height: 8),
            Text(
              _primaryCardName(card, l10n),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              _secondaryCardName(card, l10n),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            GlassPanel(
              padding: const EdgeInsets.all(14),
              radius: 18,
              child: Text(
                l10n.cardMeaningText(
                  _uprightCardMeaning(card, l10n),
                  _reversedCardMeaning(card, l10n),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _imageForCard(TarotCard card) {
  return _imageForCardId(card.id);
}

String _imageForCardId(String cardId) {
  if (visualFixtureMode) {
    final referenceImage = switch (cardId) {
      'major-18-moon' => 'moon.jpg',
      'major-17-star' => 'star.jpg',
      'major-14-temperance' => 'temperance.jpg',
      'cups-02-two' => 'cups-02.jpg',
      'swords-06-six' => 'swords-06.jpg',
      'major-16-tower' => 'tower.jpg',
      _ => null,
    };
    if (referenceImage != null) {
      return 'assets/images/cards/$referenceImage';
    }
  }

  return 'assets/images/cards/$cardId.png';
}

String _dailyCardDisplayName(CardDraw card, AppLocalizations l10n) {
  if (_usesChineseCardText(l10n) && card.cardId == 'major-18-moon') {
    return card.orientation == 'reversed' ? '月亮逆位' : '月亮正位';
  }

  return '${card.cardId} / ${_orientationLabel(card.orientation, l10n)}';
}

String _primaryCardName(TarotCard card, AppLocalizations l10n) {
  return _usesChineseCardText(l10n) ? card.zhName : card.enName;
}

String _secondaryCardName(TarotCard card, AppLocalizations l10n) {
  return _usesChineseCardText(l10n) ? card.enName : card.zhName;
}

String _uprightCardMeaning(TarotCard card, AppLocalizations l10n) {
  return _usesChineseCardText(l10n)
      ? card.uprightMeaning
      : card.enUprightMeaning;
}

String _reversedCardMeaning(TarotCard card, AppLocalizations l10n) {
  return _usesChineseCardText(l10n)
      ? card.reversedMeaning
      : card.enReversedMeaning;
}

bool _usesChineseCardText(AppLocalizations l10n) {
  return l10n.localeName.toLowerCase().startsWith('zh');
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

String _categoryShortLabel(TarotCategory category, AppLocalizations l10n) {
  final usesChinese = _usesChineseCardText(l10n);
  return switch (category) {
    TarotCategory.all => l10n.categoryAll,
    TarotCategory.major => usesChinese ? '大牌' : 'Major',
    TarotCategory.wands => usesChinese ? '權杖' : 'Wands',
    TarotCategory.cups => usesChinese ? '聖杯' : 'Cups',
    TarotCategory.swords => usesChinese ? '寶劍' : 'Swords',
    TarotCategory.pentacles => usesChinese ? '錢幣' : 'Pent.',
  };
}

String _cardTagLabel(TarotCard card, AppLocalizations l10n) {
  if (_usesChineseCardText(l10n)) {
    return switch (card.id) {
      'major-18-moon' => 'XVIII',
      'major-17-star' => 'XVII',
      'major-14-temperance' => 'XIV',
      'major-16-tower' => 'XVI',
      _ => _categoryShortLabel(card.category, l10n),
    };
  }

  return _categoryShortLabel(card.category, l10n);
}

String _referenceCardSummary(TarotCard card) {
  return switch (card.id) {
    'major-18-moon' => '直覺、恐懼、尚未照亮的真相。',
    'major-17-star' => '修復、遠方的信念、再次相信。',
    'major-14-temperance' => '調和、比例、慢慢把兩端放回一起。',
    'cups-02-two' => '互相看見、關係承諾、平等交換。',
    'swords-06-six' => '離開舊水域、過渡、帶著經驗前往下一站。',
    'major-16-tower' => '突變、真相、舊結構被迫鬆動。',
    _ => card.uprightMeaning,
  };
}

List<TarotCard> _referenceFeaturedCards(List<TarotCard> cards) {
  const featuredIds = [
    'major-18-moon',
    'major-17-star',
    'major-14-temperance',
    'cups-02-two',
    'swords-06-six',
    'major-16-tower',
  ];
  final byId = {for (final card in cards) card.id: card};
  final featured = [
    for (final id in featuredIds)
      if (byId[id] != null) byId[id]!,
  ];
  return featured;
}

final _visualPreviewHistory = [
  DeepReadingHistoryItem(
    id: 'preview-1',
    question: '關係中的沉默',
    summary: '月亮、節制、星星，已保存完整解讀',
    resultLocale: 'zh-TW',
    createdAt: DateTime.utc(2026, 5, 21),
  ),
  DeepReadingHistoryItem(
    id: 'preview-2',
    question: '新的職務邀請',
    summary: '權杖二、正義、隱者，風險與下一步',
    resultLocale: 'zh-TW',
    createdAt: DateTime.utc(2026, 5, 20),
  ),
  DeepReadingHistoryItem(
    id: 'preview-3',
    question: '低潮的出口',
    summary: '高塔、聖杯四、太陽，自我照顧提醒',
    resultLocale: 'zh-TW',
    createdAt: DateTime.utc(2026, 4, 28),
  ),
];

String _orientationLabel(String orientation, AppLocalizations l10n) {
  return switch (orientation) {
    'upright' => l10n.upright,
    'reversed' => l10n.reversed,
    _ => orientation,
  };
}

Future<void> _showNameDialog(
  BuildContext context,
  Future<void> Function(String displayName) onSave, {
  String initialName = '',
}) async {
  final l10n = AppLocalizations.of(context)!;
  final usesChineseVisual = visualFixtureMode && _usesChineseCardText(l10n);
  final textController = TextEditingController(text: initialName);
  textController.selection = TextSelection(
    baseOffset: 0,
    extentOffset: initialName.length,
  );

  try {
    if (usesChineseVisual) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 18,
          ),
          child: GlassPanel(
            radius: 26,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const EyebrowText('Display name'),
                          const SizedBox(height: 8),
                          Text(
                            '編輯暱稱',
                            style: Theme.of(sheetContext).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        fixedSize: const Size(44, 44),
                        foregroundColor: _ArcanaColors.ivory,
                        backgroundColor: _ArcanaColors.ink2.withValues(
                          alpha: 0.72,
                        ),
                        side: BorderSide(
                          color: _ArcanaColors.gold.withValues(alpha: 0.28),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _VisualEmailField(
                  label: '暱稱',
                  hintText: '王大明',
                  controller: textController,
                ),
                const SizedBox(height: 10),
                Text(
                  '暱稱會顯示在個人檔案與占卜紀錄。',
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                ArcanaPrimaryButton(
                  onPressed: () async {
                    await onSave(textController.text);
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                  child: const Text('儲存名稱'),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

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
  } finally {
    textController.dispose();
  }
}
