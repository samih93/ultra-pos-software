import 'package:desktoppossystem/shared/utils/enum.dart';

class LicenseSettingsModel {
  final bool showShift;
  final bool activateMenu;
  final bool onlyActivateMenu;
  final bool workWithIngredients;
  final bool activateSubscription;
  final String screenUI;

  LicenseSettingsModel({
    required this.showShift,
    required this.activateMenu,
    required this.onlyActivateMenu,
    required this.workWithIngredients,
    required this.activateSubscription,
    required this.screenUI,
  });

  factory LicenseSettingsModel.fromMap(Map<String, dynamic> map) {
    return LicenseSettingsModel(
      showShift: map['show_shift'] == true,
      activateMenu: map['activate_menu'] == true,
      onlyActivateMenu: map['only_activate_menu'] == true,
      workWithIngredients: map['work_with_ingredients'] == true,
      activateSubscription: map['activate_subscription'] == true,
      screenUI: map['screen_ui'] == "market"
          ? ScreenUI.market.name
          : ScreenUI.restaurant.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'show_shift': showShift,
      'activate_menu': activateMenu,
      'only_activate_menu': onlyActivateMenu,
      'work_with_ingredients': workWithIngredients,
      'activate_subscription': activateSubscription,
      'screen_ui': screenUI,
    };
  }

  static Map<String, dynamic> defaultJsonSetting() {
    return {
      'show_shift': true,
      'activate_menu': false,
      'only_activate_menu': false,
      'work_with_ingredients': false,
      'activate_subscription': false,
      'screen_ui': ScreenUI.market.name,
    };
  }
}
