import 'package:flutter/material.dart';

/// Display info for cars shown in the garage UI.
///
/// Physics properties are in CarType enum (car.dart).
/// This file handles presentation: name, color, cost, description.
class CarInfo {
  final String id;
  final String name;
  final String description;
  final Color color;
  final int cost;
  final int unlockLevel;

  const CarInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.cost,
    required this.unlockLevel,
  });

  static const List<CarInfo> allCars = [
    CarInfo(
      id: 'standard',
      name: 'Speedster',
      description: 'A balanced racer. Great for beginners!',
      color: Colors.red,
      cost: 0,
      unlockLevel: 0,
    ),
    CarInfo(
      id: 'heavy',
      name: 'Tank',
      description: 'Heavy and strong. Plows through anything!',
      color: Colors.green,
      cost: 100,
      unlockLevel: 5,
    ),
    CarInfo(
      id: 'bouncy',
      name: 'Bouncer',
      description: 'Super springy! Bounces over gaps!',
      color: Colors.blue,
      cost: 150,
      unlockLevel: 10,
    ),
    CarInfo(
      id: 'fast',
      name: 'Rocket',
      description: 'Lightning fast! Hard to control!',
      color: Colors.purple,
      cost: 200,
      unlockLevel: 15,
    ),
  ];

  static CarInfo getById(String id) {
    return allCars.firstWhere((car) => car.id == id,
        orElse: () => allCars.first);
  }
}
