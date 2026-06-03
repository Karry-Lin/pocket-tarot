part of '../../main.dart';

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
