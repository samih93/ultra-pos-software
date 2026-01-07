import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/order_type_section.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/new_default_button.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeAmountDialog extends ConsumerWidget {
  const ChangeAmountDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var saleController = ref.watch(saleControllerProvider);
    UserModel usermodel =
        ref.watch(currentUserProvider) ?? UserModel.fakeUser();
    return AlertDialog(
      scrollable: true,
      content: SizedBox(
        height: context.isWindows ? 500 : 410,
        width: context.isWindows ? 400 : 350,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                children: [
                  const DefaultTextView(text: "Pay in : "),
                  CustomToggleButton(
                    text1: AppConstance.primaryCurrency.currencyLocalization(),
                    text2: AppConstance.secondaryCurrency
                        .currencyLocalization(),
                    isSelected: saleController.payInDolar,
                    onPressed: (index) {
                      ref
                          .read(saleControllerProvider)
                          .onchangePaymentCurrency();
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DefaultTextView(text: "Total :", fontSize: context.bodySize),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: DefaultTextView(
                      text:
                          "${saleController.foreignTotalPrice.toStringAsFixed(2)} ${AppConstance.primaryCurrency.currencyLocalization()}  / ${saleController.localTotalPrice.formatAmountNumber()} ${AppConstance.secondaryCurrency.currencyLocalization()} ",
                      color: Colors.red,
                      fontSize: context.bodySize,
                    ),
                  ),
                ],
              ),
              kGap5,
              InkWell(
                onTap: () {
                  ref
                      .read(saleControllerProvider)
                      .onChangeEnteringAmountType(true);
                },
                child: Container(
                  padding: kPadd5,
                  decoration: !saleController.onEnterReceived
                      ? null
                      : BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Pallete.primaryColor,
                          ),
                          borderRadius: kRadius15,
                        ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DefaultTextView(
                        text: "Received :",
                        fontSize: context.bodySize,
                      ),
                      DefaultTextView(
                        text:
                            "${saleController.payInDolar ? "${saleController.receivedAmount.toStringAsFixed(2)} ${AppConstance.primaryCurrency.currencyLocalization()}" : "${saleController.receivedAmount.formatAmountNumber()} ${AppConstance.secondaryCurrency.currencyLocalization()}"} ",
                        fontSize: context.bodySize,
                      ),
                    ],
                  ),
                ),
              ),
              kGap5,
              NumberDialog(qty: "1"),
              kGap5,
              InkWell(
                onTap: () {
                  ref
                      .read(saleControllerProvider)
                      .onChangeEnteringAmountType(false);
                },
                child: Container(
                  padding: context.isWindows ? kPadd5 : kPaddH5,
                  decoration: saleController.onEnterReceived
                      ? null
                      : BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Pallete.primaryColor,
                          ),
                          borderRadius: kRadius15,
                        ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DefaultTextView(
                        text: "Return :",
                        fontSize: context.bodySize,
                      ),
                      DefaultTextView(
                        text: saleController.isShowInDolarInSaleScreen
                            ? "${saleController.changeDue.toStringAsFixed(2)} ${AppConstance.primaryCurrency.currencyLocalization()}"
                            : '${saleController.changeDue.formatAmountNumber()} ${AppConstance.secondaryCurrency.currencyLocalization()}',
                        color: Colors.red,
                        fontSize: context.bodySize,
                      ),
                    ],
                  ),
                ),
              ),
              if (saleController.returnedSoFar > 0) ...[
                kGap5,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DefaultTextView(
                      text:
                          "- ${saleController.returnedSoFar.toStringAsFixed(2)} \$",
                      color: Colors.red,
                      fontSize: context.bodySize,
                    ),
                  ],
                ),
              ],
              Row(
                children: [
                  kEmptyWidget,
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (saleController.returnedSoFar > 0)
                        const SizedBox(
                          width: 80,
                          child: Divider(color: Pallete.redColor, height: 1),
                        ),
                      DefaultTextView(
                        text:
                            '${saleController.totalChangeInLebanonInDialog.formatAmountNumber()} ${AppConstance.secondaryCurrency}',
                        color: Colors.red,
                        fontSize: context.bodySize,
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NewDefaultButton(
                    text: S.of(context).pay,
                    width: 80,
                    state: ref.watch(receiptControllerProvider).payRequestState,
                    onpress: () async {
                      ReceiptModel receiptModel = ReceiptModel(
                        orderType: ref.read(selectedOrderTypeProvider),
                        foreignReceiptPrice: saleController.foreignTotalPrice,
                        localReceiptPrice: saleController.localTotalPrice,
                        receiptDate: DateTime.now().toString(),
                        userId: usermodel.id,
                        dollarRate: ref.read(saleControllerProvider).dolarRate,
                        transactionType: TransactionType.salePayment,
                        paymentType: PaymentType.cash,
                        shiftId: ref.read(currentShiftProvider).id!,
                        customerId: saleController.customerModel?.id,
                        isPaid: true,
                        isHasDiscount: saleController.basketItems.any(
                          (e) => e.discount! > 0,
                        ),
                      );
                      receiptModel.customerModel = saleController.customerModel;
                      await ref
                          .read(receiptControllerProvider)
                          .pay(
                            receiptModel,
                            saleController.basketItems,
                            context: context,
                          )
                          .whenComplete(() {
                            context.pop();
                            ref.read(saleControllerProvider).resetAmounts();
                          });
                    },
                  ),
                  kGap20,
                  ElevatedButtonWidget(
                    text: "Reset",
                    radius: 5,
                    onPressed: () {
                      ref.read(saleControllerProvider).resetAmounts();
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 40,
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: Colors.white,
                      fillColor: Theme.of(context).primaryColor,
                      color: Colors.grey,
                      isSelected: [
                        ref.watch(printerControllerProvider).isprintReceipt,
                        !ref.watch(printerControllerProvider).isprintReceipt,
                      ],
                      onPressed: (index) {
                        ref
                            .read(printerControllerProvider)
                            .onchangePrintingStatus();
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.print_outlined),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.print_disabled_outlined),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NumberDialog extends ConsumerWidget {
  final String qty;
  NumberDialog({super.key, required this.qty});

  final List<String> _numbers = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0",
    "00",
    "000",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraintsDashboardItem) => Column(
            children: [
              Wrap(
                children: [
                  ..._numbers.map(
                    (e) => InkWell(
                      onTap: () {
                        ref.read(saleControllerProvider).onReceiveAmount(e);
                      },
                      child: buildItemNumber(
                        e,
                        constraintsDashboardItem.maxWidth,
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  buildItemNumber(String item, double maxWidth, BuildContext context) =>
      Container(
        width: maxWidth / 3,
        height: context.isWindows ? 50 : 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: DefaultTextView(
            text: item,
            color: item == "Delete" ? Colors.red : null,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
