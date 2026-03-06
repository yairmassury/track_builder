import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_builder/models/track_data.dart';

void main() {
  late List<LevelData> levels;

  setUp(() {
    final file = File('assets/data/levels.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    levels = (json['levels'] as List)
        .map((e) => LevelData.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  test('all 40 levels load from JSON', () {
    expect(levels.length, 40);
  });

  test('all level IDs are sequential 1-40', () {
    final ids = levels.map((l) => l.id).toList()..sort();
    expect(ids, List.generate(40, (i) => i + 1));
  });

  test('each world has exactly 10 levels', () {
    final worldCounts = <String, int>{};
    for (final level in levels) {
      worldCounts[level.world] = (worldCounts[level.world] ?? 0) + 1;
    }
    expect(worldCounts['desert'], 10);
    expect(worldCounts['space'], 10);
    expect(worldCounts['ocean'], 10);
    expect(worldCounts['jungle'], 10);
  });

  test('all levels have valid grid dimensions', () {
    for (final level in levels) {
      expect(level.gridColumns, greaterThan(0),
          reason: 'Level ${level.id} has invalid columns');
      expect(level.gridRows, greaterThan(0),
          reason: 'Level ${level.id} has invalid rows');
    }
  });

  test('start and end cells are within grid bounds', () {
    for (final level in levels) {
      expect(level.startCol, lessThan(level.gridColumns),
          reason: 'Level ${level.id} start col out of bounds');
      expect(level.startRow, lessThan(level.gridRows),
          reason: 'Level ${level.id} start row out of bounds');
      expect(level.endCol, lessThan(level.gridColumns),
          reason: 'Level ${level.id} end col out of bounds');
      expect(level.endRow, lessThan(level.gridRows),
          reason: 'Level ${level.id} end row out of bounds');
    }
  });

  test('start and end cells are different', () {
    for (final level in levels) {
      final different =
          level.startCol != level.endCol || level.startRow != level.endRow;
      expect(different, isTrue,
          reason: 'Level ${level.id} has same start and end');
    }
  });

  test('all levels have at least one available piece', () {
    for (final level in levels) {
      expect(level.availablePieces.isNotEmpty, isTrue,
          reason: 'Level ${level.id} has no pieces');
    }
  });

  test('piece limits match available pieces', () {
    for (final level in levels) {
      for (final piece in level.availablePieces) {
        expect(level.pieceLimits.containsKey(piece), isTrue,
            reason: 'Level ${level.id} missing limit for $piece');
        expect(level.pieceLimits[piece], greaterThan(0),
            reason: 'Level ${level.id} has 0 limit for $piece');
      }
    }
  });

  test('difficulty increases within each world', () {
    // Later levels should generally have more pieces and larger grids
    for (final world in ['desert', 'space', 'ocean', 'jungle']) {
      final worldLevels = levels.where((l) => l.world == world).toList();
      worldLevels.sort((a, b) => a.id.compareTo(b.id));

      // First level should have smaller or equal grid than last
      final first = worldLevels.first;
      final last = worldLevels.last;
      expect(
        last.gridColumns * last.gridRows,
        greaterThanOrEqualTo(first.gridColumns * first.gridRows),
        reason: '$world: last level should have >= grid size than first',
      );
    }
  });
}
