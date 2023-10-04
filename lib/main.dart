import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bitmap_algorithms/bloc/main_bloc.dart';
import 'package:bitmap_algorithms/gesture_event.dart';
import 'package:bitmap_algorithms/task1/curve_painter.dart';
import 'package:bitmap_algorithms/task2/bresenham_painter.dart';
import 'package:bitmap_algorithms/task2/wu_painter.dart';
import 'package:bitmap_algorithms/task1/flood_fill_painter.dart';
import 'package:bitmap_algorithms/task3/triangle_painter.dart';
import 'package:bitmap_algorithms/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

final repaintBoundaryKey = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocProvider<MainBloc>(
          create: (context) => MainBloc(),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                const ToolBar(),
                Expanded(
                  child: RepaintBoundary(
                    key: repaintBoundaryKey,
                    child: BlocBuilder<MainBloc, MainState>(
                      builder: (context, state) {
                        return GestureDetector(
                          onPanDown: (details) {
                            print("Pan ${details.localPosition.dx} ${details.localPosition.dy}");
                            context.read<MainBloc>().add(MainGestureUpdate(
                                details.localPosition,
                                GestureEventType.panDown));
                          },
                          onPanEnd: (details) {
                            context.read<MainBloc>().add(MainGestureUpdate(
                                  state.gestureEvents.isNotEmpty
                                      ? state.gestureEvents.last.position
                                      : Offset.zero,
                                  GestureEventType.panEnd,
                                ));
                          },
                          onPanUpdate: (details) {
                            context.read<MainBloc>().add(MainGestureUpdate(
                                details.localPosition,
                                GestureEventType.panUpdate));
                          },
                          child: ClipRRect(
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              if (state.canvasHistory == null) {
                                final history = List.filled(
                                    constraints.maxWidth.toInt() *
                                        constraints.maxHeight.toInt() *
                                        4,
                                    255);
                                ui.decodeImageFromPixels(
                                    Uint8List.fromList(history),
                                    constraints.maxWidth.toInt(),
                                    constraints.maxHeight.toInt(),
                                    ui.PixelFormat.rgba8888, (image) {
                                  context
                                      .read<MainBloc>()
                                      .add(MainCanvasHistoryUpdate(image));
                                });
                              }
                              return CustomPaint(
                                foregroundPainter: switch (state) {
                                  BresenhamState() => BresenhamPainter(
                                      gestureEvents: state.gestureEvents,
                                      image: state.canvasHistory,
                                      clearFlag: state.clearFlag),
                                  WuState() => WuPainter(
                                      gestureEvents: state.gestureEvents,
                                      image: state.canvasHistory,
                                      clearFlag: state.clearFlag),
                                  FloodFillState() => FloodFillPainter(
                                      gestureEvents: state.gestureEvents,
                                      image: state.canvasHistory,
                                      clearFlag: state.clearFlag),
                                  ImageFillState() => FloodFillPainter(
                                      gestureEvents: state.gestureEvents,
                                      image: state.canvasHistory,
                                      clearFlag: state.clearFlag),
                                  FindBoundaryState() => FloodFillPainter(
                                      gestureEvents: state.gestureEvents,
                                      image: state.canvasHistory,
                                      clearFlag: state.clearFlag),
                                  CurveState() => CurvePainter(
                                      path: state.path,
                                      gestureEvents: state.gestureEvents,
                                      image: state.canvasHistory,
                                      clearFlag: state.clearFlag),
                                  TriangleState() => TrianglePainter(
                                      gestureEvents: state.gestureEvents,
                                      image: state.canvasHistory,
                                      clearFlag: state.clearFlag,),
                                },
                                child: Container(
                                  color: Colors.white,
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
