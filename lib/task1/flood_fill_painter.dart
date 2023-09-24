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

  FloodFillPainter(
      {required this.gestureEvents,
      required this.clearFlag,
      this.byteData,
      this.image});

  @override
  void paint(Canvas canvas, Size size) {
    drawHistory(canvas, image, clearFlag);

    if (gestureEvents.isEmpty || byteData == null) {
      return;
    }

    final int width = image!.width;
    final int height = image!.height;

    final List<Offset> points = [];

    void floodFill(int x, int y, Color targetColor) {
      if (x < 0 || x >= width || y < 0 || y >= height) {
        return;
      }

      final int currentPixelOffset = (y * width + x) * 4;
      final Color currentPixelColor = Color.fromRGBO(
        byteData!.getUint8(currentPixelOffset),
        byteData!.getUint8(currentPixelOffset + 1),
        byteData!.getUint8(currentPixelOffset + 2),
        byteData!.getUint8(currentPixelOffset + 3) / 255.0,
      );

      if (currentPixelColor != targetColor) {
        return;
      }

      int left = x;
      int right = x;

      // Находим левую границу
      while (left >= 0 &&
          Color.fromRGBO(
                  byteData!.getUint8((y * width + left) * 4),
                  byteData!.getUint8((y * width + left) * 4 + 1),
                  byteData!.getUint8((y * width + left) * 4 + 2),
                  byteData!.getUint8((y * width + left) * 4 + 3) / 255.0) ==
              targetColor) {
        left--;
      }

      // Находим правую границу
      while (right < width &&
          Color.fromRGBO(
                  byteData!.getUint8((y * width + right) * 4),
                  byteData!.getUint8((y * width + right) * 4 + 1),
                  byteData!.getUint8((y * width + right) * 4 + 2),
                  byteData!.getUint8((y * width + right) * 4 + 3) / 255.0) ==
              targetColor) {
        right++;
      }

      // Рисуем линию между левой и правой границами
      for (int i = left + 1; i < right; i++) {
        points.add(Offset(i.toDouble(), y.toDouble()));
      }

      // Рекурсивно обрабатываем верхнюю и нижнюю строки
      for (int i = left + 1; i < right; i++) {
        floodFill(i, y - 1, targetColor); // Верхняя строка
        floodFill(i, y + 1, targetColor); // Нижняя строка
      }
    }

    final int targetPixelX = gestureEvents.last.position.dx.toInt();
    final int targetPixelY = gestureEvents.last.position.dy.toInt();

    final Color targetColor = Color.fromRGBO(
      byteData!.getUint8((targetPixelY * width + targetPixelX) * 4),
      byteData!.getUint8((targetPixelY * width + targetPixelX) * 4 + 1),
      byteData!.getUint8((targetPixelY * width + targetPixelX) * 4 + 2),
      byteData!.getUint8((targetPixelY * width + targetPixelX) * 4 + 3) / 255.0,
    );

    floodFill(targetPixelX, targetPixelY, targetColor);

    canvas.drawPoints(ui.PointMode.points, points, gestureEvents.last.style);
  }
}
