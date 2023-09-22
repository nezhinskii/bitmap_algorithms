import 'dart:ui';

import 'package:bitmap_algorithms/our_painter.dart';
import 'package:bitmap_algorithms/gesture_event.dart';

class BresenhamPainter extends OurPainter{
  const BresenhamPainter({
    required super.gestureEvents,
    required super.clearFlag,
    super.image,
  });

  List<Offset> _bresenhamLine(Offset start, Offset end){
    int xStart = start.dx.toInt(), yStart = start.dy.toInt(), xEnd = end.dx.toInt(), yEnd = end.dy.toInt();
    int dx = (xEnd - xStart).abs(), dy = (yEnd - yStart).abs();
    final res = <Offset>[];
    if (dy/dx.toDouble() > 1){
      if (yEnd < yStart){
        (xEnd, xStart) = (xStart, xEnd);
        (yEnd, yStart) = (yStart, yEnd);
      }
      int d = 2 * dx - dy, xi = xStart;
      for(int yi = yStart; yi <= yEnd; ++yi){
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
      if (xEnd < xStart){
        (xEnd, xStart) = (xStart, xEnd);
        (yEnd, yStart) = (yStart, yEnd);
      }
      int d = 2 * dy - dx, yi = yStart;
      for(int xi = xStart; xi <= xEnd; ++xi){
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
    super.paint(canvas, size);
    if (gestureEvents.length > 1 && gestureEvents.last.type == GestureEventType.panUpdate){
      final points = _bresenhamLine(gestureEvents[gestureEvents.length - 2].position, gestureEvents.last.position);
      canvas.drawPoints(
        PointMode.points,
        points,
        gestureEvents.last.style
      );
    }
  }

}