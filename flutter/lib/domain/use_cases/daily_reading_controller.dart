import 'package:pocket_tarot/domain/models/api_reading_models.dart';
import 'package:pocket_tarot/domain/models/local_settings.dart';

typedef DailyReadingFetcher = Future<DailyReading?> Function();
typedef DailyReadingCreator =
    Future<DailyReading> Function(DailyReadingCreateRequest request);
typedef DailyReadingDeleter = Future<void> Function();
typedef LocalSettingsLoader = Future<LocalSettings> Function();
typedef DailyReadingLocationLoader =
    Future<DailyReadingLocationResult> Function();
typedef SystemLocaleCodeLoader = String Function();

enum DailyReadingStatus { initial, loading, empty, creating, loaded, error }

class DailyReadingState {
  const DailyReadingState({
    required this.status,
    this.reading,
    this.errorMessage,
  });

  const DailyReadingState.initial() : this(status: DailyReadingStatus.initial);

  final DailyReadingStatus status;
  final DailyReading? reading;
  final String? errorMessage;
}

class DailyReadingCreateRequest {
  const DailyReadingCreateRequest({
    required this.locale,
    required this.weatherEnabled,
    this.latitude,
    this.longitude,
    this.permissionDenied = false,
  });

  final String locale;
  final bool weatherEnabled;
  final double? latitude;
  final double? longitude;
  final bool permissionDenied;
}

enum DailyReadingLocationStatus { success, permissionDenied }

class DailyReadingLocationResult {
  const DailyReadingLocationResult.success({
    required this.latitude,
    required this.longitude,
  }) : status = DailyReadingLocationStatus.success;

  const DailyReadingLocationResult.permissionDenied()
    : status = DailyReadingLocationStatus.permissionDenied,
      latitude = null,
      longitude = null;

  final DailyReadingLocationStatus status;
  final double? latitude;
  final double? longitude;
}

class DailyReadingController {
  DailyReadingController({
    required DailyReadingFetcher fetchToday,
    required DailyReadingCreator createToday,
    required DailyReadingDeleter deleteToday,
    required LocalSettingsLoader loadSettings,
    required DailyReadingLocationLoader requestLocation,
    required SystemLocaleCodeLoader systemLocaleCode,
  }) : _fetchToday = fetchToday,
       _createToday = createToday,
       _deleteToday = deleteToday,
       _loadSettings = loadSettings,
       _requestLocation = requestLocation,
       _systemLocaleCode = systemLocaleCode;

  final DailyReadingFetcher _fetchToday;
  final DailyReadingCreator _createToday;
  final DailyReadingDeleter _deleteToday;
  final LocalSettingsLoader _loadSettings;
  final DailyReadingLocationLoader _requestLocation;
  final SystemLocaleCodeLoader _systemLocaleCode;

  DailyReadingState _state = const DailyReadingState.initial();

  DailyReadingState get state => _state;

  Future<void> loadToday() async {
    _state = const DailyReadingState(status: DailyReadingStatus.loading);

    try {
      final reading = await _fetchToday();
      _state = reading == null
          ? const DailyReadingState(status: DailyReadingStatus.empty)
          : DailyReadingState(
              status: DailyReadingStatus.loaded,
              reading: reading,
            );
    } catch (error) {
      _state = DailyReadingState(
        status: DailyReadingStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> drawToday() async {
    _state = DailyReadingState(
      status: DailyReadingStatus.creating,
      reading: _state.reading,
    );

    try {
      await _createAndLoadToday();
    } catch (error) {
      _state = DailyReadingState(
        status: DailyReadingStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> redrawToday() async {
    _state = DailyReadingState(
      status: DailyReadingStatus.loading,
      reading: _state.reading,
    );

    try {
      await _deleteToday();
      _state = const DailyReadingState(status: DailyReadingStatus.empty);
    } catch (error) {
      _state = DailyReadingState(
        status: DailyReadingStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> _createAndLoadToday() async {
    final settings = await _loadSettings();
    final request = await _createRequest(settings);
    final reading = await _createToday(request);
    _state = DailyReadingState(
      status: DailyReadingStatus.loaded,
      reading: reading,
    );
  }

  Future<DailyReadingCreateRequest> _createRequest(
    LocalSettings settings,
  ) async {
    final locale = _resolveLocale(settings.localeMode);
    if (!settings.weatherEnabled) {
      return DailyReadingCreateRequest(locale: locale, weatherEnabled: false);
    }

    final location = await _requestLocation();
    return DailyReadingCreateRequest(
      locale: locale,
      weatherEnabled: true,
      latitude: location.latitude,
      longitude: location.longitude,
      permissionDenied:
          location.status == DailyReadingLocationStatus.permissionDenied,
    );
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
