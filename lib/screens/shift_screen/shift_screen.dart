import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/reports/end_of_day_model.dart';
import 'package:desktoppossystem/models/reports/end_of_shift_employee_model.dart';
import 'package:desktoppossystem/models/reports/restaurant_stock_usage_model.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/shift_screen/components/shift_balance_section.dart';
import 'package:desktoppossystem/screens/shift_screen/components/shift_receipt_list.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../main_screen.dart/main_controller.dart';

final shiftSelectedUserProvider = StateProvider<UserModel?>((ref) {
  return null;
});

class ShiftScreen extends ConsumerWidget {
  const ShiftScreen({super.key});

  generateCurrentShiftText(WidgetRef ref, BuildContext context) {
    if (ref.watch(currentShiftProvider).id != null &&
        DateTime.tryParse(
              ref.watch(currentShiftProvider).startShiftDate.toString(),
            ) !=
            null) {
      return "${S.of(context).currentShift} : #${ref.watch(currentShiftProvider).id} -  ${DateTime.parse(ref.watch(currentShiftProvider).startShiftDate.toString()).formatDateTime12Hours()} => ${ref.watch(currentShiftProvider).endShiftDate == null ? S.of(context).now : DateTime.parse(ref.watch(currentShiftProvider).endShiftDate.toString()).formatDateTime12Hours()}";
    }
    return "";
  }

  generateSelectedShiftText(WidgetRef ref, BuildContext context) {
    if (ref.watch(selectedShiftProvider).id != null &&
        DateTime.tryParse(
              ref.watch(selectedShiftProvider).startShiftDate.toString(),
            ) !=
            null) {
      return "#${ref.watch(selectedShiftProvider).id!} - ${DateTime.parse(ref.watch(selectedShiftProvider).startShiftDate.toString()).formatDateTime12Hours()} => ${ref.watch(selectedShiftProvider).endShiftDate == null ? S.of(context).now : DateTime.parse(ref.watch(selectedShiftProvider).endShiftDate.toString()).formatDateTime12Hours()}";
    }
    return "";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var receiptController = ref.watch(receiptControllerProvider);

    return Column(
      children: [
        Row(
          crossAxisAlignment: .start,
          children: [
            Container(
              padding: defaultPadding,
              decoration: BoxDecoration(
                color: Pallete.whiteColor,
                borderRadius: defaultRadius,
              ),
              child: DefaultTextView(
                color: context.primaryColor,
                fontSize: 16,
                text: generateCurrentShiftText(ref, context),
              ),
            ),
          ],
        ),
        if (ref.watch(mainControllerProvider).isAdmin) ...[
          kGap5,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 10,
            children: [
              Flexible(
                child: Row(
                  children: [
                    AppSquaredOutlinedButton(
                      child: const Icon(Icons.arrow_back_ios_rounded),
                      onPressed: () {
                        ref
                            .read(receiptControllerProvider)
                            .fetchShift(isPrev: true);
                      },
                    ),
                    Flexible(
                      child: Tooltip(
                        message: generateSelectedShiftText(ref, context),
                        child: DefaultTextView(
                          fontSize: 16,
                          text: generateSelectedShiftText(ref, context),
                        ),
                      ),
                    ),
                    AppSquaredOutlinedButton(
                      isDisabled:
                          ref.watch(currentShiftProvider).id ==
                          ref.watch(selectedShiftProvider).id,
                      child: const Icon(Icons.arrow_forward_ios_rounded),
                      onPressed: () {
                        ref
                            .read(receiptControllerProvider)
                            .fetchShift(isNext: true);
                      },
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 5,
                  children: [
                    if (ref.watch(selectedShiftProvider).id! <
                        ref.watch(currentShiftProvider).id!)
                      AppSquaredOutlinedButton(
                        size: const Size(110, 38),
                        child: Text(S.of(context).currentShift),
                        onPressed: () {
                          ref
                              .read(receiptControllerProvider)
                              .fetchShift(isLast: true);
                        },
                      ),
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
                          border: Border.all(
                            width: 1,
                            color: Pallete.greyColor,
                          ),
                        ),
                        child: DropdownButton<UserModel>(
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          value: ref.watch(shiftSelectedUserProvider),
                          underline: kEmptyWidget,
                          borderRadius: defaultRadius,
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
                            receiptController.onChangeUserSelection(
                              value!,
                              isForShift: true,
                            );
                          },
                        ),
                      ),
                    ),
                    AppSquaredOutlinedButton(
                      states: [
                        ref
                            .watch(globalControllerProvider)
                            .openDailySaleExcelRequestState,
                      ],
                      onPressed: () async {
                        await downalodShiftReport(ref, receiptController);
                      },
                      child: const FaIcon(
                        FontAwesomeIcons.fileExcel,
                        size: 18,
                        color: Pallete.greenColor,
                      ),
                    ),
                    if (!ref.read(isAtLastShiftProvider))
                      ElevatedButtonWidget(
                        height: 38,
                        states: [
                          ref
                              .watch(printerControllerProvider)
                              .printEndOfShiftRequest,
                        ],
                        icon: Icons.print,
                        text: S.of(context).print,
                        onPressed: () async {
                          ref
                              .read(printerControllerProvider)
                              .printEndOfShift(
                                context,
                                isPrintShift: true,
                                isForSelectedShift: true,
                              )
                              .then((value) {});
                        },
                      ),
                    if (ref.read(isAtLastShiftProvider))
                      ElevatedButtonWidget(
                        icon: FontAwesomeIcons.rightFromBracket,
                        height: 38,
                        states: [
                          ref
                              .watch(printerControllerProvider)
                              .printEndOfShiftRequest,
                        ],
                        width: 100,
                        text: S.of(context).endOFShift,
                        isDisabled:
                            receiptController.receiptsListByShift.isEmpty,
                        onPressed: () async {
                          await ref
                              .read(printerControllerProvider)
                              .printEndOfShift(context)
                              .then((value) {
                                // ! end shift
                                receiptController.onEndShift(
                                  userId: ref.read(currentUserProvider)!.id!,
                                  role: ref
                                      .read(currentUserProvider)!
                                      .role
                                      .toString(),
                                );
                              });
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
        const ShiftBalanceSection(),
        kGap15,
        Expanded(
          child: receiptController.receiptsListByShift.isEmpty
              ? const Center(
                  child: Text(
                    "No Receipts yet",
                    style: TextStyle(color: Colors.grey, fontSize: 25),
                  ),
                )
              : const ShiftReceiptList(),
        ),
      ],
    ).baseContainer(context.cardColor);
  }

  Future<void> downalodShiftReport(
    WidgetRef ref,
    ReceiptController receiptController,
  ) async {
    List<ProductModel> products = [];
    List<RestaurantStockUsageModel> stockUsage = [];
    List<RestaurantStockModel> stockItems = [];

    await Future.wait([
      ref
          .read(receiptControllerProvider)
          .getsellingProducts(shiftId: ref.watch(selectedShiftProvider).id!)
          .then((value) {
            products = value;
          }),
      if (ref.read(mainControllerProvider).isWorkWithIngredients &&
          ref.read(mainControllerProvider).isSuperAdmin)
        ref
            .read(receiptControllerProvider)
            .fetchStockUsageReport(
              view: null,
              shiftId: ref.read(selectedShiftProvider).id!,
            )
            .then((value) {
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
        futureReceiptTotalsByShiftProvider,
      );
      totalsAsync.when(
        data: (totals) {
          var endOfDayModel = EndOfDayModel(
            stockUsage: stockUsage,
            stockItems: stockItems,
            date: ref
                .read(salesSelectedDateProvider)
                .toString()
                .split(" ")
                .first,
            nbCustomers: totals.totalInvoices,
            employeeName: ref.read(shiftSelectedUserProvider)?.name.toString(),
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
            imageData: [],
            expenses: receiptController.expensesByShift,
            totalSubscriptions:
                ref.read(mainControllerProvider).subscriptionActivated
                ? totals.totalSubscriptions
                : null,
            endOfShiftEmployeeModel: EndOfShiftEmployeeModel(
              shiftId: ref.watch(selectedShiftProvider).id!,
              employeeName: ref.read(currentUserProvider) != null
                  ? ref.read(currentUserProvider)!.name.toString()
                  : "User",
              startShiftDate: ref
                  .watch(selectedShiftProvider)
                  .startShiftDate
                  .toString(),
              endShiftDate:
                  ref.watch(selectedShiftProvider).endShiftDate ??
                  DateTime.now().toString(),
            ),
          );
          ref
              .read(globalControllerProvider)
              .openDailySalesInExcel(products, endOfDayModel);
        },
        error: (Object error, StackTrace stackTrace) {
          return kEmptyWidget;
        },
        loading: () {
          return kEmptyWidget;
        },
      );
    });
  }
}

// _ImageDataContainer(List<ReceiptModel> receipts, BuildContext context) {
//   var currentfont = getfontSizeByPrinterSize(context
//       .read<PrinterController>()
//       .currentPrinterSettings
//       .pageSize
//       .toString());
//   return Container(
//     decoration: const BoxDecoration(
//       color: Colors.white,
//     ),
//     // color: Colors.white,
//     child: Column(
//         crossAxisAlignment: .start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ...receipts.map((e) => SizedBox(
//                 width: currentfont == 13 ? 280 : 500,
//                 child: Row(
//                   children: [
//                     Text(
//                       " #${e.id} : ",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                         fontSize: currentfont,
//                       ),
//                     ),
//                     Text(
//                       " ${AmountFormat.format(e.localReceiptPrice)} ",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                         fontSize: currentfont,
//                       ),
//                     ),
//                     Text(
//                       " - ${e.paymentType == PaymentType.cash ? "Cash" : "Deposit"} ",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                         fontSize: currentfont,
//                       ),
//                     ),
//                   ],
//                 ),
//               ))
//         ]),
//   );
//}
