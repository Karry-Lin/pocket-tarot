import 'package:pocket_tarot/domain/models/local_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSettingsRepository {
  const LocalSettingsRepository(this._preferences);

  static const _localeModeKey = 'localeMode';
  static const _weatherEnabledKey = 'weatherEnabled';

  final SharedPreferences _preferences;

  Future<LocalSettings> load() async {
    return LocalSettings(
      localeMode: LocaleMode.fromStorageValue(_preferences.getString(_localeModeKey)),
      weatherEnabled: _preferences.getBool(_weatherEnabledKey) ?? true,
    );
  }

  Future<void> save(LocalSettings settings) async {
    await Future.wait([
      _preferences.setString(_localeModeKey, settings.localeMode.storageValue),
      _preferences.setBool(_weatherEnabledKey, settings.weatherEnabled),
    ]);
  }
}
