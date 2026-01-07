import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/receipt_details_dialog.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/refund_details_receipt.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class DailySalesReceiptItemMobile extends ConsumerWidget {
  const DailySalesReceiptItemMobile(this.receiptModel, {super.key});
  final ReceiptModel receiptModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var receiptController = ref.watch(receiptControllerProvider);
    final showPending = ref.read(selectedFinancialFilterIndex) == 1;
    final isSuperAdmin = ref.watch(mainControllerProvider).isAdmin;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      elevation: 1,
      shadowColor: context.brightnessColor,
      color: context.cardColor,
      shape: RoundedRectangleBorder(borderRadius: defaultRadius),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer info if pending
            if (receiptModel.customerModel != null && showPending) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Pallete.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: Pallete.primaryColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16.spMax,
                      color: Pallete.primaryColor,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: DefaultTextView(
                        text:
                            "${receiptModel.customerModel?.name} / ${receiptModel.customerModel?.phoneNumber}",
                        fontWeight: FontWeight.bold,
                        fontSize: 13.spMax,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
            ],

            // Receipt ID and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 16.spMax,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4.w),
                    DefaultTextView(
                      text: '#1-${receiptModel.id.toString()}',
                      fontWeight: FontWeight.bold,
                      fontSize: 14.spMax,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14.spMax, color: Colors.grey),
                    SizedBox(width: 4.w),
                    DefaultTextView(
                      text: DateFormat(
                        "dd-MM-yyyy h:mm a",
                      ).format(DateTime.parse(receiptModel.receiptDate)),
                      fontSize: 11.spMax,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Prices and Payment Type
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    label: AppConstance.primaryCurrency.currencyLocalization(),
                    value: receiptModel.foreignReceiptPrice
                        .validateDouble()
                        .formatDouble()
                        .toString(),
                    icon: Icons.attach_money,
                    valueColor: Pallete.greenColor,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    label: AppConstance.secondaryCurrency
                        .currencyLocalization(),
                    value: receiptModel.localReceiptPrice
                        .validateDouble()
                        .formatAmountNumber(),
                    icon: Icons.currency_exchange,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    label: S.of(context).paymentType,
                    value: receiptModel.paymentType.name,
                    icon: Icons.payment,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // View Details Button
                AppSquaredOutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          ReceiptDetailsDialog(receiptModel: receiptModel),
                    );
                  },
                  child: Icon(Icons.remove_red_eye, size: 16.spMax),
                ),

                // Refund Button (if applicable)
                if (!(receiptModel.transactionType == TransactionType.deposit ||
                    receiptModel.transactionType == TransactionType.withdraw ||
                    (receiptModel.foreignReceiptPrice == 0 &&
                        receiptModel.localReceiptPrice == 0))) ...[
                  SizedBox(width: 8.w),
                  AppSquaredOutlinedButton(
                    child: Icon(Icons.reply, size: 16.spMax),
                    onPressed: () async {
                      await ref
                          .read(receiptControllerProvider)
                          .getDetailsReceiptById(receiptModel.id!)
                          .then((value) {
                            if (value.isNotEmpty) {
                              value = value
                                  .where(
                                    (element) => element.isRefunded != true,
                                  )
                                  .toList();
                              context.to(RefundDetailsReceipt(value));
                            }
                          });
                    },
                  ),
                ],

                // Pay Button (if pending)
                if (receiptModel.isPaid != true &&
                    receiptModel.transactionType ==
                        TransactionType.pendingPayment) ...[
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Pallete.redColor,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                      ),
                      icon: Icon(
                        Icons.payment,
                        size: 16.spMax,
                        color: Colors.white,
                      ),
                      label: DefaultTextView(
                        text: S.of(context).pay,
                        fontSize: 11.spMax,
                        color: Colors.white,
                      ),
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
                  ),
                ],

                // Delete Button (if admin)
                if (isSuperAdmin) ...[
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Pallete.redColor,
                      size: 20.spMax,
                    ),
                    onPressed: () async {
                      final receiptId = receiptModel.id;
                      if (receiptId == null) return;

                      showDialog(
                        context: context,
                        builder: (context) {
                          RequestState deleteState = RequestState.success;
                          return StatefulBuilder(
                            builder: (BuildContext context, setstate) {
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
                                      .deleteReceipt(receiptModel, context)
                                      .whenComplete(() {
                                        setstate(() {
                                          deleteState = RequestState.success;
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12.spMax, color: Colors.grey),
            SizedBox(width: 3.w),
            Flexible(
              child: DefaultTextView(
                text: label,
                fontSize: 10.spMax,
                color: Colors.grey,
                maxlines: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        DefaultTextView(
          text: value,
          fontSize: 12.spMax,
          fontWeight: FontWeight.w600,
          color: valueColor,
        ),
      ],
    );
  }
}
