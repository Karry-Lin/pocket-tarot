import 'package:pocket_tarot/data/services/api_client.dart';
import 'package:pocket_tarot/domain/models/api_reading_models.dart';

class DailyReadingRepository {
  const DailyReadingRepository(this._apiClient);

  final PocketTarotApiClient _apiClient;

  Future<DailyReading?> fetchToday() async {
    try {
      final json = await _apiClient.getJson('/daily-readings/today');
      return DailyReading.fromJson((json['data']! as Map).cast<String, Object?>());
    } on ApiException catch (error) {
      if (error.code == 'DAILY_READING_NOT_FOUND') {
        return null;
      }

      rethrow;
    }
  }

  Future<DailyReading> createToday({
    required String locale,
    required bool weatherEnabled,
    double? latitude,
    double? longitude,
    bool permissionDenied = false,
  }) async {
    final json = await _apiClient.postJson('/daily-readings/today', {
      'locale': locale,
      'weather': {
        'enabled': weatherEnabled,
        'status': _weatherStatus(weatherEnabled: weatherEnabled, permissionDenied: permissionDenied),
        'latitude': latitude,
        'longitude': longitude,
      },
    });

    return DailyReading.fromJson((json['data']! as Map).cast<String, Object?>());
  }

  String _weatherStatus({required bool weatherEnabled, required bool permissionDenied}) {
    if (!weatherEnabled) {
      return 'disabled';
    }

    if (permissionDenied) {
      return 'permission_denied';
    }

    return 'success';
  }
}
