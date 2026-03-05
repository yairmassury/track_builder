import 'package:flame_audio/flame_audio.dart';

/// Manages all game audio: background music and sound effects.
///
/// Uses Flame's audio system for OGG playback.
/// All audio files should be in OGG Vorbis format for Android.
class AudioSystem {
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  double _musicVolume = 0.5;
  double _sfxVolume = 0.8;

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  /// Initialize the audio system and preload common sounds
  Future<void> init() async {
    // Preload frequently used sound effects for zero-latency playback
    await FlameAudio.audioCache.loadAll([
      // These files need to exist in assets/audio/
      // 'sfx/click.ogg',
      // 'sfx/snap.ogg',
      // 'sfx/launch.ogg',
      // 'sfx/success.ogg',
      // 'sfx/fail.ogg',
      // 'sfx/error.ogg',
      // 'sfx/star.ogg',
      // 'sfx/coin.ogg',
      // 'sfx/unlock.ogg',
    ]);
  }

  /// Play background music (loops automatically)
  void playBackgroundMusic([String track = 'music/main_theme.ogg']) {
    if (!_musicEnabled) return;
    FlameAudio.bgm.play(track, volume: _musicVolume);
  }

  /// Stop background music
  void stopBackgroundMusic() {
    FlameAudio.bgm.stop();
  }

  /// Play a one-shot sound effect
  void playSound(String name) {
    if (!_sfxEnabled) return;
    FlameAudio.play('sfx/$name.ogg', volume: _sfxVolume);
  }

  /// Toggle music on/off
  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (!_musicEnabled) {
      FlameAudio.bgm.stop();
    } else {
      playBackgroundMusic();
    }
  }

  /// Toggle SFX on/off
  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
  }

  /// Set music volume (0.0 to 1.0)
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    // TODO: Update current BGM volume
  }

  /// Set SFX volume (0.0 to 1.0)
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  /// Clean up audio resources
  void dispose() {
    FlameAudio.bgm.stop();
    FlameAudio.bgm.dispose();
  }
}
