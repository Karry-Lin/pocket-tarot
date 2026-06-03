part of '../../main.dart';

class DivinationScreen extends ConsumerStatefulWidget {
  const DivinationScreen({super.key});

  @override
  ConsumerState<DivinationScreen> createState() => _DivinationScreenState();
}

class _DivinationScreenState extends ConsumerState<DivinationScreen> {
  final TextEditingController _questionController = TextEditingController();
  DeepReadingState _deepState = const DeepReadingState.initial();
  RouteInformationProvider? _routeInformationProvider;
  String? _lastPath;

  @override
  void initState() {
    super.initState();
    _questionController.addListener(_onQuestionChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
      if (mounted) {
        _routeInformationProvider = GoRouter.of(context).routeInformationProvider;
        _lastPath = _routeInformationProvider?.value.uri.path;
        _routeInformationProvider?.addListener(_onRouteChanged);
      }
    });
  }

  @override
  void dispose() {
    _questionController.removeListener(_onQuestionChanged);
    _questionController.dispose();
    _routeInformationProvider?.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (!mounted) return;
    final currentPath = _routeInformationProvider?.value.uri.path;
    if (currentPath == '/divination' && _lastPath != '/divination') {
      _loadHistory();
    }
    _lastPath = currentPath;
  }

  void _onQuestionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _openDrawRoute() {
    final questionText = _questionController.text.trim();
    if (questionText.isEmpty) {
      return;
    }
    final question = Uri.encodeComponent(questionText);
    _questionController.clear();
    context.push<void>('/draw?question=$question');
  }

  Future<void> _loadHistory() async {
    final controller = await ref.read(deepReadingControllerProvider.future);
    final historyFuture = controller.loadHistory();
    if (mounted) {
      setState(() => _deepState = controller.state);
    }
    await historyFuture;
    if (mounted) {
      setState(() => _deepState = controller.state);
    }
  }

  Future<void> _handleRefresh() async {
    _questionController.clear();
    await _loadHistory();
  }

  Future<void> _openHistoryReading(String id) async {
    final controller = await ref.read(deepReadingControllerProvider.future);
    await controller.loadSavedReading(id);
    if (mounted) {
      setState(() => _deepState = controller.state);
      if (controller.state.reading != null) {
        await context.push<void>('/result');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerAsync = ref.watch(deepReadingControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final usesChinese = _usesChineseCardText(l10n);

    return ScreenFrame(
      title: l10n.divinationTitle,
      eyebrow: 'Reading room',
      trailing: null,
      onRefresh: _handleRefresh,
      child: controllerAsync.when(
        loading: () => _AppLoadingIndicator(
          message: usesChinese ? '正在連結占卜房...' : 'Connecting to reading room...',
        ),
        error: (error, stackTrace) => InfoPanel(
          title: l10n.divinationLoadFailed,
          child: Text(error.toString()),
        ),
        data: (_) => _deepContent(context),
      ),
    );
  }

  Widget _deepContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usesChinese = _usesChineseCardText(l10n);
    final canStartDraft = _questionController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          ornate: true,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EyebrowText(usesChinese ? '占卜入口' : 'Reading entry'),
                  const SizedBox(height: 8),
                  Text(
                    usesChinese
                        ? '把問題放進星盤。'
                        : 'Place your question on the table.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    usesChinese
                        ? '輸入正在面對的情境，或選擇一個常見主題，進入三張牌陣。'
                        : 'Describe the situation or choose a theme before entering the three-card spread.',
                  ),
                  const SizedBox(height: 16),
                  Text(usesChinese ? '你想問什麼？' : l10n.questionLabel),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 108,
                    child: TextField(
                      controller: _questionController,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _ArcanaColors.ivory,
                      ),
                      decoration: InputDecoration(
                        hintText: usesChinese
                            ? '例如：這段關係裡，我需要看見什麼？'
                            : 'Example: What should I notice about this situation?',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final prompt in _questionPrompts(l10n, usesChinese))
                        PromptChip(
                          text: prompt.label,
                          onPressed: () =>
                              _applyQuestionTemplate(prompt.question),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ArcanaPrimaryButton(
                    onPressed: canStartDraft ? _openDrawRoute : null,
                    child: Text(usesChinese ? '進行深度占卜' : 'Begin deep reading'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (_deepState.status == DeepReadingStatus.error &&
            _deepState.errorMessage != null) ...[
          InfoPanel(
            title: l10n.historyTitle,
            child: Text(_deepState.errorMessage!),
          ),
          const SizedBox(height: 18),
        ],
        DeepHistoryPanel(
          state: _deepState,
          onLoadHistory: _loadHistory,
          onOpenHistory: _openHistoryReading,
        ),
      ],
    );
  }

  void _applyQuestionTemplate(String question) {
    _questionController.text = question;
    _questionController.selection = TextSelection.collapsed(
      offset: question.length,
    );
  }
}

class _QuestionPrompt {
  const _QuestionPrompt({required this.label, required this.question});

  final String label;
  final String question;
}

List<_QuestionPrompt> _questionPrompts(
  AppLocalizations l10n,
  bool usesChinese,
) {
  if (usesChinese) {
    return const [
      _QuestionPrompt(label: '感情迷茫', question: '這段關係裡，我需要看見什麼，才能更清楚地面對自己的感受？'),
      _QuestionPrompt(
        label: '職場抉擇',
        question: '面對目前的職場選擇，我該如何判斷下一步才不會偏離自己的方向？',
      ),
      _QuestionPrompt(label: '自我探索', question: '最近反覆出現的內在課題，正在提醒我看見什麼？'),
    ];
  }

  return [
    _QuestionPrompt(
      label: l10n.promptWork,
      question: 'What should I consider before choosing my next step at work?',
    ),
    _QuestionPrompt(
      label: l10n.promptLove,
      question:
          'What should I understand about this relationship before I respond?',
    ),
    _QuestionPrompt(
      label: l10n.promptNextStep,
      question: 'What is the next honest step I can take from here?',
    ),
  ];
}
