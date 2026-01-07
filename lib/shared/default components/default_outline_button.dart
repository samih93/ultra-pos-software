import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DefaultOutlineButton extends ConsumerWidget {
  const DefaultOutlineButton({
    super.key,
    required this.name,
    this.onpress,
    this.textcolor,
    this.backgroundColor,
    this.fontSize,
    this.bordercolor,
    this.states = const [RequestState.success],
    this.coloredLoadingLogo = false,
  });
  final String name;
  final VoidCallback? onpress;
  final Color? textcolor;
  final Color? backgroundColor;
  final double? fontSize;
  final Color? bordercolor;
  final List<RequestState> states; // Accept multiple states
  final bool? coloredLoadingLogo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoading =
        states.contains(RequestState.loading); // Check if any state is loading
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          side: BorderSide(width: 1, color: bordercolor ?? Colors.transparent),
          backgroundColor: backgroundColor ?? Colors.transparent),
      onPressed: onpress,
      child: Row(
        children: [
          isLoading
              ? CoreCircularIndicator(
                  coloredLogo: coloredLoadingLogo,
                )
              : Text(
                  name,
                  style: TextStyle(
                      color: textcolor ?? (context.primaryColor),
                      fontSize: fontSize ?? 11),
                ),
        ],
      ),
    );
  }
}
