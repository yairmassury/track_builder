import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

/// The car that drives along the track.
///
/// Uses Box2D physics for realistic movement along track surfaces.
/// Different car types have different properties (mass, bounciness, speed).
class Car extends BodyComponent {
  final Vector2 initialPosition;
  final CarType carType;

  bool hasReachedEnd = false;

  Car({
    required Vector2 position,
    required this.carType,
  }) : initialPosition = position;

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition,
      fixedRotation: false,
      bullet: true,
    );

    final body = world.createBody(bodyDef);

    final shape = PolygonShape()
      ..setAsBox(
        carType.width / 2,
        carType.height / 2,
        Vector2.zero(),
        0,
      );

    body.createFixture(
      FixtureDef(shape)
        ..density = carType.density
        ..friction = carType.friction
        ..restitution = carType.bounciness,
    );

    return body;
  }

  @override
  void render(Canvas canvas) {
    // Draw car as a colored rectangle with rounded corners
    final w = carType.width;
    final h = carType.height;
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: w,
      height: h,
    );

    // Car body
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(0.15)),
      Paint()..color = carType.color,
    );

    // Outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(0.15)),
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.05,
    );

    // Windshield
    final windshield = Rect.fromLTWH(w * 0.1, -h * 0.3, w * 0.2, h * 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(windshield, const Radius.circular(0.05)),
      Paint()..color = const Color(0xAA87CEEB),
    );

    // Wheels (small dark circles)
    final wheelPaint = Paint()..color = const Color(0xFF333333);
    final wheelR = h * 0.2;
    canvas.drawCircle(Offset(-w * 0.3, h * 0.35), wheelR, wheelPaint);
    canvas.drawCircle(Offset(w * 0.3, h * 0.35), wheelR, wheelPaint);
    canvas.drawCircle(Offset(-w * 0.3, -h * 0.35), wheelR, wheelPaint);
    canvas.drawCircle(Offset(w * 0.3, -h * 0.35), wheelR, wheelPaint);
  }

  bool hasFallenOff(Vector2 screenSize) {
    final pos = body.position;
    return pos.y > screenSize.y + 5 ||
        pos.x < -5 ||
        pos.x > screenSize.x + 5;
  }

  void launch({double force = 5.0}) {
    body.applyLinearImpulse(Vector2(force, -1.0));
  }
}

enum CarType {
  standard(
    name: 'Speedster',
    width: 2.0,
    height: 1.0,
    density: 1.0,
    friction: 0.3,
    bounciness: 0.2,
    unlockLevel: 0,
    color: Color(0xFFFF4444),
  ),
  heavy(
    name: 'Tank',
    width: 2.5,
    height: 1.2,
    density: 2.0,
    friction: 0.5,
    bounciness: 0.1,
    unlockLevel: 5,
    color: Color(0xFF44AA44),
  ),
  bouncy(
    name: 'Bouncer',
    width: 1.8,
    height: 1.0,
    density: 0.8,
    friction: 0.2,
    bounciness: 0.7,
    unlockLevel: 10,
    color: Color(0xFF4488FF),
  ),
  fast(
    name: 'Rocket',
    width: 2.2,
    height: 0.8,
    density: 0.6,
    friction: 0.15,
    bounciness: 0.3,
    unlockLevel: 15,
    color: Color(0xFFAA44FF),
  );

  final String name;
  final double width;
  final double height;
  final double density;
  final double friction;
  final double bounciness;
  final int unlockLevel;
  final Color color;

  const CarType({
    required this.name,
    required this.width,
    required this.height,
    required this.density,
    required this.friction,
    required this.bounciness,
    required this.unlockLevel,
    required this.color,
  });
}
