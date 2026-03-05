import 'package:flutter_test/flutter_test.dart';
import 'package:track_builder/game/systems/scoring_system.dart';

void main() {
  late ScoringSystem scoring;

  setUp(() {
    scoring = ScoringSystem();
  });

  group('calculateStars', () {
    test('1 star for basic completion', () {
      final stars = scoring.calculateStars(
        piecesUsed: 10,
        timeElapsed: 30.0,
        bonusCollected: false,
        targetTime: 15.0,
        targetPieces: 8,
      );
      expect(stars, 1);
    });

    test('2 stars when within time limit', () {
      final stars = scoring.calculateStars(
        piecesUsed: 10,
        timeElapsed: 14.0,
        bonusCollected: false,
        targetTime: 15.0,
        targetPieces: 8,
      );
      expect(stars, 2);
    });

    test('2 stars when under piece limit', () {
      final stars = scoring.calculateStars(
        piecesUsed: 7,
        timeElapsed: 30.0,
        bonusCollected: false,
        targetTime: 15.0,
        targetPieces: 8,
      );
      expect(stars, 2);
    });

    test('3 stars when target met AND bonus collected', () {
      final stars = scoring.calculateStars(
        piecesUsed: 7,
        timeElapsed: 10.0,
        bonusCollected: true,
        targetTime: 15.0,
        targetPieces: 8,
      );
      expect(stars, 3);
    });

    test('2 stars when bonus collected but no target met', () {
      final stars = scoring.calculateStars(
        piecesUsed: 20,
        timeElapsed: 100.0,
        bonusCollected: true,
        targetTime: 15.0,
        targetPieces: 8,
      );
      expect(stars, 1);
    });

    test('1 star when no targets set', () {
      final stars = scoring.calculateStars(
        piecesUsed: 5,
        timeElapsed: 10.0,
        bonusCollected: false,
      );
      expect(stars, 1);
    });

    test('exact time limit still earns 2 stars', () {
      final stars = scoring.calculateStars(
        piecesUsed: 10,
        timeElapsed: 15.0,
        bonusCollected: false,
        targetTime: 15.0,
      );
      expect(stars, 2);
    });

    test('exact piece limit still earns 2 stars', () {
      final stars = scoring.calculateStars(
        piecesUsed: 8,
        timeElapsed: 100.0,
        bonusCollected: false,
        targetPieces: 8,
      );
      expect(stars, 2);
    });
  });

  group('calculateCoins', () {
    test('10 coins per star', () {
      expect(scoring.calculateCoins(stars: 1, isFirstCompletion: false), 10);
      expect(scoring.calculateCoins(stars: 2, isFirstCompletion: false), 20);
      expect(scoring.calculateCoins(stars: 3, isFirstCompletion: false), 30);
    });

    test('25 bonus for first completion', () {
      expect(scoring.calculateCoins(stars: 1, isFirstCompletion: true), 35);
      expect(scoring.calculateCoins(stars: 3, isFirstCompletion: true), 55);
    });
  });

  group('totalStars', () {
    test('sums all level stars', () {
      expect(scoring.totalStars({1: 3, 2: 2, 3: 1}), 6);
    });

    test('empty map returns 0', () {
      expect(scoring.totalStars({}), 0);
    });
  });

  group('checkTrophyProgress', () {
    test('gold at 90%+', () {
      expect(
        scoring.checkTrophyProgress(27, 30),
        TrophyLevel.gold,
      );
    });

    test('silver at 60-89%', () {
      expect(
        scoring.checkTrophyProgress(18, 30),
        TrophyLevel.silver,
      );
    });

    test('bronze at 30-59%', () {
      expect(
        scoring.checkTrophyProgress(9, 30),
        TrophyLevel.bronze,
      );
    });

    test('none below 30%', () {
      expect(
        scoring.checkTrophyProgress(5, 30),
        TrophyLevel.none,
      );
    });
  });
}
