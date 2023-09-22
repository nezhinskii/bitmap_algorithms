import 'package:bitmap_algorithms/gesture_event.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
abstract class OurPainter extends CustomPainter{
  final List<GestureEvent> gestureEvents;
  final ui.Image? image;
  final bool clearFlag;

  const OurPainter({
    required this.gestureEvents,
    required this.clearFlag,
    this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null && !clearFlag){
      canvas.drawImage(image!, Offset.zero, Paint());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}