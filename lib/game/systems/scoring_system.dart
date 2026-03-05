/// Handles score calculation and star awards for completed levels.
///
/// Scoring criteria:
///   1 star: Track connects and car reaches the end
///   2 stars: Car reaches end within time limit
///   3 stars: Completed with bonus objectives (collect coins, use specific pieces)
class ScoringSystem {
  /// Calculate stars for a completed level run
  int calculateStars({
    required int piecesUsed,
    required double timeElapsed,
    required bool bonusCollected,
    int? targetPieces,
    double? targetTime,
  }) {
    int stars = 1; // Base star for completing the level

    // Second star: within time limit (or under piece limit)
    if (targetTime != null && timeElapsed <= targetTime) {
      stars = 2;
    } else if (targetPieces != null && piecesUsed <= targetPieces) {
      stars = 2;
    }

    // Third star: bonus objective completed
    if (stars >= 2 && bonusCollected) {
      stars = 3;
    }

    return stars;
  }

  /// Calculate coins earned from a level completion
  int calculateCoins({
    required int stars,
    required bool isFirstCompletion,
  }) {
    int coins = stars * 10; // 10 coins per star

    // Bonus coins for first-time completion
    if (isFirstCompletion) {
      coins += 25;
    }

    return coins;
  }

  /// Calculate total stars across all levels
  int totalStars(Map<int, int> levelStars) {
    return levelStars.values.fold(0, (sum, stars) => sum + stars);
  }

  /// Check if a trophy milestone has been reached
  TrophyLevel checkTrophyProgress(int totalStarsEarned, int maxPossibleStars) {
    final ratio = totalStarsEarned / maxPossibleStars;
    if (ratio >= 0.9) return TrophyLevel.gold;
    if (ratio >= 0.6) return TrophyLevel.silver;
    if (ratio >= 0.3) return TrophyLevel.bronze;
    return TrophyLevel.none;
  }
}

enum TrophyLevel {
  none,
  bronze,
  silver,
  gold,
}
