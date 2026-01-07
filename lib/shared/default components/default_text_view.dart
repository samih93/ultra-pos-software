import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class DefaultTextView extends ConsumerWidget {
  const DefaultTextView({
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.textDecoration,
    this.maxlines,
    this.overflow,
    this.activated,
    this.textHeight,
    this.letterSpacing,
    super.key,
  });
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final TextDecoration? textDecoration;
  final int? maxlines;
  final TextOverflow? overflow;
  final bool? activated;
  final double? textHeight;
  final double? letterSpacing;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      text,
      maxLines: maxlines ?? 1,
      textAlign:
          textAlign ??
          (ref.watch(mainControllerProvider).isLtr
              ? TextAlign.left
              : TextAlign.right),
      overflow: overflow ?? TextOverflow.ellipsis,
      style: TextStyle(
        letterSpacing: letterSpacing ?? 1,
        height: textHeight,
        decoration: textDecoration,
        color: activated == true
            ? context.primaryColor
            : color ??
                  (ref.watch(isDarkModeProvider)
                      ? Pallete.whiteColor
                      : Pallete.blackColor),
        fontSize: fontSize != null ? fontSize!.spMax : 13.spMax,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
    );
  }
}

// without State
class DefaultTextViewForPrinting extends StatelessWidget {
  const DefaultTextViewForPrinting({
    required this.text,
    this.color,
    this.fontsize,
    this.fontWeight,
    this.textAlign,
    this.textDecoration,
    this.maxlines,
    this.overflow,
    this.activated,
    super.key,
  });
  final String text;
  final Color? color;
  final double? fontsize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final TextDecoration? textDecoration;
  final int? maxlines;
  final TextOverflow? overflow;
  final bool? activated;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxlines ?? 1,
      textAlign: TextAlign.left,
      overflow: overflow ?? TextOverflow.ellipsis,
      style: TextStyle(
        decoration: textDecoration,
        color: activated == true
            ? context.primaryColor
            : color ?? Colors.black87,
        fontSize: fontsize != null ? fontsize!.spMax : 14.spMax,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
    );
  }
}
