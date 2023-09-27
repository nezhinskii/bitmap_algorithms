import 'dart:math';
import 'dart:ui' as ui;

import 'package:bitmap_algorithms/canvas_history_manager.dart';
import 'package:bitmap_algorithms/gesture_event.dart';
import 'package:flutter/rendering.dart';

class BresenhamPainter extends CustomPainter with CanvasHistoryManager {
  final List<GestureEvent> gestureEvents;
  final ui.Image? image;
  final bool clearFlag;

  BresenhamPainter({
    required this.gestureEvents,
    required this.clearFlag,
    this.image
  });

  List<Offset> bresenhamLine(Offset start, Offset end){
    int xStart = start.dx.toInt(), yStart = start.dy.toInt(), xEnd = end.dx.toInt(), yEnd = end.dy.toInt();
    int dx = (xEnd - xStart).abs(), dy = (yEnd - yStart).abs();
    final res = <Offset>[];
    if (dy/dx.toDouble() > 1){
      int d = 2 * dx - dy, xi = xStart;
      for(int yi = yStart; yStart < yEnd ? yi <= yEnd: yi >= yEnd; yi += yStart < yEnd ? 1:-1){
        res.add(Offset(xi.toDouble(), yi.toDouble()));
        if (d < 0) {
          d += 2 *dx;
        } else {
          if (xStart > xEnd){
            xi--;
          } else{
            xi++;
          }
          d += 2 * (dx - dy);
        }
      }
    } else {
      int d = 2 * dy - dx, yi = yStart;
      for(int xi = xStart; xStart < xEnd ? xi <= xEnd: xi >= xEnd; xi += xStart < xEnd ? 1:-1){
        res.add(Offset(xi.toDouble(), yi.toDouble()));
        if (d < 0) {
          d += 2 *dy;
        } else {
          if (yStart > yEnd){
            yi--;
          } else{
            yi++;
          }
          d += 2 * (dy - dx);
        }
      }
    }
    return res;
  }

  @override
  void paint(Canvas canvas, Size size) async {
    drawHistory(canvas, image, clearFlag);
    if (gestureEvents.length > 1 && gestureEvents.last.type == GestureEventType.panUpdate){
      final points = bresenhamLine(gestureEvents[gestureEvents.length - 2].position, gestureEvents.last.position);
      canvas.drawPoints(
        ui.PointMode.points,
        points,
        gestureEvents.last.style
      );
    }
  }

}