import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'game/track_builder_game.dart';
import 'game/components/track_piece.dart';
import 'screens/main_menu.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to landscape (track building works better in landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide system UI for immersive game experience
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize local storage
  await Hive.initFlutter();
  await StorageService.instance.init();

  runApp(const TrackBuilderApp());
}

class TrackBuilderApp extends StatelessWidget {
  const TrackBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Track Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        fontFamily: 'Fredoka',
        useMaterial3: true,
      ),
      home: const MainMenu(),
    );
  }
}

/// Widget that hosts the Flame game within Flutter
class GameScreen extends StatefulWidget {
  final int levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final TrackBuilderGame game;

  @override
  void initState() {
    super.initState();
    game = TrackBuilderGame(levelId: widget.levelId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game canvas
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'BuildHud': (ctx, g) => _BuildHud(game: game),
              'RunHud': (ctx, g) => _RunHud(game: game),
              'LevelComplete': (ctx, g) => _LevelCompleteOverlay(
                    game: game,
                    onNext: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              GameScreen(levelId: widget.levelId + 1),
                        ),
                      );
                    },
                    onRetry: () => game.resetLevel(),
                    onMenu: () => Navigator.pop(context),
                  ),
              'LevelFailed': (ctx, g) => _LevelFailedOverlay(
                    onRetry: () => game.resetLevel(),
                    onMenu: () => Navigator.pop(context),
                  ),
              'InvalidTrack': (ctx, g) => const _InvalidTrackToast(),
              'Tutorial': (ctx, g) => _TutorialOverlay(
                    onDismiss: () => game.overlays.remove('Tutorial'),
                  ),
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BUILD PHASE HUD
// ---------------------------------------------------------------------------

class _BuildHud extends StatefulWidget {
  final TrackBuilderGame game;

  const _BuildHud({required this.game});

  @override
  State<_BuildHud> createState() => _BuildHudState();
}

class _BuildHudState extends State<_BuildHud> {
  @override
  void initState() {
    super.initState();
    widget.game.onStateChanged = () {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    widget.game.onStateChanged = null;
    super.dispose();
  }

  String _getHintText() {
    final game = widget.game;
    if (game.placedPieceComponents.isEmpty) {
      return 'Start by placing a piece next to the green arrow!';
    }
    if (game.validateTrack()) {
      return 'Track is connected! Press GO to launch the car!';
    }
    final startRow = game.startCell.row;
    final endRow = game.endCell.row;
    final endCol = game.endCell.col;
    if (endRow < startRow) {
      return 'Build towards the top-right to reach the finish flag!';
    } else if (endRow > startRow) {
      return 'Build downward to reach the finish flag!';
    } else {
      return 'Build to the right (column $endCol) to reach the flag!';
    }
  }

  TrackPieceType? get _selectedType => widget.game.selectedPieceType;
  set _selectedType(TrackPieceType? val) => widget.game.selectedPieceType = val;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar: back button + level name + clear button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _HudButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.game.levelData.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black54),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${widget.game.placedPieceComponents.length} pieces',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          if (widget.game.levelData.targetPieces != null) ...[
                            Text(
                              ' / ${widget.game.levelData.targetPieces}',
                              style: TextStyle(
                                color: widget.game.placedPieceComponents.length <=
                                        widget.game.levelData.targetPieces!
                                    ? Colors.green
                                    : Colors.orange,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (widget.game.levelData.targetTime != null) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.timer, color: Colors.white38, size: 12),
                            Text(
                              ' ${widget.game.levelData.targetTime!.toInt()}s',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Hint button (shows path direction)
                _HudButton(
                  icon: Icons.lightbulb_outline,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _getHintText(),
                          style: const TextStyle(fontSize: 14),
                        ),
                        backgroundColor: Colors.orange.shade700,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                // Eraser toggle
                GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.game.removeMode = !widget.game.removeMode;
                      if (widget.game.removeMode) {
                        _selectedType = null;
                      }
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.game.removeMode
                          ? Colors.red.withAlpha(180)
                          : Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                      border: widget.game.removeMode
                          ? Border.all(color: Colors.red, width: 2)
                          : null,
                    ),
                    child: Icon(
                      Icons.backspace_outlined,
                      color: widget.game.removeMode
                          ? Colors.white
                          : Colors.white70,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _HudButton(
                  icon: Icons.delete_outline,
                  onTap: () {
                    widget.game.clearTrack();
                    setState(() {});
                  },
                ),
                const SizedBox(width: 8),
                // GO button
                GestureDetector(
                  onTap: () => widget.game.launchCar(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'GO!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom: piece palette
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.game.levelData.availablePieces.map((pieceId) {
                final type = TrackPieceType.values.byName(pieceId);
                final remaining =
                    widget.game.piecesRemaining[pieceId] ?? 0;
                final isSelected = _selectedType == type;

                return GestureDetector(
                  onTap: remaining > 0
                      ? () => setState(() {
                            _selectedType =
                                isSelected ? null : type;
                            widget.game.removeMode = false;
                          })
                      : null,
                  child: _PalettePiece(
                    type: type,
                    remaining: remaining,
                    isSelected: isSelected,
                  ),
                );
              }).toList(),
            ),
          ),

          // Bonus objective
          if (widget.game.levelData.hasBonusObjective &&
              widget.game.levelData.bonusDescription != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Bonus: ${widget.game.levelData.bonusDescription}',
                      style: const TextStyle(
                          color: Colors.amber, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),

          // Instructions
          if (_selectedType != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Tap on the grid to place  |  Tap placed piece to rotate',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PalettePiece extends StatelessWidget {
  final TrackPieceType type;
  final int remaining;
  final bool isSelected;

  const _PalettePiece({
    required this.type,
    required this.remaining,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 72,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: remaining > 0
            ? (isSelected
                ? Colors.blue.withOpacity(0.6)
                : Colors.white12)
            : Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Colors.blue, width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _pieceIcon(type),
            color: remaining > 0 ? _pieceColor(type) : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 2),
          Text(
            'x$remaining',
            style: TextStyle(
              color: remaining > 0 ? Colors.white : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _pieceName(type),
            style: const TextStyle(color: Colors.white54, fontSize: 9),
          ),
        ],
      ),
    );
  }

  IconData _pieceIcon(TrackPieceType type) {
    switch (type) {
      case TrackPieceType.straight:
        return Icons.horizontal_rule;
      case TrackPieceType.ramp:
        return Icons.trending_up;
      case TrackPieceType.curveLeft:
        return Icons.turn_left;
      case TrackPieceType.curveRight:
        return Icons.turn_right;
      case TrackPieceType.loop:
        return Icons.loop;
      case TrackPieceType.jump:
        return Icons.flight_takeoff;
      case TrackPieceType.tunnel:
        return Icons.width_normal;
      case TrackPieceType.bridge:
        return Icons.architecture;
      case TrackPieceType.booster:
        return Icons.bolt;
    }
  }

  Color _pieceColor(TrackPieceType type) {
    switch (type) {
      case TrackPieceType.straight:
        return Colors.orange;
      case TrackPieceType.ramp:
        return Colors.green;
      case TrackPieceType.curveLeft:
      case TrackPieceType.curveRight:
        return Colors.blue;
      case TrackPieceType.loop:
        return Colors.purple;
      case TrackPieceType.jump:
        return Colors.red;
      case TrackPieceType.tunnel:
        return Colors.brown;
      case TrackPieceType.bridge:
        return Colors.grey;
      case TrackPieceType.booster:
        return Colors.deepOrange;
    }
  }

  String _pieceName(TrackPieceType type) {
    switch (type) {
      case TrackPieceType.straight:
        return 'Straight';
      case TrackPieceType.ramp:
        return 'Ramp';
      case TrackPieceType.curveLeft:
        return 'Curve L';
      case TrackPieceType.curveRight:
        return 'Curve R';
      case TrackPieceType.loop:
        return 'Loop';
      case TrackPieceType.jump:
        return 'Jump';
      case TrackPieceType.tunnel:
        return 'Tunnel';
      case TrackPieceType.bridge:
        return 'Bridge';
      case TrackPieceType.booster:
        return 'Boost';
    }
  }
}

// ---------------------------------------------------------------------------
// RUN PHASE HUD
// ---------------------------------------------------------------------------

class _RunHud extends StatelessWidget {
  final TrackBuilderGame game;

  const _RunHud({required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HudButton(
              icon: Icons.stop,
              onTap: () => game.resetLevel(),
            ),
            const Spacer(),
            // Timer and speed display
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
              ),
              child: StreamBuilder(
                stream: Stream.periodic(const Duration(milliseconds: 100)),
                builder: (ctx, _) {
                  final speed = game.car != null
                      ? game.physicsSystem.getSpeed(game.car!.body)
                      : 0.0;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${game.runTime.toStringAsFixed(1)}s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.speed,
                        color: speed > 5
                            ? Colors.red
                            : speed > 2
                                ? Colors.orange
                                : Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        speed.toStringAsFixed(1),
                        style: TextStyle(
                          color: speed > 5
                              ? Colors.red
                              : speed > 2
                                  ? Colors.orange
                                  : Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LEVEL COMPLETE OVERLAY
// ---------------------------------------------------------------------------

class _LevelCompleteOverlay extends StatefulWidget {
  final TrackBuilderGame game;
  final VoidCallback onNext;
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  const _LevelCompleteOverlay({
    required this.game,
    required this.onNext,
    required this.onRetry,
    required this.onMenu,
  });

  @override
  State<_LevelCompleteOverlay> createState() => _LevelCompleteOverlayState();
}

class _LevelCompleteOverlayState extends State<_LevelCompleteOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _starController;
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _bounceController.forward();
  }

  @override
  void dispose() {
    _starController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stars = widget.game.earnedStars;
    final coins = widget.game.earnedCoins;

    return Stack(
      children: [
        // Confetti particles
        ..._buildConfetti(context),
        Center(
          child: ScaleTransition(
        scale: _bounceAnim,
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xEE1A1A2E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amber, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Level Complete!',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Animated stars
              AnimatedBuilder(
                animation: _starController,
                builder: (context, _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final starDelay = i * 0.3;
                      final progress = (_starController.value - starDelay)
                          .clamp(0.0, 0.4) / 0.4;
                      final earned = i < stars;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Transform.scale(
                          scale: earned ? (0.5 + progress * 0.5) : 1.0,
                          child: Transform.rotate(
                            angle: earned ? (1 - progress) * 0.5 : 0,
                            child: Icon(
                              earned && progress > 0
                                  ? Icons.star
                                  : Icons.star_border,
                              color: earned && progress > 0
                                  ? Colors.amber
                                  : Colors.grey,
                              size: 52,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Time
              Text(
                'Time: ${widget.game.runTime.toStringAsFixed(1)}s',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 8),

              // Coins
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on,
                      color: Colors.amber, size: 24),
                  const SizedBox(width: 4),
                  Text(
                    '+$coins',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HudButton(icon: Icons.home, onTap: widget.onMenu, size: 48),
                  const SizedBox(width: 16),
                  _HudButton(icon: Icons.replay, onTap: widget.onRetry, size: 48),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: widget.onNext,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
      ],
    );
  }

  List<Widget> _buildConfetti(BuildContext context) {
    final rng = math.Random(42);
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final colors = [
      Colors.amber,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];

    return List.generate(20, (i) {
      final startX = rng.nextDouble() * screenW;
      final color = colors[rng.nextInt(colors.length)];
      final size = 6.0 + rng.nextDouble() * 8;
      final delay = Duration(milliseconds: rng.nextInt(1500));
      final duration = Duration(milliseconds: 1500 + rng.nextInt(1000));

      return _ConfettiPiece(
        startX: startX,
        screenH: screenH,
        color: color,
        size: size,
        delay: delay,
        duration: duration,
      );
    });
  }
}

class _ConfettiPiece extends StatefulWidget {
  final double startX;
  final double screenH;
  final Color color;
  final double size;
  final Duration delay;
  final Duration duration;

  const _ConfettiPiece({
    required this.startX,
    required this.screenH,
    required this.color,
    required this.size,
    required this.delay,
    required this.duration,
  });

  @override
  State<_ConfettiPiece> createState() => _ConfettiPieceState();
}

class _ConfettiPieceState extends State<_ConfettiPiece>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Positioned(
          left: widget.startX + math.sin(t * 6) * 30,
          top: -20 + t * (widget.screenH + 40),
          child: Opacity(
            opacity: t < 0.8 ? 1.0 : (1.0 - (t - 0.8) / 0.2),
            child: Transform.rotate(
              angle: t * 8,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// LEVEL FAILED OVERLAY
// ---------------------------------------------------------------------------

class _LevelFailedOverlay extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  const _LevelFailedOverlay({
    required this.onRetry,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xEE1A1A2E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.red.shade400, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Oops! Try again!',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The car didn\'t make it.\nAdjust your track and try again!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HudButton(icon: Icons.home, onTap: onMenu, size: 48),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.replay, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Try Again',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// INVALID TRACK TOAST
// ---------------------------------------------------------------------------

class _InvalidTrackToast extends StatelessWidget {
  const _InvalidTrackToast();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Track not connected! Connect start to end.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TUTORIAL OVERLAY
// ---------------------------------------------------------------------------

class _TutorialOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const _TutorialOverlay({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xEE1A1A2E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'How to Play',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _tutorialStep(
                  Icons.touch_app,
                  '1. Pick a track piece from the bottom',
                ),
                _tutorialStep(
                  Icons.grid_on,
                  '2. Tap on the grid to place it',
                ),
                _tutorialStep(
                  Icons.rotate_right,
                  '3. Tap a placed piece to rotate it',
                ),
                _tutorialStep(
                  Icons.route,
                  '4. Connect start (green) to end (flag)',
                ),
                _tutorialStep(
                  Icons.play_arrow,
                  '5. Press GO to launch the car!',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tap anywhere to start building',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tutorialStep(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SHARED HUD BUTTON
// ---------------------------------------------------------------------------

class _HudButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _HudButton({
    required this.icon,
    required this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.6),
      ),
    );
  }
}
