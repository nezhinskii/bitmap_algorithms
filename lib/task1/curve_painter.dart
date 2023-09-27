import 'dart:ui' as ui;

import 'package:bitmap_algorithms/canvas_history_manager.dart';
import 'package:bitmap_algorithms/gesture_event.dart';
import 'package:flutter/cupertino.dart';

class CurvePainter extends CustomPainter with CanvasHistoryManager{
  final List<GestureEvent> gestureEvents;
  final ui.Image? image;
  final bool clearFlag;

  CurvePainter({
    required this.gestureEvents,
    required this.clearFlag,
    this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    drawHistory(canvas, image, clearFlag);
    if (gestureEvents.isNotEmpty){
      canvas.drawPoints(
        ui.PointMode.polygon,
        gestureEvents.map((e) => e.position).toList(),
        gestureEvents.last.style
      );
    }
  }
}