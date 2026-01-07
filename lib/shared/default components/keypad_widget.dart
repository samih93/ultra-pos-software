import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:flutter/material.dart';

class KeypadWidget extends StatelessWidget {
  final void Function(String)
      onButtonPress; // Callback function for button press

  const KeypadWidget({Key? key, required this.onButtonPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 12, // 9 numbers + Clear + 0 + Submit
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        String buttonText = '';
        VoidCallback? onPressedCallback;

        if (index < 9) {
          buttonText = (index + 1).toString(); // 1-9 numbers
          onPressedCallback = () => onButtonPress(buttonText);
        } else if (index == 9) {
          buttonText = 'Clear'; // Clear button
          onPressedCallback = () => onButtonPress(buttonText);
        } else if (index == 10) {
          buttonText = '0'; // 0 button
          onPressedCallback = () => onButtonPress(buttonText);
        } else if (index == 11) {
          buttonText = '✔️'; // Submit button (checkmark)
          onPressedCallback = () => onButtonPress(buttonText);
        }

        return AppSquaredOutlinedButton(
          size: const Size(40, 40),
          onPressed: onPressedCallback!,
          child: Text(buttonText),
        );
      },
    );
  }
}
