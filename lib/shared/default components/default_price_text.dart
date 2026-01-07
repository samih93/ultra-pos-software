import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppPriceText extends ConsumerWidget {
  const AppPriceText({
    required this.text,
    required this.unit,
    this.fontSize,
    this.color,
    this.fontWeight,
    super.key,
  });

  final String text;
  final String unit;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        DefaultTextView(
          fontWeight: fontWeight,
          color: color,
          text: text,
          fontSize: fontSize ?? 14,
        ),
        DefaultTextView(
          color: color,
          text: " $unit",
          fontSize: (fontSize ?? 14) - 4,
        ),
      ],
    );
  }
}
