part of '../../main.dart';

class DrawScreen extends ConsumerStatefulWidget {
  const DrawScreen({super.key, this.initialQuestion = ''});

  final String initialQuestion;

  @override
  ConsumerState<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends ConsumerState<DrawScreen> {
  DeepReadingState _deepState = const DeepReadingState.initial();
  bool _isDraftLoading = true;
  bool _isCreatingResult = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDraft());
  }

  Future<void> _loadDraft() async {
    setState(() {
      _isDraftLoading = true;
      _errorMessage = null;
    });

    final controller = await ref.read(deepReadingControllerProvider.future);
    await controller.startDraft(widget.initialQuestion);
    if (!mounted) {
      return;
    }

    setState(() {
      _deepState = controller.state;
      _isDraftLoading = false;
      _errorMessage = controller.state.status == DeepReadingStatus.error
          ? controller.state.errorMessage
          : null;
    });
  }

  Future<void> _toggleCard(int index) async {
    if (_deepState.selectedIndexes.contains(index) ||
        _deepState.selectedIndexes.length >= 3) {
      return;
    }

    final controller = await ref.read(deepReadingControllerProvider.future);
    controller.toggleSelection(index);
    if (mounted) {
      setState(() => _deepState = controller.state);
    }
  }

  Future<void> _showResult() async {
    if (_deepState.selectedIndexes.length != 3) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final controller = await ref.read(deepReadingControllerProvider.future);
    setState(() {
      _isCreatingResult = true;
      _errorMessage = null;
    });

    await controller.createResult(
      messages: DeepReadingMessages(
        selectExactlyThreeCards: l10n.deepSelectExactlyThreeCards,
        noSavableResult: l10n.deepNoSavableResult,
      ),
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _deepState = controller.state;
      _isCreatingResult = false;
      _errorMessage = controller.state.status == DeepReadingStatus.error
          ? controller.state.errorMessage
          : null;
    });
    if (controller.state.status == DeepReadingStatus.resultReady) {
      await context.push<void>('/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndexes = _deepState.selectedIndexes;
    final selectedCount = selectedIndexes.length;
    final l10n = AppLocalizations.of(context)!;
    final drawCards = _deepState.draftCards.isEmpty
        ? _fallbackDrawCardDraws
        : _deepState.draftCards;

    if (_isCreatingResult) {
      return _DeepReadingBackScope(
        child: AppBackdrop(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 34),
              child: Center(
                child: ArcanaLoadingView(
                  title: l10n.deepLoadingTitle,
                  message: l10n.deepLoadingMessage,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_isDraftLoading) {
      return _DeepReadingBackScope(
        child: AppBackdrop(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 34),
              child: Center(
                child: ArcanaLoadingView(
                  title: l10n.drawPreparingTitle,
                  message: l10n.drawPreparingMessage,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return _DeepReadingBackScope(
      child: AppBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 34),
            child: LayoutBuilder(
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _RoundBackButton(
                          onPressed: () => context.go('/divination'),
                        ),
                        const SizedBox(width: 12),
                        const EyebrowText('Choose three'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.drawTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    _ProgressLine(progress: selectedCount / 3),
                    const SizedBox(height: 8),
                    Text(
                      l10n.drawSelectedStatus(selectedCount),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: _bodyTextStyle(color: _ArcanaColors.error),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, gridConstraints) {
                          const spacing = 8.0;
                          final tileWidth =
                              (gridConstraints.maxWidth - spacing * 2) / 3;
                          final tileHeight =
                              (gridConstraints.maxHeight - spacing * 2) / 3;
                          final aspectRatio = tileWidth / tileHeight;

                          return GridView.builder(
                            key: const ValueKey('visual-draw-grid'),
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: aspectRatio,
                                  crossAxisSpacing: spacing,
                                  mainAxisSpacing: spacing,
                                ),
                            itemCount: drawCards.length,
                            itemBuilder: (context, index) {
                              final card = drawCards[index];
                              final selectedOrder =
                                  selectedIndexes.indexOf(index) + 1;
                              return _VisualDrawCard(
                                key: ValueKey('draw-card-$index'),
                                imagePath: _imageForCardId(card.cardId),
                                selected: selectedIndexes.contains(index),
                                selectedOrder: selectedOrder,
                                onTap: () => _toggleCard(index),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    ArcanaPrimaryButton(
                      onPressed: selectedCount == 3 ? _showResult : null,
                      child: Text(l10n.drawReadButton),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
