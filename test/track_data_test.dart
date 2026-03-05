import 'package:flutter_test/flutter_test.dart';
import 'package:track_builder/models/track_data.dart';

void main() {
  group('LevelData.fromJson', () {
    test('parses basic level', () {
      final json = {
        'id': 1,
        'name': 'First Ride',
        'world': 'desert',
        'gridColumns': 8,
        'gridRows': 6,
        'startCol': 0,
        'startRow': 3,
        'endCol': 7,
        'endRow': 3,
        'availablePieces': ['straight'],
        'pieceLimits': {'straight': 7},
        'targetTime': 15.0,
        'targetPieces': 7,
        'hasBonusObjective': false,
      };

      final level = LevelData.fromJson(json);

      expect(level.id, 1);
      expect(level.name, 'First Ride');
      expect(level.world, 'desert');
      expect(level.gridColumns, 8);
      expect(level.gridRows, 6);
      expect(level.startCol, 0);
      expect(level.startRow, 3);
      expect(level.endCol, 7);
      expect(level.endRow, 3);
      expect(level.availablePieces, ['straight']);
      expect(level.pieceLimits['straight'], 7);
      expect(level.targetTime, 15.0);
      expect(level.targetPieces, 7);
      expect(level.hasBonusObjective, false);
    });

    test('handles missing optional fields', () {
      final json = {
        'id': 2,
        'name': 'Test',
        'world': 'desert',
        'gridColumns': 10,
        'gridRows': 8,
        'startCol': 0,
        'startRow': 0,
        'endCol': 9,
        'endRow': 7,
        'availablePieces': ['straight', 'ramp'],
      };

      final level = LevelData.fromJson(json);

      expect(level.targetTime, isNull);
      expect(level.targetPieces, isNull);
      expect(level.hasBonusObjective, false);
      expect(level.bonusDescription, isNull);
      expect(level.pieceLimits, isEmpty);
    });
  });

  group('WorldData', () {
    test('has 4 worlds defined', () {
      expect(WorldData.worlds.length, 4);
    });

    test('desert world is first and unlocked at 0 stars', () {
      final desert = WorldData.worlds[0];
      expect(desert.id, 'desert');
      expect(desert.starsToUnlock, 0);
      expect(desert.levelIds.length, 10);
      expect(desert.levelIds.first, 1);
      expect(desert.levelIds.last, 10);
    });

    test('worlds require increasing stars to unlock', () {
      for (int i = 1; i < WorldData.worlds.length; i++) {
        expect(
          WorldData.worlds[i].starsToUnlock,
          greaterThan(WorldData.worlds[i - 1].starsToUnlock),
        );
      }
    });

    test('all 40 level IDs are unique', () {
      final allIds =
          WorldData.worlds.expand((w) => w.levelIds).toList();
      expect(allIds.length, 40);
      expect(allIds.toSet().length, 40);
    });
  });
}
