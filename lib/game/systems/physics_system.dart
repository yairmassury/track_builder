import 'package:flame_forge2d/flame_forge2d.dart';

/// Manages the physics simulation for the track and car.
class PhysicsSystem {
  final Forge2DWorld world;

  static const double defaultGravity = 9.81;
  static const double boosterForce = 15.0;

  PhysicsSystem({required this.world});

  void applyBoost(Body body, {double force = boosterForce}) {
    final velocity = body.linearVelocity;
    if (velocity.length > 0) {
      final direction = velocity.normalized();
      body.applyLinearImpulse(direction * force);
    }
  }

  bool isBodyStuck(Body body, {double threshold = 0.1}) {
    return body.linearVelocity.length < threshold;
  }

  double getSpeed(Body body) {
    return body.linearVelocity.length;
  }

  void createBoundaries({
    required double width,
    required double height,
  }) {
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: Vector2.zero(),
    );
    final body = world.createBody(bodyDef);

    final bottomEdge = EdgeShape()
      ..set(Vector2(0, height), Vector2(width, height));
    body.createFixture(FixtureDef(bottomEdge)..friction = 0.3);

    final leftEdge = EdgeShape()
      ..set(Vector2(0, 0), Vector2(0, height));
    body.createFixture(FixtureDef(leftEdge)..friction = 0.3);

    final rightEdge = EdgeShape()
      ..set(Vector2(width, 0), Vector2(width, height));
    body.createFixture(FixtureDef(rightEdge)..friction = 0.3);
  }
}
