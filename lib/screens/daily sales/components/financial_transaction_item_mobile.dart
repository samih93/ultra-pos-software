import 'package:desktoppossystem/controller/financial_transaction_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/financial_transaction_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
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

class FinancialTransactionItemMobile extends ConsumerWidget {
  const FinancialTransactionItemMobile(this.model, {super.key});
  final FinancialTransactionModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // Transaction type and flow icon
            Row(
              children: [
                if (model.flow == TransactionFlow.OUT)
                  Icon(Icons.upload, color: Pallete.redColor, size: 20.spMax),
                if (model.flow == TransactionFlow.IN)
                  Icon(
                    Icons.download,
                    color: Pallete.greenColor,
                    size: 20.spMax,
                  ),
                SizedBox(width: 8.w),
                Expanded(
                  child: DefaultTextView(
                    text: model.transactionType.name,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.spMax,
                  ),
                ),
                if (isSuperAdmin)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Pallete.redColor,
                      size: 20.spMax,
                    ),
                    onPressed: () => _handleDelete(context, ref),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            SizedBox(height: 8.h),

            // Date
            _buildInfoRow(
              context,
              icon: Icons.calendar_today,
              label: S.of(context).date,
              value: DateFormat(
                "dd-MM-yyyy h:mm a",
              ).format(DateTime.parse(model.transactionDate)),
            ),
            SizedBox(height: 6.h),

            // Amounts row
            Row(
              children: [
                Expanded(
                  child: _buildAmountCard(
                    context,
                    label: AppConstance.primaryCurrency.currencyLocalization(),
                    amount: model.primaryAmount
                        .validateDouble()
                        .formatDouble()
                        .toString(),
                    isPrimary: true,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildAmountCard(
                    context,
                    label: AppConstance.secondaryCurrency
                        .currencyLocalization(),
                    amount: model.secondaryAmount
                        .validateDouble()
                        .formatAmountNumber(),
                    isPrimary: false,
                  ),
                ),
              ],
            ),

            // Note if available
            if (model.note != null && model.note!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 16.spMax,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: DefaultTextView(
                        text: model.note!,
                        fontSize: 12.spMax,
                        color: Colors.grey[700],
                        maxlines: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14.spMax, color: Colors.grey),
        SizedBox(width: 6.w),
        DefaultTextView(
          text: "$label: ",
          fontSize: 12.spMax,
          color: Colors.grey,
        ),
        Expanded(
          child: DefaultTextView(
            text: value,
            fontSize: 12.spMax,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountCard(
    BuildContext context, {
    required String label,
    required String amount,
    required bool isPrimary,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: (isPrimary ? Pallete.primaryColor : Colors.orange).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: isPrimary ? Pallete.primaryColor : Colors.orange,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextView(text: label, fontSize: 10.spMax, color: Colors.grey),
          SizedBox(height: 2.h),
          DefaultTextView(
            text: amount,
            fontSize: 13.spMax,
            fontWeight: FontWeight.bold,
            color: isPrimary ? Pallete.primaryColor : Colors.orange,
          ),
        ],
      ),
    );
  }

  void _handleDelete(BuildContext context, WidgetRef ref) {
    final transactionId = model.id;

    if (transactionId == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        RequestState deleteState = RequestState.success;

        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setstate) {
            return AreYouSureDialog(
              agreeText: S.of(context).delete,
              "${S.of(context).areYouSureDelete} ${S.of(context).transaction}'",
              onCancel: () => context.pop(),
              agreeState: deleteState,
              onAgree: () async {
                setstate(() {
                  deleteState = RequestState.loading;
                });
                ref
                    .read(financialTransactionControllerProvider)
                    .deleteTransaction(transactionId, context)
                    .then((value) {
                      setstate(() {
                        deleteState = RequestState.success;
                        context.pop();
                      });
                      context.pop();
                    })
                    .catchError((e) {
                      setstate(() {
                        deleteState = RequestState.error;
                      });
                    });
              },
            );
          },
        );
      },
    );
  }
}
