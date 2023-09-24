import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bitmap_algorithms/gesture_event.dart';
import 'package:bitmap_algorithms/canvas_history_manager.dart';
import 'package:flutter/rendering.dart';

class FloodFillPainter extends CustomPainter with CanvasHistoryManager {
  final List<GestureEvent> gestureEvents;
  final ui.Image? image;
  final ByteData? byteData;
  final bool clearFlag;

  FloodFillPainter({
    required this.gestureEvents,
    required this.clearFlag,
    this.byteData,
    this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    drawHistory(canvas, image, clearFlag);

    if (gestureEvents.isEmpty || byteData == null) {
      return;
    }

    final int width = image!.width;
    final int height = image!.height;
    Uint8List uint8List = byteData!.buffer.asUint8List();

    final int targetPixelX = gestureEvents.last.position.dx.toInt();
    final int targetPixelY = gestureEvents.last.position.dy.toInt();

    final int targetPixelOffset = (targetPixelY * width + targetPixelX) * 4;

    final Color targetColor = Color.fromRGBO(
      uint8List[targetPixelOffset],
      uint8List[targetPixelOffset + 1],
      uint8List[targetPixelOffset + 2],
      uint8List[targetPixelOffset + 3] / 255.0,
    );

    final List<Offset> points = [];
    final List<List<bool>> visited = List.generate(
      width,
      (i) => List<bool>.filled(height, false),
    );

    final List<List<int>> stack = [];

    stack.add([targetPixelX, targetPixelY]);

    while (stack.isNotEmpty) {
      final currentPoint = stack.removeLast();
      final x = currentPoint[0];
      final y = currentPoint[1];

      if (x >= 0 && x < width && y >= 0 && y < height && !visited[x][y]) {
        visited[x][y] = true;

        final int currentPixelOffset = (y * width + x) * 4;
        final Color currentPixelColor = Color.fromRGBO(
          uint8List[currentPixelOffset],
          uint8List[currentPixelOffset + 1],
          uint8List[currentPixelOffset + 2],
          uint8List[currentPixelOffset + 3] / 255.0,
        );

        if (currentPixelColor == targetColor) {
          int left = x;
          int right = x;

          while (left >= 0 &&
              Color.fromRGBO(
                      uint8List[(y * width + left) * 4],
                      uint8List[(y * width + left) * 4 + 1],
                      uint8List[(y * width + left) * 4 + 2],
                      uint8List[(y * width + left) * 4 + 3] / 255.0) ==
                  targetColor) {
            left--;
          }

          while (right < width &&
              Color.fromRGBO(
                      uint8List[(y * width + right) * 4],
                      uint8List[(y * width + right) * 4 + 1],
                      uint8List[(y * width + right) * 4 + 2],
                      uint8List[(y * width + right) * 4 + 3] / 255.0) ==
                  targetColor) {
            right++;
          }

          for (int i = left + 1; i < right; i++) {
            visited[i][y] = true;
            var color = gestureEvents.last.style.color;
            var offset = (y * width + i) * 4;
            uint8List[offset] = color.red;
            uint8List[offset + 1] = color.green;
            uint8List[offset + 2] = color.blue;
            uint8List[offset + 3] = color.alpha;
            //points.add(Offset(i.toDouble(), y.toDouble()));

            if (y > 0) {
              stack.add([i, y - 1]);
            }
            if (y < height - 1) {
              stack.add([i, y + 1]);
            }
          }
        }
      }
    }
    ui.Image? img;
    ui.decodeImageFromList(uint8List, (result) {
      img = result.clone();
    });

    //canvas.drawImage(img!, Offset.zero, Paint());
    //canvas.drawPoints(ui.PointMode.points, points, gestureEvents.last.style);
  }
}
