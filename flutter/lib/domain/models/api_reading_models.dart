class CardDraw {
  const CardDraw({
    required this.cardId,
    required this.orientation,
  });

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
  });

  final String id;
  final String localDate;
  final CardDraw card;
  final String markdownResult;
  final String summary;
  final String resultLocale;
  final DateTime createdAt;

  factory DailyReading.fromJson(Map<String, Object?> json) {
    return DailyReading(
      id: json['id']! as String,
      localDate: json['localDate']! as String,
      card: CardDraw.fromJson((json['card']! as Map).cast<String, Object?>()),
      markdownResult: json['markdownResult']! as String,
      summary: json['summary']! as String,
      resultLocale: json['resultLocale']! as String,
      createdAt: DateTime.parse(json['createdAt']! as String),
    );
  }
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
          .map((item) => SelectedReadingCard.fromJson(item.cast<String, Object?>()))
          .toList(growable: false),
      markdownResult: json['markdownResult']! as String,
      summary: json['summary']! as String,
      resultLocale: json['resultLocale']! as String,
      isSavedForHistory: json['isSavedForHistory']! as bool,
      createdAt: DateTime.parse(json['createdAt']! as String),
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
  const HistoryVisibility({
    required this.id,
    required this.isSavedForHistory,
  });

  final String id;
  final bool isSavedForHistory;

  factory HistoryVisibility.fromJson(Map<String, Object?> json) {
    return HistoryVisibility(
      id: json['id']! as String,
      isSavedForHistory: json['isSavedForHistory']! as bool,
    );
  }
}
