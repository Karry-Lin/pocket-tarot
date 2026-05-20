import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pocket_tarot/domain/models/tarot_card.dart';

class TarotCatalogRepository {
  const TarotCatalogRepository(this._assetBundle);

  final AssetBundle _assetBundle;

  Future<List<TarotCard>> loadCards() async {
    final source = await _assetBundle.loadString('assets/data/tarot_cards.json');
    final json = jsonDecode(source) as Map<String, Object?>;
    final cards = (json['cards']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map(TarotCard.fromJson)
        .toList(growable: false);

    return cards;
  }

  List<TarotCard> filterByCategory(List<TarotCard> cards, TarotCategory category) {
    if (category == TarotCategory.all) {
      return cards;
    }

    return cards.where((card) => card.category == category).toList(growable: false);
  }

  List<TarotCard> search(List<TarotCard> cards, String query) {
    return cards.where((card) => card.matches(query)).toList(growable: false);
  }
}
