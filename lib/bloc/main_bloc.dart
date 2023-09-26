import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:bitmap_algorithms/gesture_event.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(const BresenhamState([], null)) {
    on<MainGestureUpdate>(_onGestureUpdate);
    on<MainImageUpdate>(_onImageUpdate);
    on<MainClearEvent>(_clearHistory);
    on<MainPickBresenham>((_, Emitter emit) {
      emit(BresenhamState([], state.canvasHistory));
    });
    on<MainPickWu>((_, Emitter emit) {
      emit(WuState([], state.canvasHistory));
    });
    on<MainPickFloodFill>((_, Emitter emit) {
      emit(FloodFillState([], state.canvasHistory, null));
    });
  }
  final Paint style = Paint()
    ..strokeWidth = 1
    ..color = Colors.black;

  void _floodFill(ui.Image image, ByteData byteData, GestureEvent gestureEvent){

    final int width = image!.width;
    final int height = image!.height;
    Uint8List uint8List = byteData!.buffer.asUint8List();

    final int targetPixelX = gestureEvent.position.dx.toInt();
    final int targetPixelY = gestureEvent.position.dy.toInt();

    final int targetPixelOffset = (targetPixelY * width + targetPixelX) * 4;

    final Color targetColor = Color.fromRGBO(
      uint8List[targetPixelOffset],
      uint8List[targetPixelOffset + 1],
      uint8List[targetPixelOffset + 2],
      uint8List[targetPixelOffset + 3] / 255.0,
    );

    final List<Offset> points = [];
    final List<List<bool>> visited = List.generate(
      width,
          (i) => List<bool>.filled(height, false),
    );

    final List<List<int>> stack = [];

    stack.add([targetPixelX, targetPixelY]);

    while (stack.isNotEmpty) {
      final currentPoint = stack.removeLast();
      final x = currentPoint[0];
      final y = currentPoint[1];

      if (x >= 0 && x < width && y >= 0 && y < height && !visited[x][y]) {
        visited[x][y] = true;

        final int currentPixelOffset = (y * width + x) * 4;
        final Color currentPixelColor = Color.fromRGBO(
          uint8List[currentPixelOffset],
          uint8List[currentPixelOffset + 1],
          uint8List[currentPixelOffset + 2],
          uint8List[currentPixelOffset + 3] / 255.0,
        );

        if (currentPixelColor == targetColor) {
          int left = x;
          int right = x;

          while (left >= 0 &&
              Color.fromRGBO(
                  uint8List[(y * width + left) * 4],
                  uint8List[(y * width + left) * 4 + 1],
                  uint8List[(y * width + left) * 4 + 2],
                  uint8List[(y * width + left) * 4 + 3] / 255.0) ==
                  targetColor) {
            left--;
          }

          while (right < width &&
              Color.fromRGBO(
                  uint8List[(y * width + right) * 4],
                  uint8List[(y * width + right) * 4 + 1],
                  uint8List[(y * width + right) * 4 + 2],
                  uint8List[(y * width + right) * 4 + 3] / 255.0) ==
                  targetColor) {
            right++;
          }

          for (int i = left + 1; i < right; i++) {
            visited[i][y] = true;
            var color = gestureEvent.style.color;
            var offset = (y * width + i) * 4;
            uint8List[offset] = color.red;
            uint8List[offset + 1] = color.green;
            uint8List[offset + 2] = color.blue;
            uint8List[offset + 3] = color.alpha;
            // points.add(Offset(i.toDouble(), y.toDouble()));

            if (y > 0) {
              stack.add([i, y - 1]);
            }
            if (y < height - 1) {
              stack.add([i, y + 1]);
            }
          }
        }
      }
    }
    ui.Image? img;
    ui.decodeImageFromPixels(uint8List,
        width.toInt(),
        height.toInt(),
        ui.PixelFormat.rgba8888,
        (image){
          emit(FloodFillState([], image, null));
        }
    );
  }

  void _onGestureUpdate(MainGestureUpdate event, Emitter emit) async {
    final List<GestureEvent> eventList = [];
    final gestureEvent =
        GestureEvent(type: event.type, position: event.position, style: style);

    ByteData? bd;
    switch (gestureEvent.type) {
      case GestureEventType.panUpdate:
        if (state is BresenhamState || state is WuState) {
          eventList.addAll([state.gestureEvents.first, gestureEvent]);
        }
      case GestureEventType.panEnd:
        if (state is BresenhamState || state is WuState) {
          eventList.addAll([state.gestureEvents.first, gestureEvent]);
        }
      case GestureEventType.panDown:
        eventList.add(gestureEvent);
        if (state is FloodFillState) {
          bd = await state.canvasHistory?.toByteData();
          _floodFill(state.canvasHistory!, bd!, gestureEvent);
          return;
        }
    }
    if (state is FloodFillState) {
      var st = state as FloodFillState;
      emit(
        st.copyWith(
          gestureEvents: eventList,
          byteData: bd,
        ),
      );
    } else {
      emit(state.copyWith(gestureEvents: eventList));
    }
  }

  void _onImageUpdate(MainImageUpdate event, Emitter emit) {
    emit(state.copyWith(canvasHistory: event.image, clearFlag: false));
  }

  void _clearHistory(MainClearEvent event, Emitter emit) {
    emit(state.copyWith(
        canvasHistory: null, gestureEvents: [], clearFlag: true));
  }
}
