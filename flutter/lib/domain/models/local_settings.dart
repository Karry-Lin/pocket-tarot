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
  });

  final LocaleMode localeMode;
  final bool weatherEnabled;
}
