part of '../../main.dart';

class GateScaffold extends ConsumerWidget {
  const GateScaffold({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.feedbackMessage,
    this.actionBusy = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final String? feedbackMessage;
  final bool actionBusy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return _RootBackExitGuard(
      child: AppBackdrop(
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
                if (feedbackMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    feedbackMessage!,
                    textAlign: TextAlign.center,
                    style: _bodyTextStyle(color: _ArcanaColors.error),
                  ),
                ],
                const SizedBox(height: 24),
                Align(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 180,
                      maxWidth: 240,
                      minHeight: 48,
                    ),
                    child: FilledButton(
                      onPressed: actionBusy ? null : onAction,
                      child: actionBusy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(actionLabel),
                    ),
                  ),
                ),
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
      ),
    );
  }
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.maxLines = 1,
    this.errorText,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final int maxLines;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      maxLines: maxLines,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: _ArcanaColors.ivory),
      decoration: InputDecoration(labelText: label, errorText: errorText),
    );
  }
}
