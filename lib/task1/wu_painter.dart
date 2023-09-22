import 'dart:ui';

import 'package:bitmap_algorithms/gesture_event.dart';
import 'package:bitmap_algorithms/our_painter.dart';

class WuPainter extends OurPainter{
  WuPainter({
    required super.gestureEvents,
    required super.clearFlag,
    super.image
  });

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    if (gestureEvents.length > 1 && gestureEvents.last.type == GestureEventType.panUpdate){
      final paint = gestureEvents.last.style;
      final start = gestureEvents[gestureEvents.length - 2].position, end = gestureEvents.last.position;
      var xStart = start.dx.toInt(), yStart = start.dy.toInt(), xEnd = end.dx.toInt(), yEnd = end.dy.toInt();
      canvas.drawPoints(PointMode.points, [Offset(xStart.toDouble(), yStart.toDouble())], paint);
      final dx = xEnd - xStart, dy = yEnd - yStart;
      var gradient = dy/dx;
      if (gradient.abs() > 1){
        if (yEnd < yStart){
          (xEnd, xStart) = (xStart, xEnd);
          (yEnd, yStart) = (yStart, yEnd);
        }
        gradient = dx/dy;
        var x = xStart + gradient;
        for (var y = yStart + 1; y < yEnd; ++y){
          canvas.drawPoints(
            PointMode.points,
            [Offset(x.floor().toDouble(), y.toDouble())],
            paint..color = paint.color.withOpacity(1 - (x - x.floor()))
          );
          canvas.drawPoints(
            PointMode.points,
            [Offset(x.ceil().toDouble(), y.toDouble())],
            paint..color = paint.color.withOpacity(1 - (x.ceil() - x))
          );
          x += gradient;
        }
      } else {
        if (xEnd < xStart){
          (xEnd, xStart) = (xStart, xEnd);
          (yEnd, yStart) = (yStart, yEnd);
        }
        var y = yStart + gradient;
        for (var x = xStart + 1; x < xEnd; ++x){
          canvas.drawPoints(
            PointMode.points,
            [Offset(x.toDouble(), y.floor().toDouble())],
            paint..color = paint.color.withOpacity(1 - (y - y.floor()))
          );
          canvas.drawPoints(
            PointMode.points,
            [Offset(x.toDouble(), y.ceil().toDouble())],
            paint..color = paint.color.withOpacity(1 - (y.ceil() - y))
          );
          y += gradient;
        }
      }
      paint.color = paint.color.withOpacity(1);
    }

  }

}