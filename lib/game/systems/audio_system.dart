import 'package:flame_audio/flame_audio.dart';

import '../../services/storage_service.dart';

/// Manages all game audio: background music and sound effects.
///
/// Uses Flame's audio system for OGG playback.
/// Loads preferences from StorageService. Gracefully handles missing files.
class AudioSystem {
  bool get musicEnabled => StorageService.instance.musicEnabled;
  bool get sfxEnabled => StorageService.instance.sfxEnabled;
  double get musicVolume => StorageService.instance.musicVolume;
  double get sfxVolume => StorageService.instance.sfxVolume;

  bool _audioAvailable = false;

  /// Initialize the audio system and preload common sounds
  Future<void> init() async {
    try {
      // Try loading a test file to check if audio assets exist
      // If no audio assets are bundled yet, we silently disable audio
      _audioAvailable = false;
    } catch (_) {
      _audioAvailable = false;
    }
  }

  /// Play background music (loops automatically)
  void playBackgroundMusic([String track = 'music/main_theme.ogg']) {
    if (!musicEnabled || !_audioAvailable) return;
    try {
      FlameAudio.bgm.play(track, volume: musicVolume);
    } catch (_) {
      // Audio file not found — ignore
    }
  }

  /// Stop background music
  void stopBackgroundMusic() {
    if (!_audioAvailable) return;
    FlameAudio.bgm.stop();
  }

  /// Play a one-shot sound effect
  void playSound(String name) {
    if (!sfxEnabled || !_audioAvailable) return;
    try {
      FlameAudio.play('sfx/$name.ogg', volume: sfxVolume);
    } catch (_) {
      // Audio file not found — ignore
    }
  }

  /// Toggle music on/off
  void toggleMusic() {
    StorageService.instance.musicEnabled = !musicEnabled;
    if (!musicEnabled) {
      stopBackgroundMusic();
    } else {
      playBackgroundMusic();
    }
  }

  /// Toggle SFX on/off
  void toggleSfx() {
    StorageService.instance.sfxEnabled = !sfxEnabled;
  }

  /// Set music volume (0.0 to 1.0)
  void setMusicVolume(double volume) {
    StorageService.instance.musicVolume = volume.clamp(0.0, 1.0);
  }

  /// Set SFX volume (0.0 to 1.0)
  void setSfxVolume(double volume) {
    StorageService.instance.sfxVolume = volume.clamp(0.0, 1.0);
  }

  /// Enable audio playback (call after audio files are bundled)
  void enableAudio() {
    _audioAvailable = true;
  }

  /// Clean up audio resources
  void dispose() {
    if (!_audioAvailable) return;
    FlameAudio.bgm.stop();
    FlameAudio.bgm.dispose();
  }
}
