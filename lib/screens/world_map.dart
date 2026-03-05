import 'package:flutter/material.dart';

import '../main.dart';
import '../models/track_data.dart';
import '../services/storage_service.dart';

class WorldMap extends StatefulWidget {
  const WorldMap({super.key});

  @override
  State<WorldMap> createState() => _WorldMapState();
}

class _WorldMapState extends State<WorldMap> {
  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Color(0xFFF4A460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Choose a World',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Worlds list
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: WorldData.worlds.length,
                  itemBuilder: (context, index) {
                    final world = WorldData.worlds[index];
                    final isUnlocked =
                        storage.totalStars >= world.starsToUnlock;

                    return _WorldCard(
                      world: world,
                      isUnlocked: isUnlocked,
                      totalStars: storage.totalStars,
                      onTap: isUnlocked
                          ? () => _openWorld(context, world)
                              .then((_) => setState(() {}))
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openWorld(BuildContext context, WorldData world) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LevelSelect(world: world),
      ),
    );
  }
}

class _WorldCard extends StatelessWidget {
  final WorldData world;
  final bool isUnlocked;
  final int totalStars;
  final VoidCallback? onTap;

  static const _worldColors = {
    'desert': Color(0xFFE8A838),
    'space': Color(0xFF3A3A8C),
    'ocean': Color(0xFF1E90FF),
    'jungle': Color(0xFF2E8B57),
  };

  const _WorldCard({
    required this.world,
    required this.isUnlocked,
    required this.totalStars,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _worldColors[world.id] ?? Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        decoration: BoxDecoration(
          color: isUnlocked ? color : Colors.grey.shade600,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isUnlocked ? color : Colors.grey).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked) ...[
              const Icon(Icons.lock, color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              Text(
                '${world.starsToUnlock - totalStars} more stars',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ] else ...[
              Icon(
                _worldIcon(world.id),
                color: Colors.white,
                size: 64,
              ),
            ],
            const SizedBox(height: 16),
            Text(
              world.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _worldIcon(String worldId) {
    switch (worldId) {
      case 'desert':
        return Icons.wb_sunny;
      case 'space':
        return Icons.rocket_launch;
      case 'ocean':
        return Icons.water;
      case 'jungle':
        return Icons.forest;
      default:
        return Icons.landscape;
    }
  }
}

class _LevelSelect extends StatefulWidget {
  final WorldData world;

  const _LevelSelect({required this.world});

  @override
  State<_LevelSelect> createState() => _LevelSelectState();
}

class _LevelSelectState extends State<_LevelSelect> {
  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Color(0xFFF4A460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.world.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: widget.world.levelIds.length,
                  itemBuilder: (context, index) {
                    final levelId = widget.world.levelIds[index];
                    final stars = storage.getLevelStars(levelId);
                    final isUnlocked =
                        levelId <= storage.highestUnlockedLevel;

                    return _LevelBadge(
                      levelNumber: index + 1,
                      stars: stars,
                      isUnlocked: isUnlocked,
                      onTap: isUnlocked
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      GameScreen(levelId: levelId),
                                ),
                              ).then((_) => setState(() {}));
                            }
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int levelNumber;
  final int stars;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _LevelBadge({
    required this.levelNumber,
    required this.stars,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.orange : Colors.grey.shade600,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              const Icon(Icons.lock, color: Colors.white54, size: 28)
            else
              Text(
                '$levelNumber',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (isUnlocked && stars > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
