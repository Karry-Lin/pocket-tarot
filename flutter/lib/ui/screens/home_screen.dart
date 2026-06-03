part of '../../main.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DailyReadingState _dailyState = const DailyReadingState.initial();
  String? _displayName;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadToday();
      _loadHomeProfile();
    });
  }

  Future<void> _loadHomeProfile() async {
    try {
      final controller = await ref.read(profileControllerProvider.future);
      await controller.load();
      if (mounted) {
        setState(
          () => _displayName = controller.state.snapshot?.user.displayName,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _displayName = null);
      }
    }
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

  Future<void> _confirmRedrawToday() async {
    final l10n = AppLocalizations.of(context)!;
    final usesChinese = _usesChineseCardText(l10n);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(usesChinese ? '清除今日抽牌？' : 'Clear today\'s reading?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              usesChinese
                  ? '這只會刪除今天的抽牌紀錄，不會自動重新抽牌。畫面會回到抽卡前。'
                  : 'This only deletes today\'s reading. It will not redraw automatically, and the screen will return to before the draw.',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(usesChinese ? '取消' : 'Cancel'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(usesChinese ? '確認' : 'Confirm'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await _redrawToday();
    }
  }

  Future<void> _redrawToday() async {
    setState(() => _isClearing = true);
    final controller = await ref.read(dailyReadingControllerProvider.future);
    final redrawFuture = controller.redrawToday();
    if (mounted) {
      setState(() => _dailyState = controller.state);
    }
    await redrawFuture;
    if (mounted) {
      setState(() {
        _dailyState = controller.state;
        _isClearing = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    if (_dailyState.status == DailyReadingStatus.loaded) {
      await _redrawToday();
    } else {
      await _loadToday();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerAsync = ref.watch(dailyReadingControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final usesChinese = _usesChineseCardText(l10n);
    final loaded = _dailyState.status == DailyReadingStatus.loaded;
    final scrollable = loaded || _dailyState.status == DailyReadingStatus.error;

    return ScreenFrame(
      title: _homeTitle(
        displayName: _displayName,
        loaded: loaded,
        usesChinese: usesChinese,
        l10n: l10n,
      ),
      eyebrow: loaded ? 'Daily result' : 'Daily ritual',
      scrollable: scrollable,
      onRefresh: _handleRefresh,
      trailing: loaded
          ? _DailyRedrawButton(
              label: usesChinese ? '清除' : 'Clear',
              onPressed: _confirmRedrawToday,
            )
          : null,
      child: controllerAsync.when(
        loading: () => _AppLoadingIndicator(
          message: _isClearing
              ? (usesChinese ? '正在重置今日抽卡...' : 'Resetting today\'s card...')
              : (usesChinese ? '正在召喚今日塔羅牌面...' : 'Summoning today\'s tarot spread...'),
        ),
        error: (error, stackTrace) =>
            _DailyErrorPanel(message: error.toString(), onRetry: _loadToday),
        data: (_) => _dailyContent(context),
      ),
    );
  }

  Widget _dailyContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usesChinese = _usesChineseCardText(l10n);

    return switch (_dailyState.status) {
      DailyReadingStatus.initial || DailyReadingStatus.loading => _AppLoadingIndicator(
        message: _isClearing
            ? (usesChinese ? '正在重置今日抽卡...' : 'Resetting today\'s card...')
            : (usesChinese ? '正在召喚今日塔羅牌面...' : 'Summoning today\'s tarot spread...'),
      ),
      DailyReadingStatus.empty => _DailyEmptyState(onDraw: _drawToday),
      DailyReadingStatus.creating => ArcanaLoadingView(
        title: l10n.dailyLoadingTitle,
        message: l10n.dailyLoadingMessage,
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

String _homeTitle({
  required String? displayName,
  required bool loaded,
  required bool usesChinese,
  required AppLocalizations l10n,
}) {
  final name = displayName?.trim();
  if (name != null && name.isNotEmpty) {
    if (loaded) {
      return usesChinese ? '$name，今日牌面已揭曉' : '$name, today\'s card is revealed';
    }

    return usesChinese ? '$name，牌桌亮起' : '$name, the table is lit';
  }

  return usesChinese ? (loaded ? '今日抽牌結果' : '每日抽牌') : l10n.homeTitle;
}

class DailyResultCard extends ConsumerWidget {
  const DailyResultCard({super.key, required this.reading});

  final DailyReading reading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cards = ref.watch(tarotCardsProvider).asData?.value ?? const [];
    final tarotCard = _findCardById(cards, reading.card.cardId);
    final weatherDisplay = _dailyWeatherDisplay(reading, l10n);
    final streakDisplay = _dailyStreakDisplay(reading, l10n);
    final usesChinese = _usesChineseCardText(l10n);

    final sections = reading.markdownResult
        .split(RegExp(
          r'(?=^#{2,4}\s+)|(?=^#{2,4}(?=\S))|(?=^\s*\*\*(今日牌義|今日提醒|行動建議|問題核心|隱藏影響|總結|Card Meaning|Daily Reminder|Action Advice|Core Question|Hidden Influence|Summary)\*\*)|(?=^\s*(今日牌義|今日提醒|行動建議|問題核心|隱藏影響|總結|Card Meaning|Daily Reminder|Action Advice|Core Question|Hidden Influence|Summary)[\s：:])',
          multiLine: true,
          caseSensitive: false,
        ))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => s
            .replaceAll(RegExp(r'^\s*[-*_]{3,}\s*$', multiLine: true), '')
            .trim())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          ornate: true,
          padding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: usesChinese ? 224 : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TarotImageCard(
                  imagePath: _imageForCardId(reading.card.cardId),
                  width: usesChinese ? 106 : 94,
                  height: usesChinese ? 184 : 141,
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
                        _dailyCardDisplayName(reading.card, l10n, tarotCard),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reading.summary,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: GlassPanel(
                  key: const ValueKey('daily-weather-card'),
                  padding: const EdgeInsets.all(14),
                  radius: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const EyebrowText('Weather'),
                      const SizedBox(height: 7),
                      Text(
                        weatherDisplay.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        weatherDisplay.body,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassPanel(
                  key: const ValueKey('daily-streak-card'),
                  padding: const EdgeInsets.all(14),
                  radius: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const EyebrowText('Streak'),
                      const SizedBox(height: 7),
                      Text(
                        streakDisplay.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        streakDisplay.body,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassPanel(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < sections.length; i++) ...[
                SafeMarkdownBody(data: sections[i]),
                if (i < sections.length - 1) const _ArcanaSectionDivider(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyRedrawButton extends StatelessWidget {
  const _DailyRedrawButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh_rounded, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        foregroundColor: _ArcanaColors.gold2,
        side: BorderSide(color: _ArcanaColors.gold2.withValues(alpha: 0.44)),
        textStyle: _bodyTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: _ArcanaColors.gold2,
          height: 1,
        ),
      ),
    );
  }
}

class _DailyInfoDisplay {
  const _DailyInfoDisplay({required this.title, required this.body});

  final String title;
  final String body;
}

_DailyInfoDisplay _dailyWeatherDisplay(
  DailyReading reading,
  AppLocalizations l10n,
) {
  final usesChinese = _usesChineseCardText(l10n);
  final weather = reading.weather;

  if (weather == null) {
    return _DailyInfoDisplay(
      title: usesChinese ? '未提供天氣' : 'No weather data',
      body: usesChinese
          ? '這次每日抽牌沒有附帶天氣資訊。'
          : 'This reading has no weather snapshot.',
    );
  }

  return switch (weather.status) {
    'success' => _successfulWeatherDisplay(weather, usesChinese),
    'disabled' => _DailyInfoDisplay(
      title: usesChinese ? '未使用天氣' : 'Weather off',
      body: usesChinese
          ? '這次解讀未加入所在地天氣。'
          : 'This reading did not include local weather.',
    ),
    'permission_denied' => _DailyInfoDisplay(
      title: usesChinese ? '未取得位置' : 'Location not shared',
      body: usesChinese
          ? '未取得位置權限，因此未加入即時天氣。'
          : 'Location permission was not available for this draw.',
    ),
    _ => _DailyInfoDisplay(
      title: usesChinese ? '天氣暫不可用' : 'Weather unavailable',
      body: usesChinese
          ? 'API 沒有回傳可用的即時天氣。'
          : 'The API did not return usable current weather.',
    ),
  };
}

_DailyInfoDisplay _successfulWeatherDisplay(
  WeatherSnapshot weather,
  bool usesChinese,
) {
  final current = weather.current;
  if (current == null) {
    return _DailyInfoDisplay(
      title: usesChinese ? '天氣已啟用' : 'Weather included',
      body: usesChinese
          ? '本次解讀已加入所在地天氣。'
          : 'Local weather was included in this reading.',
    );
  }

  final weatherName = _weatherCodeLabel(current.weatherCode, usesChinese);
  final temperature = current.temperature2m;
  final locationLabel = _weatherLocationLabel(weather, usesChinese);
  final title = temperature == null
      ? '$locationLabel $weatherName'
      : '$locationLabel ${temperature.round()}° $weatherName';
  final humidity = current.relativeHumidity2m;
  final precipitation = current.precipitation;
  final bodyParts = <String>[];

  if (humidity != null) {
    bodyParts.add(
      usesChinese ? '濕度 ${humidity.round()}%' : 'Humidity ${humidity.round()}%',
    );
  }
  if (precipitation != null && precipitation > 0) {
    bodyParts.add(
      usesChinese
          ? '降雨 ${precipitation.toStringAsFixed(1)} mm'
          : 'Rain ${precipitation.toStringAsFixed(1)} mm',
    );
  }

  return _DailyInfoDisplay(
    title: title,
    body: bodyParts.isEmpty
        ? (usesChinese
              ? '即時天氣已納入今日解讀。'
              : 'Current weather was included in this reading.')
        : bodyParts.join(usesChinese ? '，' : ', '),
  );
}

String _weatherLocationLabel(WeatherSnapshot weather, bool usesChinese) {
  final locationName = weather.locationName?.trim();
  if (locationName != null && locationName.isNotEmpty) {
    return locationName;
  }

  return usesChinese ? '所在地' : 'Local';
}

String _weatherCodeLabel(double? weatherCode, bool usesChinese) {
  final code = weatherCode?.round();
  if (code == null) {
    return usesChinese ? '天氣' : 'weather';
  }
  if (code == 0) {
    return usesChinese ? '晴' : 'Clear';
  }
  if (code >= 1 && code <= 3) {
    return usesChinese ? '多雲' : 'Cloudy';
  }
  if (code == 45 || code == 48) {
    return usesChinese ? '霧' : 'Fog';
  }
  if ((code >= 51 && code <= 57) || (code >= 80 && code <= 82)) {
    return usesChinese ? '小雨' : 'Showers';
  }
  if (code >= 61 && code <= 67) {
    return usesChinese ? '雨' : 'Rain';
  }
  if (code >= 71 && code <= 77) {
    return usesChinese ? '雪' : 'Snow';
  }
  if (code >= 95) {
    return usesChinese ? '雷雨' : 'Thunderstorm';
  }

  return usesChinese ? '天氣' : 'weather';
}

_DailyInfoDisplay _dailyStreakDisplay(
  DailyReading reading,
  AppLocalizations l10n,
) {
  final usesChinese = _usesChineseCardText(l10n);
  final streak = reading.dailyStreak;

  if (streak != null && streak > 0) {
    return _DailyInfoDisplay(
      title: usesChinese ? '連續 $streak 天' : '$streak-day streak',
      body: usesChinese
          ? '你正在建立一種穩定的觀察習慣。'
          : 'You are building a steady observation habit.',
    );
  }

  return _DailyInfoDisplay(
    title: usesChinese ? '今日已完成' : 'Drawn today',
    body: usesChinese
        ? '這筆紀錄建立於 ${_dailyReadingDateLabel(reading.localDate)}。'
        : 'Recorded on ${_dailyReadingDateLabel(reading.localDate)}.',
  );
}

String _dailyReadingDateLabel(String localDate) {
  final parts = localDate.split('-');
  if (parts.length != 3) {
    return localDate;
  }

  final month = int.tryParse(parts[1]) ?? 0;
  final day = int.tryParse(parts[2]) ?? 0;
  if (month <= 0 || day <= 0) {
    return localDate;
  }

  return '$month/$day';
}

class _DailyEmptyState extends StatelessWidget {
  const _DailyEmptyState({required this.onDraw});

  final VoidCallback onDraw;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usesChineseText = _usesChineseCardText(l10n);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stageHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 660.0;
        final compact = stageHeight < 560 || constraints.maxWidth < 320;
        final copyHeight = compact ? 172.0 : 164.0;
        final deckTop = copyHeight + (compact ? 12.0 : 100.0);
        final constellationBottom = compact ? 0.0 : 24.0;
        final title = usesChineseText
            ? '讓一張牌先替今天開口'
            : 'Let one card speak first';

        return SizedBox(
          key: const ValueKey('daily-ritual-stage'),
          height: stageHeight,
          child: Stack(
            children: [
              Positioned(
                top: compact ? 8.0 : 86.0,
                right: 0,
                left: 0,
                child: SizedBox(
                  key: const ValueKey('daily-ritual-copy'),
                  height: copyHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: EyebrowText('One card today')),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: usesChineseText
                            ? const TextStyle(
                                fontFamily: 'ChenYuluoyan',
                                fontSize: 28,
                                color: _ArcanaColors.ivory,
                                fontWeight: FontWeight.w400,
                              )
                            : Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        usesChineseText
                            ? '不用急著追完整答案，輕觸中央牌背，先接住此刻最靠近你的訊號。'
                            : 'Tap the deck and let the closest signal surface for today.',
                        textAlign: TextAlign.center,
                        style: usesChineseText
                            ? const TextStyle(
                                fontFamily: 'LXGWWenKaiMonoTC',
                                fontSize: 14,
                                color: _ArcanaColors.muted,
                                fontWeight: FontWeight.w300,
                                height: 1.55,
                              )
                            : Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: deckTop,
                right: 0,
                left: 0,
                child: DailyDeckStage(
                  onTap: onDraw,
                  semanticLabel: l10n.dailyDrawButton,
                ),
              ),
              Positioned(
                right: 0,
                bottom: constellationBottom,
                left: 0,
                child: const _DailyRitualConstellation(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DailyDeckStage extends StatefulWidget {
  const DailyDeckStage({super.key, this.onTap, this.semanticLabel});

  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  State<DailyDeckStage> createState() => _DailyDeckStageState();
}

class _DailyDeckStageState extends State<DailyDeckStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    if (_ambientRitualMotionEnabled) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = KeyedSubtree(
      key: const ValueKey('daily-ritual-continuous-motion'),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final sway = math.sin(progress * math.pi * 2);
          final counterSway = math.sin((progress + 0.38) * math.pi * 2);

          return SizedBox(
            key: const ValueKey('daily-ritual-deck'),
            height: 218,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    key: const ValueKey('daily-ritual-orbit-pulse'),
                    painter: _DailyDeckOrbitPainter(progress: progress),
                  ),
                ),
                Transform.translate(
                  offset: Offset(-20 - 2 * sway, 12 + 3 * counterSway),
                  child: Transform.scale(
                    scale: 0.93,
                    child: _DeckCard(rotation: -0.23 + 0.025 * sway),
                  ),
                ),
                Transform.translate(
                  offset: Offset(20 + 2 * counterSway, 10 - 3 * sway),
                  child: Transform.scale(
                    scale: 0.93,
                    child: _DeckCard(rotation: 0.22 + 0.025 * counterSway),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -4 + 4 * sway),
                  child: Transform.scale(
                    scale: 0.96 + 0.015 * counterSway,
                    child: _DeckCard(rotation: 0.015 * sway),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (widget.onTap == null) {
      return stage;
    }

    return Semantics(
      key: const ValueKey('daily-ritual-deck-action'),
      button: true,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: MouseRegion(cursor: SystemMouseCursors.click, child: stage),
      ),
    );
  }
}

bool get _ambientRitualMotionEnabled {
  var enabled = true;
  assert(() {
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    enabled =
        !bindingName.contains('TestWidgetsFlutterBinding') &&
        !bindingName.contains('AutomatedTestWidgetsFlutterBinding');
    return true;
  }());
  return enabled;
}

class _DailyDeckOrbitPainter extends CustomPainter {
  const _DailyDeckOrbitPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final pulse = 0.5 + 0.5 * math.sin(progress * math.pi * 2);
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _ArcanaColors.gold.withValues(alpha: 0.18 + pulse * 0.08);
    final softPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _ArcanaColors.muted.withValues(alpha: 0.16);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = _ArcanaColors.gold2.withValues(alpha: 0.38 + pulse * 0.22);

    final wideOrbit = Rect.fromCenter(
      center: center,
      width: size.width * 0.84,
      height: size.height * 0.74,
    );
    final innerOrbit = Rect.fromCenter(
      center: center,
      width: size.width * 0.62,
      height: size.height * 0.58,
    );

    canvas.drawOval(wideOrbit, orbitPaint);
    canvas.drawOval(innerOrbit, softPaint);
    canvas.drawArc(
      wideOrbit,
      progress * math.pi * 2,
      math.pi * 0.28,
      false,
      arcPaint,
    );

    final starPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _ArcanaColors.gold2.withValues(alpha: 0.44);
    for (var index = 0; index < 6; index += 1) {
      final angle = progress * math.pi * 2 + index * math.pi / 3;
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * size.width * 0.41,
          center.dy + math.sin(angle) * size.height * 0.37,
        ),
        index.isEven ? 1.4 : 0.9,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DailyDeckOrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _DailyRitualConstellation extends StatelessWidget {
  const _DailyRitualConstellation();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('daily-ritual-constellation'),
      height: 86,
      child: CustomPaint(painter: _DailyRitualConstellationPainter()),
    );
  }
}

class _DailyRitualConstellationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(size.width * 0.26, size.height * 0.28),
      Offset(size.width * 0.42, size.height * 0.54),
      Offset(size.width * 0.58, size.height * 0.32),
      Offset(size.width * 0.74, size.height * 0.62),
    ];
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _ArcanaColors.gold.withValues(alpha: 0.16);
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _ArcanaColors.gold2.withValues(alpha: 0.48);

    for (var index = 0; index < points.length - 1; index += 1) {
      canvas.drawLine(points[index], points[index + 1], linePaint);
    }
    for (final point in points) {
      canvas.drawCircle(point, 1.6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
