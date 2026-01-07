import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/reports/end_of_day_model.dart';
import 'package:desktoppossystem/models/reports/restaurant_stock_usage_model.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/balance_section.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/daily_sales_receipt_list.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/financial_transactions_list_section.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/sales_select_date_section.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen_mobile.dart';
import 'package:desktoppossystem/screens/main_screen.dart/components/daily_sales_transactions_dialog/add_daily_transaction_dialog.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button_new.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final showTransactionsProvider = StateProvider<bool>((ref) {
  return false;
});
final selectedFinancialFilterIndex = StateProvider<int>((ref) {
  return 0;
});

final salesSelectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final salesSelectedUser = StateProvider<UserModel?>((ref) {
  return null;
});

// final showBalanceSectionProvider = StateProvider<bool>((ref) {
//   return true;
// });

class DailyFinancialScreen extends ConsumerWidget {
  const DailyFinancialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ResponsiveWidget(
      desktopView: DailyFinancialScreenDesktop(),
      mobileView: DailyFinancialScreenMobile(),
    );
  }
}

class DailyFinancialScreenDesktop extends ConsumerWidget {
  const DailyFinancialScreenDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var receiptController = ref.watch(receiptControllerProvider);
    final showTransaction = ref.watch(selectedFinancialFilterIndex) == 2;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            const SalesSelectDateSection(),
            const Spacer(),
            Row(
              spacing: 10,
              children: [
                if (ref.watch(mainControllerProvider).isAdmin)
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 180,
                      minWidth: 130,
                    ),
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: defaultRadius,
                        color: Pallete.whiteColor,
                        border: Border.all(width: 1, color: Pallete.greyColor),
                      ),
                      child: DropdownButton<UserModel>(
                        isExpanded: true,
                        underline: kEmptyWidget,
                        borderRadius: defaultRadius,
                        dropdownColor: Colors.white,
                        value: ref.read(salesSelectedUser),
                        iconEnabledColor: Pallete.blackColor,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        items: ref
                            .read(receiptControllerProvider)
                            .users
                            .map(
                              (e) => DropdownMenuItem<UserModel>(
                                value: e,
                                child: DefaultTextView(
                                  color: Pallete.blackColor,
                                  maxlines: 2,
                                  text: e.name.toString(),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          receiptController.onChangeUserSelection(value!);
                        },
                      ),
                    ),
                  ),
                Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (ref.watch(mainControllerProvider).isAdmin) ...[
                      AppSquaredOutlinedButton(
                        states: [
                          receiptController.getSellingProductsRequestState,
                          ref
                              .watch(globalControllerProvider)
                              .openDailySaleExcelRequestState,
                        ],
                        onPressed: () async {
                          await downloadDailyReport(ref, receiptController);
                        },
                        child: const FaIcon(
                          FontAwesomeIcons.fileExcel,
                          size: 18,
                          color: Pallete.greenColor,
                        ),
                      ),
                      AppSquaredOutlinedButton(
                        states: [
                          ref
                              .watch(printerControllerProvider)
                              .printEndOfDayRequest,
                        ],
                        onPressed: () async {
                          await ref
                              .read(printerControllerProvider)
                              .printEndOfDay(context, isForDailySales: true);
                        },
                        child: const Icon(Icons.print),
                      ),
                    ],
                    // AppSquaredOutlinedButton(
                    //     child: ref.watch(showBalanceSectionProvider)
                    //         ? const Icon(Icons.arrow_drop_up)
                    //         : const Icon(Icons.arrow_drop_down),
                    //     onPressed: () async {
                    //       ref
                    //           .read(showBalanceSectionProvider.notifier)
                    //           .update((state) => !state);
                    //     }),
                  ],
                ),
              ],
            ),
            AppSquaredOutlinedButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AddDailyTransactionDialog();
                  },
                );
              },
            ),
            CustomToggleButtonNew(
              labels: [
                S.of(context).receipts.capitalizeFirstLetter(),
                S.of(context).pending.capitalizeFirstLetter(),
                S.of(context).transactions.capitalizeFirstLetter(),
              ],
              height: 38,
              onPressed: (index) {
                if (index == 0 || index == 1) {
                  ref
                      .read(receiptControllerProvider)
                      .onChangeReceiptsOrderType(index);
                }
                ref.read(selectedFinancialFilterIndex.notifier).update((state) {
                  return index; // Update the selected index state
                });
              },
              selectedIndex: ref.watch(selectedFinancialFilterIndex),
            ),
          ],
        ),
        const BalanceSection(),
        kGap5,
        ref.watch(selectedFinancialFilterIndex) == 2
            ? const Expanded(child: FinancialTransactionsListSection())
            : const Expanded(child: DailySalesReceiptList()),
      ],
    ).baseContainer(context.cardColor);
  }
}

Future<void> downloadDailyReport(
  WidgetRef ref,
  ReceiptController receiptController,
) async {
  List<ProductModel> products = [];
  List<RestaurantStockUsageModel> stockUsage = [];
  List<RestaurantStockModel> stockItems = [];
  await Future.wait([
    ref.read(receiptControllerProvider).getsellingProducts().then((value) {
      products = value;
    }),
    if (ref.read(mainControllerProvider).isWorkWithIngredients &&
        ref.read(mainControllerProvider).isSuperAdmin)
      ref.read(receiptControllerProvider).fetchStockUsageReport().then((value) {
        stockUsage = value;
      }),
    if (ref.read(mainControllerProvider).isWorkWithIngredients &&
        ref.read(mainControllerProvider).isAdmin)
      ref.read(receiptControllerProvider).fetchAllStockItems().then((value) {
        stockItems = value;
        stockItems.sort((a, b) {
          // First, compare by unitType
          int unitTypeComparison = a.unitType.name.compareTo(b.unitType.name);

          // If unitType is the same, then compare by qty
          if (unitTypeComparison == 0) {
            return b.qty.compareTo(a.qty); // Sort by qty in descending order
          } else {
            return unitTypeComparison; // Sort by unitType in ascending order
          }
        });
      }),
  ]).then((value) {
    final AsyncValue<ReceiptTotals> totalsAsync = ref.watch(
      futureReceiptTotalsProvider,
    );
    totalsAsync.when(
      data: (totals) {
        var endOfDayModel = EndOfDayModel(
          date: ref.read(salesSelectedDateProvider).toString().split(" ").first,
          nbCustomers: totals.totalInvoices,
          salesPrimary: totals.salesDolar,
          salesSecondary: totals.salesLebanon,
          totalPrimary:
              totals.totalPrimaryBalance +
              (totals.totalSecondaryBalance /
                      ref.read(saleControllerProvider).dolarRate)
                  .formatDouble(),
          depositDolar: totals.totalDepositDolar,
          depositLebanese: totals.totalDepositLebanon,
          withdrawDolar: totals.totalWithdrawDolar,
          withdrawLebanese: totals.totalWithdrawLebanon,
          withdrawDolarFromCash: totals.totalWithdrawDolarFromCash,
          withdrawLebaneseFromCash: totals.totalWithdrawLebanonFromCash,
          totalPendingAmount: totals.totalPendingAmount,
          totalPendingReceipts: totals.totalPendingReceipts,
          totalCollectedPending: totals.totalCollectedPending,
          totalRefunds: totals.totalRefunds,
          totalPurchasesPrimary: totals.totalPurchasesPrimary,
          totalPurchasesSecondary: totals.totalPurchasesSecondary,
          totalSubscriptions:
              ref.read(mainControllerProvider).subscriptionActivated
              ? totals.totalSubscriptions
              : null,
          imageData: [],
          endOfShiftEmployeeModel: null,
        );
        ref
            .read(globalControllerProvider)
            .openDailySalesInExcel(products, endOfDayModel);
      },
      error: (error, stackTrace) {},
      loading: () {},
    );
  });
}
