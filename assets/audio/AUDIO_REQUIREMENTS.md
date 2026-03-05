# Track Builder - Audio Asset Requirements

All audio files should be in **OGG Vorbis** format (.ogg) for Android compatibility.
Place them in `assets/audio/` following the directory structure below.

## Directory Structure

```
assets/audio/
  sfx/
    click.ogg          - UI button tap
    snap.ogg           - Track piece placed on grid
    launch.ogg         - Car launches (GO button)
    success.ogg        - Level complete fanfare
    fail.ogg           - Level failed / car falls off
    error.ogg          - Invalid action (e.g., track not connected)
    star.ogg           - Star earned (plays up to 3x with delay)
    coin.ogg           - Coins awarded
    unlock.ogg         - New item unlocked (car, trophy)
    rotate.ogg         - Track piece rotated
    remove.ogg         - Track piece removed from grid
    engine_loop.ogg    - Car engine running (loopable, ~2-4 sec)
    boost.ogg          - Booster pad activated
    bounce.ogg         - Car bounces off surface
  music/
    main_theme.ogg     - Main menu background music (loopable, 30-60 sec)
    build_theme.ogg    - Build phase background music (loopable, 30-60 sec)
    run_theme.ogg      - Run phase background music (upbeat, loopable, 30-60 sec)
```

## Sound Effect Specifications

### UI Sounds
| File | Duration | Style | Notes |
|------|----------|-------|-------|
| click.ogg | 0.1-0.2s | Soft pop/click | Friendly, not sharp. Used for all button taps. |
| snap.ogg | 0.2-0.3s | Satisfying snap/click | Like a puzzle piece fitting. Plays when piece placed on grid. |
| rotate.ogg | 0.1-0.2s | Quick whoosh | Short rotation sound. |
| remove.ogg | 0.2s | Soft "undo" sound | Reverse of snap. |
| error.ogg | 0.3-0.5s | Gentle buzzer/bonk | Not harsh or scary (kids game!). Plays when track is invalid. |

### Game Sounds
| File | Duration | Style | Notes |
|------|----------|-------|-------|
| launch.ogg | 0.5-1.0s | Engine rev + whoosh | Exciting launch sound when car starts. |
| engine_loop.ogg | 2-4s | Gentle engine hum | Must loop seamlessly. Plays during car movement. |
| boost.ogg | 0.3-0.5s | Quick acceleration burst | Plays when car hits a booster pad. |
| bounce.ogg | 0.1-0.2s | Soft boing | Plays on car collisions. Cartoony. |

### Reward Sounds
| File | Duration | Style | Notes |
|------|----------|-------|-------|
| success.ogg | 1.5-2.0s | Cheerful fanfare | Celebratory! Plays on level complete. |
| fail.ogg | 1.0-1.5s | Gentle "aww" / sad trombone | Not discouraging, more funny/silly. Kids game! |
| star.ogg | 0.3-0.5s | Bright chime/ding | Plays for each star earned (staggered). |
| coin.ogg | 0.2-0.3s | Coin collect jingle | Quick and satisfying. |
| unlock.ogg | 0.5-1.0s | Treasure/achievement sound | Exciting reveal sound. |

## Music Specifications

| File | Duration | BPM | Style | Notes |
|------|----------|-----|-------|-------|
| main_theme.ogg | 30-60s | 100-120 | Cheerful, adventurous | Loopable. Main menu vibe - inviting, fun. Think cartoon adventure. |
| build_theme.ogg | 30-60s | 80-100 | Calm, thinking | Loopable. Puzzle-solving mood. Gentle and encouraging. |
| run_theme.ogg | 30-60s | 120-140 | Upbeat, exciting | Loopable. Racing/action feel. Energetic but not overwhelming. |

## General Guidelines

- **Target audience**: Kids ages 4-8. All sounds should be friendly, not scary or harsh.
- **Volume normalization**: All files should be normalized to similar loudness (-14 LUFS recommended).
- **Sample rate**: 44100 Hz
- **Bitrate**: 128 kbps OGG is fine for mobile
- **No silence padding**: Trim silence from start/end of all files.
- **Loop points**: Music files and engine_loop.ogg must loop seamlessly (match start/end waveform).

## Free Asset Sources

These sites offer royalty-free sounds suitable for kids games:
- OpenGameArt.org
- Freesound.org (check individual licenses)
- Kenney.nl/assets (CC0 game assets)
- Mixkit.co (free sound effects)

## After Adding Files

Once audio files are placed in `assets/audio/`, update `pubspec.yaml` to include them:

```yaml
flutter:
  assets:
    - assets/data/
    - assets/audio/sfx/
    - assets/audio/music/
```

Then in `audio_system.dart`, call `enableAudio()` to activate playback, and uncomment the preload list in `init()`.
