import 'package:flame_forge2d/flame_forge2d.dart';

/// Grid system for track piece placement.
///
/// Provides snap-to-grid functionality so kids can easily place
/// pieces with their fingers.
class GridSystem {
  final double gridSize;

  int _columns = 0;
  int _rows = 0;

  late List<List<String?>> _cells;

  GridCell? startCell;
  GridCell? endCell;

  /// Start position in physics world coordinates
  Vector2 get startPosition {
    if (startCell == null) return Vector2.zero();
    return Vector2(
      (startCell!.col + 0.5) * gridSize,
      (startCell!.row + 0.5) * gridSize,
    );
  }

  /// End position in physics world coordinates
  Vector2 get endPosition {
    if (endCell == null) return Vector2.zero();
    return Vector2(
      (endCell!.col + 0.5) * gridSize,
      (endCell!.row + 0.5) * gridSize,
    );
  }

  GridSystem({required this.gridSize});

  int get columns => _columns;
  int get rows => _rows;

  void initialize({required int columns, required int rows}) {
    _columns = columns;
    _rows = rows;
    _cells = List.generate(
      rows,
      (_) => List.filled(columns, null),
    );
  }

  GridCell worldToGrid(Vector2 worldPos) {
    return GridCell(
      col: (worldPos.x / gridSize).round().clamp(0, _columns - 1),
      row: (worldPos.y / gridSize).round().clamp(0, _rows - 1),
    );
  }

  Vector2 gridToWorld(GridCell cell) {
    return Vector2(
      cell.col * gridSize + gridSize / 2,
      cell.row * gridSize + gridSize / 2,
    );
  }

  Vector2 snapToGrid(Vector2 worldPos) {
    final cell = worldToGrid(worldPos);
    return gridToWorld(cell);
  }

  bool isCellEmpty(GridCell cell) {
    if (cell.row < 0 || cell.row >= _rows) return false;
    if (cell.col < 0 || cell.col >= _columns) return false;
    return _cells[cell.row][cell.col] == null;
  }

  void placePiece(GridCell cell, String pieceId) {
    _cells[cell.row][cell.col] = pieceId;
  }

  void removePiece(GridCell cell) {
    _cells[cell.row][cell.col] = null;
  }

  String? getPieceAt(GridCell cell) {
    if (cell.row < 0 || cell.row >= _rows) return null;
    if (cell.col < 0 || cell.col >= _columns) return null;
    return _cells[cell.row][cell.col];
  }

  void clearAll() {
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _columns; c++) {
        _cells[r][c] = null;
      }
    }
  }
}

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
