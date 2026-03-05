import 'package:hive_flutter/hive_flutter.dart';

/// Singleton service wrapping Hive for all local persistence.
///
/// Stores player progress, settings, unlocked items — everything
/// stays on-device, no network access ever.
class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  late Box _progressBox;
  late Box _settingsBox;

  Future<void> init() async {
    _progressBox = await Hive.openBox('progress');
    _settingsBox = await Hive.openBox('settings');
  }

  // --- Player Progress ---

  int get coins => _progressBox.get('coins', defaultValue: 0) as int;

  set coins(int value) => _progressBox.put('coins', value);

  void addCoins(int amount) => coins = coins + amount;

  /// Get stars earned for a specific level (0 if not played)
  int getLevelStars(int levelId) {
    return _progressBox.get('level_stars_$levelId', defaultValue: 0) as int;
  }

  /// Save stars for a level (only if better than previous)
  void saveLevelStars(int levelId, int stars) {
    final current = getLevelStars(levelId);
    if (stars > current) {
      _progressBox.put('level_stars_$levelId', stars);
    }
  }

  /// Get the highest unlocked level
  int get highestUnlockedLevel {
    return _progressBox.get('highest_unlocked_level', defaultValue: 1) as int;
  }

  set highestUnlockedLevel(int value) {
    _progressBox.put('highest_unlocked_level', value);
  }

  /// Check if a level has been completed at least once
  bool isLevelCompleted(int levelId) => getLevelStars(levelId) > 0;

  /// Get total stars across all levels
  int get totalStars {
    int total = 0;
    for (int i = 1; i <= 40; i++) {
      total += getLevelStars(i);
    }
    return total;
  }

  // --- Unlocked Cars ---

  List<String> get unlockedCars {
    final list = _progressBox.get('unlocked_cars', defaultValue: ['standard']);
    return List<String>.from(list as List);
  }

  void unlockCar(String carId) {
    final cars = unlockedCars;
    if (!cars.contains(carId)) {
      cars.add(carId);
      _progressBox.put('unlocked_cars', cars);
    }
  }

  bool isCarUnlocked(String carId) => unlockedCars.contains(carId);

  String get selectedCar {
    return _progressBox.get('selected_car', defaultValue: 'standard') as String;
  }

  set selectedCar(String carId) => _progressBox.put('selected_car', carId);

  // --- Unlocked Track Pieces ---

  List<String> get unlockedPieces {
    final list = _progressBox.get('unlocked_pieces',
        defaultValue: ['straight', 'ramp', 'curveLeft', 'curveRight']);
    return List<String>.from(list as List);
  }

  void unlockPiece(String pieceId) {
    final pieces = unlockedPieces;
    if (!pieces.contains(pieceId)) {
      pieces.add(pieceId);
      _progressBox.put('unlocked_pieces', pieces);
    }
  }

  // --- Trophies ---

  List<String> get earnedTrophies {
    final list = _progressBox.get('trophies', defaultValue: []);
    return List<String>.from(list as List);
  }

  void earnTrophy(String trophyId) {
    final trophies = earnedTrophies;
    if (!trophies.contains(trophyId)) {
      trophies.add(trophyId);
      _progressBox.put('trophies', trophies);
    }
  }

  // --- Settings ---

  bool get musicEnabled =>
      _settingsBox.get('music_enabled', defaultValue: true) as bool;

  set musicEnabled(bool value) => _settingsBox.put('music_enabled', value);

  bool get sfxEnabled =>
      _settingsBox.get('sfx_enabled', defaultValue: true) as bool;

  set sfxEnabled(bool value) => _settingsBox.put('sfx_enabled', value);

  double get musicVolume =>
      (_settingsBox.get('music_volume', defaultValue: 0.5) as num).toDouble();

  set musicVolume(double value) => _settingsBox.put('music_volume', value);

  double get sfxVolume =>
      (_settingsBox.get('sfx_volume', defaultValue: 0.8) as num).toDouble();

  set sfxVolume(double value) => _settingsBox.put('sfx_volume', value);

  // --- Reset ---

  Future<void> resetAll() async {
    await _progressBox.clear();
    await _settingsBox.clear();
  }
}
