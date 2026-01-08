import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/controller/expenses_controller.dart';
import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/controller/user_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/screens/dashboard/components/overview_dashboard.dart';
import 'package:desktoppossystem/screens/dashboard/components/sales_by_vew_pie_diagram.dart';
import 'package:desktoppossystem/screens/license_screen/license_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_controller.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/constances/asset_constant.dart';
import 'package:desktoppossystem/shared/constances/screens_title_constant.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_about_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/reusable_confirm_dialog.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/app_text_style.dart';
import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../controller/restaurant_stock_controller.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({this.padding, super.key});
  final EdgeInsets? padding;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var mainController = ref.watch(mainControllerProvider);
    UserModel userModel =
        ref.watch(currentUserProvider) ?? UserModel.fakeUser();

    return SafeArea(
      child: Stack(
        children: [
          Container(
            padding: padding ?? EdgeInsets.zero,
            child: Drawer(
              backgroundColor: context.cardColor,
              //  backgroundColor: Pallete.whiteColor,
              width: 270,
              // removing it for ios , checking if it creates issues
              // key: UniqueKey(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: isEnglishLanguage
                        ? const Radius.circular(16)
                        : Radius.zero,
                    bottomRight: isEnglishLanguage
                        ? const Radius.circular(16)
                        : Radius.zero,
                    topLeft: !isEnglishLanguage
                        ? const Radius.circular(16)
                        : Radius.zero,
                    bottomLeft: !isEnglishLanguage
                        ? const Radius.circular(16)
                        : Radius.zero,
                  ),
                  border: padding != null
                      ? Border.all(width: 1, color: Pallete.greyColor)
                      : null,
                ),
                child: Column(
                  children: [
                    Image.asset(
                      ref.read(isDarkModeProvider)
                          ? AssetConstant.coreWhiteLogoWithName
                          : AssetConstant.coreLogoWithName,
                      width: context.isWindows ? 120 : 70,
                    ),
                    kGap5,
                    Padding(
                      padding: kPadd10,
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  userModel.name ?? "User",
                                  style: AppTextStyles.boldTitle,
                                ),
                              ),
                            ],
                          ),
                          userModel.name != null
                              ? Text(
                                  userModel.role?.name
                                          .capitalizeFirstLetter() ??
                                      "User",
                                  style: AppTextStyles.subtitle,
                                )
                              : kEmptyWidget,
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Pallete.primaryColor),
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: MyCustomScrollBehavior(),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            ...mainController.appbarTitle.keys.map((element) {
                              final screenName = element;
                              final isRestaurantUi =
                                  mainController.screenUI ==
                                  ScreenUI.restaurant;
                              return Column(
                                children: [
                                  ColoredBox(
                                    color:
                                        screenName ==
                                            ref.watch(currentMainScreenProvider)
                                        ? context.primaryColor.withValues(
                                            alpha: 0.2,
                                          )
                                        : Colors.transparent,
                                    child: ListTile(
                                      dense: true,
                                      title: Text(
                                        fetchScreenNameBasedByText(
                                          context,
                                          screenName,
                                        ),
                                      ),

                                      leading: Icon(
                                        mainController.iconsMap[element],
                                        size: 18,
                                      ),
                                      onTap: () async {
                                        context.pop();

                                        ref
                                            .read(
                                              currentMainScreenProvider
                                                  .notifier,
                                            )
                                            .update((state) => screenName);
                                        await Future.delayed(
                                          const Duration(milliseconds: 200),
                                        );

                                        clearUnusedData(ref, screenName);

                                        Future.microtask(() async {
                                          switch (screenName) {
                                            //! customers
                                            case ScreenName.CustomerScreen:
                                              if (context.mounted) {
                                                ref
                                                    .read(
                                                      customerControllerProvider,
                                                    )
                                                    .fetchCustomersByBatch(
                                                      batch: 20,
                                                      offset: 0,
                                                    );
                                              }

                                              break;

                                            //! case receipt screen
                                            case ScreenName.DailyFinancials:
                                              if (context.mounted) {
                                                Future.microtask(() {
                                                  ref
                                                          .read(
                                                            salesSelectedDateProvider
                                                                .notifier,
                                                          )
                                                          .state =
                                                      DateTime.now();
                                                });
                                                ref
                                                    .read(
                                                      receiptControllerProvider,
                                                    )
                                                    .fetchPaginatedReceiptsByDay();

                                                ref.invalidate(
                                                  selectedFinancialFilterIndex,
                                                );
                                                isValidLicense(ref).then((
                                                  value,
                                                ) async {
                                                  if (!value) {
                                                    context.off(
                                                      const LicenseScreen(),
                                                    );
                                                  }
                                                });
                                              }

                                              break;
                                            case ScreenName.ShiftScreen:
                                              if (context.mounted) {
                                                ref
                                                    .read(
                                                      selectedShiftProvider
                                                          .notifier,
                                                    )
                                                    .update(
                                                      (state) => ref.read(
                                                        currentShiftProvider,
                                                      ),
                                                    );

                                                ref
                                                    .read(
                                                      receiptControllerProvider,
                                                    )
                                                    .fetchPaginatedReceiptsByShift(
                                                      resetPagination: true,
                                                    );
                                              }

                                              break;
                                            //! dashboard screen
                                            case ScreenName.Dashboard:
                                              if (context.mounted) {
                                                if (!ref
                                                    .read(
                                                      mainControllerProvider,
                                                    )
                                                    .isWorkWithIngredients) {
                                                  ref.refresh(
                                                    marketNotificationCountProvider,
                                                  );
                                                } else {
                                                  ref.refresh(
                                                    restaurantNotificationCountProvider,
                                                  );
                                                }
                                                ref
                                                    .read(
                                                      selectedDashboardViewProvider
                                                          .notifier,
                                                    )
                                                    .state = DashboardFilterEnum
                                                    .today;
                                                ref
                                                        .read(
                                                          isZoneSalesProvider
                                                              .notifier,
                                                        )
                                                        .state =
                                                    false;
                                              }

                                              break;

                                            case ScreenName.Expenses:
                                              if (context.mounted) {
                                                ref
                                                    .read(
                                                      expensesControllerProvider,
                                                    )
                                                    .fetchAllExpenses();
                                              }

                                              break;

                                            case ScreenName.InventoryScreen:
                                              if (context.mounted) {
                                                ref.refresh(
                                                  futureProductStatsProvider,
                                                );

                                                ref
                                                    .read(
                                                      stockControllerProvider,
                                                    )
                                                    .getStockByBatch(
                                                      batch: 30,
                                                      offset: 0,
                                                    );
                                                ref
                                                    .read(
                                                      stockControllerProvider,
                                                    )
                                                    .clearCategory();
                                              }

                                              break;

                                            case ScreenName
                                                .RestaurantInventoryScreen:
                                              if (context.mounted) {
                                                ref.refresh(
                                                  futureRestaurantInventoryCost,
                                                );
                                                ref
                                                    .read(
                                                      restaurantStockControllerProvider,
                                                    )
                                                    .fetchAllStockItems();
                                                ref
                                                        .read(
                                                          selectedSandwichProvider
                                                              .notifier,
                                                        )
                                                        .state =
                                                    null;
                                                ref.invalidate(
                                                  selectedIngredientsProvider,
                                                );
                                              }

                                              break;
                                            //! printer screen
                                            case ScreenName.SettingsScreen:
                                              if (context.mounted) {
                                                ref
                                                    .read(
                                                      printerControllerProvider,
                                                    )
                                                    .receiptNumberTextController
                                                    .text = ref
                                                    .read(
                                                      saleControllerProvider,
                                                    )
                                                    .receiptNumber
                                                    .toString();
                                                ref
                                                    .read(
                                                      settingControllerProvider,
                                                    )
                                                    .fetchSettings();
                                              }

                                              break;
                                            case ScreenName.ProfitReport:
                                              if (context.mounted) {
                                                ref
                                                    .read(
                                                      profitControllerProvider,
                                                    )
                                                    .onChangeProfitReport(
                                                      date: null,
                                                      view:
                                                          ReportInterval.daily,
                                                    );
                                              }

                                              break;
                                            case ScreenName.UserScreen:
                                              if (context.mounted) {
                                                ref
                                                    .read(
                                                      userControllerProvider,
                                                    )
                                                    .getAllUsers();
                                              }
                                              break;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }),
                            if (userModel.id ==
                                    int.tryParse(SecureConfig.quiverUserId) ||
                                context.isMobile)
                              ListTile(
                                dense: true,
                                title: const Text("Activate Licence"),
                                onTap: () {
                                  context.to(
                                    const LicenseScreen(
                                      isUsingQuiverTech: true,
                                    ),
                                  );
                                },
                                leading: const Icon(
                                  FontAwesomeIcons.idCard,
                                  size: 18,
                                ),
                              ),
                            ListTile(
                              dense: true,
                              title: DefaultTextView(
                                text: S.of(context).logout,
                                color: Pallete.redColor,
                                fontSize: 15,
                              ),
                              leading: const Icon(
                                Icons.power_settings_new_sharp,
                                color: Colors.red,
                              ),
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  builder: (_) {
                                    RequestState logoutState =
                                        RequestState.success;

                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return ReusableConfirmDialog(
                                          content: S
                                              .of(context)
                                              .areYouSureYouWantToLogout,
                                          confirmText: S.of(context).logout,
                                          onCancel: () {
                                            context.pop();
                                          },
                                          isLoading:
                                              logoutState ==
                                              RequestState.loading,
                                          onConfirm: () {
                                            setState(() {
                                              logoutState =
                                                  RequestState.loading;
                                            });
                                            ref
                                                .read(
                                                  authControllerProvider
                                                      .notifier,
                                                )
                                                .logOut(context)
                                                .whenComplete(() {
                                                  setState(() {
                                                    logoutState =
                                                        RequestState.success;
                                                  });
                                                });
                                          },
                                          gradientAcceptColor:
                                              myredLinearGradient(),
                                          title: '${S.of(context).logout}?',
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (mainController.isShowSelectModule && !context.isMobile)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppSquaredOutlinedButton(
                            child: Icon(
                              FontAwesomeIcons.utensils,
                              color:
                                  mainController.screenUI == ScreenUI.restaurant
                                  ? context.primaryColor
                                  : null,
                            ),
                            onPressed: () {
                              ref
                                  .read(mainControllerProvider)
                                  .onchangeSaleScreenUI(ScreenUI.restaurant);
                            },
                          ),
                          kGap5,
                          AppSquaredOutlinedButton(
                            child: Icon(
                              Icons.shopping_cart,
                              color: mainController.screenUI == ScreenUI.market
                                  ? context.primaryColor
                                  : null,
                            ),
                            onPressed: () {
                              ref
                                  .read(mainControllerProvider)
                                  .onchangeSaleScreenUI(ScreenUI.market);
                            },
                          ),
                        ],
                      ),
                    kGap10,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DefaultTextView(
                          text: "Developed By ",
                          color: context.brightnessColor,
                        ),
                        DefaultTextView(
                          text: "Ultra Pos®",
                          fontWeight: FontWeight.bold,
                          color: context.brightnessColor,
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DefaultTextView(
                          text: appVersion,
                          fontWeight: FontWeight.bold,
                          color: context.brightnessColor,
                        ),
                        kGap10,
                        const CoreLicenseInfo(),
                      ],
                    ),

                    // const QuiverSocialMediaWidget(),
                    // kGap10,
                    kGap5,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
