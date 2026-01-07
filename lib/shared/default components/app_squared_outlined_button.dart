import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSquaredOutlinedButton extends ConsumerWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Size size;
  final Color borderColor;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final bool isDisabled;
  final List<RequestState> states;

  const AppSquaredOutlinedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = const Size(38, 38),
    this.borderColor = const Color(0xFFE0E0E0),
    this.backgroundColor,
    this.padding = kPadd3,
    this.isDisabled = false,
    this.states = const [RequestState.success],
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoading = states.contains(RequestState.loading);
    final disabledColor = context.disabledColor;
    final effectiveBackgroundColor = isDisabled
        ? disabledColor.withValues(alpha: 0.1)
        : backgroundColor ?? Pallete.whiteColor;

    final effectiveBorderColor =
        isDisabled ? disabledColor.withValues(alpha: 0.3) : borderColor;

    final effectiveForegroundColor =
        isDisabled ? disabledColor : Pallete.blackColor;
    return Material(
      color: effectiveBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: kRadius8,
        side: BorderSide(color: effectiveBorderColor),
      ),
      child: InkWell(
        borderRadius: kRadius8,
        onTap: (isDisabled || isLoading) ? null : onPressed,
        child: Container(
          width: size.width,
          height: size.height,
          alignment: Alignment.center,
          padding: padding,
          child: isLoading
              ? const Padding(
                  padding: kPadd3,
                  child: CoreCircularIndicator(coloredLogo: true, height: 38),
                )
              : DefaultTextStyle.merge(
                  style: TextStyle(color: effectiveForegroundColor),
                  child: IconTheme.merge(
                    data: IconThemeData(
                        color: effectiveForegroundColor,
                        size: size.height - 18),
                    child: child,
                  ),
                ),
        ),
      ),
    );
  }
}
