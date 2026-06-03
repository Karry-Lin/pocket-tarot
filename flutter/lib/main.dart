import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart' as firebase;
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
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_tarot/data/services/audio_service.dart';


part 'ui/widgets/common_widgets.dart';
part 'ui/widgets/tarot_widgets.dart';
part 'ui/widgets/auth_widgets.dart';
part 'ui/screens/startup_screen.dart';
part 'ui/screens/login_screen.dart';
part 'ui/screens/verify_email_screen.dart';
part 'ui/screens/pending_activation_screen.dart';
part 'ui/screens/account_deleted_screen.dart';
part 'ui/screens/app_shell.dart';
part 'ui/screens/home_screen.dart';
part 'ui/screens/divination_screen.dart';
part 'ui/screens/draw_screen.dart';
part 'ui/screens/reading_result_screen.dart';
part 'ui/screens/library_screen.dart';
part 'ui/screens/profile_screen.dart';

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
      GoRoute(
        path: '/draw',
        builder: (context, state) => DrawScreen(
          initialQuestion: state.uri.queryParameters['question'] ?? '',
        ),
      ),
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
  return GoogleFonts.cinzel(
    textStyle: TextStyle(
      color: _ArcanaColors.ivory,
      fontFamilyFallback: const [
        'Noto Serif TC',
        'Source Han Serif TC',
        'Iowan Old Style',
        'Georgia',
        'serif',
      ],
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: 0.5,
    ),
  );
}

TextStyle _bodyTextStyle({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w500,
  Color color = _ArcanaColors.muted,
  double height = 1.55,
}) {
  return GoogleFonts.lora(
    textStyle: TextStyle(
      color: color,
      fontFamilyFallback: const [
        'Noto Sans TC',
        'Microsoft JhengHei',
        'Segoe UI',
        'sans-serif',
      ],
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: 0,
    ),
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
      checkmarkColor: _ArcanaColors.gold2,
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

