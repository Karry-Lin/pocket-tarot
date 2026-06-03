part of '../../main.dart';

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
