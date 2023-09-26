import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:bitmap_algorithms/gesture_event.dart';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(const BresenhamState([], null)) {
    on<MainGestureUpdate>(_onGestureUpdate);
    on<MainCanvasHistoryUpdate>(_onCanvasHistoryUpdate);
    on<MainClearEvent>(_clearHistory);
    on<MainLoadFillImage>(_onLoadFillImage);
    on<MainPickBresenham>((_, Emitter emit) {
      emit(BresenhamState([], state.canvasHistory));
    });
    on<MainPickWu>((_, Emitter emit) {
      emit(WuState([], state.canvasHistory));
    });
    on<MainPickFloodFill>((_, Emitter emit) {
      emit(FloodFillState([], state.canvasHistory));
    });
    on<MainPickImageFill>((_, Emitter emit) {
      emit(ImageFillState(null, null, [], state.canvasHistory));
    });
  }
  final Paint style = Paint()
    ..strokeWidth = 1
    ..color = Colors.black;

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
          await _floodFill(state.canvasHistory!, gestureEvent);
          return;
        }
        if (state is ImageFillState) {
          final imageFillState = (state as ImageFillState);
          if (imageFillState.fillImage == null) {
            return;
          }
          await _imageFill(state.canvasHistory!, imageFillState.fillImage!, gestureEvent);
          return;
        }
    }
    emit(state.copyWith(gestureEvents: eventList));
  }

  void _onCanvasHistoryUpdate(MainCanvasHistoryUpdate event, Emitter emit) {
    emit(state.copyWith(canvasHistory: event.canvasHistory, clearFlag: false));
  }

  void _clearHistory(MainClearEvent event, Emitter emit) {
    emit(state.copyWith(
        canvasHistory: null, gestureEvents: [], clearFlag: true));
  }

  void _onLoadFillImage(MainLoadFillImage event, Emitter emit) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.image,
    );
    final bytes = result?.files.single.bytes;
    final fileName = result?.files.single.name;
    if (bytes != null){
      final image = await decodeImageFromList(bytes);
      emit(ImageFillState(fileName, image, [], state.canvasHistory));
    }
  }

  Future<void> _floodFill(ui.Image image, GestureEvent gestureEvent) async {
    final int width = image.width;
    final int height = image.height;

    ByteData? byteData = await state.canvasHistory?.toByteData();
    if (byteData == null) return;

    Uint8List uint8List = byteData.buffer.asUint8List();

    final int targetPixelX = gestureEvent.position.dx.toInt();
    final int targetPixelY = gestureEvent.position.dy.toInt();

    final int targetPixelOffset = (targetPixelY * width + targetPixelX) * 4;

    final Color targetColor = Color.fromRGBO(
      uint8List[targetPixelOffset],
      uint8List[targetPixelOffset + 1],
      uint8List[targetPixelOffset + 2],
      uint8List[targetPixelOffset + 3] / 255.0,
    );

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
    ui.decodeImageFromPixels(
        uint8List, width.toInt(), height.toInt(), ui.PixelFormat.rgba8888,
            (image) {
          emit(FloodFillState([], image));
        });
  }

  Future<void> _imageFill(
      ui.Image mainImage, ui.Image maskImage, GestureEvent gestureEvent) async {
    final int mainWidth = mainImage.width;
    final int mainHeight = mainImage.height;

    final int maskWidth = maskImage.width;
    final int maskHeight = maskImage.height;

    var mainByteData = await mainImage.toByteData();
    var maskByteData = await maskImage.toByteData();

    if (mainByteData == null || maskByteData == null) return;

    Uint8List maskPixels = maskByteData.buffer.asUint8List();
    Uint8List mainPixels = mainByteData.buffer.asUint8List();

    final int targetPixelX = gestureEvent.position.dx.toInt();
    final int targetPixelY = gestureEvent.position.dy.toInt();

    final int targetPixelOffset = (targetPixelY * mainWidth + targetPixelX) * 4;

    final Color targetColor = Color.fromRGBO(
      mainPixels[targetPixelOffset],
      mainPixels[targetPixelOffset + 1],
      mainPixels[targetPixelOffset + 2],
      mainPixels[targetPixelOffset + 3] / 255.0,
    );

    final List<List<bool>> visited = List.generate(
      mainWidth,
          (i) => List<bool>.filled(mainHeight, false),
    );

    final List<List<int>> stack = [];

    stack.add([targetPixelX, targetPixelY]);

    while (stack.isNotEmpty) {
      final currentPoint = stack.removeLast();
      final x = currentPoint[0];
      final y = currentPoint[1];

      if (x >= 0 &&
          x < mainWidth &&
          y >= 0 &&
          y < mainHeight &&
          !visited[x][y]) {
        visited[x][y] = true;

        final int currentPixelOffset = (y * mainWidth + x) * 4;
        final Color currentPixelColor = Color.fromRGBO(
          mainPixels[currentPixelOffset],
          mainPixels[currentPixelOffset + 1],
          mainPixels[currentPixelOffset + 2],
          mainPixels[currentPixelOffset + 3] / 255.0,
        );

        if (currentPixelColor == targetColor) {
          int left = x;
          int right = x;

          while (left >= 0 &&
              Color.fromRGBO(
                  mainPixels[(y * mainWidth + left) * 4],
                  mainPixels[(y * mainWidth + left) * 4 + 1],
                  mainPixels[(y * mainWidth + left) * 4 + 2],
                  mainPixels[(y * mainWidth + left) * 4 + 3] / 255.0) ==
                  targetColor) {
            left--;
          }

          while (right < mainWidth &&
              Color.fromRGBO(
                  mainPixels[(y * mainWidth + right) * 4],
                  mainPixels[(y * mainWidth + right) * 4 + 1],
                  mainPixels[(y * mainWidth + right) * 4 + 2],
                  mainPixels[(y * mainWidth + right) * 4 + 3] / 255.0) ==
                  targetColor) {
            right++;
          }

          for (int curX = left + 1; curX < right; curX++) {
            visited[curX][y] = true;

            var mainOffset = (y * mainWidth + curX) * 4;

            var maskX = (curX - targetPixelX) % maskWidth;
            var maskY = (y - targetPixelY) % maskHeight;

            var maskOffset = (maskY * maskWidth + maskX) * 4;

            mainPixels[mainOffset] = maskPixels[maskOffset];
            mainPixels[mainOffset + 1] = maskPixels[maskOffset + 1];
            mainPixels[mainOffset + 2] = maskPixels[maskOffset + 2];
            mainPixels[mainOffset + 3] = maskPixels[maskOffset + 3];

            if (y > 0) {
              stack.add([curX, y - 1]);
            }
            if (y < mainHeight - 1) {
              stack.add([curX, y + 1]);
            }
          }
        }
      }
    }
    ui.decodeImageFromPixels(mainPixels, mainWidth.toInt(), mainHeight.toInt(),
      ui.PixelFormat.rgba8888, (image) {
        final fillState = (state as ImageFillState);
        emit(ImageFillState(fillState.imageName, fillState.fillImage, [], image));
      }
    );
  }

}
