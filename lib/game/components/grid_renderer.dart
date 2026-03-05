import 'dart:ui';

import 'package:flame/components.dart';

import 'grid.dart';

/// Visual renderer for the game grid.
///
/// Draws grid lines, start/end markers, and cell highlights.
/// This is a pure rendering component — no physics.
class GridRendererComponent extends PositionComponent {
  final GridSystem grid;
  final double pixelsPerUnit;

  /// Offset from game origin in pixels
  double offsetX = 0;
  double offsetY = 0;

  GridCell? highlightedCell;
  bool highlightValid = true;

  GridRendererComponent({
    required this.grid,
    required this.pixelsPerUnit,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    canvas.translate(offsetX, offsetY);

    _drawGridLines(canvas);
    _drawStartMarker(canvas);
    _drawEndMarker(canvas);
    _drawHighlight(canvas);

    canvas.restore();
  }

  void _drawGridLines(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0x30FFFFFF)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final cellSize = grid.gridSize * pixelsPerUnit;

    for (int c = 0; c <= grid.columns; c++) {
      final x = c * cellSize;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, grid.rows * cellSize),
        paint,
      );
    }

    for (int r = 0; r <= grid.rows; r++) {
      final y = r * cellSize;
      canvas.drawLine(
        Offset(0, y),
        Offset(grid.columns * cellSize, y),
        paint,
      );
    }
  }

  void _drawStartMarker(Canvas canvas) {
    final startCell = grid.startCell;
    if (startCell == null) return;

    final cellSize = grid.gridSize * pixelsPerUnit;
    final rect = Rect.fromLTWH(
      startCell.col * cellSize,
      startCell.row * cellSize,
      cellSize,
      cellSize,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = const Color(0x4000FF00)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xAA00FF00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Arrow pointing right
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final s = cellSize * 0.2;
    final path = Path()
      ..moveTo(cx - s, cy - s)
      ..lineTo(cx + s, cy)
      ..lineTo(cx - s, cy + s)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xCC00FF00)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawEndMarker(Canvas canvas) {
    final endCell = grid.endCell;
    if (endCell == null) return;

    final cellSize = grid.gridSize * pixelsPerUnit;
    final rect = Rect.fromLTWH(
      endCell.col * cellSize,
      endCell.row * cellSize,
      cellSize,
      cellSize,
    );

    // Checkered pattern
    final darkPaint = Paint()
      ..color = const Color(0xBB000000)
      ..style = PaintingStyle.fill;
    final lightPaint = Paint()
      ..color = const Color(0xBBFFFFFF)
      ..style = PaintingStyle.fill;

    final checkerSize = cellSize / 4;
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        final paint = (r + c) % 2 == 0 ? darkPaint : lightPaint;
        canvas.drawRect(
          Rect.fromLTWH(
            rect.left + c * checkerSize,
            rect.top + r * checkerSize,
            checkerSize,
            checkerSize,
          ),
          paint,
        );
      }
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xAAFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  void _drawHighlight(Canvas canvas) {
    if (highlightedCell == null) return;

    final cellSize = grid.gridSize * pixelsPerUnit;
    final rect = Rect.fromLTWH(
      highlightedCell!.col * cellSize,
      highlightedCell!.row * cellSize,
      cellSize,
      cellSize,
    );

    final color = highlightValid
        ? const Color(0x4000AAFF)
        : const Color(0x40FF0000);
    final borderColor = highlightValid
        ? const Color(0xAA00AAFF)
        : const Color(0xAAFF0000);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  void setHighlight(GridCell? cell, {bool valid = true}) {
    highlightedCell = cell;
    highlightValid = valid;
  }

  void clearHighlight() {
    highlightedCell = null;
  }
}
