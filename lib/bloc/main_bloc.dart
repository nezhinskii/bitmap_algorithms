import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:bitmap_algorithms/gesture_event.dart';
import 'package:bitmap_algorithms/main.dart';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
    on<MainPickCurve>((_, Emitter emit) {
      emit(CurveState(Path(), [], state.canvasHistory));
    });
    on<MainPickFloodFill>((_, Emitter emit) {
      emit(FloodFillState([], state.canvasHistory));
    });
    on<MainPickImageFill>((_, Emitter emit) {
      emit(ImageFillState(null, null, [], state.canvasHistory));
    });
    on<MainPickFindBoundary>((_, Emitter emit) {
      emit(FindBoundaryState([], state.canvasHistory));
    });
  }
  final Paint style = Paint()
    ..strokeWidth = 1
    ..color = Colors.black;

  void _updateCanvasHistory() async {
    final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    final updatedHistory = await boundary?.toImage();
    if (updatedHistory != null) {
      add(MainCanvasHistoryUpdate(updatedHistory));
    }
  }

  void _onGestureUpdate(MainGestureUpdate event, Emitter emit) async {
    final List<GestureEvent> eventList = [];
    final gestureEvent =
        GestureEvent(type: event.type, position: event.position, style: style);

    switch (gestureEvent.type) {
      case GestureEventType.panUpdate:
        if (state is BresenhamState || state is WuState) {
          eventList.addAll([state.gestureEvents.first, gestureEvent]);
        }
        if (state is CurveState) {
          eventList.addAll(state.gestureEvents);
          eventList.add(gestureEvent);
        }
      case GestureEventType.panEnd:
        switch (state) {
          case BresenhamState() ||
                WuState() ||
                FloodFillState() ||
                CurveState():
            _updateCanvasHistory();
          default:
        }
        if (state is BresenhamState || state is WuState) {
          eventList.addAll([state.gestureEvents.first, gestureEvent]);
        }
        if (state is CurveState) {
          eventList.addAll(state.gestureEvents);
          eventList.add(gestureEvent);
        }
      case GestureEventType.panDown:
        eventList.add(gestureEvent);
        if (state is CurveState) {
          final curveState = state as CurveState;
          emit(curveState.copyWith(
              path: Path()..moveTo(event.position.dx, event.position.dy),
              gestureEvents: eventList));
          return;
        }
        if (state is FloodFillState) {
          await _floodFill(state.canvasHistory!, gestureEvent);
          return;
        }
        if (state is FindBoundaryState) {
          await _findBoundary(state.canvasHistory!, gestureEvent);
          return;
        }
        if (state is ImageFillState) {
          final imageFillState = (state as ImageFillState);
          if (imageFillState.fillImage == null) {
            return;
          }
          await _imageFill(
              state.canvasHistory!, imageFillState.fillImage!, gestureEvent);
          return;
        }
    }
    emit(state.copyWith(gestureEvents: eventList));
  }

  void _onCanvasHistoryUpdate(MainCanvasHistoryUpdate event, Emitter emit) {
    emit(state.copyWith(canvasHistory: event.canvasHistory, clearFlag: false));
  }

  void _clearHistory(MainClearEvent event, Emitter emit) {
    if (state is CurveState) {
      final curveState = state as CurveState;
      emit(curveState.copyWith(
          path: Path(),
          canvasHistory: null,
          gestureEvents: [],
          clearFlag: true));
    }
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
    if (bytes != null) {
      final image = await decodeImageFromList(bytes);
      emit(ImageFillState(fileName, image, [], state.canvasHistory));
    }
  }

  Future<void> _floodFill(ui.Image image, GestureEvent gestureEvent) async {
    final int width = image.width;
    final int height = image.height;

    ByteData? byteData = await state.canvasHistory?.toByteData();
    if (byteData == null) return;

    Uint8List pixels = byteData.buffer.asUint8List();
    Uint8List oldPixels = Uint8List.fromList(pixels);

    final int targetPixelX = gestureEvent.position.dx.toInt();
    final int targetPixelY = gestureEvent.position.dy.toInt();

    final int targetPixelOffset = (targetPixelY * width + targetPixelX) * 4;

    final Color targetColor = Color.fromRGBO(
      pixels[targetPixelOffset],
      pixels[targetPixelOffset + 1],
      pixels[targetPixelOffset + 2],
      pixels[targetPixelOffset + 3] / 255.0,
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
          pixels[currentPixelOffset],
          pixels[currentPixelOffset + 1],
          pixels[currentPixelOffset + 2],
          pixels[currentPixelOffset + 3] / 255.0,
        );

        double threshold = 1;
        if (calculateColorMatchPercentage(
                oldPixels, currentPixelOffset, targetPixelOffset) >=
            threshold) {
          int left = x;
          int right = x;

          while (left >= 0 &&
              calculateColorMatchPercentage(
                      oldPixels, (y * width + left) * 4, targetPixelOffset) >=
                  threshold) {
            left--;
          }

          while (right < width &&
              calculateColorMatchPercentage(
                      oldPixels, (y * width + right) * 4, targetPixelOffset) >=
                  threshold) {
            right++;
          }

          for (int i = left + 1; i < right; i++) {
            visited[i][y] = true;
            var color = gestureEvent.style.color;
            var offset = (y * width + i) * 4;
            pixels[offset] = color.red;
            pixels[offset + 1] = color.green;
            pixels[offset + 2] = color.blue;
            pixels[offset + 3] = color.alpha;

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
        pixels, width.toInt(), height.toInt(), ui.PixelFormat.rgba8888,
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
    Uint8List oldPixels = Uint8List.fromList(mainPixels);

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
        double threshold = 1;
        if (calculateColorMatchPercentage(
                oldPixels, currentPixelOffset, targetPixelOffset) >=
            threshold) {
          int left = x;
          int right = x;

          while (left >= 0 &&
              calculateColorMatchPercentage(oldPixels,
                      (y * mainWidth + left) * 4, targetPixelOffset) >=
                  threshold) {
            left--;
          }

          while (right < mainWidth &&
              calculateColorMatchPercentage(oldPixels,
                      (y * mainWidth + right) * 4, targetPixelOffset) >=
                  threshold) {
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
    });
  }

  Future<void> _findBoundary1(ui.Image image, GestureEvent gestureEvent) async {
    final int width = image.width;
    final int height = image.height;

    ByteData? byteData = await image.toByteData();
    if (byteData == null) return;

    Uint8List pixels = byteData.buffer.asUint8List();

    List<List<bool>> visited = List.generate(
      width,
      (i) => List<bool>.filled(height, false),
    );

    List<int> boundaryPoints = [];

    final int startPixelX = gestureEvent.position.dx.toInt();
    final int startPixelY = gestureEvent.position.dy.toInt();

    final int startPixelOffset = (startPixelY * width + startPixelX) * 4;

    int x = startPixelX + 1;
    int y = startPixelY;
    int targetPixelOffset = startPixelOffset + 4;
    while (x <= width &&
        calculateColorMatchPercentage(
                pixels, startPixelOffset, targetPixelOffset) >=
            1) {
      targetPixelOffset += 4;
      x++;
    }
    if (x > width) return;

    final List<List<int>> directions = [
      [1, 0], // Вправо
      [1, 1], // Вправо-вниз
      [0, 1], // Вниз
      [-1, 1], // Влево-вниз
      [-1, 0], // Влево
      [-1, -1], // Влево-вверх
      [0, -1], // Вверх
      [1, -1] // Вправо-вверх
    ];

    int direction = 2;

    void traverse(int x, int y) {
      do {
        if (x >= 0 && x < width && y >= 0 && y < height && !visited[x][y]) {
          visited[x][y] = true;
          final int currentPixelOffset = (y * width + x) * 4;

          if (calculateColorMatchPercentage(
                  pixels, currentPixelOffset, startPixelOffset) <
              1) {
            boundaryPoints.add(currentPixelOffset);
            direction = (direction + 1) % 8;
            x += directions[direction][0];
            y += directions[direction][1];
          } else {
            x -= directions[direction][0];
            y -= directions[direction][1];
            direction = (direction + 7) % 8;
            x += directions[direction][0];
            y += directions[direction][1];
          }
        }
      } while (!visited[x][y]);
    }

    traverse(x, y);

    Map<int, List<int>> boundaryMap = {};
    for (var el in boundaryPoints..sort()) {
      var curX = el ~/ 4 % width;
      var curY = el ~/ 4 ~/ width;
      if (boundaryMap[curY] == null) boundaryMap[curY] = [];
      boundaryMap[curY]!.add(curX);
    }

    print(boundaryMap);
    for (var curY in boundaryMap.keys) {
      boundaryMap[curY]!.sort();
      print("\t$curY");
      for (var i = 0; i < boundaryMap[curY]!.length; i += 2) {
        var curX = boundaryMap[curY]![i];
        print(curX);
        var finX = boundaryMap[curY]![i + 1];
        while (curX < finX &&
            calculateColorMatchPercentage(
                    pixels, (curY * width + curX) * 4, targetPixelOffset) >=
                1) {
          curX++;
        }
        if (curX != finX) {
          print("!!!!!!!!!!");
          traverse(curX, curY);
        }
      }
    }

    var color = gestureEvent.style.color;
    for (final offset in boundaryPoints) {
      pixels[offset] = color.red;
      pixels[offset + 1] = color.green;
      pixels[offset + 2] = color.blue;
      pixels[offset + 3] = color.alpha;
    }

    ui.decodeImageFromPixels(
        pixels, width.toInt(), height.toInt(), ui.PixelFormat.rgba8888,
        (image) {
      emit(FindBoundaryState([], image));
    });
  }

  Future<void> _findBoundary(ui.Image image, GestureEvent gestureEvent) async {
    final int width = image.width;
    final int height = image.height;

    ByteData? byteData = await state.canvasHistory?.toByteData();
    if (byteData == null) return;

    Uint8List pixels = byteData.buffer.asUint8List();
    Uint8List oldPixels = Uint8List.fromList(pixels);

    final int targetPixelX = gestureEvent.position.dx.toInt();
    final int targetPixelY = gestureEvent.position.dy.toInt();

    final int targetPixelOffset = (targetPixelY * width + targetPixelX) * 4;

    final List<List<bool>> visited = List.generate(
      width,
      (i) => List<bool>.filled(height, false),
    );

    final List<List<int>> stack = [];

    stack.add([targetPixelX, targetPixelY]);
    var color = gestureEvent.style.color;
    while (stack.isNotEmpty) {
      final currentPoint = stack.removeLast();
      final x = currentPoint[0];
      final y = currentPoint[1];

      if (x >= 0 && x < width && y >= 0 && y < height && !visited[x][y]) {
        visited[x][y] = true;

        final int currentPixelOffset = (y * width + x) * 4;

        double threshold = 1;
        if (calculateColorMatchPercentage(
                oldPixels, currentPixelOffset, targetPixelOffset) >=
            threshold) {
          int left = x;
          int right = x;

          while (left >= 0 &&
              calculateColorMatchPercentage(
                      oldPixels, (y * width + left) * 4, targetPixelOffset) >=
                  threshold) {
            left--;
          }

          while (right < width &&
              calculateColorMatchPercentage(
                      oldPixels, (y * width + right) * 4, targetPixelOffset) >=
                  threshold) {
            right++;
          }

          var offset = (y * width + left) * 4;
          pixels[offset] = color.red;
          pixels[offset + 1] = color.green;
          pixels[offset + 2] = color.blue;
          pixels[offset + 3] = color.alpha;

          offset = (y * width + right) * 4;
          pixels[offset] = color.red;
          pixels[offset + 1] = color.green;
          pixels[offset + 2] = color.blue;
          pixels[offset + 3] = color.alpha;

          for (int i = left; i < right + 1; i++) {
            visited[i][y] = true;
            if (y > 0) {
              stack.add([i, y - 1]);
            }
            if (y < height - 1) {
              stack.add([i, y + 1]);
            }
          }
        } else {
          var offset = (y * width + x) * 4;
          pixels[offset] = color.red;
          pixels[offset + 1] = color.green;
          pixels[offset + 2] = color.blue;
          pixels[offset + 3] = color.alpha;
        }
      }
    }
    ui.decodeImageFromPixels(
        pixels, width.toInt(), height.toInt(), ui.PixelFormat.rgba8888,
        (image) {
      emit(FindBoundaryState([], image));
    });
  }

  double calculateColorMatchPercentage(
      List<int> pixels, int pixelOffset1, int pixelOffset2) {
    final int redDiff = (pixels[pixelOffset1] - pixels[pixelOffset2]).abs();
    final int greenDiff =
        (pixels[pixelOffset1 + 1] - pixels[pixelOffset2 + 1]).abs();
    final int blueDiff =
        (pixels[pixelOffset1 + 2] - pixels[pixelOffset2 + 2]).abs();
    final int alphaDiff =
        (pixels[pixelOffset1 + 3] - pixels[pixelOffset2 + 3]).abs();

    final double matchPercentage =
        1.0 - (redDiff + greenDiff + blueDiff + alphaDiff) / (255 * 4);
    return matchPercentage;
  }
}
