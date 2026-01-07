import 'package:flutter/material.dart';

class AppTextStyles {
  // Title Text Style
  static TextStyle title = const TextStyle(
    fontSize: 20.0, // Adjusted font size
    fontWeight: FontWeight.bold,
  );

  // Subtitle Text Style
  static TextStyle subtitle = const TextStyle(
    fontSize: 11.0, // Adjusted font size
    fontWeight: FontWeight.w400,
    color: Colors.grey, // Set subtitle color to grey
  );

  // AppBar Title Text Style
  static TextStyle appBarTitle = const TextStyle(
    fontSize: 20.0, // Slightly larger font for app bar title
    fontWeight: FontWeight.w600,
  );

  // Normal Text Style (for general text)
  static TextStyle normal = const TextStyle(
    fontSize: 14.0, // Adjusted font size to 14
    fontWeight: FontWeight.normal,
  );
  static TextStyle boldTitle = const TextStyle(
    fontSize: 14.0, // Adjusted font size to 14
    fontWeight: FontWeight.bold,
    // Default color for normal text
  );

  // Primary Text Style (same color as primary color in theme)
  static TextStyle primary = const TextStyle(
    fontSize: 14.0, // Adjusted font size for primary text
    fontWeight: FontWeight.normal,
    color: Colors.blue, // Assuming primary color is blue, modify if needed
  );
}
