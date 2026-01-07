// ignore_for_file: use_build_context_synchronously, unused_result

import 'dart:io';

import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/components/barcode/sale_barcode_listener.dart';
import 'package:desktoppossystem/screens/main_screen.dart/components/dolar_rate_widget.dart';
import 'package:desktoppossystem/screens/main_screen.dart/components/market_notification_icon.dart';
import 'package:desktoppossystem/screens/main_screen.dart/components/my_drawer.dart';
import 'package:desktoppossystem/screens/main_screen.dart/components/restaurant_notification_icon.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/price_check_screen/price_check_screen.dart';
import 'package:desktoppossystem/screens/sale_screens/market_sale_screen/components/mobile_scanner_section.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/constances/auth_role.dart';
import 'package:desktoppossystem/shared/constances/screens_title_constant.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/auto_complete_product.dart';
import 'package:desktoppossystem/shared/default%20components/new_default_button.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/styles/app_text_style.dart';
import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller/receipt_controller.dart';

final currentMainScreenProvider = StateProvider<String>((ref) {
  return ScreenName.SaleScreen;
});

final isOnSearchProvider = StateProvider<bool>((ref) {
  return false;
});

final barcodeListenerEnabledProvider = StateProvider<bool>((ref) => true);
// to check if scanned by barcode reader
final isScanningProvider = StateProvider<bool>((ref) => false);

class MainScreen extends ConsumerWidget {
  MainScreen({super.key});

  final barcodeSearchTextController = TextEditingController();

  final FocusNode _barcodeSearchFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // to avoid add receipt without shift
    // current shift loaded from receipt controller on initialize
    if (ref.read(currentShiftProvider).id == null) {
      ref.read(receiptControllerProvider);
    }
    ref.read(printerControllerProvider);
    var mainController = ref.watch(mainControllerProvider);
    if (ref.read(currentUserProvider)?.role?.name == AuthRole.priceChecker) {
      return const PriceCheckScreen();
    }
    // load categories if ui market , used in profit controller
    ref.read(categoryControllerProvider);

    return !mainController.isMenuPrepared
        ? const Scaffold(body: Center(child: CoreCircularIndicator()))
        : Scaffold(
            key: _key,
            appBar: AppBar(
              actions: context.isMobile
                  ? _buildMobileActions(context, ref)
                  : _buildDesktopActions(context, ref),
              title: context.isMobile
                  ? _buildMobileTitle(context, ref, mainController)
                  : _buildDesktopTitle(context, ref, mainController),
            ),
            drawer:
                ref.read(mainControllerProvider).isSales ||
                    (context.width > 1310 &&
                        ref.watch(mainControllerProvider).screenUI ==
                            ScreenUI.market)
                ? null
                : const MyDrawer(),
            body: SafeArea(
              child: Row(
                children: [
                  if (context.width > 1310 &&
                      ref.watch(mainControllerProvider).screenUI ==
                          ScreenUI.market &&
                      !ref.read(mainControllerProvider).isSales)
                    const SizedBox(
                      width: 250,
                      child: MyDrawer(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                      ),
                    ),
                  Expanded(
                    child: RepaintBoundary(
                      child: mainController
                          .screens[ref.watch(currentMainScreenProvider)],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  // Desktop Actions
  List<Widget> _buildDesktopActions(BuildContext context, WidgetRef ref) {
    return [
      Platform.isWindows ? const DolarRateWidget() : kEmptyWidget,
      kGap5,
      const MarketNotificationIcon(),
      const RestaurantNotificationIcon(),
      kGap5,
      const SettingIconButton(),
      const HomeIconButton(),
      const ToggleThemeButton(),
    ];
  }

  // Mobile Actions - Only ToggleThemeButton
  List<Widget> _buildMobileActions(BuildContext context, WidgetRef ref) {
    return [const ToggleThemeButton()];
  }

  // Desktop Title
  Widget _buildDesktopTitle(
    BuildContext context,
    WidgetRef ref,
    MainController mainController,
  ) {
    return Row(
      children: [
        if (Platform.isWindows ||
            (context.isMobile &&
                ref.read(currentMainScreenProvider) != ScreenName.SaleScreen))
          Expanded(
            child: Text(
              ref.read(currentUserProvider)?.role?.name == AuthRole.salesRole
                  ? ref.read(currentUserProvider)!.name.toString()
                  : fetchScreenNameBasedByText(
                      context,
                      ref.watch(currentMainScreenProvider),
                    ),
              style: AppTextStyles.appBarTitle,
            ),
          ),
        Row(
          children: [
            if (ref.watch(currentMainScreenProvider) == ScreenName.SaleScreen &&
                mainController.screenUI == ScreenUI.restaurant &&
                ref.watch(barcodeListenerEnabledProvider))
              SizedBox(
                width: 280,
                child: AppTextFormField(
                  backColor: Pallete.coreMistColor,
                  focusNode: _barcodeSearchFocusNode,
                  controller: barcodeSearchTextController,
                  hinttext: S.of(context).barcodeOrName,
                  onchange: (val) {
                    ref
                        .read(productControllerProvider)
                        .searchForAProduct(val.validateString());

                    if (val.validateString().trim() != "") {
                      ref
                          .read(isOnSearchProvider.notifier)
                          .update((state) => true);
                    } else {
                      ref
                          .read(isOnSearchProvider.notifier)
                          .update((state) => false);
                    }
                  },
                  suffixIcon: ref.watch(isOnSearchProvider)
                      ? IconButton(
                          onPressed: () {
                            ref
                                .read(isOnSearchProvider.notifier)
                                .update((state) => false);
                            barcodeSearchTextController.clear();
                            ref
                                .read(productControllerProvider)
                                .resetProductList();
                          },
                          icon: Icon(Icons.close, color: context.primaryColor),
                        )
                      : kEmptyWidget,
                  inputtype: TextInputType.name,
                ),
              ),
          ],
        ),
        BarcodeScanListener(
          barcodeSearchTextController: barcodeSearchTextController,
        ),
        if (ref.watch(currentMainScreenProvider) == ScreenName.SaleScreen &&
            mainController.screenUI == ScreenUI.market)
          AutoCompleteProduct(
            isForMarket: true,
            onFieldSubmit: (p0) {
              ref
                  .read(saleControllerProvider)
                  .addItemToBasket(p0, weight: p0.weight);
            },
            onProductSelected: (product) {
              ref.read(saleControllerProvider).addItemToBasket(product);
            },
          ),
        if (ref.watch(mainControllerProvider).isSales) ...[
          kGap10,
          NewDefaultButton(
            width: 100,
            height: 50,
            onpress: () {
              showDialog(
                context: context,
                builder: (_) {
                  RequestState logoutState = RequestState.success;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AreYouSureDialog(
                        agreeText: S.of(context).logout,
                        '${S.of(context).areYouSureYouWantToLogout} ${S.of(context).quetionMark}',
                        onCancel: () {
                          context.pop();
                          context.pop();
                        },
                        agreeState: logoutState,
                        onAgree: () {
                          setState(() {
                            logoutState = RequestState.loading;
                          });
                          ref
                              .read(authControllerProvider.notifier)
                              .logOut(context)
                              .then((value) {
                                setState(() {
                                  logoutState = RequestState.success;
                                });
                              });
                        },
                      );
                    },
                  );
                },
              );
            },
            gradient: myredLinearGradient(),
            text: S.of(context).logout,
          ),
        ],
      ],
    );
  }

  // Mobile Title - Search field based on screenUI
  Widget _buildMobileTitle(
    BuildContext context,
    WidgetRef ref,
    MainController mainController,
  ) {
    // Only show search on Sale Screen
    if (ref.watch(currentMainScreenProvider) != ScreenName.SaleScreen) {
      return Text(
        fetchScreenNameBasedByText(
          context,
          ref.watch(currentMainScreenProvider),
        ),
        style: AppTextStyles.appBarTitle,
      );
    }

    // Restaurant UI - AppTextFormField
    if (mainController.screenUI == ScreenUI.restaurant) {
      return AppTextFormField(
        backColor: Pallete.coreMistColor,
        focusNode: _barcodeSearchFocusNode,
        controller: barcodeSearchTextController,
        hinttext: S.of(context).barcodeOrName,
        onchange: (val) {
          ref
              .read(productControllerProvider)
              .searchForAProduct(val.validateString());

          if (val.validateString().trim() != "") {
            ref.read(isOnSearchProvider.notifier).update((state) => true);
          } else {
            ref.read(isOnSearchProvider.notifier).update((state) => false);
          }
        },
        suffixIcon: ref.watch(isOnSearchProvider)
            ? IconButton(
                onPressed: () {
                  ref
                      .read(isOnSearchProvider.notifier)
                      .update((state) => false);
                  barcodeSearchTextController.clear();
                  ref.read(productControllerProvider).resetProductList();
                },
                icon: Icon(Icons.close, color: context.primaryColor),
              )
            : kEmptyWidget,
        inputtype: TextInputType.name,
      );
    }

    // Market UI - AutoCompleteProduct
    return Row(
      children: [
        Expanded(
          child: AutoCompleteProduct(
            isForMarket: true,
            onFieldSubmit: (p0) {
              ref
                  .read(saleControllerProvider)
                  .addItemToBasket(p0, weight: p0.weight);
            },
            onProductSelected: (product) {
              ref.read(saleControllerProvider).addItemToBasket(product);
            },
          ),
        ),
        IconButton(
          icon: Icon(
            ref.watch(mobileScannerActiveProvider)
                ? Icons.close
                : Icons.qr_code_scanner,
          ),
          onPressed: () {
            ref
                .read(mobileScannerActiveProvider.notifier)
                .update((state) => !state);
          },
        ),
      ],
    );
  }
}

class SettingIconButton extends ConsumerWidget {
  const SettingIconButton({super.key});

  void fetchAndOpenSettingScreen(BuildContext context, WidgetRef ref) {
    if (context.mounted) {
      ref.read(printerControllerProvider).receiptNumberTextController.text = ref
          .read(saleControllerProvider)
          .receiptNumber
          .toString();
      ref.read(settingControllerProvider).fetchSettings();
    }
    ref.read(currentMainScreenProvider.notifier).state =
        ScreenName.SettingsScreen;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ref.watch(currentMainScreenProvider);
    return screen == ScreenName.SaleScreen
        ? IconButton(
            onPressed: () {
              fetchAndOpenSettingScreen(context, ref);
            },
            icon: const Icon(Icons.settings_outlined),
          )
        : kEmptyWidget;
  }
}

class HomeIconButton extends ConsumerWidget {
  const HomeIconButton({super.key});

  handleHomeButtonPress(WidgetRef ref) {
    final mainController = ref.read(mainControllerProvider);

    ref.read(currentMainScreenProvider.notifier).state = ScreenName.SaleScreen;
    clearUnusedData(ref, ScreenName.SaleScreen);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ref.watch(currentMainScreenProvider);
    final isMobile = context.isMobile;
    return screen != ScreenName.SaleScreen && !isMobile
        ? IconButton(
            onPressed: () => handleHomeButtonPress(ref),
            icon: const Icon(Icons.home_outlined),
          )
        : kEmptyWidget;
  }
}

final selectedThemeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});

class ToggleThemeButton extends ConsumerWidget {
  const ToggleThemeButton({super.key});

  static const List<ThemeMode> themeModeList = [
    ThemeMode.light,
    ThemeMode.dark,
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return IconButton(
      onPressed: () {
        final newSelectedMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
        ref.read(selectedThemeModeProvider.notifier).state = newSelectedMode;
        ref
            .read(themeNotifierProvider.notifier)
            .changeThemeMode(newSelectedMode);
        // Save the theme mode to preferences
        ref
            .read(appPreferencesProvider)
            .saveData(key: "theme", value: newSelectedMode.name.toString());
      },
      icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode_outlined),
    );
  }
}
