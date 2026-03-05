/// Handles score calculation and star awards for completed levels.
///
/// Scoring criteria:
///   1 star: Track connects and car reaches the end
///   2 stars: Car reaches end within time limit OR under piece limit
///   3 stars: Completed with bonus objectives
class ScoringSystem {
  int calculateStars({
    required int piecesUsed,
    required double timeElapsed,
    required bool bonusCollected,
    double? targetTime,
    int? targetPieces,
  }) {
    int stars = 1;

    // Second star: within time limit or under piece limit
    bool hitTarget = false;
    if (targetTime != null && timeElapsed <= targetTime) {
      hitTarget = true;
    }
    if (targetPieces != null && piecesUsed <= targetPieces) {
      hitTarget = true;
    }
    if (hitTarget) stars = 2;

    // Third star: bonus objective completed
    if (stars >= 2 && bonusCollected) {
      stars = 3;
    }

    return stars;
  }

  int calculateCoins({
    required int stars,
    required bool isFirstCompletion,
  }) {
    int coins = stars * 10;
    if (isFirstCompletion) coins += 25;
    return coins;
  }

  int totalStars(Map<int, int> levelStars) {
    return levelStars.values.fold(0, (sum, stars) => sum + stars);
  }

  TrophyLevel checkTrophyProgress(int totalStarsEarned, int maxPossibleStars) {
    final ratio = totalStarsEarned / maxPossibleStars;
    if (ratio >= 0.9) return TrophyLevel.gold;
    if (ratio >= 0.6) return TrophyLevel.silver;
    if (ratio >= 0.3) return TrophyLevel.bronze;
    return TrophyLevel.none;
  }
}

enum TrophyLevel { none, bronze, silver, gold }
