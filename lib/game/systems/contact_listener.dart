import 'package:flame_forge2d/flame_forge2d.dart';

/// Handles collision events between game bodies.
/// Detects when the car hits boosters or reaches the end zone.
class TrackContactListener extends ContactListener {
  void Function()? onReachedEnd;
  void Function()? onBoostHit;

  @override
  void beginContact(Contact contact) {
    final a = contact.fixtureA;
    final b = contact.fixtureB;

    // Check for end zone
    if (_isCarFixture(a, b) && _hasUserData(a, b, 'endZone')) {
      onReachedEnd?.call();
    }

    // Check for booster
    if (_isCarFixture(a, b) && _hasUserData(a, b, 'booster')) {
      onBoostHit?.call();
    }
  }

  bool _isCarFixture(Fixture a, Fixture b) {
    return a.body.bodyType == BodyType.dynamic ||
        b.body.bodyType == BodyType.dynamic;
  }

  bool _hasUserData(Fixture a, Fixture b, String data) {
    return a.userData == data || b.userData == data;
  }

  @override
  void endContact(Contact contact) {}

  @override
  void preSolve(Contact contact, Manifold oldManifold) {}

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {}
}
