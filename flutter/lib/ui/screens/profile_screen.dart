part of '../../main.dart';

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

  Future<void> _showLocaleModeSheet(LocaleMode currentMode) async {
    final selected = await showModalBottomSheet<LocaleMode>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) =>
          _VisualLocaleModeSheet(currentMode: currentMode),
    );
    if (selected != null && selected != currentMode) {
      await _setLocaleMode(selected);
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

    return ScreenFrame(
      title: l10n.profileTitle,
      eyebrow: 'Profile',
      trailing: null,
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
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showNameDialog(
                  context,
                  _updateDisplayName,
                  initialName: snapshot.user.displayName,
                ),
                icon: Icon(usesChinese ? Icons.edit_outlined : Icons.edit),
                tooltip: l10n.editDisplayName,
                style: usesChinese
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
        SizedBox(height: usesChinese ? 18 : 12),
        Row(
          children: [
            Expanded(
              child: GlassPanel(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                radius: 18,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: usesChinese ? 74 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EyebrowText(
                        usesChinese ? 'All-time daily' : 'Daily draw',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        usesChinese
                            ? '${snapshot.stats.dailyReadingCount} 次'
                            : '${snapshot.stats.dailyReadingCount}',
                        style: usesChinese
                            ? Theme.of(context).textTheme.titleMedium
                            : Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        usesChinese ? '每日一抽完成次數。' : l10n.navHome,
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
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                radius: 18,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: usesChinese ? 74 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EyebrowText(
                        usesChinese ? 'All-time reading' : 'Deep reading',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        usesChinese
                            ? '${snapshot.stats.deepReadingCount} 次'
                            : '${snapshot.stats.deepReadingCount}',
                        style: usesChinese
                            ? Theme.of(context).textTheme.titleMedium
                            : Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        usesChinese ? '深度占卜完成次數。' : l10n.navDivination,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const EyebrowText('Settings'),
            const SizedBox(height: 8),
            _SectionTitle(usesChinese ? '設定選項' : 'Settings'),
            const SizedBox(height: 14),
            _VisualSettingRow(
              title: usesChinese ? '使用所在地天氣' : l10n.weatherToggle,
              subtitle: usesChinese
                  ? '只用於生成今日心靈天氣'
                  : 'Only used to generate daily spiritual weather.',
              toggled: settings.weatherEnabled,
              onTap: () => _setWeatherEnabled(!settings.weatherEnabled),
            ),
            const SizedBox(height: 16),
            _VisualSettingRow(
              title: usesChinese ? '語言設定' : 'Language',
              subtitle: _localeModeLabel(settings.localeMode, l10n),
              action: usesChinese ? '變更' : 'Change',
              onTap: () => _showLocaleModeSheet(settings.localeMode),
            ),
          ],
        ),
        SizedBox(height: usesChinese ? 14 : 12),
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
              Text(
                usesChinese
                    ? '目前使用帳號登入。登出後仍可保留你的雲端紀錄。'
                    : 'You are signed in. Your saved readings remain available after signing out.',
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
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

String _localeModeLabel(LocaleMode localeMode, AppLocalizations l10n) {
  return switch (localeMode) {
    LocaleMode.system => l10n.localeSystem,
    LocaleMode.zhTw => l10n.localeZh,
    LocaleMode.en => l10n.localeEn,
  };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _ArcanaSectionDivider extends StatelessWidget {
  const _ArcanaSectionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 28,
      thickness: 1,
      color: _ArcanaColors.gold.withValues(alpha: 0.22),
    );
  }
}

class _VisualSettingRow extends StatelessWidget {
  const _VisualSettingRow({
    required this.title,
    required this.subtitle,
    this.toggled,
    this.action,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool? toggled;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _ArcanaColors.gold.withValues(alpha: 0.18),
            ),
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
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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
    final usesChinese = _usesChineseCardText(l10n);
    final previewHistory =
        visualFixtureMode && usesChinese && state.history.isEmpty
        ? _visualPreviewHistory
        : state.history;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EyebrowText('Saved readings'),
        const SizedBox(height: 8),
        Text(l10n.historyTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        if (state.status == DeepReadingStatus.historyLoading)
          const GlassPanel(
            padding: EdgeInsets.all(18),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state.historyErrorMessage != null)
          GlassPanel(
            padding: const EdgeInsets.all(18),
            radius: 18,
            child: Text(
              usesChinese
                  ? '歷史紀錄暫時無法載入。'
                  : 'History could not be loaded right now.',
            ),
          )
        else if (previewHistory.isEmpty)
          GlassPanel(
            padding: const EdgeInsets.all(18),
            radius: 18,
            child: Text(l10n.emptyHistory),
          )
        else
          for (var index = 0; index < previewHistory.length; index++) ...[
            _VisualHistoryCard(
              item: previewHistory[index],
              onTap: () => onOpenHistory(previewHistory[index].id),
            ),
            if (index != previewHistory.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _VisualHistoryCard extends StatelessWidget {
  const _VisualHistoryCard({required this.item, required this.onTap});

  final DeepReadingHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tag = _readingDateLabel(item.createdAt, l10n);

    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.all(14),
        radius: 18,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.question.isEmpty
                        ? l10n.unnamedQuestion
                        : item.question,
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
      ),
    );
  }
}

class _VisualLocaleModeSheet extends StatelessWidget {
  const _VisualLocaleModeSheet({required this.currentMode});

  final LocaleMode currentMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usesChinese = _usesChineseCardText(l10n);
    final modes = [LocaleMode.system, LocaleMode.zhTw, LocaleMode.en];

    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
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
                      const EyebrowText('Language'),
                      const SizedBox(height: 8),
                      Text(
                        usesChinese ? '語言設定' : 'Language',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    fixedSize: const Size(44, 44),
                    foregroundColor: _ArcanaColors.ivory,
                    backgroundColor: _ArcanaColors.ink2.withValues(alpha: 0.72),
                    side: BorderSide(
                      color: _ArcanaColors.gold.withValues(alpha: 0.28),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final mode in modes) ...[
              _VisualLocaleOption(
                label: _localeModeLabel(mode, l10n),
                selected: mode == currentMode,
                onTap: () => Navigator.of(context).pop(mode),
              ),
              if (mode != modes.last) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _VisualLocaleOption extends StatelessWidget {
  const _VisualLocaleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? _ArcanaColors.gold2.withValues(alpha: 0.72)
                  : _ArcanaColors.gold.withValues(alpha: 0.18),
            ),
            color: selected
                ? _ArcanaColors.gold.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.04),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle, color: _ArcanaColors.gold2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _readingDateLabel(DateTime createdAt, AppLocalizations l10n) {
  final localCreatedAt = createdAt.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final createdDay = DateTime(
    localCreatedAt.year,
    localCreatedAt.month,
    localCreatedAt.day,
  );
  final dayDelta = today.difference(createdDay).inDays;

  if (dayDelta == 0) {
    return _usesChineseCardText(l10n) ? '今天' : 'Today';
  }
  if (dayDelta == 1) {
    return _usesChineseCardText(l10n) ? '昨天' : 'Yesterday';
  }

  return '${localCreatedAt.month}/${localCreatedAt.day}';
}

class _VisualNameEditSheet extends StatefulWidget {
  const _VisualNameEditSheet({required this.initialName, required this.onSave});

  final String initialName;
  final Future<void> Function(String displayName) onSave;

  @override
  State<_VisualNameEditSheet> createState() => _VisualNameEditSheetState();
}

class _VisualNameEditSheetState extends State<_VisualNameEditSheet> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialName);
    _textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initialName.length,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usesChinese = _usesChineseCardText(l10n);

    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
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
                        l10n.editNameTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    fixedSize: const Size(44, 44),
                    foregroundColor: _ArcanaColors.ivory,
                    backgroundColor: _ArcanaColors.ink2.withValues(alpha: 0.72),
                    side: BorderSide(
                      color: _ArcanaColors.gold.withValues(alpha: 0.28),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _VisualEmailField(
              label: l10n.nicknameLabel,
              hintText: usesChinese ? '王大明' : 'Kerry',
              controller: _textController,
            ),
            const SizedBox(height: 10),
            Text(
              usesChinese
                  ? '暱稱會顯示在個人檔案與占卜紀錄。'
                  : 'This name appears on your profile and reading records.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            ArcanaPrimaryButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await widget.onSave(_textController.text);
                if (mounted) {
                  navigator.pop();
                }
              },
              child: Text(usesChinese ? '儲存名稱' : l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
