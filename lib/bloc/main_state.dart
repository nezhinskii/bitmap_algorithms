part of 'main_bloc.dart';

sealed class MainState {
  final List<GestureEvent> gestureEvents;
  final ui.Image? canvasHistory;
  final bool clearFlag;
  const MainState(this.gestureEvents, this.canvasHistory, [this.clearFlag = false]);

  MainState copyWith({List<GestureEvent>? gestureEvents, ui.Image? canvasHistory, bool? clearFlag});
}

class BresenhamState extends MainState{
  const BresenhamState(super.gestureEvents, super.canvasHistory, [super.clearFlag]);

  @override
  BresenhamState copyWith({List<GestureEvent>? gestureEvents, ui.Image? canvasHistory, bool? clearFlag}) {
    return BresenhamState(
      gestureEvents ?? this.gestureEvents,
      clearFlag == true ? null : canvasHistory ?? this.canvasHistory,
      clearFlag ?? this.clearFlag
    );
  }
}

class WuState extends MainState{
  const WuState(super.gestureEvents, super.canvasHistory, [super.clearFlag]);

  @override
  WuState copyWith({List<GestureEvent>? gestureEvents, ui.Image? canvasHistory, bool? clearFlag}) {
    return WuState(
      gestureEvents ?? this.gestureEvents,
      clearFlag == true ? null : canvasHistory ?? this.canvasHistory,
      clearFlag ?? this.clearFlag
    );
  }
}


