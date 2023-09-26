part of 'main_bloc.dart';

@immutable
sealed class MainEvent {
  const MainEvent();
}

class MainGestureUpdate extends MainEvent {
  final Offset position;
  final GestureEventType type;
  const MainGestureUpdate(this.position, this.type);
}

class MainCanvasHistoryUpdate extends MainEvent {
  final ui.Image canvasHistory;
  const MainCanvasHistoryUpdate(this.canvasHistory);
}

class MainClearEvent extends MainEvent {
  const MainClearEvent();
}

class MainLoadFillImage extends MainEvent {
  const MainLoadFillImage();
}

class MainPickBresenham extends MainEvent {
  const MainPickBresenham();
}

class MainPickWu extends MainEvent {
  const MainPickWu();
}

class MainPickFloodFill extends MainEvent {
  const MainPickFloodFill();
}

class MainPickImageFill extends MainEvent {
  const MainPickImageFill();
}

class MainPickFindBoundary extends MainEvent {
  const MainPickFindBoundary();
}
