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
      bullet: true, // Better collision detection for fast-moving car
    );

    final body = world.createBody(bodyDef);

    // Car shape — a small rectangle
    final shape = PolygonShape()
      ..setAsBox(
        carType.width / 2,
        carType.height / 2,
        Vector2.zero(),
        0,
      );

    final fixtureDef = FixtureDef(shape)
      ..density = carType.density
      ..friction = carType.friction
      ..restitution = carType.bounciness;

    body.createFixture(fixtureDef);
    return body;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // TODO: Check if car has reached the end zone
    // TODO: Add particle trail effects
  }

  /// Check if the car has fallen off the screen
  bool hasFallenOff(Vector2 screenSize) {
    final pos = body.position;
    return pos.y > screenSize.y + 100 || // Below screen
        pos.x < -100 ||                   // Left of screen
        pos.x > screenSize.x + 100;       // Right of screen
  }

  /// Apply an initial launch impulse
  void launch({double force = 5.0}) {
    body.applyLinearImpulse(Vector2(force, -1.0));
  }
}

/// Different car types with varying physics properties
enum CarType {
  standard(
    name: 'Speedster',
    width: 2.0,
    height: 1.0,
    density: 1.0,
    friction: 0.3,
    bounciness: 0.2,
    unlockLevel: 0,
  ),
  heavy(
    name: 'Tank',
    width: 2.5,
    height: 1.2,
    density: 2.0,
    friction: 0.5,
    bounciness: 0.1,
    unlockLevel: 5,
  ),
  bouncy(
    name: 'Bouncer',
    width: 1.8,
    height: 1.0,
    density: 0.8,
    friction: 0.2,
    bounciness: 0.7,
    unlockLevel: 10,
  ),
  fast(
    name: 'Rocket',
    width: 2.2,
    height: 0.8,
    density: 0.6,
    friction: 0.15,
    bounciness: 0.3,
    unlockLevel: 15,
  );

  final String name;
  final double width;
  final double height;
  final double density;
  final double friction;
  final double bounciness;
  final int unlockLevel;

  const CarType({
    required this.name,
    required this.width,
    required this.height,
    required this.density,
    required this.friction,
    required this.bounciness,
    required this.unlockLevel,
  });
}
