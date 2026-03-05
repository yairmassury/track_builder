import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// Visual component for a track piece placed on the grid.
///
/// During the BUILD phase, this renders the piece as a colored shape.
/// No Box2D physics — physics bodies are created separately when
/// the car launches (RUN phase).
class TrackPieceComponent extends PositionComponent with DragCallbacks {
  final TrackPieceType type;
  int rotation;
  final double cellPixelSize;

  /// Callback when the piece is dragged off the grid (removed)
  void Function(TrackPieceComponent)? onRemoved;

  /// Callback when the piece is tapped (to rotate)
  void Function(TrackPieceComponent)? onTapped;

  bool _isDragging = false;

  TrackPieceComponent({
    required this.type,
    required this.cellPixelSize,
    this.rotation = 0,
    this.onRemoved,
    this.onTapped,
  }) : super(
          size: Vector2.all(cellPixelSize),
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final color = _pieceColor(type);
    final rect = Rect.fromLTWH(2, 2, size.x - 4, size.y - 4);

    // Save and rotate canvas
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(rotation * pi / 2);
    canvas.translate(-size.x / 2, -size.y / 2);

    // Fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = color.withOpacity(1.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Draw piece-specific markings
    _drawPieceDetail(canvas, type, size.x, size.y);

    canvas.restore();

    // Drag visual feedback
    if (_isDragging) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y),
          const Radius.circular(6),
        ),
        Paint()
          ..color = const Color(0x4400AAFF)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawPieceDetail(Canvas canvas, TrackPieceType type, double w, double h) {
    final paint = Paint()
      ..color = const Color(0xAAFFFFFF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    switch (type) {
      case TrackPieceType.straight:
        // Horizontal line through center
        canvas.drawLine(Offset(4, h / 2), Offset(w - 4, h / 2), paint);
        break;

      case TrackPieceType.ramp:
        // Diagonal line going up
        canvas.drawLine(Offset(4, h * 0.7), Offset(w - 4, h * 0.3), paint);
        // Arrow up
        canvas.drawLine(Offset(w * 0.6, h * 0.25), Offset(w - 4, h * 0.3), paint);
        break;

      case TrackPieceType.curveLeft:
        // Quarter arc curving up
        final path = Path()
          ..moveTo(4, h / 2)
          ..quadraticBezierTo(w / 2, h / 2, w / 2, 4);
        canvas.drawPath(path, paint);
        break;

      case TrackPieceType.curveRight:
        // Quarter arc curving down
        final path = Path()
          ..moveTo(4, h / 2)
          ..quadraticBezierTo(w / 2, h / 2, w / 2, h - 4);
        canvas.drawPath(path, paint);
        break;

      case TrackPieceType.loop:
        // Circle in center
        canvas.drawCircle(Offset(w / 2, h / 2 - 4), w * 0.25, paint);
        // Entry/exit lines
        canvas.drawLine(Offset(4, h * 0.6), Offset(w * 0.25, h * 0.6), paint);
        canvas.drawLine(Offset(w * 0.75, h * 0.6), Offset(w - 4, h * 0.6), paint);
        break;

      case TrackPieceType.jump:
        // Two ramps with gap
        canvas.drawLine(Offset(4, h * 0.6), Offset(w * 0.35, h * 0.3), paint);
        canvas.drawLine(Offset(w * 0.65, h * 0.3), Offset(w - 4, h * 0.6), paint);
        // Stars in the gap
        final starPaint = Paint()..color = const Color(0xCCFFD700);
        canvas.drawCircle(Offset(w / 2, h * 0.4), 3, starPaint);
        break;

      case TrackPieceType.tunnel:
        // Two parallel lines (floor + ceiling)
        canvas.drawLine(Offset(4, h * 0.35), Offset(w - 4, h * 0.35), paint);
        canvas.drawLine(Offset(4, h * 0.65), Offset(w - 4, h * 0.65), paint);
        break;

      case TrackPieceType.bridge:
        // Elevated line with pillars
        canvas.drawLine(Offset(4, h * 0.4), Offset(w - 4, h * 0.4), paint);
        // Pillars
        final pillarPaint = Paint()
          ..color = const Color(0x88FFFFFF)
          ..strokeWidth = 2.0;
        canvas.drawLine(Offset(w * 0.3, h * 0.4), Offset(w * 0.3, h - 4), pillarPaint);
        canvas.drawLine(Offset(w * 0.7, h * 0.4), Offset(w * 0.7, h - 4), pillarPaint);
        break;

      case TrackPieceType.booster:
        // Arrows pointing right (speed!)
        final arrowPaint = Paint()
          ..color = const Color(0xCCFF4400)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        for (final xOff in [0.25, 0.5, 0.75]) {
          canvas.drawLine(
            Offset(w * xOff - 6, h * 0.35),
            Offset(w * xOff + 2, h / 2),
            arrowPaint,
          );
          canvas.drawLine(
            Offset(w * xOff + 2, h / 2),
            Offset(w * xOff - 6, h * 0.65),
            arrowPaint,
          );
        }
        break;
    }
  }

  Color _pieceColor(TrackPieceType type) {
    switch (type) {
      case TrackPieceType.straight:
        return const Color(0xCCFF8C00); // Orange
      case TrackPieceType.ramp:
        return const Color(0xCC4CAF50); // Green
      case TrackPieceType.curveLeft:
        return const Color(0xCC2196F3); // Blue
      case TrackPieceType.curveRight:
        return const Color(0xCC42A5F5); // Light blue
      case TrackPieceType.loop:
        return const Color(0xCCE040FB); // Purple
      case TrackPieceType.jump:
        return const Color(0xCCFF5252); // Red
      case TrackPieceType.tunnel:
        return const Color(0xCC795548); // Brown
      case TrackPieceType.bridge:
        return const Color(0xCC9E9E9E); // Grey
      case TrackPieceType.booster:
        return const Color(0xCCFF6D00); // Deep orange
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragging = true;
    priority = 100;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;
    priority = 0;
    // The game handles snapping — see TrackBuilderGame.onPieceDragEnd
  }
}

/// Data definition for a track piece type.
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
