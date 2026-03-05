/// Represents the player's overall progress in the game.
///
/// This is a read-only snapshot — actual persistence is in StorageService.
class PlayerProgress {
  final int coins;
  final int totalStars;
  final int highestUnlockedLevel;
  final List<String> unlockedCars;
  final List<String> unlockedPieces;
  final List<String> earnedTrophies;
  final String selectedCar;

  const PlayerProgress({
    required this.coins,
    required this.totalStars,
    required this.highestUnlockedLevel,
    required this.unlockedCars,
    required this.unlockedPieces,
    required this.earnedTrophies,
    required this.selectedCar,
  });

  factory PlayerProgress.initial() {
    return const PlayerProgress(
      coins: 0,
      totalStars: 0,
      highestUnlockedLevel: 1,
      unlockedCars: ['standard'],
      unlockedPieces: ['straight', 'ramp', 'curveLeft', 'curveRight'],
      earnedTrophies: [],
      selectedCar: 'standard',
    );
  }
}
