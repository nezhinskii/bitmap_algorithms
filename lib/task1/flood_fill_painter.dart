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


    // canvas.drawPoints(ui.PointMode.points, points, gestureEvents.last.style);
  }
}
