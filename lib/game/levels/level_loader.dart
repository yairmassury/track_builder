import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/track_data.dart';

/// Loads level definitions from the bundled levels.json asset.
class LevelLoader {
  List<LevelData>? _cachedLevels;

  Future<List<LevelData>> _loadAll() async {
    if (_cachedLevels != null) return _cachedLevels!;

    final jsonString = await rootBundle.loadString('assets/data/levels.json');
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final levelsList = jsonData['levels'] as List;

    _cachedLevels =
        levelsList.map((l) => LevelData.fromJson(l as Map<String, dynamic>)).toList();
    return _cachedLevels!;
  }

  Future<LevelData> loadLevel(int levelId) async {
    final levels = await _loadAll();
    return levels.firstWhere(
      (l) => l.id == levelId,
      orElse: () => throw Exception('Level $levelId not found'),
    );
  }

  Future<List<LevelData>> loadWorld(String worldId) async {
    final levels = await _loadAll();
    return levels.where((l) => l.world == worldId).toList();
  }

  Future<int> get totalLevelCount async => (await _loadAll()).length;
}
