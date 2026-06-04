import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_tarot/app/app_providers.dart';
import 'package:pocket_tarot/domain/models/local_settings.dart';

class AudioService {
  AudioService(this._ref) {
    debugPrint('AudioService: Initializing...');
    
    final audioContext = AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
      respectSilence: false,
      stayAwake: true,
    ).build();

    // 設定 Global AudioContext
    AudioPlayer.global.setAudioContext(audioContext).then((_) {
      debugPrint('AudioService: Global audio context configured successfully');
    }).catchError((e) {
      debugPrint('AudioService: Global audio context configuration error: $e');
    });

    // 分別為三個播放器實例設定獨立的 AudioContext，確保混音正常、不互相奪取音訊焦點
    _bgmPlayer.setAudioContext(audioContext).catchError((e) {
      debugPrint('AudioService: _bgmPlayer setAudioContext error: $e');
    });
    _magicPlayer.setAudioContext(audioContext).catchError((e) {
      debugPrint('AudioService: _magicPlayer setAudioContext error: $e');
    });
    _sfxPlayer.setAudioContext(audioContext).catchError((e) {
      debugPrint('AudioService: _sfxPlayer setAudioContext error: $e');
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
    debugPrint('AudioService: updateCachedSettings called: bgmEnabled=${settings.bgmEnabled}, sfxEnabled=${settings.sfxEnabled}');
    
    // 如果設定無實質變化，則直接返回，避免與 updateBgmState/updateSfxState 產生重複操作衝突
    if (settings.bgmEnabled == _cachedSettings.bgmEnabled &&
        settings.sfxEnabled == _cachedSettings.sfxEnabled) {
      debugPrint('AudioService: updateCachedSettings skipped (no changes)');
      return;
    }

    final oldSettings = _cachedSettings;
    _cachedSettings = settings;

    // 背景音樂狀態改變時才進行操作
    if (settings.bgmEnabled != oldSettings.bgmEnabled) {
      if (!settings.bgmEnabled) {
        debugPrint('AudioService: Stop BGM because bgmEnabled changed to false');
        _bgmPlayer.stop().catchError((e) {
          debugPrint('AudioService: Stop BGM error: $e');
        });
      } else {
        if (_isBgmPlaying && _bgmPlayer.state != PlayerState.playing) {
          debugPrint('AudioService: Resume BGM because bgmEnabled changed to true');
          _bgmPlayer.play(AssetSource('audio/bgm.mp3')).then((_) {
            _bgmPlayer.setReleaseMode(ReleaseMode.loop).catchError((e) => debugPrint('BGM loop error: $e'));
          }).catchError((e) {
            debugPrint('AudioService: Play BGM error: $e');
          });
        }
      }
    }

    // 環境音效狀態改變時才進行操作
    if (settings.sfxEnabled != oldSettings.sfxEnabled) {
      if (!settings.sfxEnabled) {
        debugPrint('AudioService: Stop Magic SFX because sfxEnabled changed to false');
        _magicPlayer.stop().catchError((e) {
          debugPrint('AudioService: Stop Magic SFX error: $e');
        });
      }
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
        _bgmPlayer.play(AssetSource('audio/bgm.mp3')).then((_) {
          _bgmPlayer.setReleaseMode(ReleaseMode.loop).catchError((e) {
            debugPrint('AudioService playBgm setReleaseMode error: $e');
          });
        }).catchError((e) {
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
    if (_cachedSettings.bgmEnabled == enabled) {
      debugPrint('AudioService: updateBgmState skipped (no changes)');
      return;
    }
    _cachedSettings = _cachedSettings.copyWith(bgmEnabled: enabled);
    if (enabled) {
      if (_isBgmPlaying) {
        try {
          if (_bgmPlayer.state != PlayerState.playing) {
            debugPrint('AudioService: updateBgmState calling play');
            _bgmPlayer.play(AssetSource('audio/bgm.mp3')).then((_) {
              _bgmPlayer.setReleaseMode(ReleaseMode.loop).catchError((e) {
                debugPrint('AudioService updateBgmState setReleaseMode error: $e');
              });
            }).catchError((e) {
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
    if (_cachedSettings.sfxEnabled == enabled) {
      debugPrint('AudioService: updateSfxState skipped (no changes)');
      return;
    }
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
      debugPrint('AudioService: playCardDraw calling stop and play (non-blocking)');
      // 獨立異步呼叫，不使用 then 串接，避免 stop() 的 Future 因從未播放而懸空掛起
      _sfxPlayer.stop().catchError((e) {
        debugPrint('AudioService playCardDraw stop error: $e');
      });
      _sfxPlayer.play(AssetSource('audio/card_draw.mp3')).catchError((e) {
        debugPrint('AudioService playCardDraw play error: $e');
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
      _magicPlayer.play(AssetSource('audio/magic_loading.mp3')).then((_) {
        _magicPlayer.setReleaseMode(ReleaseMode.loop).catchError((e) {
          debugPrint('AudioService playLoadingMagic setReleaseMode error: $e');
        });
      }).catchError((e) {
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
      _magicPlayer.stop().then((_) {
        debugPrint('AudioService: stopLoadingMagic() complete, restoring BGM');
        playBgm();
      }).catchError((e) {
        debugPrint('AudioService stopLoadingMagic player stop error: $e');
        playBgm();
      });
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
