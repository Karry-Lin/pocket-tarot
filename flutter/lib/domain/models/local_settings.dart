enum LocaleMode {
  system,
  zhTw,
  en;

  String get storageValue {
    return switch (this) {
      LocaleMode.system => 'system',
      LocaleMode.zhTw => 'zh-TW',
      LocaleMode.en => 'en',
    };
  }

  static LocaleMode fromStorageValue(String? value) {
    return switch (value) {
      'zh-TW' => LocaleMode.zhTw,
      'en' => LocaleMode.en,
      _ => LocaleMode.system,
    };
  }
}

class LocalSettings {
  const LocalSettings({
    required this.localeMode,
    required this.weatherEnabled,
    this.bgmEnabled = true,
    this.sfxEnabled = true,
  });

  final LocaleMode localeMode;
  final bool weatherEnabled;
  final bool bgmEnabled;
  final bool sfxEnabled;

  LocalSettings copyWith({
    LocaleMode? localeMode,
    bool? weatherEnabled,
    bool? bgmEnabled,
    bool? sfxEnabled,
  }) {
    return LocalSettings(
      localeMode: localeMode ?? this.localeMode,
      weatherEnabled: weatherEnabled ?? this.weatherEnabled,
      bgmEnabled: bgmEnabled ?? this.bgmEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
    );
  }
}
