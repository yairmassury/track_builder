import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

/// Renders the physics collision shapes of track pieces during RUN phase.
/// This gives visual feedback of where the car can drive.
class TrackBodyRenderer extends PositionComponent {
  final List<Body> trackBodies;
  final double pixelsPerUnit;
  final double offsetX;
  final double offsetY;

  TrackBodyRenderer({
    required this.trackBodies,
    required this.pixelsPerUnit,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = const Color(0x88FF8C00) // Semi-transparent orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(offsetX, offsetY);

    for (final body in trackBodies) {
      for (final fixture in body.fixtures) {
        final shape = fixture.shape;

        if (shape is ChainShape) {
          final path = Path();
          for (int i = 0; i < shape.vertices.length; i++) {
            final v = shape.vertices[i];
            final screenX = (body.position.x + v.x) * pixelsPerUnit;
            final screenY = (body.position.y + v.y) * pixelsPerUnit;
            if (i == 0) {
              path.moveTo(screenX, screenY);
            } else {
              path.lineTo(screenX, screenY);
            }
          }
          canvas.drawPath(path, paint);
        } else if (shape is EdgeShape) {
          final v1 = shape.vertex1;
          final v2 = shape.vertex2;
          canvas.drawLine(
            Offset(
              (body.position.x + v1.x) * pixelsPerUnit,
              (body.position.y + v1.y) * pixelsPerUnit,
            ),
            Offset(
              (body.position.x + v2.x) * pixelsPerUnit,
              (body.position.y + v2.y) * pixelsPerUnit,
            ),
            paint,
          );
        }
      }
    }

    canvas.restore();
  }
}
