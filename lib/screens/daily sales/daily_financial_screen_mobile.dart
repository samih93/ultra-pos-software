import 'dart:io';

import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/reports/end_of_day_model.dart';
import 'package:desktoppossystem/models/reports/restaurant_stock_usage_model.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/balance_section.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/daily_sales_receipt_list_mobile.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/financial_transactions_list_section_mobile.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/sales_select_date_section.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/components/daily_sales_transactions_dialog/add_daily_transaction_dialog.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button_new.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DailyFinancialScreenMobile extends ConsumerWidget {
  const DailyFinancialScreenMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var receiptController = ref.watch(receiptControllerProvider);
    final selectedIndex = ref.watch(selectedFinancialFilterIndex);

    return Column(
      children: [
        // Date selector
        const SalesSelectDateSection(),
        kGap5,

        // Toggle buttons and actions in mobile layout
        Column(
          children: [
            // Toggle between receipts, pending, transactions
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
                  return index;
                });
              },
              selectedIndex: selectedIndex,
            ),
            kGap5,

            // Actions row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // User filter dropdown (if admin)
                if (ref.watch(mainControllerProvider).isAdmin)
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: defaultRadius,
                        color: Pallete.whiteColor,
                        border: Border.all(width: 1, color: Pallete.greyColor),
                      ),
                      child: DropdownButton<dynamic>(
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
                              (e) => DropdownMenuItem(
                                value: e,
                                child: DefaultTextView(
                                  color: Pallete.blackColor,
                                  maxlines: 1,
                                  fontSize: 12,
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
                kGap5,

                // Action buttons in popup menu
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    if (ref.watch(mainControllerProvider).isAdmin) ...[
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.fileExcel,
                              size: 18,
                              color: Pallete.greenColor,
                            ),
                            kGap10,
                            DefaultTextView(text: S.of(context).exportToExcel),
                          ],
                        ),
                        onTap: () async {
                          await downloadDailyReport(ref, receiptController);
                        },
                      ),
                      if (Platform.isAndroid)
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.print),
                              kGap10,
                              Text(S.of(context).print),
                            ],
                          ),
                          onTap: () async {
                            await ref
                                .read(printerControllerProvider)
                                .printEndOfDay(context, isForDailySales: true);
                          },
                        ),
                    ],
                  ],
                ),

                // Add transaction button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AddDailyTransactionDialog();
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        kGap5,

        // Balance section
        const BalanceSection(),
        kGap5,

        // Content based on selected tab
        selectedIndex == 2
            ? const Expanded(child: FinancialTransactionsListSectionMobile())
            : const Expanded(child: DailySalesReceiptListMobile()),
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
          int unitTypeComparison = a.unitType.name.compareTo(b.unitType.name);
          if (unitTypeComparison == 0) {
            return b.qty.compareTo(a.qty);
          } else {
            return unitTypeComparison;
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
