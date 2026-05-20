enum TarotCategory { all, major, wands, cups, swords, pentacles }

class TarotCard {
  const TarotCard({
    required this.id,
    required this.category,
    required this.zhName,
    required this.enName,
    required this.uprightMeaning,
    required this.reversedMeaning,
    required this.keywords,
  });

  final String id;
  final TarotCategory category;
  final String zhName;
  final String enName;
  final String uprightMeaning;
  final String reversedMeaning;
  final List<String> keywords;

  factory TarotCard.fromJson(Map<String, Object?> json) {
    return TarotCard(
      id: json['id']! as String,
      category: _categoryFromJson(json['category']! as String),
      zhName: json['zhName']! as String,
      enName: json['enName']! as String,
      uprightMeaning: json['uprightMeaning']! as String,
      reversedMeaning: json['reversedMeaning']! as String,
      keywords: (json['keywords']! as List<Object?>).cast<String>(),
    );
  }

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }

    return [
      id,
      zhName,
      enName,
      uprightMeaning,
      reversedMeaning,
      ...keywords,
    ].any((value) => value.toLowerCase().contains(normalized));
  }
}

TarotCategory _categoryFromJson(String value) {
  return switch (value) {
    'major' => TarotCategory.major,
    'wands' => TarotCategory.wands,
    'cups' => TarotCategory.cups,
    'swords' => TarotCategory.swords,
    'pentacles' => TarotCategory.pentacles,
    _ => throw FormatException('Unknown tarot category: $value'),
  };
}
