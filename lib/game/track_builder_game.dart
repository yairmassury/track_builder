import 'dart:math';
import 'dart:ui' show Color, Offset;

import 'package:flame/components.dart' show Anchor;
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../models/track_data.dart';
import '../services/storage_service.dart';
import 'components/car.dart';
import 'components/grid.dart';
import 'components/grid_renderer.dart';
import 'components/track_piece.dart';
import 'components/track_body_renderer.dart';
import 'components/track_piece_catalog.dart';
import 'systems/physics_system.dart';
import 'systems/scoring_system.dart';
import 'systems/audio_system.dart';
import 'systems/contact_listener.dart';
import 'systems/track_validator.dart';
import 'levels/level_loader.dart';

class TrackBuilderGame extends Forge2DGame with TapCallbacks {
  final int levelId;

  Color _bgColor = const Color(0xFF1A1A2E);

  @override
  Color backgroundColor() => _bgColor;

  GamePhase phase = GamePhase.building;
  late LevelData levelData;

  late final GridSystem grid;
  late final GridRendererComponent gridRenderer;
  late final PhysicsSystem physicsSystem;
  late final ScoringSystem scoringSystem;
  late final AudioSystem audioSystem;
  late final LevelLoader levelLoader;

  final Map<GridCell, TrackPieceComponent> placedPieceComponents = {};
  final Map<GridCell, PlacedPiece> placedPieceData = {};
  final Map<String, int> piecesRemaining = {};
  final List<Body> _trackBodies = [];
  TrackBodyRenderer? _trackRenderer;

  Car? car;
  late final TrackContactListener _contactListener;

  TrackPieceType? selectedPieceType;
  void Function()? onStateChanged;

  double _runTime = 0;
  double _stuckTime = 0;
  static const double _stuckThreshold = 3.0;

  late GridCell startCell;
  late GridCell endCell;

  double _cellPixelSize = 50.0;
  double _gridOffsetX = 0;
  double _gridOffsetY = 0;

  TrackBuilderGame({required this.levelId})
      : super(gravity: Vector2(0, 9.81), zoom: 1);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    levelLoader = LevelLoader();
    levelData = await levelLoader.loadLevel(levelId);

    // Set world-themed background
    _bgColor = switch (levelData.world) {
      'desert' => const Color(0xFF2D1B0E),
      'space' => const Color(0xFF0A0A2A),
      'ocean' => const Color(0xFF0A1A3A),
      'jungle' => const Color(0xFF0A2A1A),
      _ => const Color(0xFF1A1A2E),
    };

    // Calculate scale to fit grid on screen
    final screenW = size.x;
    final screenH = size.y;
    final gridPixelW = screenW * 0.85;
    final gridPixelH = screenH * 0.70;
    _cellPixelSize = min(
      gridPixelW / levelData.gridColumns,
      gridPixelH / levelData.gridRows,
    );

    final gridTotalW = levelData.gridColumns * _cellPixelSize;
    final gridTotalH = levelData.gridRows * _cellPixelSize;
    _gridOffsetX = (screenW - gridTotalW) / 2;
    _gridOffsetY = (screenH - gridTotalH) / 2 - screenH * 0.05;

    // Initialize grid
    grid = GridSystem(gridSize: 1.0);
    grid.initialize(
      columns: levelData.gridColumns,
      rows: levelData.gridRows,
    );

    startCell = GridCell(col: levelData.startCol, row: levelData.startRow);
    endCell = GridCell(col: levelData.endCol, row: levelData.endRow);
    grid.startCell = startCell;
    grid.endCell = endCell;

    // Grid renderer
    gridRenderer = GridRendererComponent(
      grid: grid,
      pixelsPerUnit: _cellPixelSize,
    );
    gridRenderer.offsetX = _gridOffsetX;
    gridRenderer.offsetY = _gridOffsetY;
    add(gridRenderer);

    // Systems
    physicsSystem = PhysicsSystem(world: world);
    scoringSystem = ScoringSystem();
    audioSystem = AudioSystem();
    await audioSystem.init();

    // Contact listener for boosters and end zone
    _contactListener = TrackContactListener();
    _contactListener.onReachedEnd = () {
      if (phase == GamePhase.running) {
        onRunComplete(success: true);
      }
    };
    _contactListener.onBoostHit = () {
      if (car != null && phase == GamePhase.running) {
        physicsSystem.applyBoost(car!.body, force: 2.0);
      }
    };
    world.physicsWorld.setContactListener(_contactListener);

    for (final entry in levelData.pieceLimits.entries) {
      piecesRemaining[entry.key] = entry.value;
    }

    overlays.add('BuildHud');

    // Configure camera so Forge2D physics bodies align with our pixel grid.
    // Zoom = cellPixelSize means 1 physics unit = 1 grid cell = cellPixelSize pixels.
    // The camera viewfinder is anchored at top-left and offset to match grid position.
    camera.viewfinder.zoom = _cellPixelSize;
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2(
      -_gridOffsetX / _cellPixelSize,
      -_gridOffsetY / _cellPixelSize,
    );
  }

  double get cellPixelSize => _cellPixelSize;

  /// Convert screen/canvas position to grid cell
  GridCell? screenToGridCell(dynamic screenPos) {
    final localX = (screenPos.x as double) - _gridOffsetX;
    final localY = (screenPos.y as double) - _gridOffsetY;
    final col = (localX / _cellPixelSize).floor();
    final row = (localY / _cellPixelSize).floor();

    if (col < 0 || col >= grid.columns) return null;
    if (row < 0 || row >= grid.rows) return null;
    return GridCell(col: col, row: row);
  }

  /// Place a track piece on the grid
  bool placePiece(TrackPieceType type, GridCell cell, {int rotation = 0}) {
    if (phase != GamePhase.building) return false;
    if (!grid.isCellEmpty(cell)) return false;
    if (cell == startCell || cell == endCell) return false;

    final pieceId = type.name;
    final remaining = piecesRemaining[pieceId] ?? 0;
    if (remaining <= 0) return false;

    final component = TrackPieceComponent(
      type: type,
      cellPixelSize: _cellPixelSize,
      rotation: rotation,
    );
    // Set position in screen coordinates
    component.x = _gridOffsetX + cell.col * _cellPixelSize;
    component.y = _gridOffsetY + cell.row * _cellPixelSize;

    placedPieceComponents[cell] = component;
    placedPieceData[cell] = PlacedPiece(type: type, rotation: rotation);
    grid.placePiece(cell, pieceId);
    piecesRemaining[pieceId] = remaining - 1;

    add(component);
    return true;
  }

  void removePiece(GridCell cell) {
    if (phase != GamePhase.building) return;

    final component = placedPieceComponents.remove(cell);
    final data = placedPieceData.remove(cell);
    if (component != null && data != null) {
      remove(component);
      final pieceId = data.type.name;
      piecesRemaining[pieceId] = (piecesRemaining[pieceId] ?? 0) + 1;
      grid.removePiece(cell);
    }
  }

  void rotatePiece(GridCell cell) {
    if (phase != GamePhase.building) return;

    final component = placedPieceComponents[cell];
    final data = placedPieceData[cell];
    if (component != null && data != null) {
      final newRotation = (data.rotation + 1) % 4;
      component.rotation = newRotation;
      placedPieceData[cell] = PlacedPiece(type: data.type, rotation: newRotation);
    }
  }

  bool validateTrack() {
    return TrackValidator.isValid(
      grid: grid,
      pieces: placedPieceData,
      startCell: startCell,
      endCell: endCell,
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (phase != GamePhase.building) return;

    final cell = screenToGridCell(event.canvasPosition);
    if (cell == null) return;

    if (placedPieceData.containsKey(cell)) {
      if (removeMode) {
        removePiece(cell);
      } else {
        rotatePiece(cell);
      }
      onStateChanged?.call();
      return;
    }

    if (selectedPieceType != null) {
      final placed = placePiece(selectedPieceType!, cell);
      if (placed) {
        final remaining = piecesRemaining[selectedPieceType!.name] ?? 0;
        if (remaining <= 0) {
          selectedPieceType = null;
        }
        onStateChanged?.call();
      }
    }
  }

  /// When true, tapping a placed piece removes it instead of rotating
  bool removeMode = false;

  void launchCar() {
    if (phase != GamePhase.building) return;

    if (!validateTrack()) {
      overlays.add('InvalidTrack');
      Future.delayed(const Duration(seconds: 2), () {
        overlays.remove('InvalidTrack');
      });
      return;
    }

    phase = GamePhase.running;
    _runTime = 0;
    _stuckTime = 0;

    _createTrackPhysicsBodies();

    // Add visual renderer for track surfaces
    _trackRenderer = TrackBodyRenderer(
      trackBodies: _trackBodies,
      pixelsPerUnit: _cellPixelSize,
      offsetX: _gridOffsetX,
      offsetY: _gridOffsetY,
    );
    add(_trackRenderer!);

    final carStartPos = Vector2(
      (startCell.col + 0.5) * grid.gridSize,
      (startCell.row + 0.3) * grid.gridSize,
    );

    car = Car(
      position: carStartPos,
      carType: CarType.standard,
    );
    add(car!);

    Future.delayed(const Duration(milliseconds: 100), () {
      car?.launch(force: 3.0);
    });

    overlays.remove('BuildHud');
    overlays.add('RunHud');
  }

  void _createTrackPhysicsBodies() {
    for (final entry in placedPieceData.entries) {
      final cell = entry.key;
      final piece = entry.value;
      final catalog = TrackPieceCatalog.getByType(piece.type);

      final centerX = (cell.col + 0.5) * grid.gridSize;
      final centerY = (cell.row + 0.5) * grid.gridSize;

      final bodyDef = BodyDef(
        type: BodyType.static,
        position: Vector2(centerX, centerY),
      );
      final body = world.createBody(bodyDef);

      for (final shape in catalog.collisionShapes) {
        if (shape.length < 2) continue;

        final rotatedPoints = shape.map((p) {
          return _rotateOffset(p, piece.rotation);
        }).toList();

        final chainShape = ChainShape()
          ..createChain(
            rotatedPoints.map((p) => Vector2(p.dx, p.dy)).toList(),
          );

        body.createFixture(
          FixtureDef(chainShape)
            ..friction = catalog.friction
            ..restitution = 0.1,
        );
      }

      _trackBodies.add(body);

      if (piece.type == TrackPieceType.booster) {
        final sensorShape = PolygonShape()
          ..setAsBox(0.4, 0.1, Vector2.zero(), 0);
        body.createFixture(
          FixtureDef(sensorShape)
            ..isSensor = true
            ..userData = 'booster',
        );
      }
    }

    // End zone sensor
    final endX = (endCell.col + 0.5) * grid.gridSize;
    final endY = (endCell.row + 0.5) * grid.gridSize;
    final endBody = world.createBody(BodyDef(
      type: BodyType.static,
      position: Vector2(endX, endY),
    ));
    endBody.createFixture(
      FixtureDef(PolygonShape()..setAsBox(0.3, 0.3, Vector2.zero(), 0))
        ..isSensor = true
        ..userData = 'endZone',
    );
    _trackBodies.add(endBody);
  }

  Offset _rotateOffset(Offset p, int rotation) {
    var x = p.dx;
    var y = p.dy;
    for (int i = 0; i < (rotation % 4); i++) {
      final newX = -y;
      final newY = x;
      x = newX;
      y = newY;
    }
    return Offset(x, y);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (phase == GamePhase.running && car != null) {
      _runTime += dt;

      if (_isCarInEndZone()) {
        onRunComplete(success: true);
        return;
      }

      if (car!.hasFallenOff(Vector2(
        grid.columns * grid.gridSize + 5,
        grid.rows * grid.gridSize + 5,
      ))) {
        onRunComplete(success: false);
        return;
      }

      if (physicsSystem.isBodyStuck(car!.body, threshold: 0.05)) {
        _stuckTime += dt;
        if (_stuckTime > _stuckThreshold) {
          onRunComplete(success: false);
          return;
        }
      } else {
        _stuckTime = 0;
      }
    }
  }

  bool _isCarInEndZone() {
    if (car == null) return false;
    final carPos = car!.body.position;
    final endPos = Vector2(
      (endCell.col + 0.5) * grid.gridSize,
      (endCell.row + 0.5) * grid.gridSize,
    );
    return (carPos - endPos).length < 0.5;
  }

  void onRunComplete({required bool success}) {
    if (phase != GamePhase.running) return;
    phase = GamePhase.complete;

    overlays.remove('RunHud');

    if (success) {
      final stars = scoringSystem.calculateStars(
        piecesUsed: placedPieceComponents.length,
        timeElapsed: _runTime,
        bonusCollected: false,
        targetTime: levelData.targetTime,
        targetPieces: levelData.targetPieces,
      );

      final isFirst = !StorageService.instance.isLevelCompleted(levelId);
      final coins = scoringSystem.calculateCoins(
        stars: stars,
        isFirstCompletion: isFirst,
      );

      StorageService.instance.saveLevelStars(levelId, stars);
      StorageService.instance.addCoins(coins);

      if (levelId >= StorageService.instance.highestUnlockedLevel) {
        StorageService.instance.highestUnlockedLevel = levelId + 1;
      }

      _checkTrophies();

      overlays.add('LevelComplete');
    } else {
      overlays.add('LevelFailed');
    }
  }

  double get runTime => _runTime;

  int get earnedStars => scoringSystem.calculateStars(
        piecesUsed: placedPieceComponents.length,
        timeElapsed: _runTime,
        bonusCollected: false,
        targetTime: levelData.targetTime,
        targetPieces: levelData.targetPieces,
      );

  int get earnedCoins => scoringSystem.calculateCoins(
        stars: earnedStars,
        isFirstCompletion: !StorageService.instance.isLevelCompleted(levelId),
      );

  void resetLevel() {
    if (car != null) {
      remove(car!);
      car = null;
    }

    if (_trackRenderer != null) {
      remove(_trackRenderer!);
      _trackRenderer = null;
    }

    for (final body in _trackBodies) {
      world.destroyBody(body);
    }
    _trackBodies.clear();

    phase = GamePhase.building;
    _runTime = 0;
    _stuckTime = 0;

    overlays.remove('LevelComplete');
    overlays.remove('LevelFailed');
    overlays.remove('RunHud');
    overlays.add('BuildHud');
  }

  void _checkTrophies() {
    final s = StorageService.instance;
    final total = s.totalStars;

    if (total >= 1) s.earnTrophy('first_star');
    if (total >= 10) s.earnTrophy('ten_stars');
    if (total >= 30) s.earnTrophy('thirty_stars');

    // World trophies (each world has 10 levels, max 30 stars)
    _checkWorldTrophies(s, 'desert', 1, 10);
    _checkWorldTrophies(s, 'space', 11, 20);
    _checkWorldTrophies(s, 'ocean', 21, 30);
    _checkWorldTrophies(s, 'jungle', 31, 40);

    // Car collector
    if (s.unlockedCars.length >= 4) s.earnTrophy('all_cars');
  }

  void _checkWorldTrophies(StorageService s, String world, int startId, int endId) {
    int worldStars = 0;
    for (int i = startId; i <= endId; i++) {
      worldStars += s.getLevelStars(i);
    }
    if (worldStars >= 9) s.earnTrophy('${world}_bronze');
    if (worldStars >= 18) s.earnTrophy('${world}_silver');
    if (worldStars >= 27) s.earnTrophy('${world}_gold');
  }

  void clearTrack() {
    if (phase != GamePhase.building) return;

    for (final component in placedPieceComponents.values) {
      remove(component);
    }
    placedPieceComponents.clear();
    placedPieceData.clear();
    grid.clearAll();

    piecesRemaining.clear();
    for (final entry in levelData.pieceLimits.entries) {
      piecesRemaining[entry.key] = entry.value;
    }
  }
}

enum GamePhase {
  building,
  running,
  complete,
}
