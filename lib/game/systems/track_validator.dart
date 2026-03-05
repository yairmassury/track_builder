import 'dart:collection';

import '../components/grid.dart';
import '../components/track_piece.dart';

/// Validates track connectivity using BFS from start to end.
///
/// Checks that placed track pieces form a continuous path
/// from the start cell to the end cell, with entry/exit
/// points properly aligned between adjacent pieces.
class TrackValidator {
  /// Validates that a connected path exists from start to end.
  ///
  /// Returns true if the track is valid and the car can
  /// theoretically reach the end.
  static bool isValid({
    required GridSystem grid,
    required Map<GridCell, PlacedPiece> pieces,
    required GridCell startCell,
    required GridCell endCell,
  }) {
    if (pieces.isEmpty) return false;
    if (!pieces.containsKey(startCell)) return false;
    if (!pieces.containsKey(endCell)) return false;

    // BFS from start to end
    final visited = <GridCell>{};
    final queue = Queue<GridCell>();
    queue.add(startCell);
    visited.add(startCell);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      if (current == endCell) return true;

      final currentPiece = pieces[current];
      if (currentPiece == null) continue;

      // Get all cells this piece connects to via its exit points
      final neighbors = _getConnectedNeighbors(
        current,
        currentPiece,
        pieces,
      );

      for (final neighbor in neighbors) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add(neighbor);
        }
      }
    }

    return false;
  }

  /// Find neighboring cells that are connected to the current piece.
  ///
  /// A connection exists when the current piece's exit direction
  /// matches the neighbor piece's entry direction.
  static List<GridCell> _getConnectedNeighbors(
    GridCell cell,
    PlacedPiece piece,
    Map<GridCell, PlacedPiece> allPieces,
  ) {
    final result = <GridCell>[];

    // Get exit directions for this piece type (considering rotation)
    final exits = _getExitDirections(piece.type, piece.rotation);

    for (final dir in exits) {
      final neighborCell = GridCell(
        col: cell.col + dir.dx,
        row: cell.row + dir.dy,
      );

      final neighborPiece = allPieces[neighborCell];
      if (neighborPiece == null) continue;

      // Check if the neighbor accepts entry from the opposite direction
      final oppositeDir = _Direction(-dir.dx, -dir.dy);
      final neighborEntries =
          _getEntryDirections(neighborPiece.type, neighborPiece.rotation);

      if (neighborEntries.any((e) => e.dx == oppositeDir.dx && e.dy == oppositeDir.dy)) {
        result.add(neighborCell);
      }
    }

    return result;
  }

  /// Get the directions a piece type exits to, accounting for rotation.
  /// Rotation: 0=default, 1=90CW, 2=180, 3=270CW
  static List<_Direction> _getExitDirections(TrackPieceType type, int rotation) {
    final base = _baseExitDirections(type);
    return base.map((d) => _rotate(d, rotation)).toList();
  }

  static List<_Direction> _getEntryDirections(TrackPieceType type, int rotation) {
    final base = _baseEntryDirections(type);
    return base.map((d) => _rotate(d, rotation)).toList();
  }

  /// Base exit directions (rotation=0) for each piece type.
  /// Right = (1,0), Down = (0,1), Left = (-1,0), Up = (0,-1)
  static List<_Direction> _baseExitDirections(TrackPieceType type) {
    switch (type) {
      case TrackPieceType.straight:
      case TrackPieceType.tunnel:
      case TrackPieceType.bridge:
      case TrackPieceType.booster:
        return [const _Direction(1, 0)]; // Exits right
      case TrackPieceType.ramp:
        return [const _Direction(1, 0)]; // Exits right (and up)
      case TrackPieceType.curveLeft:
        return [const _Direction(0, -1)]; // Exits up
      case TrackPieceType.curveRight:
        return [const _Direction(0, 1)]; // Exits down
      case TrackPieceType.loop:
        return [const _Direction(1, 0)]; // Exits right
      case TrackPieceType.jump:
        return [const _Direction(1, 0)]; // Exits right
    }
  }

  /// Base entry directions (rotation=0) for each piece type.
  static List<_Direction> _baseEntryDirections(TrackPieceType type) {
    switch (type) {
      case TrackPieceType.straight:
      case TrackPieceType.tunnel:
      case TrackPieceType.bridge:
      case TrackPieceType.booster:
        return [const _Direction(-1, 0)]; // Enters from left
      case TrackPieceType.ramp:
        return [const _Direction(-1, 0)]; // Enters from left
      case TrackPieceType.curveLeft:
        return [const _Direction(-1, 0)]; // Enters from left
      case TrackPieceType.curveRight:
        return [const _Direction(-1, 0)]; // Enters from left
      case TrackPieceType.loop:
        return [const _Direction(-1, 0)]; // Enters from left
      case TrackPieceType.jump:
        return [const _Direction(-1, 0)]; // Enters from left
    }
  }

  /// Rotate a direction 90 degrees clockwise, [times] times.
  static _Direction _rotate(_Direction dir, int times) {
    var d = dir;
    for (int i = 0; i < (times % 4); i++) {
      // 90 CW: (x,y) -> (y, -x) ... wait, in screen coords:
      // Right(1,0) -> Down(0,1) -> Left(-1,0) -> Up(0,-1)
      d = _Direction(-d.dy, d.dx);
    }
    return d;
  }
}

/// Represents a placed piece on the grid with its rotation.
class PlacedPiece {
  final TrackPieceType type;
  final int rotation; // 0, 1, 2, 3 (x90 degrees CW)

  const PlacedPiece({required this.type, this.rotation = 0});
}

class _Direction {
  final int dx;
  final int dy;

  const _Direction(this.dx, this.dy);
}
