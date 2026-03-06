# Track Builder

A fun track-building puzzle game for kids ages 4-8. Build tracks, launch cars, and watch them ride!

## Features

- **4 Themed Worlds**: Desert Rally, Space Race, Ocean Dash, Jungle Run
- **40 Levels** with progressive difficulty
- **9 Track Piece Types**: Straight, Ramp, Curves, Loop, Jump, Tunnel, Bridge, Booster
- **4 Unlockable Cars**: Speedster, Tank, Bouncer, Rocket
- **Physics Simulation**: Real Box2D physics for car movement
- **Star Rating System**: 1-3 stars per level based on time and piece count
- **Trophy Room**: Earn trophies for world completion milestones
- **Garage**: Buy and select different cars with earned coins
- **Fully Offline**: Zero network access, all data stored locally

## Tech Stack

- **Flutter 3.41** + **Dart 3.11**
- **Flame Engine** for 2D game rendering
- **flame_forge2d** (Box2D) for physics simulation
- **Hive** for local storage (no SQLite)

## Building

```bash
# Run tests
flutter test

# Build debug APK
export ANDROID_HOME=~/android-sdk
flutter build apk --debug

# Build release APK (47.5MB)
flutter build apk --release

# Build for web (browser preview)
flutter build web
python3 -m http.server 8080 --directory build/web
```

## Project Structure

```
lib/
  game/
    components/    # Flame visual components (car, grid, track pieces, trail)
    systems/       # Physics, scoring, audio, validation, contacts
    levels/        # Level loader
  screens/         # Flutter UI (menu, world map, garage, trophies, settings)
  models/          # Data models (levels, cars, progress)
  services/        # Storage service (Hive)
  main.dart        # App entry + game screen with overlay HUDs
assets/
  data/            # Level definitions (levels.json)
  audio/           # SFX and music (OGG format) — see AUDIO_REQUIREMENTS.md
test/              # 56 unit tests
tools/             # Icon generator script
```

## How to Play

1. Select a track piece from the palette at the bottom
2. Tap on the grid to place it
3. Tap a placed piece to rotate it
4. Connect the green start arrow to the checkered flag
5. Press GO to launch the car!
6. Earn stars based on time and piece count

## License

Private project.
