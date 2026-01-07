import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NumberPad extends ConsumerWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> codeNumbers = [
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "C",
      "0",
      "Enter",
    ];

    ValueNotifier<String> passwordListenable = ValueNotifier("");

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ValueListenableBuilder(
          valueListenable: passwordListenable,
          builder: (context, password, child) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              if (index < password.length) {
                // Fill the square if the index is less than the password length
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Pallete.primaryColorDark),
                    borderRadius: BorderRadius.circular(5),
                    color: Pallete.primaryColorDark, // filled square
                  ),
                  child: const Center(
                    child: Text(
                      "*", // or you can display a number here if you want
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
                );
              } else {
                // Empty square if the index is greater than the password length
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Pallete.primaryColorDark),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      "*", // Represents empty space
                      style: TextStyle(fontSize: 30, color: Colors.grey),
                    ),
                  ),
                );
              }
            }),
          ),
        ),
        Padding(
          padding: kPaddH15,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: context.isWindows ? 2.1 : 2.7,
              crossAxisCount: 3, // 3 columns
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 12, // We have 12 buttons
            itemBuilder: (context, index) {
              Widget buttonChild = Container(); // Default empty child
              String codeNumber = codeNumbers[index];
              if (index < 9) {
                // Buttons 1 to 9
                buttonChild = Center(
                  child: Text(codeNumber, style: const TextStyle(fontSize: 20)),
                );
              } else if (index == 9) {
                // Clear button
                buttonChild = const Center(
                  child: Text('C', style: TextStyle(fontSize: 24)),
                );
              } else if (index == 10) {
                // Button for '0'
                buttonChild = const Center(
                  child: Text('0', style: TextStyle(fontSize: 24)),
                );
              } else if (index == 11) {
                // Enter button (check password length)
                buttonChild = const Center(
                  child: Icon(Icons.check, size: 30, color: Pallete.whiteColor),
                );
              }
              return NumPadButtonWidget(
                index: index,
                codeNumber: codeNumber,
                passwordListenable: passwordListenable,
                child: buttonChild,
                onPressed: () {
                  // Handle logic based on the button pressed
                  if (codeNumber == "C") {
                    // Clear functionality (remove the last character)
                    passwordListenable.value = "";
                  } else if (codeNumber == "Enter") {
                    // Enter functionality (submit password if length is 4)
                    if (passwordListenable.value.length == 4) {
                      ref
                          .read(authControllerProvider.notifier)
                          .signInWithPassword(
                            passwordListenable.value,
                            context,
                          );
                    }
                  } else {
                    // Add the number to password if length is less than 4
                    if (passwordListenable.value.length < 4) {
                      passwordListenable.value += codeNumber;
                    }
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class NumPadButtonWidget extends ConsumerWidget {
  final int index;
  final String codeNumber;
  final ValueNotifier<String> passwordListenable;
  final Widget child;
  final VoidCallback? onPressed;
  const NumPadButtonWidget({
    super.key,
    required this.index,
    required this.codeNumber,
    required this.passwordListenable,
    required this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: index == 9
            ? Pallete
                  .orangeColor // 'Clear' button color
            : index == 11
            ? context
                  .primaryColor // '✔️' button color
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Set the radius to 10
        ),
        padding: kPadd3, // Vertical padding based on screen height

        elevation: 5, // Optional, to add a shadow effect
      ),
      onPressed: onPressed,
      child: child, // Use the dynamic child widget here
    );
  }
}
