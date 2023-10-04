import 'dart:ui' as ui;

import 'package:bitmap_algorithms/canvas_history_manager.dart';
import 'package:bitmap_algorithms/gesture_event.dart';
import 'package:flutter/cupertino.dart';

class CurvePainter extends CustomPainter with CanvasHistoryManager{
  final List<GestureEvent> gestureEvents;
  final ui.Image? image;
  final bool clearFlag;
  final Path path;

  CurvePainter({
    required this.gestureEvents,
    required this.clearFlag,
    required this.path,
    this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    drawHistory(canvas, image, clearFlag);
    if (gestureEvents.isNotEmpty){
      if (gestureEvents.length == 1) {
        path.moveTo(gestureEvents.last.position.dx, gestureEvents.last.position.dy);
      } else {
        if (gestureEvents.last.type == GestureEventType.panUpdate){
          path.lineTo(gestureEvents.last.position.dx, gestureEvents.last.position.dy);
        }
        canvas.drawPath(path, gestureEvents.last.style..style = PaintingStyle.stroke);
        if(gestureEvents.last.type == GestureEventType.panEnd){
          path.reset();
        }
      }
    }
  }
}