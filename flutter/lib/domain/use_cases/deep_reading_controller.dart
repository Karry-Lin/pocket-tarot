import 'package:pocket_tarot/domain/models/api_reading_models.dart';
import 'package:pocket_tarot/domain/models/local_settings.dart';

typedef DeepDraftCreator = Future<List<CardDraw>> Function();
typedef DeepReadingCreator =
    Future<DeepReading> Function(DeepReadingCreateRequest request);
typedef DeepHistoryFetcher = Future<List<DeepReadingHistoryItem>> Function();
typedef SavedDeepReadingFetcher = Future<DeepReading> Function(String id);
typedef DeepHistoryVisibilitySetter =
    Future<HistoryVisibility> Function({
      required String id,
      required bool isSavedForHistory,
    });
typedef DeepLocalSettingsLoader = Future<LocalSettings> Function();
typedef DeepSystemLocaleCodeLoader = String Function();

class DeepReadingMessages {
  const DeepReadingMessages({
    required this.selectExactlyThreeCards,
    required this.noSavableResult,
  });

  const DeepReadingMessages.zhTw()
    : selectExactlyThreeCards = '必須選擇 3 張牌',
      noSavableResult = '沒有可保存的占卜結果';

  final String selectExactlyThreeCards;
  final String noSavableResult;
}

enum DeepReadingStatus {
  initial,
  drafting,
  draftReady,
  creating,
  resultReady,
  historyLoading,
  historyReady,
  error,
}

class DeepReadingState {
  const DeepReadingState({
    required this.status,
    this.question = '',
    this.draftCards = const [],
    this.selectedIndexes = const [],
    this.reading,
    this.history = const [],
    this.errorMessage,
    this.resultHistorySaved,
  });

  const DeepReadingState.initial() : this(status: DeepReadingStatus.initial);

  final DeepReadingStatus status;
  final String question;
  final List<CardDraw> draftCards;
  final List<int> selectedIndexes;
  final DeepReading? reading;
  final List<DeepReadingHistoryItem> history;
  final String? errorMessage;
  final bool? resultHistorySaved;

  bool get isResultSavedForHistory {
    return resultHistorySaved ?? reading?.isSavedForHistory ?? false;
  }

  DeepReadingState copyWith({
    DeepReadingStatus? status,
    String? question,
    List<CardDraw>? draftCards,
    List<int>? selectedIndexes,
    DeepReading? reading,
    List<DeepReadingHistoryItem>? history,
    String? errorMessage,
    bool? resultHistorySaved,
  }) {
    return DeepReadingState(
      status: status ?? this.status,
      question: question ?? this.question,
      draftCards: draftCards ?? this.draftCards,
      selectedIndexes: selectedIndexes ?? this.selectedIndexes,
      reading: reading ?? this.reading,
      history: history ?? this.history,
      errorMessage: errorMessage,
      resultHistorySaved: resultHistorySaved ?? this.resultHistorySaved,
    );
  }
}

class DeepReadingCreateRequest {
  const DeepReadingCreateRequest({
    required this.locale,
    required this.question,
    required this.draftCards,
    required this.selectedIndexes,
  });

  final String locale;
  final String question;
  final List<CardDraw> draftCards;
  final List<int> selectedIndexes;
}

class DeepReadingController {
  DeepReadingController({
    required DeepDraftCreator createDraft,
    required DeepReadingCreator createReading,
    required DeepHistoryFetcher fetchHistory,
    required SavedDeepReadingFetcher fetchSavedReading,
    required DeepHistoryVisibilitySetter setHistoryVisibility,
    required DeepLocalSettingsLoader loadSettings,
    required DeepSystemLocaleCodeLoader systemLocaleCode,
  }) : _createDraft = createDraft,
       _createReading = createReading,
       _fetchHistory = fetchHistory,
       _fetchSavedReading = fetchSavedReading,
       _setHistoryVisibility = setHistoryVisibility,
       _loadSettings = loadSettings,
       _systemLocaleCode = systemLocaleCode;

  final DeepDraftCreator _createDraft;
  final DeepReadingCreator _createReading;
  final DeepHistoryFetcher _fetchHistory;
  final SavedDeepReadingFetcher _fetchSavedReading;
  final DeepHistoryVisibilitySetter _setHistoryVisibility;
  final DeepLocalSettingsLoader _loadSettings;
  final DeepSystemLocaleCodeLoader _systemLocaleCode;

  DeepReadingState _state = const DeepReadingState.initial();

  DeepReadingState get state => _state;

  Future<void> startDraft(String question) async {
    final normalizedQuestion = _normalizeQuestion(question);
    _state = DeepReadingState(
      status: DeepReadingStatus.drafting,
      question: normalizedQuestion,
    );

    try {
      final draftCards = await _createDraft();
      _state = DeepReadingState(
        status: DeepReadingStatus.draftReady,
        question: normalizedQuestion,
        draftCards: draftCards,
      );
    } catch (error) {
      _state = _state.copyWith(
        status: DeepReadingStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  void toggleSelection(int index) {
    if (index < 0 || index >= _state.draftCards.length) {
      return;
    }

    final selectedIndexes = [..._state.selectedIndexes];
    if (selectedIndexes.contains(index)) {
      selectedIndexes.remove(index);
    } else if (selectedIndexes.length < 3) {
      selectedIndexes.add(index);
    }

    _state = _state.copyWith(selectedIndexes: selectedIndexes);
  }

  Future<void> createResult({
    DeepReadingMessages messages = const DeepReadingMessages.zhTw(),
  }) async {
    if (_state.selectedIndexes.length != 3) {
      _state = _state.copyWith(
        status: DeepReadingStatus.error,
        errorMessage: messages.selectExactlyThreeCards,
      );
      return;
    }

    _state = _state.copyWith(status: DeepReadingStatus.creating);

    try {
      final settings = await _loadSettings();
      final reading = await _createReading(
        DeepReadingCreateRequest(
          locale: _resolveLocale(settings.localeMode),
          question: _state.question,
          draftCards: _state.draftCards,
          selectedIndexes: _state.selectedIndexes,
        ),
      );
      _state = _state.copyWith(
        status: DeepReadingStatus.resultReady,
        reading: reading,
        resultHistorySaved: reading.isSavedForHistory,
      );
    } catch (error) {
      _state = _state.copyWith(
        status: DeepReadingStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadHistory() async {
    _state = _state.copyWith(status: DeepReadingStatus.historyLoading);

    try {
      final history = await _fetchHistory();
      _state = _state.copyWith(
        status: DeepReadingStatus.historyReady,
        history: history,
      );
    } catch (error) {
      _state = _state.copyWith(
        status: DeepReadingStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadSavedReading(String id) async {
    _state = _state.copyWith(status: DeepReadingStatus.historyLoading);

    try {
      final reading = await _fetchSavedReading(id);
      _state = _state.copyWith(
        status: DeepReadingStatus.resultReady,
        reading: reading,
        resultHistorySaved: reading.isSavedForHistory,
      );
    } catch (error) {
      _state = _state.copyWith(
        status: DeepReadingStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> updateHistoryVisibility(
    bool isSavedForHistory, {
    DeepReadingMessages messages = const DeepReadingMessages.zhTw(),
  }) async {
    final reading = _state.reading;
    if (reading == null) {
      _state = _state.copyWith(
        status: DeepReadingStatus.error,
        errorMessage: messages.noSavableResult,
      );
      return;
    }

    try {
      final visibility = await _setHistoryVisibility(
        id: reading.id,
        isSavedForHistory: isSavedForHistory,
      );
      _state = _state.copyWith(
        status: DeepReadingStatus.resultReady,
        resultHistorySaved: visibility.isSavedForHistory,
      );
    } catch (error) {
      _state = _state.copyWith(
        status: DeepReadingStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  String _normalizeQuestion(String value) {
    final trimmed = value.trim();
    return trimmed.length <= 1000 ? trimmed : trimmed.substring(0, 1000);
  }

  String _resolveLocale(LocaleMode localeMode) {
    return switch (localeMode) {
      LocaleMode.zhTw => 'zh-TW',
      LocaleMode.en => 'en',
      LocaleMode.system =>
        _systemLocaleCode().toLowerCase().startsWith('zh') ? 'zh-TW' : 'en',
    };
  }
}
