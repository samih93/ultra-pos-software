//!NOTE ----------default Button -----------------------------
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';

class NewDefaultButton extends StatelessWidget {
  const NewDefaultButton({
    this.width,
    this.background,
    this.textcolor = Colors.white,
    this.onpress,
    required this.text,
    this.gradient,
    this.radius,
    this.height,
    this.isUppercase,
    this.isDisabled,
    this.state = RequestState.success,
    this.coloredLogo = false,
    super.key,
  });

  final double? width;
  final Color? background;
  final Color? textcolor;
  final VoidCallback? onpress;
  final String text;
  final Gradient? gradient;
  final double? radius;
  final double? height;
  final bool? isUppercase;
  final bool? isDisabled;
  final RequestState? state;
  final bool? coloredLogo;

  @override
  Widget build(BuildContext context) {
    final disabledColor = context.disabledColor;

    return Container(
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 15),
        gradient: isDisabled == true
            ? (gradient?.getDisabledGradient(disabledColor) ??
                  coreGradient().getDisabledGradient(disabledColor))
            : gradient ??
                  coreGradient(), // Use coreGradient if gradient is null
      ),
      child: MaterialButton(
        height: height ?? 40,
        onPressed: isDisabled == true || state == RequestState.loading
            ? null
            : onpress,
        child: state == RequestState.loading
            ? SizedBox(
                height: (height ?? 40) / 1.8,
                width: (height ?? 40) / 1.8,
                child: CoreCircularIndicator(coloredLogo: coloredLogo),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  (isUppercase != null && isUppercase == true)
                      ? text.toUpperCase()
                      : text,
                  style: TextStyle(color: textcolor ?? Colors.white),
                ),
              ),
      ),
    );
  }
}
