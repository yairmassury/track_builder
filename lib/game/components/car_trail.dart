import 'dart:ui';
import 'dart:math';

import 'package:flame/components.dart';

/// Renders a simple particle trail behind the car.
/// Creates small colored dots that fade out over time.
class CarTrail extends PositionComponent {
  final List<_TrailParticle> _particles = [];
  final Color trailColor;
  final Random _rng = Random();

  double _spawnTimer = 0;
  static const double _spawnInterval = 0.03;

  /// World-space position of the car (updated each frame by the game)
  Vector2 carWorldPos = Vector2.zero();

  /// Pixels per physics unit (for converting world → screen coords)
  final double pixelsPerUnit;
  final double offsetX;
  final double offsetY;

  CarTrail({
    required this.trailColor,
    required this.pixelsPerUnit,
    required this.offsetX,
    required this.offsetY,
  });

  void addParticleAt(double worldX, double worldY) {
    _particles.add(_TrailParticle(
      x: worldX,
      y: worldY,
      vx: (_rng.nextDouble() - 0.5) * 0.5,
      vy: (_rng.nextDouble() - 0.5) * 0.3 - 0.2,
      life: 0.5 + _rng.nextDouble() * 0.3,
      size: 2 + _rng.nextDouble() * 3,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      addParticleAt(carWorldPos.x, carWorldPos.y);
    }

    for (final p in _particles) {
      p.age += dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
    }
    _particles.removeWhere((p) => p.age >= p.life);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    canvas.translate(offsetX, offsetY);

    for (final p in _particles) {
      final alpha = ((1 - p.age / p.life) * 200).toInt().clamp(0, 255);
      final paint = Paint()
        ..color = trailColor.withAlpha(alpha);
      final screenX = p.x * pixelsPerUnit;
      final screenY = p.y * pixelsPerUnit;
      canvas.drawCircle(Offset(screenX, screenY), p.size, paint);
    }

    canvas.restore();
  }
}

class _TrailParticle {
  double x, y;
  double vx, vy;
  double life;
  double age = 0;
  double size;

  _TrailParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.size,
  });
}
