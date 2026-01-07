import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/receipt_details_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ShiftReceiptItem extends ConsumerWidget {
  const ShiftReceiptItem(this.receiptModel, {super.key});
  final ReceiptModel receiptModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var receiptController = ref.watch(receiptControllerProvider);

    return ColoredBox(
      color: receiptModel.isHasDiscount == true
          ? Colors.red.shade100
          : Colors.transparent,
      child: Row(
        children: [
          Expanded(
              child: DefaultTextView(
            text: '#1-${receiptModel.id.toString()}',
          )),
          Expanded(
              child: Center(
                  child: DefaultTextView(
                      text: DateFormat("dd-MM-yyyy h:mm a")
                          .format(DateTime.parse(receiptModel.receiptDate))))),
          Expanded(
              child: Center(
            child: DefaultTextView(
              text: receiptModel.foreignReceiptPrice
                  .validateDouble()
                  .formatDouble()
                  .toString(),
            ),
          )),
          Expanded(
              child: Center(
            child: DefaultTextView(
              text: receiptModel.localReceiptPrice
                  .validateDouble()
                  .formatAmountNumber(),
            ),
          )),
          Expanded(
            child: Center(
              child: DefaultTextView(
                text: receiptModel.transactionType != null
                    ? "cash - ${receiptModel.transactionType!.name}"
                    : receiptModel.paymentType.name,
              ),
            ),
          ),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButtonWidget(
                  text: S.of(context).detailsButton,
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          ReceiptDetailsDialog(receiptModel: receiptModel),
                    );
                  }),
            ],
          ))
        ],
      ),
    );
  }
}
