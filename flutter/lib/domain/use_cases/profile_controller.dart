import 'package:pocket_tarot/domain/models/local_settings.dart';
import 'package:pocket_tarot/domain/models/profile_models.dart';

typedef ProfileFetcher = Future<ProfileSnapshot> Function();
typedef DisplayNameUpdater = Future<UserProfile> Function(String displayName);
typedef ProfileSettingsLoader = Future<LocalSettings> Function();
typedef ProfileSettingsSaver = Future<void> Function(LocalSettings settings);
typedef ProfileSignOut = Future<void> Function();

class ProfileValidationMessages {
  const ProfileValidationMessages({required this.displayNameInvalid});

  const ProfileValidationMessages.zhTw()
    : displayNameInvalid = '暱稱長度必須為 1-16 字';

  final String displayNameInvalid;
}

enum ProfileStatus {
  initial,
  loading,
  loaded,
  saving,
  signingOut,
  signedOut,
  error,
}

class ProfileState {
  const ProfileState({
    required this.status,
    this.snapshot,
    this.settings,
    this.errorMessage,
  });

  const ProfileState.initial() : this(status: ProfileStatus.initial);

  final ProfileStatus status;
  final ProfileSnapshot? snapshot;
  final LocalSettings? settings;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileSnapshot? snapshot,
    LocalSettings? settings,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
    );
  }
}

class ProfileController {
  ProfileController({
    required ProfileFetcher fetchProfile,
    required DisplayNameUpdater updateDisplayName,
    required ProfileSettingsLoader loadSettings,
    required ProfileSettingsSaver saveSettings,
    required ProfileSignOut signOut,
    this.onProfileChanged,
  }) : _fetchProfile = fetchProfile,
       _updateDisplayName = updateDisplayName,
       _loadSettings = loadSettings,
       _saveSettings = saveSettings,
       _signOut = signOut;

  final void Function(UserProfile?)? onProfileChanged;

  final ProfileFetcher _fetchProfile;
  final DisplayNameUpdater _updateDisplayName;
  final ProfileSettingsLoader _loadSettings;
  final ProfileSettingsSaver _saveSettings;
  final ProfileSignOut _signOut;

  ProfileState _state = const ProfileState.initial();

  ProfileState get state => _state;

  Future<void> load() async {
    _state = const ProfileState(status: ProfileStatus.loading);

    try {
      final results = await Future.wait<Object>([
        _fetchProfile(),
        _loadSettings(),
      ]);
      final snapshot = results[0] as ProfileSnapshot;
      _state = ProfileState(
        status: ProfileStatus.loaded,
        snapshot: snapshot,
        settings: results[1] as LocalSettings,
      );
      onProfileChanged?.call(snapshot.user);
    } catch (error) {
      _state = ProfileState(
        status: ProfileStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> updateDisplayName(
    String value, {
    ProfileValidationMessages messages = const ProfileValidationMessages.zhTw(),
  }) async {
    final displayName = value.trim();
    if (displayName.isEmpty || displayName.length > 16) {
      _state = _state.copyWith(
        status: ProfileStatus.error,
        errorMessage: messages.displayNameInvalid,
      );
      return;
    }

    _state = _state.copyWith(status: ProfileStatus.saving);

    try {
      final user = await _updateDisplayName(displayName);
      final currentSnapshot = _state.snapshot;
      _state = _state.copyWith(
        status: ProfileStatus.loaded,
        snapshot: currentSnapshot == null
            ? null
            : ProfileSnapshot(user: user, stats: currentSnapshot.stats),
      );
      onProfileChanged?.call(user);
    } catch (error) {
      _state = _state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> setLocaleMode(LocaleMode localeMode) async {
    await _saveLocalSettings(_settingsWith(localeMode: localeMode));
  }

  Future<void> setWeatherEnabled(bool weatherEnabled) async {
    await _saveLocalSettings(_settingsWith(weatherEnabled: weatherEnabled));
  }

  Future<void> setBgmEnabled(bool bgmEnabled) async {
    await _saveLocalSettings(_settingsWith(bgmEnabled: bgmEnabled));
  }

  Future<void> setSfxEnabled(bool sfxEnabled) async {
    await _saveLocalSettings(_settingsWith(sfxEnabled: sfxEnabled));
  }

  Future<void> signOut() async {
    _state = _state.copyWith(status: ProfileStatus.signingOut);

    try {
      await _signOut();
      _state = _state.copyWith(status: ProfileStatus.signedOut);
      onProfileChanged?.call(null);
    } catch (error) {
      _state = _state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  LocalSettings _settingsWith({
    LocaleMode? localeMode,
    bool? weatherEnabled,
    bool? bgmEnabled,
    bool? sfxEnabled,
  }) {
    final settings =
        _state.settings ??
        const LocalSettings(
          localeMode: LocaleMode.system,
          weatherEnabled: true,
        );
    return LocalSettings(
      localeMode: localeMode ?? settings.localeMode,
      weatherEnabled: weatherEnabled ?? settings.weatherEnabled,
      bgmEnabled: bgmEnabled ?? settings.bgmEnabled,
      sfxEnabled: sfxEnabled ?? settings.sfxEnabled,
    );
  }

  Future<void> _saveLocalSettings(LocalSettings settings) async {
    _state = _state.copyWith(status: ProfileStatus.saving);

    try {
      await _saveSettings(settings);
      _state = _state.copyWith(
        status: ProfileStatus.loaded,
        settings: settings,
      );
    } catch (error) {
      _state = _state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error.toString(),
      );
    }
  }
}
