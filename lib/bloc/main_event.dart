part of 'main_bloc.dart';

@immutable
sealed class MainEvent {
  const MainEvent();
}

class MainGestureUpdate extends MainEvent{
  final Offset position;
  final GestureEventType type;
  const MainGestureUpdate(this.position, this.type);
}

class MainImageUpdate extends MainEvent{
  final ui.Image image;
  const MainImageUpdate(this.image);
}

class MainClearEvent extends MainEvent{
  const MainClearEvent();
}

class MainPickBresenham extends MainEvent{
  const MainPickBresenham();
}

class MainPickWu extends MainEvent{
  const MainPickWu();
}