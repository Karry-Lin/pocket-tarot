import 'package:pocket_tarot/data/services/api_client.dart';
import 'package:pocket_tarot/domain/models/api_reading_models.dart';
import 'package:pocket_tarot/domain/use_cases/deep_reading_controller.dart';

class DeepReadingRepository {
  const DeepReadingRepository(this._apiClient);

  final PocketTarotApiClient _apiClient;

  Future<List<CardDraw>> createDraft() async {
    final json = await _apiClient.postJson('/deep-readings/drafts', {});
    final data = (json['data']! as Map).cast<String, Object?>();
    return (data['draftCards']! as List<Object?>)
        .cast<Map<Object?, Object?>>()
        .map((item) => CardDraw.fromJson(item.cast<String, Object?>()))
        .toList(growable: false);
  }

  Future<DeepReading> createReading({
    required String locale,
    required String question,
    required List<CardDraw> draftCards,
    required List<int> selectedIndexes,
  }) async {
    final json = await _apiClient.postJson('/deep-readings', {
      'locale': locale,
      'question': question,
      'draftCards': draftCards.map((card) => card.toJson()).toList(growable: false),
      'selectedIndexes': selectedIndexes,
    });

    return DeepReading.fromJson((json['data']! as Map).cast<String, Object?>());
  }

  Future<DeepReading> createReadingFromRequest(DeepReadingCreateRequest request) {
    return createReading(
      locale: request.locale,
      question: request.question,
      draftCards: request.draftCards,
      selectedIndexes: request.selectedIndexes,
    );
  }

  Future<List<DeepReadingHistoryItem>> fetchHistory() async {
    final json = await _apiClient.getJson('/deep-readings/history');
    return (json['data']! as List<Object?>)
        .cast<Map<Object?, Object?>>()
        .map((item) => DeepReadingHistoryItem.fromJson(item.cast<String, Object?>()))
        .toList(growable: false);
  }

  Future<DeepReading> fetchById(String id) async {
    final json = await _apiClient.getJson('/deep-readings/$id');
    return DeepReading.fromJson((json['data']! as Map).cast<String, Object?>());
  }

  Future<HistoryVisibility> setHistoryVisibility({
    required String id,
    required bool isSavedForHistory,
  }) async {
    final json = await _apiClient.patchJson('/deep-readings/$id/history-visibility', {
      'isSavedForHistory': isSavedForHistory,
    });

    return HistoryVisibility.fromJson((json['data']! as Map).cast<String, Object?>());
  }
}
