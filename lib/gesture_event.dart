import 'dart:ui';

enum GestureEventType{
  panDown,
  panUpdate,
  panEnd
}

class GestureEvent {
  const GestureEvent({
    required this.type,
    required this.position,
    required this.style
  });

  final GestureEventType type;
  final Offset position;
  final Paint style;
}