part of '../../main.dart';

class ReadingResultScreen extends ConsumerStatefulWidget {
  const ReadingResultScreen({super.key});

  @override
  ConsumerState<ReadingResultScreen> createState() =>
      _ReadingResultScreenState();
}

class _ReadingResultScreenState extends ConsumerState<ReadingResultScreen> {
  bool? _historySavedOverride;
  bool? _historySavingTarget;
  bool _saving = false;

  Future<void> _setReadingSaved(
    DeepReadingController? controller,
    DeepReading? reading,
    bool isSavedForHistory,
  ) async {
    if (controller == null || reading == null) {
      setState(() => _historySavedOverride = isSavedForHistory);
      return;
    }

    setState(() {
      _saving = true;
      _historySavingTarget = isSavedForHistory;
    });
    await controller.updateHistoryVisibility(isSavedForHistory);
    if (mounted) {
      setState(() {
        _historySavedOverride = controller.state.isResultSavedForHistory;
        _saving = false;
        _historySavingTarget = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.watch(deepReadingControllerProvider).asData?.value;
    final reading = controller?.state.reading;
    final resultCards = reading?.selectedCards ?? _fallbackResultCards;
    final isSaved =
        _historySavedOverride ??
        (controller?.state.isResultSavedForHistory ??
            reading?.isSavedForHistory ??
            false);
    final savingLabel = _historySavingTarget == false
        ? l10n.resultClearing
        : l10n.resultSaving;

    return _DeepReadingBackScope(
      child: AppBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _RoundBackButton(
                      onPressed: () => context.go('/divination'),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const EyebrowText('Reading result'),
                          const SizedBox(height: 5),
                          Text(
                            l10n.resultTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (
                      var index = 0;
                      index < resultCards.length;
                      index++
                    ) ...[
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final cards = ref.watch(tarotCardsProvider).asData?.value ?? const [];
                            final cardDraw = resultCards[index];
                            final card = _findCardById(cards, cardDraw.cardId);
                            final cardName = card == null
                                ? _cardNameFallback(cardDraw.cardId, l10n)
                                : _primaryCardName(card, l10n);
                            final orientation = _orientationLabel(cardDraw.orientation, l10n);
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: EyebrowText(
                                    _usesChineseCardText(l10n)
                                        ? cardDraw.positionLabel
                                        : _selectedPositionLabel(cardDraw, l10n),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TarotImageCard(
                                  imagePath: _imageForCardId(cardDraw.cardId),
                                  height: 178,
                                  radius: 12,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cardName,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: _ArcanaColors.ivory,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _usesChineseCardText(l10n) ? orientation : '($orientation)',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color: _ArcanaColors.gold2,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (index != resultCards.length - 1)
                        const SizedBox(width: 10),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                GlassPanel(child: _resultBody(context, reading)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => context.go('/divination'),
                          child: Text(l10n.resultBackToReading),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ArcanaPrimaryButton(
                        tone: isSaved
                            ? ArcanaPrimaryButtonTone.danger
                            : ArcanaPrimaryButtonTone.gold,
                        onPressed: _saving
                            ? null
                            : () => _setReadingSaved(
                                controller,
                                reading,
                                !isSaved,
                              ),
                        child: Text(
                          _saving
                              ? savingLabel
                              : (isSaved ? l10n.resultClear : l10n.resultSave),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultBody(BuildContext context, DeepReading? reading) {
    final l10n = AppLocalizations.of(context)!;
    if (reading != null) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.resultQuestionTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            reading.question.isEmpty ? l10n.resultNoQuestion : reading.question,
          ),
          const _ArcanaSectionDivider(),
          Text(
            l10n.resultCardsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(reading.summary),
          const _ArcanaSectionDivider(),
          for (var i = 0; i < sections.length; i++) ...[
            SafeMarkdownBody(data: sections[i]),
            if (i < sections.length - 1) const _ArcanaSectionDivider(),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.resultQuestionTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(l10n.fallbackResultQuestion),
        const _ArcanaSectionDivider(),
        Text(
          l10n.resultCardsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        _VisualBulletText(l10n.fallbackResultBulletMoon),
        _VisualBulletText(l10n.fallbackResultBulletTemperance),
        _VisualBulletText(l10n.fallbackResultBulletStar),
        const _ArcanaSectionDivider(),
        Text(
          l10n.fallbackResultAdviceTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(l10n.fallbackResultAdvice),
      ],
    );
  }
}

class _DeepReadingBackScope extends StatelessWidget {
  const _DeepReadingBackScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !context.mounted) {
          return;
        }
        context.go('/divination');
      },
      child: child,
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back),
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        foregroundColor: _ArcanaColors.ivory,
        backgroundColor: _ArcanaColors.ink2.withValues(alpha: 0.7),
        side: BorderSide(color: _ArcanaColors.gold.withValues(alpha: 0.25)),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: ColoredBox(
        color: Colors.white.withValues(alpha: 0.08),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0, 1),
            child: const SizedBox(
              height: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_ArcanaColors.gold2, _ArcanaColors.peacock],
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

class _VisualDrawCard extends StatelessWidget {
  const _VisualDrawCard({
    super.key,
    required this.imagePath,
    required this.selected,
    required this.selectedOrder,
    required this.onTap,
  });

  final String imagePath;
  final bool selected;
  final int selectedOrder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                return FadeTransition(
                  opacity: curved,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
                    child: child,
                  ),
                );
              },
              child: selected
                  ? Image.asset(
                      imagePath,
                      key: ValueKey('front-$imagePath'),
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/card-back.png',
                      key: const ValueKey('card-back'),
                      fit: BoxFit.cover,
                    ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? _ArcanaColors.gold2
                      : _ArcanaColors.gold2.withValues(alpha: 0.42),
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _ArcanaColors.gold2.withValues(alpha: 0.18),
                          blurRadius: 18,
                        ),
                      ]
                    : null,
              ),
            ),
            if (selected)
              Positioned(
                top: 7,
                right: 7,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _ArcanaColors.gold2,
                    border: Border.all(color: _ArcanaColors.ink2),
                  ),
                  child: SizedBox.square(
                    dimension: 24,
                    child: Center(
                      child: Text(
                        '$selectedOrder',
                        style: _bodyTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: _ArcanaColors.ink2,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VisualBulletText extends StatelessWidget {
  const _VisualBulletText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

const _fallbackDrawCardIds = [
  'major-18-moon',
  'major-14-temperance',
  'major-17-star',
  'cups-02-two',
  'swords-06-six',
  'major-16-tower',
  'major-00-fool',
  'major-11-justice',
  'major-09-hermit',
];

final _fallbackDrawCardDraws = [
  for (final cardId in _fallbackDrawCardIds)
    CardDraw(cardId: cardId, orientation: 'upright'),
];

const _fallbackResultCards = [
  SelectedReadingCard(
    position: 'core',
    positionLabel: '問題核心',
    cardId: 'major-18-moon',
    orientation: 'reversed',
  ),
  SelectedReadingCard(
    position: 'hiddenInfluence',
    positionLabel: '隱藏影響',
    cardId: 'major-14-temperance',
    orientation: 'upright',
  ),
  SelectedReadingCard(
    position: 'advice',
    positionLabel: '行動建議',
    cardId: 'major-17-star',
    orientation: 'upright',
  ),
];
