part of '../../main.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  String? _feedbackMessage;
  bool _checking = false;

  Future<void> _confirmVerified() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _checking = true;
      _feedbackMessage = null;
    });

    final controller = ref.read(appStartupControllerProvider);
    await controller.check();
    if (!mounted) {
      return;
    }

    final state = controller.state;
    if (state.status == AppStartupStatus.ready &&
        state.targetRoute != null &&
        state.targetRoute != '/verify-email') {
      context.go(state.targetRoute!);
      return;
    }

    setState(() {
      _checking = false;
      _feedbackMessage = state.status == AppStartupStatus.ready
          ? l10n.verifyEmailStillPending
          : (state.errorMessage ?? l10n.tryAgainLater);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GateScaffold(
      icon: Icons.mark_email_unread,
      title: l10n.verifyEmailTitle,
      message: l10n.verifyEmailMessage,
      actionLabel: l10n.verifyEmailAction,
      feedbackMessage: _feedbackMessage,
      actionBusy: _checking,
      onAction: _confirmVerified,
    );
  }
}
