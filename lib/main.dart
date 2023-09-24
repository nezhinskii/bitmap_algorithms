import 'package:bitmap_algorithms/bloc/main_bloc.dart';
import 'package:bitmap_algorithms/gesture_event.dart';
import 'package:bitmap_algorithms/task2/bresenham_painter.dart';
import 'package:bitmap_algorithms/task2/wu_painter.dart';
import 'package:bitmap_algorithms/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

final _repaintBoundaryKey = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void _updateCanvasHistory(MainBloc bloc) async {
    final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    final updatedHistory = await boundary?.toImage();
    if (updatedHistory != null){
      bloc.add(MainImageUpdate(updatedHistory));
    }
  }

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
                  key: _repaintBoundaryKey,
                  child: BlocBuilder<MainBloc, MainState>(
                    builder: (context, state) {
                      return GestureDetector(
                        onPanDown: (details) {
                          context.read<MainBloc>().add(
                            MainGestureUpdate(details.localPosition, GestureEventType.panDown)
                          );
                        },
                        onPanEnd: (details) {
                          switch (state){
                            case BresenhamState() || WuState():
                              _updateCanvasHistory(context.read<MainBloc>());
                            default:
                          }
                          context.read<MainBloc>().add(
                            MainGestureUpdate(
                              state.gestureEvents.isNotEmpty ? state.gestureEvents.last.position:Offset.zero,
                              GestureEventType.panEnd,
                            )
                          );
                        },
                        onPanUpdate: (details) {
                          context.read<MainBloc>().add(
                            MainGestureUpdate(details.localPosition, GestureEventType.panUpdate)
                          );
                        },
                        child: ClipRRect(
                          child: CustomPaint(
                            foregroundPainter: switch (state) {
                              BresenhamState() => BresenhamPainter(
                                  gestureEvents: state.gestureEvents,
                                  image: state.canvasHistory,
                                  clearFlag: state.clearFlag
                                ),
                              WuState() => WuPainter(
                                  gestureEvents: state.gestureEvents,
                                  image: state.canvasHistory,
                                  clearFlag: state.clearFlag
                                ),
                            },
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}



