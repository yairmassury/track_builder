import 'package:flame_forge2d/flame_forge2d.dart';

/// Manages the physics simulation for the track and car.
///
/// Wraps Box2D (via Forge2D) to provide track-specific physics
/// behaviors like booster zones, friction surfaces, and ramp launches.
class PhysicsSystem {
  final World world;

  /// Gravity strength (default: Earth-like)
  static const double defaultGravity = 9.81;

  /// Speed multiplier for booster track pieces
  static const double boosterForce = 15.0;

  PhysicsSystem({required this.world});

  /// Apply a boost impulse to a body (for booster track pieces)
  void applyBoost(Body body, {double force = boosterForce}) {
    // Boost in the direction the body is traveling
    final velocity = body.linearVelocity;
    if (velocity.length > 0) {
      final direction = velocity.normalized();
      body.applyLinearImpulse(direction * force);
    }
  }

  /// Check if a body is moving very slowly (stuck or stopped)
  bool isBodyStuck(Body body, {double threshold = 0.1}) {
    return body.linearVelocity.length < threshold;
  }

  /// Get the current speed of a body
  double getSpeed(Body body) {
    return body.linearVelocity.length;
  }

  /// Create static collision boundaries around the play area
  void createBoundaries({
    required double width,
    required double height,
  }) {
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: Vector2.zero(),
    );
    final body = world.createBody(bodyDef);

    // Bottom boundary
    final bottomEdge = EdgeShape()
      ..set(Vector2(0, height), Vector2(width, height));
    body.createFixture(FixtureDef(bottomEdge)..friction = 0.3);

    // Left boundary
    final leftEdge = EdgeShape()
      ..set(Vector2(0, 0), Vector2(0, height));
    body.createFixture(FixtureDef(leftEdge)..friction = 0.3);

    // Right boundary
    final rightEdge = EdgeShape()
      ..set(Vector2(width, 0), Vector2(width, height));
    body.createFixture(FixtureDef(rightEdge)..friction = 0.3);
  }
}
