part of '../../main.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late final AudioService _audioService;

  @override
  void initState() {
    super.initState();
    _audioService = ref.read(audioServiceProvider);
    _audioService.playBgm();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _ArcanaColors.ink,
      extendBody: false,
      body: widget.navigationShell,
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
                        symbol: '⌂',
                        label: l10n.navHome,
                        selected: widget.navigationShell.currentIndex == 0,
                        onTap: () => _goBranch(0),
                      ),
                      _BottomNavItem(
                        icon: Icons.grid_view,
                        symbol: '✦',
                        label: l10n.navDivination,
                        selected: widget.navigationShell.currentIndex == 1,
                        onTap: () => _goBranch(1),
                      ),
                      _BottomNavItem(
                        icon: Icons.menu_book,
                        symbol: '☽',
                        label: l10n.navLibrary,
                        selected: widget.navigationShell.currentIndex == 2,
                        onTap: () => _goBranch(2),
                      ),
                      _BottomNavItem(
                        icon: Icons.person,
                        symbol: '♙',
                        label: l10n.navProfile,
                        selected: widget.navigationShell.currentIndex == 3,
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
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  void dispose() {
    _audioService.stopBgm();
    super.dispose();
  }
}

const _appExitBackWindow = Duration(seconds: 2);

class _RootBackExitGuard extends StatefulWidget {
  const _RootBackExitGuard({required this.child});

  final Widget child;

  @override
  State<_RootBackExitGuard> createState() => _RootBackExitGuardState();
}

class _RootBackExitGuardState extends State<_RootBackExitGuard> {
  DateTime? _lastBackPressedAt;
  Timer? _hidePromptTimer;
  bool _showPrompt = false;

  @override
  void dispose() {
    _hidePromptTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _handleBackAttempt();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_showPrompt)
            _ExitPromptToast(message: _exitPromptMessage(context)),
        ],
      ),
    );
  }

  void _handleBackAttempt() {
    final now = DateTime.now();
    final lastPressedAt = _lastBackPressedAt;
    if (lastPressedAt != null &&
        now.difference(lastPressedAt) <= _appExitBackWindow) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPressedAt = now;
    _hidePromptTimer?.cancel();
    setState(() => _showPrompt = true);
    _hidePromptTimer = Timer(_appExitBackWindow, () {
      if (!mounted) {
        return;
      }
      setState(() => _showPrompt = false);
      _lastBackPressedAt = null;
    });
  }
}

class _ExitPromptToast extends StatelessWidget {
  const _ExitPromptToast({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 22,
      child: IgnorePointer(
        child: SafeArea(
          top: false,
          child: Center(
            child: Material(
              type: MaterialType.transparency,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 316),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _ArcanaColors.ink2.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _ArcanaColors.gold.withValues(alpha: 0.38),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.42),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _ArcanaColors.gold.withValues(alpha: 0.16),
                            border: Border.all(
                              color: _ArcanaColors.gold2.withValues(
                                alpha: 0.34,
                              ),
                            ),
                          ),
                          child: const SizedBox.square(
                            dimension: 30,
                            child: Icon(
                              Icons.keyboard_return,
                              size: 16,
                              color: _ArcanaColors.gold2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            message,
                            textAlign: TextAlign.left,
                            style:
                                _bodyTextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _ArcanaColors.ivory,
                                  height: 1.2,
                                ).copyWith(
                                  decoration: TextDecoration.none,
                                  decorationColor: Colors.transparent,
                                ),
                          ),
                        ),
                      ],
                    ),
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

String _exitPromptMessage(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return _usesChineseCardText(l10n)
      ? '再按一次返回退出 APP'
      : 'Press back again to exit';
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
