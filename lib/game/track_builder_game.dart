import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'components/car.dart';
import 'components/grid.dart';
import 'components/track_piece.dart';
import 'systems/physics_system.dart';
import 'systems/scoring_system.dart';
import 'systems/audio_system.dart';
import 'levels/level_loader.dart';

/// Main game class for Track Builder.
///
/// Manages the game loop, track building phase, and car simulation phase.
/// The game has two modes:
///   1. BUILD mode — player drags track pieces onto the grid
///   2. RUN mode — car launches and physics simulation plays out
class TrackBuilderGame extends Forge2DGame with DragCallbacks, TapCallbacks {
  final int levelId;

  // Game state
  GamePhase phase = GamePhase.building;

  // Core systems
  late final GridSystem grid;
  late final PhysicsSystem physicsSystem;
  late final ScoringSystem scoringSystem;
  late final AudioSystem audioSystem;
  late final LevelLoader levelLoader;

  // Track pieces placed by the player
  final List<TrackPieceComponent> placedPieces = [];

  // The car entity
  Car? car;

  TrackBuilderGame({required this.levelId})
      : super(gravity: Vector2(0, 9.81)); // Earth-like gravity

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize systems
    levelLoader = LevelLoader();
    grid = GridSystem(gridSize: 64.0);
    physicsSystem = PhysicsSystem(world: world);
    scoringSystem = ScoringSystem();
    audioSystem = AudioSystem();

    await audioSystem.init();

    // Load the current level
    final levelData = await levelLoader.loadLevel(levelId);

    // Set up the grid based on level dimensions
    grid.initialize(
      columns: levelData.gridColumns,
      rows: levelData.gridRows,
    );

    // Add start and end markers
    // TODO: Add visual markers for start/end positions

    // Play background music
    audioSystem.playBackgroundMusic();
  }

  /// Called when the player taps the "GO!" button
  void launchCar() {
    if (phase != GamePhase.building) return;

    // Validate track connectivity
    if (!_isTrackValid()) {
      audioSystem.playSound('error');
      // TODO: Show "Track not connected!" message
      return;
    }

    phase = GamePhase.running;

    // Create the car at the start position
    car = Car(
      position: grid.startPosition,
      carType: CarType.standard,
    );
    add(car!);

    audioSystem.playSound('launch');
  }

  /// Validates that the track connects from start to end
  bool _isTrackValid() {
    if (placedPieces.isEmpty) return false;

    // TODO: Implement full connection validation
    // Check that exit points align with entry points of adjacent pieces
    // and there's a path from start to end
    return true;
  }

  /// Called when the car reaches the end or falls off
  void onRunComplete({required bool success}) {
    phase = GamePhase.complete;

    if (success) {
      final stars = scoringSystem.calculateStars(
        piecesUsed: placedPieces.length,
        timeElapsed: 0, // TODO: track elapsed time
        bonusCollected: false, // TODO: track bonus objectives
      );

      audioSystem.playSound('success');
      overlays.add('LevelComplete');

      // Save progress
      // TODO: Save stars to StorageService
    } else {
      audioSystem.playSound('fail');
      // TODO: Show "Try again!" message
    }
  }

  /// Reset the level to building phase
  void resetLevel() {
    phase = GamePhase.building;

    // Remove the car
    if (car != null) {
      remove(car!);
      car = null;
    }

    // Keep placed pieces — let player modify their track
    overlays.remove('LevelComplete');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (phase == GamePhase.running && car != null) {
      // Check if car reached the end or fell off screen
      if (car!.hasReachedEnd) {
        onRunComplete(success: true);
      } else if (car!.hasFallenOff(size)) {
        onRunComplete(success: false);
      }
    }
  }
}

/// The current phase of gameplay
enum GamePhase {
  building, // Player is placing track pieces
  running,  // Car is driving along the track
  complete, // Run finished, showing results
}
