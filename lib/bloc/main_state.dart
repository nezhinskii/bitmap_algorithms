part of 'main_bloc.dart';

sealed class MainState {
  final List<GestureEvent> gestureEvents;
  final ui.Image? canvasHistory;
  final bool clearFlag;

  const MainState(this.gestureEvents, this.canvasHistory,
      [this.clearFlag = false]);

  MainState copyWith(
      {List<GestureEvent>? gestureEvents,
      ui.Image? canvasHistory,
      bool? clearFlag});
}

class BresenhamState extends MainState {
  const BresenhamState(super.gestureEvents, super.canvasHistory,
      [super.clearFlag]);

  @override
  BresenhamState copyWith(
      {List<GestureEvent>? gestureEvents,
      ui.Image? canvasHistory,
      bool? clearFlag}) {
    return BresenhamState(
        gestureEvents ?? this.gestureEvents,
        clearFlag == true ? null : canvasHistory ?? this.canvasHistory,
        clearFlag ?? this.clearFlag);
  }
}

class WuState extends MainState {
  const WuState(super.gestureEvents, super.canvasHistory, [super.clearFlag]);

  @override
  WuState copyWith(
      {List<GestureEvent>? gestureEvents,
      ui.Image? canvasHistory,
      bool? clearFlag}) {
    return WuState(
        gestureEvents ?? this.gestureEvents,
        clearFlag == true ? null : canvasHistory ?? this.canvasHistory,
        clearFlag ?? this.clearFlag);
  }
}

class FloodFillState extends MainState {
  const FloodFillState(super.gestureEvents, super.canvasHistory,
      [super.clearFlag]);

  @override
  FloodFillState copyWith(
      {List<GestureEvent>? gestureEvents,
      ui.Image? canvasHistory,
      bool? clearFlag}) {
    return FloodFillState(
        gestureEvents ?? this.gestureEvents,
        clearFlag == true ? null : canvasHistory ?? this.canvasHistory,
        clearFlag ?? this.clearFlag);
  }
}

class ImageFillState extends MainState {
  final ui.Image? fillImage;
  final String? imageName;

  const ImageFillState(
      this.imageName, this.fillImage, super.gestureEvents, super.canvasHistory,
      [super.clearFlag]);

  @override
  ImageFillState copyWith(
      {String? imageName,
      ui.Image? fillImage,
      List<GestureEvent>? gestureEvents,
      ui.Image? canvasHistory,
      bool? clearFlag}) {
    return ImageFillState(
        imageName ?? this.imageName,
        fillImage ?? this.fillImage,
        gestureEvents ?? this.gestureEvents,
        clearFlag == true ? null : canvasHistory ?? this.canvasHistory,
        clearFlag ?? this.clearFlag);
  }
}

class FindBoundaryState extends MainState {
  const FindBoundaryState(super.gestureEvents, super.canvasHistory,
      [super.clearFlag]);

  @override
  FindBoundaryState copyWith(
      {List<GestureEvent>? gestureEvents,
      ui.Image? canvasHistory,
      bool? clearFlag}) {
    return FindBoundaryState(
        gestureEvents ?? this.gestureEvents,
        clearFlag == true ? null : canvasHistory ?? this.canvasHistory,
        clearFlag ?? this.clearFlag);
  }
}

class CurveState extends MainState{
  const CurveState(super.gestureEvents, super.canvasHistory, [super.clearFlag]);

  @override
  CurveState copyWith(
      {List<GestureEvent>? gestureEvents,
        ui.Image? canvasHistory,
        bool? clearFlag}) {
    return CurveState(
        gestureEvents ?? this.gestureEvents,
        clearFlag == true ? null : canvasHistory ?? this.canvasHistory,
        clearFlag ?? this.clearFlag);
  }
}
class TriangleState extends MainState {
  const TriangleState(super.gestureEvents, super.canvasHistory,
      [super.clearFlag]);

  @override
  TriangleState copyWith(
      {List<GestureEvent>? gestureEvents,
      ui.Image? canvasHistory,
      bool? clearFlag}) {
    return TriangleState(
      gestureEvents ?? this.gestureEvents,
      clearFlag == true ? null : canvasHistory ?? this.canvasHistory,
      clearFlag ?? this.clearFlag,
    );
  }
}
