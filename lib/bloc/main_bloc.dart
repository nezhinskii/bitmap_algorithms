import 'dart:ui' as ui;

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
    on<MainPickBresenham>((_, Emitter emit){
      emit(BresenhamState([], state.canvasHistory));
    });
    on<MainPickWu>((_, Emitter emit){
      emit(WuState([], state.canvasHistory));
    });
  }
  final Paint style = Paint()..strokeWidth = 1..color=Colors.black;

  void _onGestureUpdate(MainGestureUpdate event, Emitter emit){
    final List<GestureEvent> eventList = [];
    final gestureEvent = GestureEvent(type: event.type, position: event.position, style: style);
    switch (gestureEvent.type){
      case GestureEventType.panUpdate:
        if (state is BresenhamState || state is WuState){
          eventList.addAll([state.gestureEvents.first, gestureEvent]);
        }
      case GestureEventType.panEnd:
        if (state is BresenhamState || state is WuState){
          eventList.addAll([state.gestureEvents.first, gestureEvent]);
        }
      case GestureEventType.panDown:
        eventList.add(gestureEvent);
    }
    emit(state.copyWith(gestureEvents: eventList));
  }

  void _onImageUpdate(MainImageUpdate event, Emitter emit){
    emit(state.copyWith(canvasHistory: event.image, clearFlag: false));
  }

  void _clearHistory(MainClearEvent event, Emitter emit){
    emit(state.copyWith(canvasHistory: null, gestureEvents: [], clearFlag: true));
  }
}
