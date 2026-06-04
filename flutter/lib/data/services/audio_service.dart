import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_tarot/app/app_providers.dart';
import 'package:pocket_tarot/domain/models/local_settings.dart';

class AudioService {
  AudioService(this._ref) {
    debugPrint('AudioService: Initializing...');
    
    // 設定 Global AudioContext
    AudioPlayer.global.setAudioContext(
      AudioContextConfig(
        focus: AudioContextConfigFocus.mixWithOthers,
        respectSilence: false,
        stayAwake: true,
      ).build(),
    ).then((_) {
      debugPrint('AudioService: Global audio context configured successfully');
    }).catchError((e) {
      debugPrint('AudioService: Global audio context configuration error: $e');
    });

    _bgmPlayer.onLog.listen((log) => debugPrint('BGM PLAYER LOG: $log'));
    _magicPlayer.onLog.listen((log) => debugPrint('MAGIC PLAYER LOG: $log'));
    _sfxPlayer.onLog.listen((log) => debugPrint('SFX PLAYER LOG: $log'));

    _bgmPlayer.setReleaseMode(ReleaseMode.loop).then((_) {
      debugPrint('AudioService: _bgmPlayer loop mode set');
    }).catchError((e) {
      debugPrint('AudioService: _bgmPlayer setReleaseMode error: $e');
    });

    _bgmPlayer.setVolume(0.7).then((_) {
      debugPrint('AudioService: _bgmPlayer volume set to 0.7');
    }).catchError((e) {
      debugPrint('AudioService: _bgmPlayer setVolume error: $e');
    });

    _magicPlayer.setReleaseMode(ReleaseMode.loop).then((_) {
      debugPrint('AudioService: _magicPlayer loop mode set');
    }).catchError((e) {
      debugPrint('AudioService: _magicPlayer setReleaseMode error: $e');
    });

    _magicPlayer.setVolume(1.0).then((_) {
      debugPrint('AudioService: _magicPlayer volume set to 1.0');
    }).catchError((e) {
      debugPrint('AudioService: _magicPlayer setVolume error: $e');
    });

    _sfxPlayer.setVolume(1.0).then((_) {
      debugPrint('AudioService: _sfxPlayer volume set to 1.0');
    }).catchError((e) {
      debugPrint('AudioService: _sfxPlayer setVolume error: $e');
    });

    // 非同步載入初始設定
    _ref.read(localSettingsRepositoryProvider.future).then((repository) async {
      final settings = await repository.load();
      debugPrint('AudioService: Loaded initial settings: bgmEnabled=${settings.bgmEnabled}, sfxEnabled=${settings.sfxEnabled}');
      updateCachedSettings(settings);
    }).catchError((e) {
      debugPrint('AudioService load initial settings error: $e');
    });
  }

  final Ref _ref;
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _magicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  LocalSettings _cachedSettings = const LocalSettings(
    localeMode: LocaleMode.system,
    weatherEnabled: true,
    bgmEnabled: true,
    sfxEnabled: true,
  );

  bool _isBgmPlaying = false;
  bool _isMagicPlaying = false;

  void updateCachedSettings(LocalSettings settings) {
    debugPrint('AudioService: updateCachedSettings: bgmEnabled=${settings.bgmEnabled}, sfxEnabled=${settings.sfxEnabled}, _isBgmPlaying=$_isBgmPlaying');
    _cachedSettings = settings;
    if (!settings.bgmEnabled) {
      if (_isBgmPlaying) {
        debugPrint('AudioService: Stop BGM because bgmEnabled is false');
        _bgmPlayer.stop().catchError((e) {
          debugPrint('AudioService: Stop BGM error in updateCachedSettings: $e');
        });
      }
    } else if (settings.bgmEnabled && _isBgmPlaying) {
      if (_bgmPlayer.state != PlayerState.playing) {
        debugPrint('AudioService: Resume BGM because bgmEnabled is true and _isBgmPlaying is true');
        _bgmPlayer.play(AssetSource('audio/bgm.mp3')).catchError((e) {
          debugPrint('AudioService: Play BGM error in updateCachedSettings: $e');
        });
      }
    }

    if (!settings.sfxEnabled) {
      debugPrint('AudioService: Stop Magic SFX because sfxEnabled is false');
      _magicPlayer.stop().catchError((e) {
        debugPrint('AudioService: Stop Magic SFX error in updateCachedSettings: $e');
      });
    }
  }

  Future<void> playBgm() async {
    debugPrint('AudioService: playBgm() called. current bgmEnabled=${_cachedSettings.bgmEnabled}');
    _isBgmPlaying = true;

    if (!_cachedSettings.bgmEnabled) {
      debugPrint('AudioService: playBgm() aborted, bgmEnabled is false');
      return;
    }

    try {
      if (_bgmPlayer.state != PlayerState.playing) {
        debugPrint('AudioService: Calling _bgmPlayer.play');
        _bgmPlayer.play(AssetSource('audio/bgm.mp3')).catchError((e) {
          debugPrint('AudioService BGM play error: $e');
        });
      } else {
        debugPrint('AudioService: playBgm() skipped, already playing');
      }
    } catch (e) {
      debugPrint('AudioService playBgm error: $e');
    }
  }

  Future<void> stopBgm() async {
    debugPrint('AudioService: stopBgm() called');
    _isBgmPlaying = false;
    try {
      _bgmPlayer.stop().catchError((e) {
        debugPrint('AudioService stopBgm error: $e');
      });
      debugPrint('AudioService: stopBgm() initiated');
    } catch (e) {
      debugPrint('AudioService stopBgm error: $e');
    }
  }

  Future<void> updateBgmState(bool enabled) async {
    debugPrint('AudioService: updateBgmState($enabled) called');
    _cachedSettings = _cachedSettings.copyWith(bgmEnabled: enabled);
    if (enabled) {
      if (_isBgmPlaying) {
        try {
          if (_bgmPlayer.state != PlayerState.playing) {
            debugPrint('AudioService: updateBgmState calling play');
            _bgmPlayer.play(AssetSource('audio/bgm.mp3')).catchError((e) {
              debugPrint('AudioService: updateBgmState play error: $e');
            });
          }
        } catch (e) {
          debugPrint('AudioService: updateBgmState play error: $e');
        }
      } else {
        debugPrint('AudioService: updateBgmState calling playBgm()');
        await playBgm();
      }
    } else {
      try {
        debugPrint('AudioService: updateBgmState calling stop');
        _bgmPlayer.stop().catchError((e) {
          debugPrint('AudioService: updateBgmState stop error: $e');
        });
      } catch (e) {
        debugPrint('AudioService: updateBgmState stop error: $e');
      }
    }
  }

  void updateSfxState(bool enabled) {
    debugPrint('AudioService: updateSfxState($enabled) called');
    _cachedSettings = _cachedSettings.copyWith(sfxEnabled: enabled);
    if (!enabled) {
      debugPrint('AudioService: updateSfxState calling stop magic');
      _magicPlayer.stop().catchError((e) {
        debugPrint('AudioService: updateSfxState stop magic error: $e');
      });
    }
  }

  Future<void> playCardDraw() async {
    debugPrint('AudioService: playCardDraw() called, sfxEnabled=${_cachedSettings.sfxEnabled}');
    if (!_cachedSettings.sfxEnabled) {
      return;
    }

    try {
      debugPrint('AudioService: playCardDraw calling stop and play');
      _sfxPlayer.stop().then((_) {
        _sfxPlayer.play(AssetSource('audio/card_draw.mp3')).catchError((e) {
          debugPrint('AudioService playCardDraw play error: $e');
        });
      }).catchError((e) {
        debugPrint('AudioService playCardDraw stop failed, playing directly: $e');
        _sfxPlayer.play(AssetSource('audio/card_draw.mp3')).catchError((err) {
          debugPrint('AudioService playCardDraw direct play error: $err');
        });
      });
    } catch (e) {
      debugPrint('AudioService playCardDraw error: $e');
    }
  }

  Future<void> playLoadingMagic() async {
    debugPrint('AudioService: playLoadingMagic() called, isMagicPlaying=$_isMagicPlaying, sfxEnabled=${_cachedSettings.sfxEnabled}');
    if (_isMagicPlaying) {
      return;
    }
    _isMagicPlaying = true;

    if (!_cachedSettings.sfxEnabled) {
      return;
    }

    try {
      debugPrint('AudioService: playLoadingMagic calling play');
      _magicPlayer.play(AssetSource('audio/magic_loading.mp3')).catchError((e) {
        debugPrint('AudioService playLoadingMagic error: $e');
      });
    } catch (e) {
      debugPrint('AudioService playLoadingMagic error: $e');
    }
  }

  Future<void> stopLoadingMagic() async {
    debugPrint('AudioService: stopLoadingMagic() called');
    _isMagicPlaying = false;
    try {
      await _magicPlayer.stop();
      debugPrint('AudioService: stopLoadingMagic() complete');
    } catch (e) {
      debugPrint('AudioService stopLoadingMagic error: $e');
    }
  }

  void dispose() {
    debugPrint('AudioService: dispose() called');
    _bgmPlayer.dispose();
    _magicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService(ref);
  
  ref.listen(localSettingsRepositoryProvider, (previous, next) {
    next.whenData((repository) async {
      try {
        final settings = await repository.load();
        debugPrint('AudioService: Provider listened to settings change: bgmEnabled=${settings.bgmEnabled}');
        service.updateCachedSettings(settings);
      } catch (e) {
        debugPrint('AudioService: Provider listened settings load error: $e');
      }
    });
  });

  ref.onDispose(() => service.dispose());
  return service;
});
