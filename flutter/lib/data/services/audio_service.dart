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
  }

  final Ref _ref;
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _magicPlayer = AudioPlayer();

  bool _isBgmPlaying = false;
  bool _isMagicPlaying = false;

  Future<void> playBgm() async {
    _isBgmPlaying = true;

    final settings = await _loadSettings();
    if (!settings.bgmEnabled) {
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
    final settings = await _loadSettings();
    if (!settings.sfxEnabled) {
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

    final settings = await _loadSettings();
    if (!settings.sfxEnabled) {
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

  Future<LocalSettings> _loadSettings() async {
    try {
      final repository = await _ref.read(localSettingsRepositoryProvider.future);
      return await repository.load();
    } catch (_) {
      return const LocalSettings(
        localeMode: LocaleMode.system,
        weatherEnabled: true,
      );
    }
  }

  void dispose() {
    _bgmPlayer.dispose();
    _magicPlayer.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
