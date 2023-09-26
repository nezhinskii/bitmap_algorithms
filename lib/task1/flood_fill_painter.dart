import 'dart:ui' as ui;

import 'package:bitmap_algorithms/gesture_event.dart';
import 'package:bitmap_algorithms/canvas_history_manager.dart';
import 'package:flutter/rendering.dart';

class FloodFillPainter extends CustomPainter with CanvasHistoryManager {
  final List<GestureEvent> gestureEvents;
  final ui.Image? image;
  final bool clearFlag;

  FloodFillPainter({
    required this.gestureEvents,
    required this.clearFlag,
    this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    drawHistory(canvas, image, clearFlag);
  }
}
