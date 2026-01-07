import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomToggleButton extends ConsumerWidget {
  final String text1;
  final String text2;
  final bool isSelected;
  final double? height;
  final Function(int) onPressed;

  const CustomToggleButton({
    Key? key,
    required this.text1,
    required this.text2,
    required this.isSelected,
    required this.onPressed,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: height ?? 30,
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(8),
        selectedColor: Colors.white,
        fillColor: context.selectedPrimaryColor,
        color: context.brightnessColor,
        isSelected: [isSelected, !isSelected],
        onPressed: (index) {
          onPressed(index);
        },
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(text1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(text2),
          ),
        ],
      ),
    );
  }
}
