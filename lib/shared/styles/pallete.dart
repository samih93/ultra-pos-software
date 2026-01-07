import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Pallete {
  static const redColor = Color(0xffff3b30);
  static const orangeColor = Color(0xffff9500);
  static const Color greenColor = Color(0xff28a745);
  static const Color yellowColor = Color(0xfff2c94c);
  static const Color blueColor = Color(0xff007aff);
  static const Color purpleColor = Color(0xff7d3cff);
  static const whiteColor = Colors.white;

  static const Color primaryColor = Color(0xff2563eb);
  static const Color primaryColorDark = Color(0xff0066cc);
  static const Color secondary = Color(0xff32d74b);
  static const Color secondaryDark = Color(0xff30d158);
  static final Color selectedColor = primaryColor.withValues(alpha: 0.5);
  static const coreMistColor = Color.fromARGB(255, 136, 205, 237);
  static Color coreMist50Color = coreMistColor.withValues(alpha: 0.5);
  static const blackColor = Color.fromARGB(255, 54, 53, 58);
  static Color limeColor = const Color(0xffb2f142);
  static const greyColor = Color(0xffd8d9dd);

  static const darkDrawerColor = Color.fromRGBO(18, 18, 18, 1);
  static const lightScaffoldBackground = Color(0xfff2f8fc);

  // Themes
  static var darkModeAppTheme = ThemeData.dark(
    useMaterial3: true,
  ).copyWith(
      primaryColor: primaryColorDark,
      // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primaryColorDark.createMaterialColor(),
        brightness: Brightness.dark,
        //primaryColorDark: Colors.blue,
      ),
      dividerTheme:
          const DividerThemeData(color: Pallete.greyColor, thickness: 1),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff121a2e),
        elevation: 0,
        iconTheme: IconThemeData(
          color: whiteColor,
        ),
      ),
      // scaffoldBackgroundColor: darkDrawerColor,
      cardColor: const Color(0xff121a2e),
      scaffoldBackgroundColor: const Color.fromARGB(255, 33, 33, 35),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: blackColor,
          elevation: 0,
          selectedItemColor: blueColor,
          unselectedItemColor: Colors.white),
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkDrawerColor,
      ),
      // cupertinoOverrideTheme:  N,
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xff121a2e),
          barrierColor: Pallete.whiteColor.withValues(alpha: 0.3))
      // will be used as alternative background color
      );

  static var lightModeAppTheme = ThemeData.light(useMaterial3: true).copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightScaffoldBackground,
      cardColor: Pallete.whiteColor, // Default container color for light mode

      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primaryColor.createMaterialColor(),
        brightness: Brightness.light,
      ),
      dividerTheme:
          const DividerThemeData(color: Pallete.greyColor, thickness: 1),
      appBarTheme: const AppBarTheme(
        backgroundColor: whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: blackColor,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: whiteColor,
          elevation: 0,
          selectedItemColor: blueColor,
          unselectedItemColor: Colors.black),
      drawerTheme: const DrawerThemeData(
        backgroundColor: whiteColor,
      ),
      switchTheme: SwitchThemeData(
        thumbColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled) ||
              !states.contains(WidgetState.selected)) {
            return Pallete.whiteColor;
          }
          if (states.contains(WidgetState.selected)) {
            return Pallete.whiteColor;
          }
          return null;
        }),
        trackColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled) ||
              !states.contains(WidgetState.selected)) {
            return Pallete.greyColor;
          }
          if (states.contains(WidgetState.selected)) {
            return Pallete.blueColor;
          }
          return null;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor, // Reached part of the track
        inactiveTrackColor: Pallete.greyColor, // Unreached part
        thumbColor: primaryColor, // Thumb color
        overlayColor: primaryColor.withValues(
            alpha: 0.2), // Ripple effect around the thumb
        trackHeight: 4.0, // Optional: thickness of the track
        thumbShape:
            const RoundSliderThumbShape(enabledThumbRadius: 10.0), // Optional
        overlayShape:
            const RoundSliderOverlayShape(overlayRadius: 20.0), // Optional
      ),
      dialogTheme: const DialogThemeData(backgroundColor: Pallete.whiteColor),
      textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black)));
}

final isDarkModeProvider = StateProvider<bool>((ref) {
  bool isDark = ref.watch(themeNotifierProvider) == Pallete.darkModeAppTheme;
  return isDark;
});
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifierController, ThemeData>((ref) {
  return ThemeNotifierController(ref);
});

class ThemeNotifierController extends StateNotifier<ThemeData> {
  ThemeMode _mode;
  final Ref _ref;
  ThemeNotifierController(this._ref, {ThemeMode mode = ThemeMode.light})
      : _mode = mode,
        super(
          Pallete.lightModeAppTheme,
        ) {
    getTheme();
  }

  ThemeMode get mode => _mode;

  void getTheme() async {
    Brightness systemMode = _ref.watch(brightnessSystemProvider).brightness;
    final theme = await _ref.read(appPreferencesProvider).getData(key: "theme");
    switch (theme) {
      case "light":
        _mode = ThemeMode.light;
        state = Pallete.lightModeAppTheme;

        break;
      case "dark":
        _mode = ThemeMode.dark;
        state = Pallete.darkModeAppTheme;

        break;
      default:
        state = Pallete.lightModeAppTheme;

        break;
    }
  }

  void changeThemeMode(ThemeMode themeMode) async {
    switch (themeMode) {
      case ThemeMode.system:
        _mode = ThemeMode.light;
        state = Pallete.lightModeAppTheme;

        break;
      case ThemeMode.light:
        _mode = ThemeMode.light;
        state = Pallete.lightModeAppTheme;

        break;
      case ThemeMode.dark:
        _mode = ThemeMode.dark;
        state = Pallete.darkModeAppTheme;

        break;
    }
  }
}

final brightnessSystemProvider =
    ChangeNotifierProvider<BrightnessSystemNotifier>((ref) {
  return BrightnessSystemNotifier();
});

class BrightnessSystemNotifier extends ChangeNotifier {
  Brightness _brightness;

  BrightnessSystemNotifier()
      : _brightness = WidgetsBinding.instance.window.platformBrightness {
    WidgetsBinding.instance.window.onPlatformBrightnessChanged =
        _handleBrightnessChange;
  }

  // Getter to expose the current brightness
  Brightness get brightness => _brightness;

  // Method to handle brightness changes
  void _handleBrightnessChange() {
    _brightness = WidgetsBinding.instance.window.platformBrightness;
    notifyListeners(); // Notify listeners of the change
  }
}
