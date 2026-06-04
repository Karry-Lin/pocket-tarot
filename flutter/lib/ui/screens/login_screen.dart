part of '../../main.dart';

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
  final FocusNode _displayNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final GlobalKey _displayNameFieldKey = GlobalKey(
    debugLabel: 'email-auth-display-name-field',
  );
  final GlobalKey _emailFieldKey = GlobalKey(
    debugLabel: 'email-auth-email-field',
  );
  final GlobalKey _passwordFieldKey = GlobalKey(
    debugLabel: 'email-auth-password-field',
  );
  final GlobalKey _confirmPasswordFieldKey = GlobalKey(
    debugLabel: 'email-auth-confirm-password-field',
  );
  EmailAuthMode _mode = EmailAuthMode.signIn;
  Map<AuthFormField, String> _errors = const {};
  String? _formError;
  String? _formMessage;
  bool _submitting = false;
  bool _showEmailForm = false;

  Timer? _bgmTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bgmTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          ref.read(audioServiceProvider).playBgm();
        }
      });
    });
  }

  @override
  void dispose() {
    _bgmTimer?.cancel();
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usesChinese = _usesChineseCardText(l10n);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    final Widget mainContent;
    if (_showEmailForm) {
      mainContent = _emailAuthBackScope(
        _VisualEmailLoginScreen(
          mode: _mode,
          displayNameController: _displayNameController,
          emailController: _emailController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          displayNameFocusNode: _displayNameFocusNode,
          emailFocusNode: _emailFocusNode,
          passwordFocusNode: _passwordFocusNode,
          confirmPasswordFocusNode: _confirmPasswordFocusNode,
          displayNameFieldKey: _displayNameFieldKey,
          emailFieldKey: _emailFieldKey,
          passwordFieldKey: _passwordFieldKey,
          confirmPasswordFieldKey: _confirmPasswordFieldKey,
          displayNameError: _errors[AuthFormField.displayName],
          emailError: _errors[AuthFormField.email],
          passwordError: _errors[AuthFormField.password],
          confirmPasswordError: _errors[AuthFormField.confirmPassword],
          formMessage: _formError ?? _formMessage,
          isError: _formError != null,
          submitting: _submitting,
          onBack: _returnToLoginOptions,
          onModeChanged: _switchMode,
          onSubmit: _submit,
        ),
      );
    } else {
      final content = AppBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  26,
                  keyboardOpen ? 18 : 28,
                  26,
                  MediaQuery.viewInsetsOf(context).bottom + 34,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: keyboardOpen ? 40 : 242,
                        ),
                        if (!keyboardOpen) ...[
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
                          Text(usesChinese ? '用一張牌整理今天。' : l10n.loginTagline),
                          const SizedBox(height: 21),
                        ],
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _submitting ? null : _signInWithGoogle,
                              icon: const FaIcon(FontAwesomeIcons.google, size: 18),
                              label: Text(
                                usesChinese ? '使用 Google 繼續' : l10n.googleLogin,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _submitting
                                  ? null
                                  : _signInWithPlayGames,
                              icon: const Icon(Icons.sports_esports),
                              label: Text(
                                usesChinese
                                    ? '使用 Play Games 繼續'
                                    : l10n.playGamesLogin,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _submitting
                                  ? null
                                  : _signInWithGithub,
                              icon: const FaIcon(FontAwesomeIcons.github, size: 18),
                              label: Text(
                                usesChinese
                                    ? '使用 GitHub 繼續'
                                    : l10n.githubLogin,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ArcanaPrimaryButton(
                              onPressed: _submitting
                                  ? null
                                  : _openEmailAuthForm,
                              child: Text(
                                usesChinese
                                    ? '使用 Email 登入'
                                    : l10n.emailLogin,
                              ),
                            ),
                            if (_formError != null || _formMessage != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                _formError ?? _formMessage!,
                                style: TextStyle(
                                  color: _formError == null
                                      ? _ArcanaColors.gold2
                                      : Theme.of(context).colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 42),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 42,
                right: 32,
                child: _LoginLanguageButton(
                  usesChinese: usesChinese,
                  onPressed: _showLoginLocaleModeSheet,
                ),
              ),
            ],
          ),
        ),
      );

      mainContent = _RootBackExitGuard(child: content);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: mainContent,
    );
  }

  Widget _emailAuthBackScope(Widget child) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _submitting) {
          return;
        }
        _returnToLoginOptions();
      },
      child: child,
    );
  }

  Future<void> _showLoginLocaleModeSheet() async {
    final repository = await ref.read(localSettingsRepositoryProvider.future);
    final currentSettings = await repository.load();
    if (!mounted) {
      return;
    }

    final selected = await showModalBottomSheet<LocaleMode>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) =>
          _VisualLocaleModeSheet(currentMode: currentSettings.localeMode),
    );
    if (selected == null || selected == currentSettings.localeMode) {
      return;
    }

    await repository.save(
      LocalSettings(
        localeMode: selected,
        weatherEnabled: currentSettings.weatherEnabled,
      ),
    );
    ref.invalidate(appLocaleProvider);
    if (mounted) {
      setState(() {});
    }
  }

  void _switchMode(EmailAuthMode mode) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    setState(() {
      _mode = mode;
      _errors = const {};
      _formError = null;
      _formMessage = null;
    });
  }

  void _openEmailAuthForm() {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    setState(() {
      _showEmailForm = true;
      _errors = const {};
      _formError = null;
      _formMessage = null;
    });
  }

  void _returnToLoginOptions() {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    setState(() {
      _showEmailForm = false;
      _mode = EmailAuthMode.signIn;
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
    } catch (error) {
      if (mounted) {
        setState(() {
          _formError = null;
          _formMessage = null;
        });
        _showErrorSnackBar(context, _emailAuthFailureMessage(error, l10n));
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
          _formError = null;
          _formMessage = null;
        });
        _showErrorSnackBar(context, l10n.googleFailure);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _signInWithPlayGames() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _formError = null;
      _formMessage = null;
      _submitting = true;
    });

    try {
      await ref.read(authActionsProvider).signInWithPlayGames();
      if (mounted) {
        context.go('/splash');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _formError = null;
          _formMessage = null;
        });
        _showErrorSnackBar(context, _playGamesAuthFailureMessage(error, l10n));
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _signInWithGithub() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _formError = null;
      _formMessage = null;
      _submitting = true;
    });

    try {
      await ref.read(authActionsProvider).signInWithGithub();
      if (mounted) {
        context.go('/splash');
      }
    } catch (error, stackTrace) {
      debugPrint('GitHub Sign-in failed with error: $error\n$stackTrace');
      if (mounted) {
        setState(() {
          _formError = null;
          _formMessage = null;
        });
        _showErrorSnackBar(context, l10n.githubFailure);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: _bodyTextStyle(color: _ArcanaColors.ivory, fontWeight: FontWeight.w700),
        ),
        backgroundColor: _ArcanaColors.wine,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: _ArcanaColors.gold.withValues(alpha: 0.38)),
        ),
      ),
    );
  }
}

String _emailAuthFailureMessage(Object error, AppLocalizations l10n) {
  if (error is firebase.FirebaseAuthException &&
      error.code == 'email-already-in-use') {
    return l10n.emailAlreadyRegistered;
  }

  if (error is firebase.FirebaseAuthException &&
      _emailCredentialFailureCodes.contains(error.code)) {
    return l10n.emailCredentialFailure;
  }

  return l10n.formFailure;
}

const _emailCredentialFailureCodes = {
  'invalid-credential',
  'invalid-login-credentials',
  'user-not-found',
  'wrong-password',
};

String _playGamesAuthFailureMessage(Object error, AppLocalizations l10n) {
  if (error is PlatformException &&
      error.code == 'play-games-unregistered-sha1') {
    final currentSha1 = switch (error.details) {
      {'currentSha1': final String value} when value.isNotEmpty => value,
      _ => null,
    };

    if (_usesChineseCardText(l10n)) {
      final suffix = currentSha1 == null ? '' : '（SHA-1：$currentSha1）';
      return 'Play Games 設定未完成，請先登記此 APK 簽章$suffix。';
    }

    final suffix = currentSha1 == null ? '' : ' (SHA-1: $currentSha1)';
    return 'Play Games setup is incomplete. Register this APK signature$suffix.';
  }

  return l10n.playGamesFailure;
}

class _LoginLanguageButton extends StatelessWidget {
  const _LoginLanguageButton({
    required this.usesChinese,
    required this.onPressed,
  });

  final bool usesChinese;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const ValueKey('login-language-button'),
      onPressed: onPressed,
      icon: const Icon(Icons.language, size: 16),
      label: Text(usesChinese ? '繁體中文' : 'EN'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: _ArcanaColors.gold2,
        backgroundColor: _ArcanaColors.ink2.withValues(alpha: 0.56),
        side: BorderSide(color: _ArcanaColors.gold.withValues(alpha: 0.42)),
        textStyle: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class _VisualEmailLoginScreen extends StatelessWidget {
  const _VisualEmailLoginScreen({
    required this.mode,
    required this.displayNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.displayNameFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.displayNameFieldKey,
    required this.emailFieldKey,
    required this.passwordFieldKey,
    required this.confirmPasswordFieldKey,
    required this.displayNameError,
    required this.emailError,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.formMessage,
    required this.isError,
    required this.submitting,
    required this.onBack,
    required this.onModeChanged,
    required this.onSubmit,
  });

  final EmailAuthMode mode;
  final TextEditingController displayNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode displayNameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final Key displayNameFieldKey;
  final Key emailFieldKey;
  final Key passwordFieldKey;
  final Key confirmPasswordFieldKey;
  final String? displayNameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? formMessage;
  final bool isError;
  final bool submitting;
  final VoidCallback onBack;
  final ValueChanged<EmailAuthMode> onModeChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usesChinese = _usesChineseCardText(l10n);
    final isRegister = mode == EmailAuthMode.register;
    final isReset = mode == EmailAuthMode.resetPassword;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final primaryLabel = switch (mode) {
      EmailAuthMode.signIn => usesChinese ? '進入口袋塔羅' : 'Enter Pocket Tarot',
      EmailAuthMode.register => usesChinese ? '建立帳號' : l10n.createAccount,
      EmailAuthMode.resetPassword => usesChinese ? '寄送重設信' : l10n.sendPasswordReset,
    };

    Widget buildContent() {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          26,
          keyboardOpen ? 18 : 28,
          26,
          34,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Visibility(
                  visible: !keyboardOpen,
                  maintainState: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Text(
                        usesChinese ? '用一張牌整理今天。' : l10n.loginTagline,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 21),
                    ],
                  ),
                ),
                _VisualAuthModeSwitch(
                  mode: mode,
                  enabled: !submitting,
                  onChanged: onModeChanged,
                ),
                const SizedBox(height: 16),
                if (isRegister) ...[
                  _VisualEmailField(
                    key: displayNameFieldKey,
                    label: usesChinese ? '顯示名稱' : l10n.displayNameLabel,
                    hintText: usesChinese ? '想被如何稱呼？' : 'What should we call you?',
                    controller: displayNameController,
                    focusNode: displayNameFocusNode,
                    errorText: displayNameError,
                  ),
                  const SizedBox(height: 12),
                ],
                _VisualEmailField(
                  key: emailFieldKey,
                  label: 'Email',
                  hintText: 'you@example.com',
                  controller: emailController,
                  focusNode: emailFocusNode,
                  errorText: emailError,
                ),
                if (!isReset) ...[
                  const SizedBox(height: 12),
                  _VisualEmailField(
                    key: passwordFieldKey,
                    label: usesChinese ? '密碼' : l10n.passwordLabel,
                    hintText: usesChinese ? '至少 6 個字元' : 'At least 6 characters',
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    obscureText: true,
                    errorText: passwordError,
                  ),
                ],
                if (isRegister) ...[
                  const SizedBox(height: 12),
                  _VisualEmailField(
                    key: confirmPasswordFieldKey,
                    label: usesChinese ? '確認密碼' : l10n.confirmPasswordLabel,
                    hintText: usesChinese ? '再輸入一次密碼' : 'Enter password again',
                    controller: confirmPasswordController,
                    focusNode: confirmPasswordFocusNode,
                    obscureText: true,
                    errorText: confirmPasswordError,
                  ),
                ],
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
                const SizedBox(height: 18),
                ArcanaPrimaryButton(
                  onPressed: submitting ? null : onSubmit,
                  child: Text(primaryLabel),
                ),
                const SizedBox(height: 8),
                if (mode == EmailAuthMode.signIn)
                  TextButton(
                    onPressed: submitting
                        ? null
                        : () => onModeChanged(EmailAuthMode.resetPassword),
                    child: Text(usesChinese ? '忘記密碼？' : '${l10n.forgotPassword}?'),
                  )
                else if (mode == EmailAuthMode.resetPassword)
                  TextButton(
                    onPressed: submitting
                        ? null
                        : () => onModeChanged(EmailAuthMode.signIn),
                    child: Text(usesChinese ? '回到 Email 登入' : 'Back to Email Sign-in'),
                  )
                else
                  const SizedBox(height: 20),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      );
    }

    return AppBackdrop(
      child: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
                final availableHeight = constraints.maxHeight - keyboardHeight;
                final shouldScroll =
                    keyboardOpen || constraints.maxHeight < 760;
                final content = buildContent();
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: availableHeight),
                  child: SingleChildScrollView(
                    key: const ValueKey('visual-email-auth-scroll'),
                    keyboardDismissBehavior: shouldScroll
                        ? ScrollViewKeyboardDismissBehavior.onDrag
                        : ScrollViewKeyboardDismissBehavior.manual,
                    physics: shouldScroll
                        ? const ClampingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: content,
                  ),
                );
              },
            ),
            Positioned(
              top: 28,
              left: 18,
              child: _RoundBackButton(onPressed: submitting ? null : onBack),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisualAuthModeSwitch extends StatelessWidget {
  const _VisualAuthModeSwitch({
    required this.mode,
    required this.enabled,
    required this.onChanged,
  });

  final EmailAuthMode mode;
  final bool enabled;
  final ValueChanged<EmailAuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usesChinese = _usesChineseCardText(l10n);

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _ArcanaColors.ink2.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _ArcanaColors.gold.withValues(alpha: 0.26)),
      ),
      child: Row(
        children: [
          _VisualAuthModeOption(
            label: usesChinese ? 'Email 登入' : l10n.emailLogin,
            selected: mode != EmailAuthMode.register,
            enabled: enabled,
            onTap: () => onChanged(EmailAuthMode.signIn),
          ),
          const SizedBox(width: 4),
          _VisualAuthModeOption(
            label: usesChinese ? '註冊' : l10n.registerAction,
            selected: mode == EmailAuthMode.register,
            enabled: enabled,
            onTap: () => onChanged(EmailAuthMode.register),
          ),
        ],
      ),
    );
  }
}

class _VisualAuthModeOption extends StatelessWidget {
  const _VisualAuthModeOption({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: selected
                ? const LinearGradient(
                    colors: [_ArcanaColors.gold2, _ArcanaColors.gold],
                  )
                : null,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? Colors.black : _ArcanaColors.ivory,
            ),
          ),
        ),
      ),
    );
  }
}

class _VisualEmailField extends StatelessWidget {
  const _VisualEmailField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.focusNode,
    this.obscureText = false,
    this.errorText,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final FocusNode? focusNode;
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
          focusNode: focusNode,
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
