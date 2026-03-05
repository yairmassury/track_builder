import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class TrophyRoom extends StatelessWidget {
  const TrophyRoom({super.key});

  static const _trophies = [
    _TrophyData(
      id: 'desert_bronze',
      name: 'Desert Explorer',
      description: 'Earn 9 stars in Desert Rally',
      icon: Icons.wb_sunny,
      requiredStars: 9,
      world: 'desert',
      tier: 'bronze',
    ),
    _TrophyData(
      id: 'desert_silver',
      name: 'Desert Champion',
      description: 'Earn 18 stars in Desert Rally',
      icon: Icons.wb_sunny,
      requiredStars: 18,
      world: 'desert',
      tier: 'silver',
    ),
    _TrophyData(
      id: 'desert_gold',
      name: 'Desert Master',
      description: 'Earn 27 stars in Desert Rally',
      icon: Icons.wb_sunny,
      requiredStars: 27,
      world: 'desert',
      tier: 'gold',
    ),
    _TrophyData(
      id: 'first_star',
      name: 'Rising Star',
      description: 'Earn your first star',
      icon: Icons.star,
      requiredStars: 1,
      tier: 'bronze',
    ),
    _TrophyData(
      id: 'ten_stars',
      name: 'Star Collector',
      description: 'Earn 10 stars total',
      icon: Icons.stars,
      requiredStars: 10,
      tier: 'silver',
    ),
    _TrophyData(
      id: 'space_bronze',
      name: 'Space Explorer',
      description: 'Earn 9 stars in Space Race',
      icon: Icons.rocket_launch,
      requiredStars: 9,
      world: 'space',
      tier: 'bronze',
    ),
    _TrophyData(
      id: 'space_silver',
      name: 'Space Champion',
      description: 'Earn 18 stars in Space Race',
      icon: Icons.rocket_launch,
      requiredStars: 18,
      world: 'space',
      tier: 'silver',
    ),
    _TrophyData(
      id: 'space_gold',
      name: 'Space Master',
      description: 'Earn 27 stars in Space Race',
      icon: Icons.rocket_launch,
      requiredStars: 27,
      world: 'space',
      tier: 'gold',
    ),
    _TrophyData(
      id: 'ocean_bronze',
      name: 'Ocean Explorer',
      description: 'Earn 9 stars in Ocean Dash',
      icon: Icons.water,
      requiredStars: 9,
      world: 'ocean',
      tier: 'bronze',
    ),
    _TrophyData(
      id: 'ocean_gold',
      name: 'Ocean Master',
      description: 'Earn 27 stars in Ocean Dash',
      icon: Icons.water,
      requiredStars: 27,
      world: 'ocean',
      tier: 'gold',
    ),
    _TrophyData(
      id: 'jungle_bronze',
      name: 'Jungle Explorer',
      description: 'Earn 9 stars in Jungle Run',
      icon: Icons.forest,
      requiredStars: 9,
      world: 'jungle',
      tier: 'bronze',
    ),
    _TrophyData(
      id: 'jungle_gold',
      name: 'Jungle Legend',
      description: 'Earn 27 stars in Jungle Run',
      icon: Icons.forest,
      requiredStars: 27,
      world: 'jungle',
      tier: 'gold',
    ),
    _TrophyData(
      id: 'thirty_stars',
      name: 'Star Master',
      description: 'Earn 30 stars total',
      icon: Icons.auto_awesome,
      requiredStars: 30,
      tier: 'gold',
    ),
    _TrophyData(
      id: 'all_cars',
      name: 'Car Collector',
      description: 'Unlock all cars',
      icon: Icons.directions_car,
      requiredStars: 0,
      tier: 'gold',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    final earnedTrophies = storage.earnedTrophies;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDAA520), Color(0xFFB8860B)],
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
                    const Expanded(
                      child: Text(
                        'Trophy Room',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
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
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: _trophies.length,
                  itemBuilder: (context, index) {
                    final trophy = _trophies[index];
                    final isEarned = earnedTrophies.contains(trophy.id);

                    return _TrophyCard(
                      trophy: trophy,
                      isEarned: isEarned,
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

class _TrophyCard extends StatelessWidget {
  final _TrophyData trophy;
  final bool isEarned;

  const _TrophyCard({
    required this.trophy,
    required this.isEarned,
  });

  Color get _tierColor {
    switch (trophy.tier) {
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey.shade300;
      case 'bronze':
        return Colors.brown.shade300;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: isEarned ? _tierColor.withOpacity(0.9) : Colors.black26,
          borderRadius: BorderRadius.circular(16),
          border: isEarned
              ? Border.all(color: _tierColor, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEarned ? trophy.icon : Icons.help_outline,
              color: isEarned ? Colors.white : Colors.white38,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              isEarned ? trophy.name : '???',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isEarned ? Colors.white : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEarned ? trophy.name : 'Locked Trophy'),
        content: Text(
          isEarned ? trophy.description : 'Keep playing to unlock this trophy!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _TrophyData {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int requiredStars;
  final String? world;
  final String tier;

  const _TrophyData({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredStars,
    this.world,
    required this.tier,
  });
}
