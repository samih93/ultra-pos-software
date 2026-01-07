import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/receipt_details_dialog.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/refund_details_receipt.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DailySalesReceiptItem extends ConsumerWidget {
  const DailySalesReceiptItem(this.receiptModel, {super.key});
  final ReceiptModel receiptModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var receiptController = ref.watch(receiptControllerProvider);
    final showPending = ref.read(selectedFinancialFilterIndex) == 1;
    return ColoredBox(
      color: receiptModel.isHasDiscount == true
          ? Colors.red.shade100
          : Colors.transparent,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          if (receiptModel.customerModel != null && showPending)
            Row(
              children: [
                DefaultTextView(
                  text: "${S.of(context).customer}: ",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                Container(
                  padding: kPadd5,
                  decoration: BoxDecoration(
                    color: Pallete.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.rectangle,
                    borderRadius: kRadius8,
                    border: Border.all(color: Pallete.primaryColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "${receiptModel.customerModel?.name} / ${receiptModel.customerModel?.phoneNumber}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          Row(
            children: [
              Expanded(
                child: DefaultTextView(
                  text: '#1-${receiptModel.id.toString()}',
                ),
              ),
              Expanded(
                child: Center(
                  child: DefaultTextView(
                    text: DateFormat(
                      "dd-MM-yyyy h:mm a",
                    ).format(DateTime.parse(receiptModel.receiptDate)),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: DefaultTextView(
                    text: receiptModel.foreignReceiptPrice
                        .validateDouble()
                        .formatDouble()
                        .toString(),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: DefaultTextView(
                    text: receiptModel.localReceiptPrice
                        .validateDouble()
                        .formatAmountNumber(),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: DefaultTextView(text: receiptModel.paymentType.name),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButtonWidget(
                      text: null,
                      icon: Icons.remove_red_eye,
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              ReceiptDetailsDialog(receiptModel: receiptModel),
                        );
                        // await receiptDetailsDialog(
                        //   context: context,
                        //   ref: ref,
                        //   receiptModel: receiptModel,
                        // );
                      },
                    ),
                    receiptModel.transactionType == TransactionType.deposit ||
                            receiptModel.transactionType ==
                                TransactionType.withdraw ||
                            (receiptModel.foreignReceiptPrice == 0 &&
                                receiptModel.localReceiptPrice == 0)
                        ? kEmptyWidget
                        : ElevatedButtonWidget(
                            text: S.of(context).refundButton,
                            radius: 5,
                            width: 80,
                            onPressed: () async {
                              await ref
                                  .read(receiptControllerProvider)
                                  .getDetailsReceiptById(receiptModel.id!)
                                  .then((value) {
                                    if (value.isNotEmpty) {
                                      value = value
                                          .where(
                                            (element) =>
                                                element.isRefunded != true,
                                          )
                                          .toList();
                                      context.to(RefundDetailsReceipt(value));
                                    }
                                  });
                            },
                          ),
                    if (receiptModel.isPaid != true &&
                        receiptModel.transactionType ==
                            TransactionType.pendingPayment)
                      ElevatedButtonWidget(
                        text: S.of(context).pay,
                        color: Pallete.redColor,
                        radius: 5,
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) => AreYouSureDialog(
                              "${S.of(context).areYouSurePay} ${receiptModel.id} ${S.of(context).quetionMark} \nRemaining Amount is ${receiptModel.remainingAmount.formatDouble()}${AppConstance.primaryCurrency.currencyLocalization()}",
                              onAgree: () {
                                ref
                                    .read(receiptControllerProvider)
                                    .togglePayReceipt(receiptModel, true)
                                    .whenComplete(() {
                                      context.pop();
                                    });
                              },
                              onCancel: () => context.pop(),
                              agreeText: S.of(context).pay,
                            ),
                          );
                        },
                      ),
                    if (ref.watch(mainControllerProvider).isAdmin)
                      ElevatedButtonWidget(
                        text: null,
                        icon: Icons.delete_outline,
                        color: Pallete.redColor,
                        onPressed: () async {
                          final receiptId = receiptModel.id;

                          if (receiptId == null) {
                            // Handle case where ID might be null or invalid
                            // Possibly show an error message or log the issue
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) {
                              RequestState deleteState = RequestState.success;

                              return StatefulBuilder(
                                builder:
                                    (
                                      BuildContext context,
                                      void Function(void Function()) setstate,
                                    ) {
                                      return AreYouSureDialog(
                                        agreeText: S.of(context).delete,
                                        "${S.of(context).areYouSureDelete} ${S.of(context).receipt} ${S.of(context).nb} '$receiptId'",
                                        onCancel: () => context.pop(),
                                        agreeState: deleteState,
                                        onAgree: () async {
                                          setstate(() {
                                            deleteState = RequestState.loading;
                                          });
                                          ref
                                              .read(receiptControllerProvider)
                                              .deleteReceipt(
                                                receiptModel,
                                                context,
                                              )
                                              .whenComplete(() {
                                                setstate(() {
                                                  deleteState =
                                                      RequestState.success;
                                                });
                                              });
                                        },
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
            ],
          ),
        ],
      ),
    );
  }
}
