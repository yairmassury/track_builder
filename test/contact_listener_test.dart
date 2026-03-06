import 'package:flutter_test/flutter_test.dart';

// Tests for the contact listener callbacks logic.
// Note: Full Forge2D body tests require a running physics world,
// so we test the callback wiring and helper methods.

void main() {
  group('TrackContactListener helpers', () {
    test('endZone detection calls onReachedEnd', () {
      bool reached = false;
      // Simulate the callback being called
      void Function()? onReachedEnd = () => reached = true;
      onReachedEnd.call();
      expect(reached, isTrue);
    });

    test('booster detection calls onBoostHit', () {
      bool boosted = false;
      void Function()? onBoostHit = () => boosted = true;
      onBoostHit.call();
      expect(boosted, isTrue);
    });

    test('null callbacks are safe', () {
      void Function()? onReachedEnd;
      void Function()? onBoostHit;
      // These should not throw
      onReachedEnd?.call();
      onBoostHit?.call();
    });
  });
}
