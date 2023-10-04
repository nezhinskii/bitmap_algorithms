import 'dart:math';
import 'dart:ui' as ui;

import 'package:bitmap_algorithms/canvas_history_manager.dart';
import 'package:bitmap_algorithms/gesture_event.dart';
import 'package:bitmap_algorithms/task2/bresenham_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef Point = ({Offset pos, Color color});

class TrianglePainter extends BresenhamPainter with CanvasHistoryManager {
  TrianglePainter(
      {required super.gestureEvents, required super.clearFlag, super.image});

  @override
  void paint(Canvas canvas, Size size) async {
    drawHistory(canvas, image, clearFlag);
    print(gestureEvents.length);
    if (gestureEvents.length == 3) {
      List<({Offset pos, Color color})> points = gestureEvents
          .map((event) => (pos: event.position, color: event.style.color))
          .toList(growable: false)
        ..sort(
          (p1, p2) => p1.pos.dy.compareTo(
            p2.pos.dy,
          ),
        );

      List<Point>? topTriangle;
      List<Point>? bottomTriangle;

      if (points[0] == points[1]) {
        topTriangle = points;
      } else if (points[1] == points[2]) {
        bottomTriangle = points;
      } else {
        final double dy = points[1].pos.dy - points[0].pos.dy;
        final double k = (points[2].pos.dx - points[0].pos.dx) /
            (points[2].pos.dy - points[0].pos.dy);
        final double dx = k * dy + points[0].pos.dx;
        print("k*dy: ${k * dy}");
        var tempPoint = (
          pos: Offset(dx, points[1].pos.dy),
          color: interpolateColor(dy / (points[2].pos.dy - points[0].pos.dy),
              points[0].color, points[2].color)
        );

        if (points[1].pos.dx > tempPoint.pos.dx) {
          final temp = tempPoint;
          tempPoint = points[1];
          points[1] = temp;
        }
        topTriangle = [points[0], points[1], tempPoint];
        bottomTriangle = [points[2], points[1], tempPoint];
      }

      if (topTriangle != null) {
        drawTriangle(canvas, topTriangle[0], topTriangle[1], topTriangle[2], 1);
      }

      if (bottomTriangle != null) {
        drawTriangle(canvas, bottomTriangle[0], bottomTriangle[1],
            bottomTriangle[2], -1);
      }
    } else {
      for (var gesture in gestureEvents) {
        canvas.drawPoints(
          ui.PointMode.points,
          [gesture.position],
          gesture.style,
        );
      }
    }
  }

  void drawTriangle(Canvas canvas, Point p1, Point p2, Point p3, int step) {
    canvas.drawPoints(ui.PointMode.points, [p1.pos], Paint()..color = p1.color);

    print("p1 ${p1.color}");
    print("p2 ${p2.color}");
    print("p3 ${p3.color}");

    //print("p1 ${p1.pos}");
    //print("p2 ${p2.pos}");
    //print("p3 ${p3.pos}");
    line1(double y) {
      var x1 = p1.pos.dx;
      var x2 = p2.pos.dx;
      var y1 = p1.pos.dy;
      var y2 = p2.pos.dy;
      return x1 - (y - y1) * (x1 - x2) / (y2 - y1);
    }

    line2(double y) {
      var x1 = p1.pos.dx;
      var x2 = p3.pos.dx;
      var y1 = p1.pos.dy;
      var y2 = p3.pos.dy;
      return (y - y1) * (x2 - x1) / (y2 - y1) + x1;
    }

    print("Color1  ${p1.color}  Color2 ${p2.color}  Color3 ${p3.color}");
    for (double i = p1.pos.dy + 1; i*step <= p3.pos.dy*step; i += step) {
      //print(i);
      var xLeft = line1(i);
      var xRight = line2(i);
      //print("left $xLeft right $xRight");
      if ((xLeft - xRight).abs() > 1e-5) {
        var coef = (i - p1.pos.dy) / (p3.pos.dy - p1.pos.dy);
        var cLeft = interpolateColor(coef, p1.color, p2.color);
        var cRight = interpolateColor(coef, p1.color, p3.color);
        print("cLeft $cLeft  cRight $cRight");
        for (double j = xLeft; j <= xRight; j += 1) {
          var coef2 = (j - xLeft) / (xRight - xLeft);
          var color = interpolateColor(coef2, cLeft, cRight);

          canvas.drawPoints(
              ui.PointMode.points,
              [Offset(j, i)],
              Paint()
                ..color = color
                ..strokeWidth = 1.0);
        }
      }
    }
  }

  Color interpolateColor(double coef, Color color1, Color color2) {
    return Color.fromRGBO(
      (color1.red + coef * (color2.red - color1.red)).round(),
      (color1.green + coef * (color2.green - color1.green)).round(),
      (color1.blue + coef * (color2.blue - color1.blue)).round(),
      1,
    );
  }
}
