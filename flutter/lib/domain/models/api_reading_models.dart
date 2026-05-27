class CardDraw {
  const CardDraw({required this.cardId, required this.orientation});

  final String cardId;
  final String orientation;

  factory CardDraw.fromJson(Map<String, Object?> json) {
    return CardDraw(
      cardId: json['cardId']! as String,
      orientation: json['orientation']! as String,
    );
  }

  Map<String, Object?> toJson() => {
    'cardId': cardId,
    'orientation': orientation,
  };
}

class DailyReading {
  const DailyReading({
    required this.id,
    required this.localDate,
    required this.card,
    required this.markdownResult,
    required this.summary,
    required this.resultLocale,
    required this.createdAt,
    this.weather,
    this.dailyStreak,
  });

  final String id;
  final String localDate;
  final CardDraw card;
  final String markdownResult;
  final String summary;
  final String resultLocale;
  final DateTime createdAt;
  final WeatherSnapshot? weather;
  final int? dailyStreak;

  factory DailyReading.fromJson(Map<String, Object?> json) {
    return DailyReading(
      id: json['id']! as String,
      localDate: json['localDate']! as String,
      card: CardDraw.fromJson((json['card']! as Map).cast<String, Object?>()),
      markdownResult: json['markdownResult']! as String,
      summary: json['summary']! as String,
      resultLocale: json['resultLocale']! as String,
      createdAt: DateTime.parse(json['createdAt']! as String),
      weather: json['weather'] is Map
          ? WeatherSnapshot.fromJson(
              (json['weather']! as Map).cast<String, Object?>(),
            )
          : null,
      dailyStreak: json['dailyStreak'] is int
          ? json['dailyStreak']! as int
          : null,
    );
  }
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.enabled,
    required this.status,
    required this.provider,
    required this.latitude,
    required this.longitude,
    this.locationName,
    required this.timezone,
    required this.current,
    required this.errorCode,
  });

  final bool enabled;
  final String status;
  final String? provider;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String timezone;
  final CurrentWeather? current;
  final String? errorCode;

  factory WeatherSnapshot.fromJson(Map<String, Object?> json) {
    return WeatherSnapshot(
      enabled: json['enabled'] == true,
      status: json['status'] as String? ?? 'unavailable',
      provider: json['provider'] as String?,
      latitude: _doubleOrNull(json['latitude']),
      longitude: _doubleOrNull(json['longitude']),
      locationName: json['locationName'] as String?,
      timezone: json['timezone'] as String? ?? 'Asia/Taipei',
      current: json['current'] is Map
          ? CurrentWeather.fromJson(
              (json['current']! as Map).cast<String, Object?>(),
            )
          : null,
      errorCode: json['errorCode'] as String?,
    );
  }
}

class CurrentWeather {
  const CurrentWeather({
    required this.time,
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
  });

  final String? time;
  final double? temperature2m;
  final double? relativeHumidity2m;
  final double? apparentTemperature;
  final double? precipitation;
  final double? weatherCode;
  final double? windSpeed10m;

  factory CurrentWeather.fromJson(Map<String, Object?> json) {
    return CurrentWeather(
      time: json['time'] as String?,
      temperature2m: _doubleOrNull(json['temperature2m']),
      relativeHumidity2m: _doubleOrNull(json['relativeHumidity2m']),
      apparentTemperature: _doubleOrNull(json['apparentTemperature']),
      precipitation: _doubleOrNull(json['precipitation']),
      weatherCode: _doubleOrNull(json['weatherCode']),
      windSpeed10m: _doubleOrNull(json['windSpeed10m']),
    );
  }
}

double? _doubleOrNull(Object? value) {
  return switch (value) {
    double() => value,
    int() => value.toDouble(),
    _ => null,
  };
}

class SelectedReadingCard extends CardDraw {
  const SelectedReadingCard({
    required super.cardId,
    required super.orientation,
    required this.position,
    required this.positionLabel,
  });

  final String position;
  final String positionLabel;

  factory SelectedReadingCard.fromJson(Map<String, Object?> json) {
    return SelectedReadingCard(
      position: json['position']! as String,
      positionLabel: json['positionLabel']! as String,
      cardId: json['cardId']! as String,
      orientation: json['orientation']! as String,
    );
  }
}

class DeepReading {
  const DeepReading({
    required this.id,
    required this.question,
    required this.selectedCards,
    required this.markdownResult,
    required this.summary,
    required this.resultLocale,
    required this.isSavedForHistory,
    required this.createdAt,
  });

  final String id;
  final String question;
  final List<SelectedReadingCard> selectedCards;
  final String markdownResult;
  final String summary;
  final String resultLocale;
  final bool isSavedForHistory;
  final DateTime createdAt;

  factory DeepReading.fromJson(Map<String, Object?> json) {
    return DeepReading(
      id: json['id']! as String,
      question: json['question']! as String,
      selectedCards: (json['selectedCards']! as List<Object?>)
          .cast<Map<Object?, Object?>>()
          .map(
            (item) =>
                SelectedReadingCard.fromJson(item.cast<String, Object?>()),
          )
          .toList(growable: false),
      markdownResult: json['markdownResult']! as String,
      summary: json['summary']! as String,
      resultLocale: json['resultLocale']! as String,
      isSavedForHistory: json['isSavedForHistory']! as bool,
      createdAt: DateTime.parse(json['createdAt']! as String),
    );
  }

  DeepReading copyWith({
    String? id,
    String? question,
    List<SelectedReadingCard>? selectedCards,
    String? markdownResult,
    String? summary,
    String? resultLocale,
    bool? isSavedForHistory,
    DateTime? createdAt,
  }) {
    return DeepReading(
      id: id ?? this.id,
      question: question ?? this.question,
      selectedCards: selectedCards ?? this.selectedCards,
      markdownResult: markdownResult ?? this.markdownResult,
      summary: summary ?? this.summary,
      resultLocale: resultLocale ?? this.resultLocale,
      isSavedForHistory: isSavedForHistory ?? this.isSavedForHistory,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DeepReadingHistoryItem {
  const DeepReadingHistoryItem({
    required this.id,
    required this.question,
    required this.summary,
    required this.resultLocale,
    required this.createdAt,
  });

  final String id;
  final String question;
  final String summary;
  final String resultLocale;
  final DateTime createdAt;

  factory DeepReadingHistoryItem.fromJson(Map<String, Object?> json) {
    return DeepReadingHistoryItem(
      id: json['id']! as String,
      question: json['question']! as String,
      summary: json['summary']! as String,
      resultLocale: json['resultLocale']! as String,
      createdAt: DateTime.parse(json['createdAt']! as String),
    );
  }
}

class HistoryVisibility {
  const HistoryVisibility({required this.id, required this.isSavedForHistory});

  final String id;
  final bool isSavedForHistory;

  factory HistoryVisibility.fromJson(Map<String, Object?> json) {
    return HistoryVisibility(
      id: json['id']! as String,
      isSavedForHistory: json['isSavedForHistory']! as bool,
    );
  }
}
