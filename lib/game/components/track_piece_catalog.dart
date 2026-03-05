import 'dart:math';
import 'dart:ui';

import 'track_piece.dart';

/// Defines all track piece types with their geometry, connection points,
/// and collision shapes. This is the single source of truth for piece data.
///
/// Collision shapes are defined in local coordinates relative to the piece.
/// Grid size is 1.0 in physics units (scaled by the game).
class TrackPieceCatalog {
  static const double _unit = 1.0; // 1 grid cell in physics units

  static final Map<TrackPieceType, TrackPieceData> pieces = {
    TrackPieceType.straight: TrackPieceData(
      id: 'straight',
      name: 'Straight',
      type: TrackPieceType.straight,
      entryPoint: Offset(-_unit / 2, 0),
      exitPoint: Offset(_unit / 2, 0),
      friction: 0.3,
      collisionShapes: [
        // Top surface — the car rides on this
        [Offset(-_unit / 2, -0.1), Offset(_unit / 2, -0.1)],
        // Bottom surface
        [Offset(-_unit / 2, 0.1), Offset(_unit / 2, 0.1)],
      ],
    ),

    TrackPieceType.ramp: TrackPieceData(
      id: 'ramp',
      name: 'Ramp',
      type: TrackPieceType.ramp,
      entryPoint: Offset(-_unit / 2, 0.2),
      exitPoint: Offset(_unit / 2, -0.3),
      friction: 0.35,
      collisionShapes: [
        // Sloped surface going up-right
        [Offset(-_unit / 2, 0.2), Offset(_unit / 2, -0.3)],
      ],
    ),

    TrackPieceType.curveLeft: TrackPieceData(
      id: 'curveLeft',
      name: 'Curve Left',
      type: TrackPieceType.curveLeft,
      entryPoint: Offset(-_unit / 2, 0),
      exitPoint: Offset(0, -_unit / 2),
      friction: 0.3,
      collisionShapes: [
        _generateArc(
          center: Offset(_unit / 2, -_unit / 2),
          radius: _unit,
          startAngle: pi / 2,
          endAngle: pi,
          segments: 6,
        ),
      ],
    ),

    TrackPieceType.curveRight: TrackPieceData(
      id: 'curveRight',
      name: 'Curve Right',
      type: TrackPieceType.curveRight,
      entryPoint: Offset(-_unit / 2, 0),
      exitPoint: Offset(0, _unit / 2),
      friction: 0.3,
      collisionShapes: [
        _generateArc(
          center: Offset(_unit / 2, _unit / 2),
          radius: _unit,
          startAngle: -pi,
          endAngle: -pi / 2,
          segments: 6,
        ),
      ],
    ),

    TrackPieceType.loop: TrackPieceData(
      id: 'loop',
      name: 'Loop',
      type: TrackPieceType.loop,
      entryPoint: Offset(-_unit / 2, 0),
      exitPoint: Offset(_unit / 2, 0),
      friction: 0.25,
      collisionShapes: [
        // Full circle loop — car goes around inside
        _generateArc(
          center: Offset(0, -0.3),
          radius: 0.4,
          startAngle: pi / 2,
          endAngle: pi / 2 + 2 * pi,
          segments: 12,
        ),
        // Entry ramp
        [Offset(-_unit / 2, 0), Offset(-0.15, 0.1)],
        // Exit ramp
        [Offset(0.15, 0.1), Offset(_unit / 2, 0)],
      ],
    ),

    TrackPieceType.jump: TrackPieceData(
      id: 'jump',
      name: 'Jump',
      type: TrackPieceType.jump,
      entryPoint: Offset(-_unit / 2, 0),
      exitPoint: Offset(_unit / 2, 0),
      friction: 0.3,
      collisionShapes: [
        // Left ramp (launch)
        [Offset(-_unit / 2, 0.1), Offset(-0.1, -0.2)],
        // Right ramp (landing)
        [Offset(0.1, -0.2), Offset(_unit / 2, 0.1)],
        // Gap in the middle — no surface, car flies!
      ],
    ),

    TrackPieceType.tunnel: TrackPieceData(
      id: 'tunnel',
      name: 'Tunnel',
      type: TrackPieceType.tunnel,
      entryPoint: Offset(-_unit / 2, 0),
      exitPoint: Offset(_unit / 2, 0),
      friction: 0.2, // Smooth inside
      collisionShapes: [
        // Floor
        [Offset(-_unit / 2, 0.1), Offset(_unit / 2, 0.1)],
        // Ceiling
        [Offset(-_unit / 2, -0.3), Offset(_unit / 2, -0.3)],
      ],
    ),

    TrackPieceType.bridge: TrackPieceData(
      id: 'bridge',
      name: 'Bridge',
      type: TrackPieceType.bridge,
      entryPoint: Offset(-_unit / 2, -0.2),
      exitPoint: Offset(_unit / 2, -0.2),
      friction: 0.3,
      collisionShapes: [
        // Elevated surface
        [Offset(-_unit / 2, -0.2), Offset(_unit / 2, -0.2)],
      ],
    ),

    TrackPieceType.booster: TrackPieceData(
      id: 'booster',
      name: 'Booster',
      type: TrackPieceType.booster,
      entryPoint: Offset(-_unit / 2, 0),
      exitPoint: Offset(_unit / 2, 0),
      friction: 0.1, // Very low friction
      collisionShapes: [
        // Flat surface with low friction
        [Offset(-_unit / 2, 0), Offset(_unit / 2, 0)],
      ],
    ),
  };

  static List<Offset> _generateArc({
    required Offset center,
    required double radius,
    required double startAngle,
    required double endAngle,
    required int segments,
  }) {
    final points = <Offset>[];
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final angle = startAngle + (endAngle - startAngle) * t;
      points.add(Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      ));
    }
    return points;
  }

  static TrackPieceData getByType(TrackPieceType type) {
    return pieces[type]!;
  }

  static TrackPieceData? getById(String id) {
    final type = TrackPieceType.values.where((t) => t.name == id).firstOrNull;
    if (type == null) return null;
    return pieces[type];
  }
}
