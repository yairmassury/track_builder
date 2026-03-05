/// Data model for a game level loaded from levels.json.
class LevelData {
  final int id;
  final String name;
  final String world;
  final int gridColumns;
  final int gridRows;
  final int startCol;
  final int startRow;
  final int endCol;
  final int endRow;
  final List<String> availablePieces;
  final Map<String, int> pieceLimits;
  final double? targetTime;
  final int? targetPieces;
  final bool hasBonusObjective;
  final String? bonusDescription;

  const LevelData({
    required this.id,
    required this.name,
    required this.world,
    required this.gridColumns,
    required this.gridRows,
    required this.startCol,
    required this.startRow,
    required this.endCol,
    required this.endRow,
    required this.availablePieces,
    this.pieceLimits = const {},
    this.targetTime,
    this.targetPieces,
    this.hasBonusObjective = false,
    this.bonusDescription,
  });

  factory LevelData.fromJson(Map<String, dynamic> json) {
    return LevelData(
      id: json['id'] as int,
      name: json['name'] as String,
      world: json['world'] as String,
      gridColumns: json['gridColumns'] as int,
      gridRows: json['gridRows'] as int,
      startCol: json['startCol'] as int,
      startRow: json['startRow'] as int,
      endCol: json['endCol'] as int,
      endRow: json['endRow'] as int,
      availablePieces: List<String>.from(json['availablePieces'] as List),
      pieceLimits: json['pieceLimits'] != null
          ? Map<String, int>.from(json['pieceLimits'] as Map)
          : {},
      targetTime: (json['targetTime'] as num?)?.toDouble(),
      targetPieces: json['targetPieces'] as int?,
      hasBonusObjective: json['hasBonusObjective'] as bool? ?? false,
      bonusDescription: json['bonusDescription'] as String?,
    );
  }
}

/// Represents a world (themed group of levels).
class WorldData {
  final String id;
  final String name;
  final int starsToUnlock;
  final List<int> levelIds;

  const WorldData({
    required this.id,
    required this.name,
    required this.starsToUnlock,
    required this.levelIds,
  });

  static const List<WorldData> worlds = [
    WorldData(
      id: 'desert',
      name: 'Desert Rally',
      starsToUnlock: 0,
      levelIds: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    ),
    WorldData(
      id: 'space',
      name: 'Space Race',
      starsToUnlock: 15,
      levelIds: [11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
    ),
    WorldData(
      id: 'ocean',
      name: 'Ocean Dash',
      starsToUnlock: 30,
      levelIds: [21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
    ),
    WorldData(
      id: 'jungle',
      name: 'Jungle Run',
      starsToUnlock: 45,
      levelIds: [31, 32, 33, 34, 35, 36, 37, 38, 39, 40],
    ),
  ];
}
