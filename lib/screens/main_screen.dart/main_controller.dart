import 'dart:io';

import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/customer_screen/customer_screen.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/screens/dashboard/dashboard_screen.dart';
import 'package:desktoppossystem/screens/online_menu_screen/online_menu_screen.dart';
import 'package:desktoppossystem/screens/profit_report_screen/profit_report_screen.dart';
import 'package:desktoppossystem/screens/purchases_screen/purchase_screen.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/restaurant_sale_screen.dart';
import 'package:desktoppossystem/screens/sale_screens/market_sale_screen/market_sale_screen.dart';
import 'package:desktoppossystem/screens/settings/manage_setting_screen.dart';
import 'package:desktoppossystem/screens/shift_screen/shift_screen.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_screen.dart';
import 'package:desktoppossystem/screens/subscription_management/subscription_management_screen.dart';
import 'package:desktoppossystem/screens/users/user_screen.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/constances/screens_title_constant.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../shared/constances/auth_role.dart';
import '../restaurant_stock/restaurant_stock_screen.dart';

final mainControllerProvider = ChangeNotifierProvider<MainController>((ref) {
  return MainController(ref: ref);
});

class MainController extends ChangeNotifier {
  final Ref _ref;
  MainController({required Ref ref}) : _ref = ref {
    UserModel? userModel = _ref.watch(currentUserProvider);
    if (userModel != null) {
      if (userModel.role!.name
          case AuthRole.adminRole ||
              AuthRole.superAdminRole ||
              AuthRole.ownerRole) {
        isAdmin = true;
      }
      if (userModel.role!.name case AuthRole.waiterRole || AuthRole.salesRole) {
        isSales = true;
      }

      isSuperAdmin =
          userModel.role!.name == AuthRole.superAdminRole ||
          userModel.role!.name == AuthRole.ownerRole;
    } else {
      isAdmin = false;
      isSuperAdmin = false;
    }
    isOwner = userModel?.id == int.tryParse(SecureConfig.quiverUserId);
    fetchSavedConfiguration();
  }
  bool isOwner = false;

  bool get isLtr => selectedLanguage != Language.ar;

  bool get isWorkWithIngredients =>
      isShowRestaurantStock && screenUI == ScreenUI.restaurant;

  Language selectedLanguage = Language.en;
  int _retryCount = 0;
  final int _maxRetries = 3; // Maximum number of retries
  final Duration _retryDelay = const Duration(
    seconds: 2,
  ); // Delay between retries

  Future fetchSavedConfiguration() async {
    try {
      final sharedPres = _ref.read(appPreferencesProvider);
      String cashedUI =
          sharedPres.getData(key: "screenUI") ??
          (!Platform.isWindows ? "market" : 'restaurant');

      subscriptionActivated = sharedPres.getSecureBool(
        key: SecureConfig.subscriptionKey,
        defaultValue: false,
      );
      menuActivated = sharedPres.getSecureBool(
        key: SecureConfig.activateMenuKey,
        defaultValue: false,
      );

      onlyActivatedMenu = sharedPres.getSecureBool(
        key: SecureConfig.onlyActivateMenuKey,
        defaultValue: false,
      );

      screenUI = cashedUI == "restaurant"
          ? ScreenUI.restaurant
          : ScreenUI.market;
      isShowShiftScreen = sharedPres.getBool(
        key: "showShift",
        defaultValue: true,
      );

      isShowRestaurantStock = sharedPres.getBool(
        key: "showRestaurantStock",
        defaultValue: false,
      );
      selectedLanguage = sharedPres
          .getData(key: "language")
          .toString()
          .toEnumLanguage();

      regenerateMenu(screenUI);
    } catch (e) {
      debugPrint(e.toString());
      if (_retryCount < _maxRetries) {
        _retryCount++;
        await Future.delayed(_retryDelay); // Delay before retrying
        fetchSavedConfiguration(); // Retry
      } else {
        // Handle the case where the maximum retries have been reached
        // You could notify the user or log the error for further analysis
        debugPrint(
          "Failed to fetch saved configuration after $_maxRetries retries.",
        );
      }
    }
  }

  bool menuActivated = false;
  void toggleMenuActivation() {
    menuActivated = !menuActivated;

    _ref
        .read(appPreferencesProvider)
        .saveData(
          key: SecureConfig.activateMenuKey,
          value: menuActivated ? SecureConfig.trueKey : SecureConfig.falseKey,
        );
    if (menuActivated == false) {
      onlyActivatedMenu = false;
      _ref
          .read(appPreferencesProvider)
          .saveData(
            key: SecureConfig.onlyActivateMenuKey,
            value: SecureConfig.falseKey,
          );
    }
    notifyListeners();
  }

  bool subscriptionActivated = false;
  void toggleSubscriptionActivation() {
    subscriptionActivated = !subscriptionActivated;
    _ref
        .read(appPreferencesProvider)
        .saveData(
          key: SecureConfig.subscriptionKey,
          value: subscriptionActivated
              ? SecureConfig.trueKey
              : SecureConfig.falseKey,
        );
    notifyListeners();
  }

  bool onlyActivatedMenu = false;

  void toggleOnlyActivatedMenu() {
    onlyActivatedMenu = !onlyActivatedMenu;
    _ref
        .read(appPreferencesProvider)
        .saveData(
          key: SecureConfig.onlyActivateMenuKey,
          value: onlyActivatedMenu
              ? SecureConfig.trueKey
              : SecureConfig.falseKey,
        );
    notifyListeners();
  }

  onchangeCurrentLanguage(Language language) async {
    selectedLanguage = language;
    await _ref
        .read(appPreferencesProvider)
        .saveData(key: "language", value: language.name);
    notifyListeners();
  }

  bool isSales = false;
  bool isAdmin = false;
  bool isSuperAdmin = false;
  //bool isOwner = false;
  //! NOTE: --------------------- On Change Index Of Screens ------------------

  ScreenUI screenUI = ScreenUI.restaurant;
  Future onchangeSaleScreenUI(ScreenUI ui) async {
    regenerateMenu(ui);
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "screenUI", value: screenUI.name.toString());
  }

  int selectedInvoice = 1;
  onChangeSelectedInvoice(int number) {
    selectedInvoice = number;
    notifyListeners();
  }

  bool isMenuPrepared = false;

  final Map<String, IconData> iconsMap = {
    ScreenName.SaleScreen: FontAwesomeIcons.cashRegister,
    ScreenName.DailyFinancials: FontAwesomeIcons.chartLine,
    ScreenName.ShiftScreen: FontAwesomeIcons.solidClock,
    ScreenName.InventoryScreen: FontAwesomeIcons.warehouse,
    ScreenName.Purchases: FontAwesomeIcons.cartShopping,
    ScreenName.RestaurantInventoryScreen: FontAwesomeIcons.utensils,
    ScreenName.CustomerScreen: FontAwesomeIcons.users,
    ScreenName.SubscriptionScreen: FontAwesomeIcons.calendarCheck,
    ScreenName.UserScreen: FontAwesomeIcons.userGear,
    ScreenName.SettingsScreen: FontAwesomeIcons.gear,
    ScreenName.ProfitReport: FontAwesomeIcons.solidFileLines,
    ScreenName.Dashboard: FontAwesomeIcons.gaugeHigh,
    ScreenName.OnlineMenuScreen: FontAwesomeIcons.globe,
  };

  Map<String, Widget> screens = {};
  Map<String, String> appbarTitle = {};

  regenerateMenu(ScreenUI ui) {
    isMenuPrepared = false;

    screenUI = ui;

    // If onlyActivatedMenu is true, show only Online Menu screen (for non-owners)
    if (!isOwner && onlyActivatedMenu && menuActivated) {
      screens = {
        ScreenName.OnlineMenuScreen: const OnlineMenuScreen(),
        ScreenName.SettingsScreen: const ManageSettingScreen(),
      };
      appbarTitle = {
        ScreenName.OnlineMenuScreen: 'Online Menu',
        ScreenName.SettingsScreen: 'Settings',
      };
      isMenuPrepared = true;
      notifyListeners();
      return;
    }

    // Build screens map - Windows-only screens are marked with Platform.isWindows
    // Remove Platform.isWindows check when a screen is ready for mobile
    screens = {
      ScreenName.SaleScreen: screenUI == ScreenUI.restaurant
          ? const RestaurantSaleScreen()
          : const MarketSaleScreen(),
      ScreenName.DailyFinancials: const DailyFinancialScreen(),
      if (Platform.isWindows && isShowShiftScreen)
        ScreenName.ShiftScreen: const ShiftScreen(),
      if (isAdmin && !isWorkWithIngredients)
        ScreenName.InventoryScreen: const StockScreen(),
      if (Platform.isWindows && isSuperAdmin && !isWorkWithIngredients)
        ScreenName.Purchases: const PurchaseScreen(),
      if (Platform.isWindows && isShowRestaurantStock && isAdmin)
        ScreenName.RestaurantInventoryScreen: const RestaurantStockScreen(),
      if (Platform.isWindows) ScreenName.CustomerScreen: const CustomerScreen(),
      if (Platform.isWindows && subscriptionActivated)
        ScreenName.SubscriptionScreen: const SubscriptionManagementScreen(),
      if (Platform.isWindows && isSuperAdmin)
        ScreenName.UserScreen: const UserScreen(),
      ScreenName.SettingsScreen: const ManageSettingScreen(),
      if (isSuperAdmin) ScreenName.ProfitReport: const ProfitReportScreen(),
      if (isAdmin) ScreenName.Dashboard: const DashboardScreen(),
      if (isAdmin && menuActivated)
        ScreenName.OnlineMenuScreen: const OnlineMenuScreen(),
    };

    appbarTitle = {
      ScreenName.SaleScreen: 'Sales',
      ScreenName.DailyFinancials: 'Daily Sales',
      if (Platform.isWindows && isShowShiftScreen)
        ScreenName.ShiftScreen: 'Shift',
      if (isAdmin && !isWorkWithIngredients)
        ScreenName.InventoryScreen: 'Inventory',
      if (Platform.isWindows && isSuperAdmin && !isWorkWithIngredients)
        ScreenName.Purchases: 'Purchases',
      if (Platform.isWindows && isShowRestaurantStock && isAdmin)
        ScreenName.RestaurantInventoryScreen: 'Restaurant Inventory',
      if (Platform.isWindows) ScreenName.CustomerScreen: 'Customers',
      if (Platform.isWindows && subscriptionActivated)
        ScreenName.SubscriptionScreen: 'Subscriptions',
      if (Platform.isWindows && isSuperAdmin) ScreenName.UserScreen: 'Users',
      ScreenName.SettingsScreen: 'Settings',
      if (isSuperAdmin) ScreenName.ProfitReport: 'Profit Report',
      if (isAdmin) ScreenName.Dashboard: 'Dashboard',
      if (isAdmin && menuActivated) ScreenName.OnlineMenuScreen: 'Online Menu',
    };

    isMenuPrepared = true;
    notifyListeners();
  }

  bool isShowShiftScreen = true;

  onchangeShowShiftScreen() {
    isShowShiftScreen = !isShowShiftScreen;
    regenerateMenu(screenUI);

    _ref
        .read(appPreferencesProvider)
        .saveData(key: "showShift", value: isShowShiftScreen);
    notifyListeners();
  }

  bool isShowRestaurantStock = false;

  onchangeViewRestaurantStock() {
    isShowRestaurantStock = !isShowRestaurantStock;
    regenerateMenu(screenUI);

    _ref
        .read(appPreferencesProvider)
        .saveData(key: "showRestaurantStock", value: isShowRestaurantStock);
    notifyListeners();
  }

  bool isShowStockScreen = true;
  onShowStock() {
    isShowStockScreen = !isShowStockScreen;
    regenerateMenu(screenUI);

    _ref
        .read(appPreferencesProvider)
        .saveData(
          key: "isShowStockScreen",
          value: isShowStockScreen.toString(),
        );
    notifyListeners();
  }

  bool isShowPurchases = true;
  onShowPurchasesScreen() {
    isShowPurchases = !isShowPurchases;
    regenerateMenu(screenUI);

    _ref
        .read(appPreferencesProvider)
        .saveData(key: "isShowPurchases", value: isShowPurchases.toString());
    notifyListeners();
  }

  bool isShowSelectModule = true;

  onchangeShowSelectModule() {
    isShowSelectModule = !isShowSelectModule;
    regenerateMenu(screenUI);
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "showModule", value: isShowSelectModule);
    notifyListeners();
  }
}
