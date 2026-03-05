import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

/// Grid system for track piece placement.
///
/// Provides snap-to-grid functionality so kids can easily place
/// pieces with their fingers. Grid cells highlight to show valid
/// placement positions.
class GridSystem {
  final double gridSize;

  int _columns = 0;
  int _rows = 0;

  /// Grid cell states: null = empty, string = piece ID
  late List<List<String?>> _cells;

  /// Start position (where the car launches from)
  Vector2 startPosition = Vector2.zero();

  /// End position (where the car needs to reach)
  Vector2 endPosition = Vector2.zero();

  GridSystem({required this.gridSize});

  int get columns => _columns;
  int get rows => _rows;

  /// Initialize the grid with the given dimensions
  void initialize({required int columns, required int rows}) {
    _columns = columns;
    _rows = rows;
    _cells = List.generate(
      rows,
      (_) => List.filled(columns, null),
    );
  }

  /// Convert a world position to the nearest grid cell
  GridCell worldToGrid(Vector2 worldPos) {
    return GridCell(
      col: (worldPos.x / gridSize).round().clamp(0, _columns - 1),
      row: (worldPos.y / gridSize).round().clamp(0, _rows - 1),
    );
  }

  /// Convert a grid cell to world position (center of cell)
  Vector2 gridToWorld(GridCell cell) {
    return Vector2(
      cell.col * gridSize + gridSize / 2,
      cell.row * gridSize + gridSize / 2,
    );
  }

  /// Snap a world position to the nearest grid center
  Vector2 snapToGrid(Vector2 worldPos) {
    final cell = worldToGrid(worldPos);
    return gridToWorld(cell);
  }

  /// Check if a grid cell is empty
  bool isCellEmpty(GridCell cell) {
    if (cell.row < 0 || cell.row >= _rows) return false;
    if (cell.col < 0 || cell.col >= _columns) return false;
    return _cells[cell.row][cell.col] == null;
  }

  /// Place a piece at a grid cell
  void placePiece(GridCell cell, String pieceId) {
    _cells[cell.row][cell.col] = pieceId;
  }

  /// Remove a piece from a grid cell
  void removePiece(GridCell cell) {
    _cells[cell.row][cell.col] = null;
  }

  /// Get the piece ID at a grid cell
  String? getPieceAt(GridCell cell) {
    if (cell.row < 0 || cell.row >= _rows) return null;
    if (cell.col < 0 || cell.col >= _columns) return null;
    return _cells[cell.row][cell.col];
  }

  /// Clear all pieces from the grid
  void clearAll() {
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _columns; c++) {
        _cells[r][c] = null;
      }
    }
  }
}

/// Represents a position on the grid
class GridCell {
  final int col;
  final int row;

  const GridCell({required this.col, required this.row});

  @override
  bool operator ==(Object other) =>
      other is GridCell && other.col == col && other.row == row;

  @override
  int get hashCode => col.hashCode ^ row.hashCode;

  @override
  String toString() => 'GridCell($col, $row)';
}
