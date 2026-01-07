import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ElevatedButtonWidget extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String? text;
  final String? subText; // New: Supports multi-line text

  final Color? color;
  final bool isDisabled;
  final List<RequestState> states; // Accept multiple states
  final double? radius;
  final IconData? icon; // Optional icon
  final double? height;
  final bool? bold;
  final double? width;
  final double? padding;

  const ElevatedButtonWidget(
      {Key? key,
      required this.text,
      this.subText,
      this.onPressed,
      this.color,
      this.isDisabled = false,
      this.states = const [RequestState.success], // Accept multiple states
      this.radius,
      this.icon, // Added icon
      this.height,
      this.width,
      this.padding,
      this.bold})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoading =
        states.contains(RequestState.loading); // Check if any state is loading
    final isDarkMode = ref.watch(isDarkModeProvider);
    //  final Color buttonColor = (color ?? Theme.of(context).colorScheme.primary);
    final Color textColor =
        color ?? (isDarkMode ? Pallete.whiteColor : Pallete.primaryColor);

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? Pallete.primaryColor : null,
          padding: padding != null ? EdgeInsets.all(padding!) : kPadd5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 10),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20, // Spinner size
                width: 20,
                child: CoreCircularIndicator(
                  coloredLogo: isDarkMode ? false : true,
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: textColor), // Icon (if provided)
                      if (text != null) kGap5, // Spacing between icon and text
                    ],
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (text != null)
                          Text(
                            text!,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: bold == true ? FontWeight.bold : null,
                            ),
                          ),
                        if (subText != null) ...[
                          kGap3,
                          Text(
                            subText!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
