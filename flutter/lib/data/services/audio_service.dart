import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_tarot/app/app_providers.dart';
import 'package:pocket_tarot/domain/models/local_settings.dart';

class AudioService {
  AudioService(this._ref) {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _bgmPlayer.setVolume(0.18);

    _magicPlayer.setReleaseMode(ReleaseMode.loop);
    _magicPlayer.setVolume(0.14);

    // 非同步載入初始設定
    _ref.read(localSettingsRepositoryProvider.future).then((repository) async {
      final settings = await repository.load();
      updateCachedSettings(settings);
    }).catchError((e) {
      debugPrint('AudioService load initial settings error: $e');
    });
  }

  final Ref _ref;
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _magicPlayer = AudioPlayer();

  LocalSettings _cachedSettings = const LocalSettings(
    localeMode: LocaleMode.system,
    weatherEnabled: true,
    bgmEnabled: true,
    sfxEnabled: true,
  );

  bool _isBgmPlaying = false;
  bool _isMagicPlaying = false;

  void updateCachedSettings(LocalSettings settings) {
    _cachedSettings = settings;
    if (!settings.bgmEnabled && _isBgmPlaying) {
      _bgmPlayer.stop().catchError((_) {});
    } else if (settings.bgmEnabled && _isBgmPlaying) {
      _bgmPlayer.play(AssetSource('audio/bgm.mp3')).catchError((_) {});
    }
  }

  Future<void> playBgm() async {
    _isBgmPlaying = true;

    if (!_cachedSettings.bgmEnabled) {
      return;
    }

    try {
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
    } catch (e) {
      debugPrint('AudioService playBgm error: $e');
    }
  }

  Future<void> stopBgm() async {
    _isBgmPlaying = false;
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('AudioService stopBgm error: $e');
    }
  }

  Future<void> updateBgmState(bool enabled) async {
    if (enabled) {
      if (_isBgmPlaying) {
        try {
          await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
        } catch (_) {}
      } else {
        await playBgm();
      }
    } else {
      try {
        await _bgmPlayer.stop();
      } catch (_) {}
    }
  }

  Future<void> playCardDraw() async {
    if (!_cachedSettings.sfxEnabled) {
      return;
    }

    try {
      final player = AudioPlayer();
      player.setVolume(0.55);
      await player.play(AssetSource('audio/card_draw.mp3'));
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      debugPrint('AudioService playCardDraw error: $e');
    }
  }

  Future<void> playLoadingMagic() async {
    if (_isMagicPlaying) {
      return;
    }
    _isMagicPlaying = true;

    if (!_cachedSettings.sfxEnabled) {
      return;
    }

    try {
      await _magicPlayer.play(AssetSource('audio/magic_loading.mp3'));
    } catch (e) {
      debugPrint('AudioService playLoadingMagic error: $e');
    }
  }

  Future<void> stopLoadingMagic() async {
    _isMagicPlaying = false;
    try {
      await _magicPlayer.stop();
    } catch (e) {
      debugPrint('AudioService stopLoadingMagic error: $e');
    }
  }

  void dispose() {
    _bgmPlayer.dispose();
    _magicPlayer.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService(ref);
  
  ref.listen(localSettingsRepositoryProvider, (previous, next) {
    next.whenData((repository) async {
      try {
        final settings = await repository.load();
        service.updateCachedSettings(settings);
      } catch (_) {}
    });
  });

  ref.onDispose(() => service.dispose());
  return service;
});
