import 'package:flutter_test/flutter_test.dart';
import 'package:track_builder/game/components/grid.dart';
import 'package:track_builder/game/components/track_piece.dart';
import 'package:track_builder/game/systems/track_validator.dart';

void main() {
  late GridSystem grid;

  setUp(() {
    grid = GridSystem(gridSize: 1.0);
    grid.initialize(columns: 8, rows: 6);
  });

  group('TrackValidator', () {
    test('empty grid is invalid', () {
      expect(
        TrackValidator.isValid(
          grid: grid,
          pieces: {},
          startCell: GridCell(col: 0, row: 3),
          endCell: GridCell(col: 7, row: 3),
        ),
        isFalse,
      );
    });

    test('straight line from start to end is valid', () {
      final pieces = <GridCell, PlacedPiece>{};
      // Place straight pieces from col 0 to col 7, row 3
      for (int c = 0; c <= 7; c++) {
        pieces[GridCell(col: c, row: 3)] =
            const PlacedPiece(type: TrackPieceType.straight);
      }

      expect(
        TrackValidator.isValid(
          grid: grid,
          pieces: pieces,
          startCell: GridCell(col: 0, row: 3),
          endCell: GridCell(col: 7, row: 3),
        ),
        isTrue,
      );
    });

    test('disconnected pieces are invalid', () {
      final pieces = <GridCell, PlacedPiece>{
        GridCell(col: 0, row: 3):
            const PlacedPiece(type: TrackPieceType.straight),
        GridCell(col: 1, row: 3):
            const PlacedPiece(type: TrackPieceType.straight),
        // Gap at col 2-5
        GridCell(col: 6, row: 3):
            const PlacedPiece(type: TrackPieceType.straight),
        GridCell(col: 7, row: 3):
            const PlacedPiece(type: TrackPieceType.straight),
      };

      expect(
        TrackValidator.isValid(
          grid: grid,
          pieces: pieces,
          startCell: GridCell(col: 0, row: 3),
          endCell: GridCell(col: 7, row: 3),
        ),
        isFalse,
      );
    });

    test('start cell without a piece is invalid', () {
      final pieces = <GridCell, PlacedPiece>{
        GridCell(col: 1, row: 3):
            const PlacedPiece(type: TrackPieceType.straight),
      };

      expect(
        TrackValidator.isValid(
          grid: grid,
          pieces: pieces,
          startCell: GridCell(col: 0, row: 3),
          endCell: GridCell(col: 1, row: 3),
        ),
        isFalse,
      );
    });

    test('end cell without a piece is invalid', () {
      final pieces = <GridCell, PlacedPiece>{
        GridCell(col: 0, row: 3):
            const PlacedPiece(type: TrackPieceType.straight),
      };

      expect(
        TrackValidator.isValid(
          grid: grid,
          pieces: pieces,
          startCell: GridCell(col: 0, row: 3),
          endCell: GridCell(col: 7, row: 3),
        ),
        isFalse,
      );
    });

    test('L-shaped path with curves is valid', () {
      // Horizontal from (0,3) to (3,3), then curve up, then vertical to (3,0)
      // curveLeft exits up (0,-1). Opposite is (0,1).
      // Straight rotation=3: entry = rotate((-1,0), 3) = (0,1), exit = rotate((1,0), 3) = (0,-1)
      // So rotation=3 means: enters from below, exits up — correct for upward travel.
      final pieces = <GridCell, PlacedPiece>{
        GridCell(col: 0, row: 3):
            const PlacedPiece(type: TrackPieceType.straight),
        GridCell(col: 1, row: 3):
            const PlacedPiece(type: TrackPieceType.straight),
        GridCell(col: 2, row: 3):
            const PlacedPiece(type: TrackPieceType.straight),
        GridCell(col: 3, row: 3):
            const PlacedPiece(type: TrackPieceType.curveLeft),
        GridCell(col: 3, row: 2):
            const PlacedPiece(type: TrackPieceType.straight, rotation: 3),
        GridCell(col: 3, row: 1):
            const PlacedPiece(type: TrackPieceType.straight, rotation: 3),
        GridCell(col: 3, row: 0):
            const PlacedPiece(type: TrackPieceType.straight, rotation: 3),
      };

      expect(
        TrackValidator.isValid(
          grid: grid,
          pieces: pieces,
          startCell: GridCell(col: 0, row: 3),
          endCell: GridCell(col: 3, row: 0),
        ),
        isTrue,
      );
    });

    test('rotated straight pieces connect vertically', () {
      // Vertical path: straight pieces rotated 90 degrees
      final pieces = <GridCell, PlacedPiece>{};
      for (int r = 0; r <= 5; r++) {
        pieces[GridCell(col: 3, row: r)] =
            const PlacedPiece(type: TrackPieceType.straight, rotation: 1);
      }

      expect(
        TrackValidator.isValid(
          grid: grid,
          pieces: pieces,
          startCell: GridCell(col: 3, row: 0),
          endCell: GridCell(col: 3, row: 5),
        ),
        isTrue,
      );
    });
  });
}
