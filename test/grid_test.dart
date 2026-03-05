import 'package:flutter_test/flutter_test.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:track_builder/game/components/grid.dart';

void main() {
  group('GridSystem', () {
    late GridSystem grid;

    setUp(() {
      grid = GridSystem(gridSize: 1.0);
      grid.initialize(columns: 8, rows: 6);
    });

    test('initializes with correct dimensions', () {
      expect(grid.columns, 8);
      expect(grid.rows, 6);
    });

    test('all cells start empty', () {
      for (int r = 0; r < 6; r++) {
        for (int c = 0; c < 8; c++) {
          expect(grid.isCellEmpty(GridCell(col: c, row: r)), isTrue);
        }
      }
    });

    test('place and retrieve piece', () {
      final cell = GridCell(col: 3, row: 2);
      grid.placePiece(cell, 'straight');

      expect(grid.isCellEmpty(cell), isFalse);
      expect(grid.getPieceAt(cell), 'straight');
    });

    test('remove piece makes cell empty again', () {
      final cell = GridCell(col: 3, row: 2);
      grid.placePiece(cell, 'straight');
      grid.removePiece(cell);

      expect(grid.isCellEmpty(cell), isTrue);
      expect(grid.getPieceAt(cell), isNull);
    });

    test('out of bounds cells are not empty', () {
      expect(grid.isCellEmpty(GridCell(col: -1, row: 0)), isFalse);
      expect(grid.isCellEmpty(GridCell(col: 8, row: 0)), isFalse);
      expect(grid.isCellEmpty(GridCell(col: 0, row: -1)), isFalse);
      expect(grid.isCellEmpty(GridCell(col: 0, row: 6)), isFalse);
    });

    test('out of bounds getPieceAt returns null', () {
      expect(grid.getPieceAt(GridCell(col: -1, row: 0)), isNull);
      expect(grid.getPieceAt(GridCell(col: 99, row: 99)), isNull);
    });

    test('worldToGrid conversion', () {
      final cell = grid.worldToGrid(Vector2(3.6, 2.4));
      expect(cell.col, 4);
      expect(cell.row, 2);
    });

    test('worldToGrid clamps to grid bounds', () {
      final cell = grid.worldToGrid(Vector2(-5.0, -5.0));
      expect(cell.col, 0);
      expect(cell.row, 0);

      final cell2 = grid.worldToGrid(Vector2(100.0, 100.0));
      expect(cell2.col, 7);
      expect(cell2.row, 5);
    });

    test('gridToWorld returns cell center', () {
      final pos = grid.gridToWorld(GridCell(col: 0, row: 0));
      expect(pos.x, 0.5);
      expect(pos.y, 0.5);

      final pos2 = grid.gridToWorld(GridCell(col: 3, row: 2));
      expect(pos2.x, 3.5);
      expect(pos2.y, 2.5);
    });

    test('snapToGrid round-trips through worldToGrid/gridToWorld', () {
      final snapped = grid.snapToGrid(Vector2(3.3, 2.7));
      // (3.3, 2.7) rounds to cell (3, 3), center is (3.5, 3.5)
      expect(snapped.x, 3.5);
      expect(snapped.y, 3.5);
    });

    test('clearAll empties all cells', () {
      grid.placePiece(GridCell(col: 0, row: 0), 'a');
      grid.placePiece(GridCell(col: 5, row: 3), 'b');
      grid.clearAll();

      expect(grid.isCellEmpty(GridCell(col: 0, row: 0)), isTrue);
      expect(grid.isCellEmpty(GridCell(col: 5, row: 3)), isTrue);
    });
  });

  group('GridCell', () {
    test('equality works', () {
      expect(GridCell(col: 1, row: 2), GridCell(col: 1, row: 2));
      expect(GridCell(col: 1, row: 2) == GridCell(col: 2, row: 1), isFalse);
    });

    test('hashCode is consistent', () {
      final a = GridCell(col: 3, row: 4);
      final b = GridCell(col: 3, row: 4);
      expect(a.hashCode, b.hashCode);
    });

    test('can be used as map key', () {
      final map = <GridCell, String>{};
      map[GridCell(col: 1, row: 2)] = 'hello';
      expect(map[GridCell(col: 1, row: 2)], 'hello');
    });

    test('toString', () {
      expect(GridCell(col: 3, row: 4).toString(), 'GridCell(3, 4)');
    });
  });
}
