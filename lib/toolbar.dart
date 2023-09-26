import 'package:bitmap_algorithms/bloc/main_bloc.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ToolBar extends StatelessWidget {
  const ToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          border: Border(
            right: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 3,
            ),
          )),
      height: double.infinity,
      width: 220,
      child: Material(
        child: Column(
          children: [
            ColorPicker(
              color: context.read<MainBloc>().style.color,
              pickersEnabled: const {
                ColorPickerType.both: false,
                ColorPickerType.primary: false,
                ColorPickerType.accent: false,
                ColorPickerType.bw: false,
                ColorPickerType.custom: false,
                ColorPickerType.wheel: true,
              },
              enableTonalPalette: false,
              enableShadesSelection: false,
              onColorChanged: (_) {},
              onColorChangeEnd: (color) {
                context.read<MainBloc>().style.color = color;
              },
            ),
            const _WidthPicker(),
            const SizedBox(
              height: 20,
            ),
            const _ImagePicker(),
            BlocBuilder<MainBloc, MainState>(
              builder: (context, state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PainterButton(
                    onPressed: () {
                      context.read<MainBloc>().add(const MainPickBresenham());
                    },
                    title: "Алгоритм Брезенхема",
                    isActive: state is BresenhamState,
                  ),
                  _PainterButton(
                    onPressed: () {
                      context.read<MainBloc>().add(const MainPickWu());
                    },
                    title: "Алгоритм Ву",
                    isActive: state is WuState,
                  ),
                  _PainterButton(
                    onPressed: () {
                      context.read<MainBloc>().add(const MainPickFloodFill());
                    },
                    title: "Заливка",
                    isActive: state is FloodFillState,
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
                onPressed: () {
                  context.read<MainBloc>().add(const MainClearEvent());
                },
                child: const Text("Очистить")),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PainterButton extends StatelessWidget {
  const _PainterButton(
      {Key? key,
      required this.isActive,
      required this.title,
      required this.onPressed})
      : super(key: key);
  final bool isActive;
  final String title;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
            backgroundColor: isActive
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.surface,
            foregroundColor: isActive
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).primaryColor),
        child: Text(title),
      ),
    );
  }
}

class _WidthPicker extends StatefulWidget {
  const _WidthPicker({
    super.key,
  });

  @override
  State<_WidthPicker> createState() => _WidthPickerState();
}

class _WidthPickerState extends State<_WidthPicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          divisions: 4,
          label: context.read<MainBloc>().style.strokeWidth.toString(),
          value: context.read<MainBloc>().style.strokeWidth,
          min: 1,
          max: 5,
          onChanged: (double value) {
            setState(() {
              context.read<MainBloc>().style.strokeWidth = value;
            });
          },
        ),
        const Text("Размер кисти"),
      ],
    );
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            context.read<MainBloc>().add(const MainLoadFillImage());
          },
          child: Text("Загрузить изображение")
        ),
        BlocBuilder<MainBloc, MainState>(
          builder: (context, state) => switch (state) {
            _ => const SizedBox.shrink()
          },
        )
      ],
    );
  }
}
