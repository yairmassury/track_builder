import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

/// Base class for all track pieces.
///
/// Each track piece has an entry point and exit point for connecting
/// to adjacent pieces on the grid. The collision shape defines the
/// surface the car rides along.
class TrackPieceComponent extends BodyComponent with DragCallbacks {
  final TrackPieceData data;
  Vector2 gridPosition;
  bool isPlaced = false;

  TrackPieceComponent({
    required this.data,
    required this.gridPosition,
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.static, // Track pieces don't move
      position: gridPosition,
    );

    final body = world.createBody(bodyDef);

    // Create collision shape from the piece data
    for (final shape in data.collisionShapes) {
      final chainShape = ChainShape()
        ..createChain(
          shape.map((p) => Vector2(p.dx, p.dy)).toList(),
        );

      final fixtureDef = FixtureDef(chainShape)
        ..friction = data.friction
        ..restitution = 0.1;

      body.createFixture(fixtureDef);
    }

    return body;
  }

  /// Check if this piece's exit connects to another piece's entry
  bool connectsTo(TrackPieceComponent other) {
    final myExit = gridPosition + Vector2(data.exitPoint.dx, data.exitPoint.dy);
    final otherEntry =
        other.gridPosition + Vector2(other.data.entryPoint.dx, other.data.entryPoint.dy);

    // Allow small tolerance for grid snapping
    return (myExit - otherEntry).length < 0.5;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    // TODO: Highlight valid grid positions
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    // TODO: Move piece with finger, show snap preview
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    // TODO: Snap to nearest grid cell
  }
}

/// Data definition for a track piece type.
///
/// This is loaded from levels.json and defines the geometry,
/// connection points, and properties of each piece type.
class TrackPieceData {
  final String id;
  final String name;
  final TrackPieceType type;
  final Offset entryPoint;
  final Offset exitPoint;
  final double friction;
  final int unlockLevel;
  final List<List<Offset>> collisionShapes;

  const TrackPieceData({
    required this.id,
    required this.name,
    required this.type,
    required this.entryPoint,
    required this.exitPoint,
    this.friction = 0.3,
    this.unlockLevel = 0,
    this.collisionShapes = const [],
  });

  factory TrackPieceData.fromJson(Map<String, dynamic> json) {
    return TrackPieceData(
      id: json['id'] as String,
      name: json['name'] as String,
      type: TrackPieceType.values.byName(json['type'] as String),
      entryPoint: Offset(
        (json['entryPoint']['x'] as num).toDouble(),
        (json['entryPoint']['y'] as num).toDouble(),
      ),
      exitPoint: Offset(
        (json['exitPoint']['x'] as num).toDouble(),
        (json['exitPoint']['y'] as num).toDouble(),
      ),
      friction: (json['friction'] as num?)?.toDouble() ?? 0.3,
      unlockLevel: json['unlockLevel'] as int? ?? 0,
      collisionShapes: (json['collisionShapes'] as List?)
              ?.map((shape) => (shape as List)
                  .map((p) => Offset(
                        (p['x'] as num).toDouble(),
                        (p['y'] as num).toDouble(),
                      ))
                  .toList())
              .toList() ??
          [],
    );
  }
}

/// Types of track pieces available in the game
enum TrackPieceType {
  straight,
  ramp,
  loop,
  curveLeft,
  curveRight,
  jump,
  tunnel,
  bridge,
  booster,
}
