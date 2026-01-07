import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';

class CustomToggleButtonNew extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final void Function(int) onPressed;
  final double? height;

  const CustomToggleButtonNew({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onPressed,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 30,
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(8),
        selectedColor: Colors.white,
        fillColor: context.selectedPrimaryColor,
        isSelected: List.generate(
          labels.length,
          (index) => index == selectedIndex,
        ),
        onPressed: onPressed,
        children: labels
            .map(
              (label) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(label),
              ),
            )
            .toList(),
      ),
    );
  }
}
