import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

mixin CanvasHistoryManager on CustomPainter {
  void drawHistory(Canvas canvas, ui.Image? image, bool clearFlag) {
    if (image != null && !clearFlag){
      canvas.drawImage(image, Offset.zero, Paint());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}