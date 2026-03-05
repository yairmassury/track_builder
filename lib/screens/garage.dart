import 'package:flutter/material.dart';

import '../models/car_data.dart';
import '../services/storage_service.dart';

class Garage extends StatefulWidget {
  const Garage({super.key});

  @override
  State<Garage> createState() => _GarageState();
}

class _GarageState extends State<Garage> {
  final _storage = StorageService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
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
                        'Garage',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Coins
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on,
                              color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${_storage.coins}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Car grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: CarInfo.allCars.length,
                  itemBuilder: (context, index) {
                    final car = CarInfo.allCars[index];
                    final isUnlocked = _storage.isCarUnlocked(car.id);
                    final isSelected = _storage.selectedCar == car.id;
                    final canAfford = _storage.coins >= car.cost;

                    return _CarCard(
                      car: car,
                      isUnlocked: isUnlocked,
                      isSelected: isSelected,
                      canAfford: canAfford,
                      onTap: () => _onCarTap(car, isUnlocked, canAfford),
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

  void _onCarTap(CarInfo car, bool isUnlocked, bool canAfford) {
    if (isUnlocked) {
      setState(() {
        _storage.selectedCar = car.id;
      });
    } else if (canAfford) {
      _showBuyDialog(car);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Need ${car.cost - _storage.coins} more coins!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBuyDialog(CarInfo car) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Buy ${car.name}?'),
        content: Text('${car.description}\n\nCost: ${car.cost} coins'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _storage.coins = _storage.coins - car.cost;
                _storage.unlockCar(car.id);
                _storage.selectedCar = car.id;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Buy!'),
          ),
        ],
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final CarInfo car;
  final bool isUnlocked;
  final bool isSelected;
  final bool canAfford;
  final VoidCallback onTap;

  const _CarCard({
    required this.car,
    required this.isUnlocked,
    required this.isSelected,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? car.color.withOpacity(0.8) : Colors.grey.shade700,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.amber, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: (isUnlocked ? car.color : Colors.grey).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Car placeholder visual
            Icon(
              Icons.directions_car,
              color: isUnlocked ? Colors.white : Colors.white38,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              car.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.white : Colors.white54,
              ),
            ),
            const SizedBox(height: 4),
            if (!isUnlocked)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on,
                      color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${car.cost}',
                    style: TextStyle(
                      color: canAfford ? Colors.amber : Colors.red.shade300,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            else if (isSelected)
              const Text(
                'SELECTED',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
