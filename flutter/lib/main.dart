import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_tarot/app/app_providers.dart';
import 'package:pocket_tarot/domain/models/api_reading_models.dart';
import 'package:pocket_tarot/data/repositories/tarot_catalog_repository.dart';
import 'package:pocket_tarot/domain/models/tarot_card.dart';
import 'package:pocket_tarot/domain/use_cases/app_startup_controller.dart';
import 'package:pocket_tarot/domain/use_cases/auth_form_validator.dart';
import 'package:pocket_tarot/domain/use_cases/daily_reading_controller.dart';
import 'package:pocket_tarot/l10n/generated/app_localizations.dart';
import 'package:pocket_tarot/ui/core/widgets/safe_markdown_body.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PocketTarotApp()));
}

final appStateProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);
final tarotCatalogRepositoryProvider = Provider<TarotCatalogRepository>((ref) {
  return TarotCatalogRepository(rootBundle);
});
final tarotCardsProvider = FutureProvider<List<TarotCard>>((ref) {
  return ref.watch(tarotCatalogRepositoryProvider).loadCards();
});

class AppState {
  const AppState({
    this.displayName = '星語',
    this.dailyDrawn = false,
    this.deepDraftStarted = false,
    this.selectedIndexes = const [],
    this.deepResultReady = false,
    this.weatherEnabled = true,
    this.localeMode = 'system',
  });

  final String displayName;
  final bool dailyDrawn;
  final bool deepDraftStarted;
  final List<int> selectedIndexes;
  final bool deepResultReady;
  final bool weatherEnabled;
  final String localeMode;

  AppState copyWith({
    String? displayName,
    bool? dailyDrawn,
    bool? deepDraftStarted,
    List<int>? selectedIndexes,
    bool? deepResultReady,
    bool? weatherEnabled,
    String? localeMode,
  }) {
    return AppState(
      displayName: displayName ?? this.displayName,
      dailyDrawn: dailyDrawn ?? this.dailyDrawn,
      deepDraftStarted: deepDraftStarted ?? this.deepDraftStarted,
      selectedIndexes: selectedIndexes ?? this.selectedIndexes,
      deepResultReady: deepResultReady ?? this.deepResultReady,
      weatherEnabled: weatherEnabled ?? this.weatherEnabled,
      localeMode: localeMode ?? this.localeMode,
    );
  }
}

class AppController extends Notifier<AppState> {
  @override
  AppState build() => const AppState();

  void drawDailyCard() => state = state.copyWith(dailyDrawn: true);

  void startDeepDraft() {
    state = state.copyWith(
      deepDraftStarted: true,
      selectedIndexes: [],
      deepResultReady: false,
    );
  }

  void toggleCard(int index) {
    final selected = [...state.selectedIndexes];
    if (selected.contains(index)) {
      selected.remove(index);
    } else if (selected.length < 3) {
      selected.add(index);
    }
    state = state.copyWith(selectedIndexes: selected);
  }

  void createDeepResult() => state = state.copyWith(deepResultReady: true);

  void setWeatherEnabled(bool value) =>
      state = state.copyWith(weatherEnabled: value);

  void setLocaleMode(String value) => state = state.copyWith(localeMode: value);

  void setDisplayName(String value) {
    final next = value.trim();
    if (next.isNotEmpty && next.length <= 16) {
      state = state.copyWith(displayName: next);
    }
  }
}

class PocketTarotApp extends StatefulWidget {
  const PocketTarotApp({super.key, this.initialLocation = '/splash'});

  final String initialLocation;

  @override
  State<PocketTarotApp> createState() => _PocketTarotAppState();
}

class _PocketTarotAppState extends State<PocketTarotApp> {
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
    return MaterialApp.router(
      title: 'Pocket Tarot',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('zh', 'TW')],
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
    return switch (_state.status) {
      AppStartupStatus.initial ||
      AppStartupStatus.checking => const SplashCheckingScreen(),
      AppStartupStatus.networkBlocked => SplashNetworkBlockedScreen(
        onRetry: _checkStartup,
      ),
      AppStartupStatus.error => SplashNetworkBlockedScreen(
        title: '啟動檢查失敗',
        message: _state.errorMessage ?? '請稍後再試',
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
                '啟動檢查中',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '正在確認連線與帳號狀態',
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
    this.title = '目前無法連線',
    this.message = '請檢查網路後重試',
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
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
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重新檢查'),
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
                '每日一張，深度三張，把今天的選擇握在手心。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              if (_mode == EmailAuthMode.register) ...[
                AuthField(
                  label: '暱稱',
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
                  label: '密碼',
                  controller: _passwordController,
                  obscureText: true,
                  errorText: _errors[AuthFormField.password],
                ),
              if (_mode == EmailAuthMode.register) ...[
                const SizedBox(height: 12),
                AuthField(
                  label: '確認密碼',
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
                label: const Text('Google 登入'),
              ),
              const SizedBox(height: 4),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  if (_mode != EmailAuthMode.signIn)
                    TextButton(
                      onPressed: () => _switchMode(EmailAuthMode.signIn),
                      child: const Text('登入'),
                    ),
                  if (_mode != EmailAuthMode.register)
                    TextButton(
                      onPressed: () => _switchMode(EmailAuthMode.register),
                      child: const Text('註冊'),
                    ),
                  if (_mode != EmailAuthMode.resetPassword)
                    TextButton(
                      onPressed: () => _switchMode(EmailAuthMode.resetPassword),
                      child: const Text('忘記密碼'),
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
    final result = switch (_mode) {
      EmailAuthMode.signIn => AuthFormValidator.validateEmailSignIn(
        email: _emailController.text,
        password: _passwordController.text,
      ),
      EmailAuthMode.register => AuthFormValidator.validateEmailRegistration(
        displayName: _displayNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
      EmailAuthMode.resetPassword => AuthFormValidator.validatePasswordReset(
        email: _emailController.text,
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
            setState(() => _formMessage = '重設信已送出');
          }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _formError = '操作失敗，請稍後再試';
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
          _formError = 'Google 登入失敗，請稍後再試';
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
    final label = switch (mode) {
      EmailAuthMode.signIn => 'Email 登入',
      EmailAuthMode.register => '建立帳號',
      EmailAuthMode.resetPassword => '送出重設信',
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
    return GateScaffold(
      icon: Icons.mark_email_unread,
      title: '確認 Email',
      message: '驗證信已送出，完成後回到 App 繼續建立 profile。',
      actionLabel: '我已完成驗證',
      onAction: () => context.go('/splash'),
    );
  }
}

class PendingActivationScreen extends StatelessWidget {
  const PendingActivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GateScaffold(
      icon: Icons.hourglass_bottom,
      title: '等待啟用',
      message: '帳號已建立，管理員啟用後即可進入完整功能。',
      actionLabel: '重新檢查',
      onAction: () => context.go('/splash'),
    );
  }
}

class AccountDeletedScreen extends StatelessWidget {
  const AccountDeletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GateScaffold(
      icon: Icons.no_accounts,
      title: '帳號已刪除',
      message: '這個帳號已停用且無法繼續使用。如有疑問，請聯絡服務維運人員。',
      actionLabel: '回到登入',
      onAction: () => context.go('/login'),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: '首頁'),
          NavigationDestination(icon: Icon(Icons.grid_view), label: '占卜館'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: '圖書館'),
          NavigationDestination(icon: Icon(Icons.person), label: '個人'),
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

    return ScreenFrame(
      title: '今日指引',
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
        message: _dailyState.errorMessage ?? '今日抽牌載入失敗',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardPreview(
          imagePath: _imageForCardId(reading.card.cardId),
          title:
              '${reading.card.cardId} / ${_orientationLabel(reading.card.orientation)}',
        ),
        const SizedBox(height: 18),
        InfoPanel(
          title: '牌義解讀',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CardPreview(
          imagePath: 'assets/images/card-back.png',
          title: '今天的牌還在牌堆裡',
        ),
        const SizedBox(height: 18),
        Text(
          '天氣、時間與當下狀態會一起送進解讀，結果只保留今天這一筆。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onDraw,
          icon: const Icon(Icons.style),
          label: const Text('抽今日牌'),
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
    return InfoPanel(
      title: '今日抽牌載入失敗',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(message),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重新載入'),
          ),
        ],
      ),
    );
  }
}

class DivinationScreen extends ConsumerWidget {
  const DivinationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final controller = ref.read(appStateProvider.notifier);

    return ScreenFrame(
      title: '占卜館',
      trailing: '${state.selectedIndexes.length}/3',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthField(label: '想問的問題', maxLines: 3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              PromptChip(text: '工作方向'),
              PromptChip(text: '感情狀態'),
              PromptChip(text: '下一步選擇'),
            ],
          ),
          const SizedBox(height: 18),
          if (!state.deepDraftStarted)
            FilledButton.icon(
              onPressed: controller.startDeepDraft,
              icon: const Icon(Icons.grid_3x3),
              label: const Text('展開 9 張牌'),
            )
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
              itemCount: 9,
              itemBuilder: (context, index) => SelectableCardBack(
                selected: state.selectedIndexes.contains(index),
                order: state.selectedIndexes.indexOf(index) + 1,
                onTap: () => controller.toggleCard(index),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: state.selectedIndexes.length == 3
                  ? controller.createDeepResult
                  : null,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('產生解讀'),
            ),
            if (state.deepResultReady) ...[
              const SizedBox(height: 18),
              const DeepResultPanel(),
            ],
          ],
        ],
      ),
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

    return ScreenFrame(
      title: '塔羅圖書館',
      trailing: '78',
      child: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            InfoPanel(title: '牌庫載入失敗', child: Text('$error')),
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
                  labelText: '搜尋牌名或關鍵字',
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
                      label: Text(category.label),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '顯示 ${filtered.length} 張牌',
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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final controller = ref.read(appStateProvider.notifier);

    return ScreenFrame(
      title: '個人檔案',
      trailing: state.displayName,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoPanel(
            title: state.displayName,
            child: const Text('user@example.com\n每日抽牌 7 次 · 深度占卜 3 次'),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'system', label: Text('系統')),
              ButtonSegment(value: 'zh-TW', label: Text('繁中')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {state.localeMode},
            onSelectionChanged: (value) =>
                controller.setLocaleMode(value.first),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: state.weatherEnabled,
            onChanged: controller.setWeatherEnabled,
            title: const Text('每日抽牌使用天氣'),
            secondary: const Icon(Icons.cloud),
          ),
          OutlinedButton.icon(
            onPressed: () => _showNameDialog(context, controller),
            icon: const Icon(Icons.edit),
            label: const Text('編輯暱稱'),
          ),
          TextButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.logout),
            label: const Text('登出'),
          ),
        ],
      ),
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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
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
                child: const Text('登出'),
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
  const PromptChip({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.add, size: 16),
      label: Text(text),
      onPressed: () {},
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
  const DeepResultPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoPanel(
          title: '深度解讀',
          child: SafeMarkdownBody(data: _deepDemoMarkdown),
        ),
        SizedBox(height: 10),
        SummaryStrip(text: '先辨識壓力，再拆小行動。'),
      ],
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
          Text('正位：${card.uprightMeaning}\n逆位：${card.reversedMeaning}'),
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

String _orientationLabel(String orientation) {
  return switch (orientation) {
    'upright' => '正位',
    'reversed' => '逆位',
    _ => orientation,
  };
}

Future<void> _showNameDialog(
  BuildContext context,
  AppController controller,
) async {
  final textController = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('編輯暱稱'),
      content: TextField(
        controller: textController,
        maxLength: 16,
        decoration: const InputDecoration(labelText: '暱稱'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            controller.setDisplayName(textController.text);
            Navigator.of(context).pop();
          },
          child: const Text('儲存'),
        ),
      ],
    ),
  );
}

const _deepDemoMarkdown = '''
## 問題核心
月亮指出你需要先承認模糊感，而不是急著排除它。

## 隱藏影響
星星讓你重新看見期待，但也提醒你不要只靠願望前進。

## 行動建議
節制建議把節奏拆小，讓判斷和情緒重新對齊。
''';
