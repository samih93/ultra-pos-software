import 'package:desktoppossystem/controller/financial_transaction_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/financial_transaction_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class FinancialTransactionItem extends ConsumerWidget {
  const FinancialTransactionItem(this.model, {super.key});
  final FinancialTransactionModel model;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var receiptController = ref.watch(receiptControllerProvider);

    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            if (model.flow == TransactionFlow.OUT)
              const Icon(Icons.upload, color: Pallete.redColor),
            if (model.flow == TransactionFlow.IN)
              const Icon(Icons.download, color: Pallete.greenColor),
            Expanded(child: DefaultTextView(text: model.transactionType.name)),
            Expanded(
              child: Center(
                child: DefaultTextView(
                  text: DateFormat(
                    "dd-MM-yyyy h:mm a",
                  ).format(DateTime.parse(model.transactionDate)),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: DefaultTextView(
                  text: model.primaryAmount
                      .validateDouble()
                      .formatDouble()
                      .toString(),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: DefaultTextView(
                  text: model.secondaryAmount
                      .validateDouble()
                      .formatAmountNumber(),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(child: SelectableText(model.note ?? '--')),
            ),
            if (ref.watch(mainControllerProvider).isAdmin)
              ElevatedButtonWidget(
                text: null,
                icon: Icons.delete_outline,
                color: Pallete.redColor,
                onPressed: () async {
                  final transactionId = model.id;

                  if (transactionId == null) {
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
                                "${S.of(context).areYouSureDelete} ${S.of(context).transaction}'",
                                onCancel: () => context.pop(),
                                agreeState: deleteState,
                                onAgree: () async {
                                  setstate(() {
                                    deleteState = RequestState.loading;
                                  });
                                  ref
                                      .read(
                                        financialTransactionControllerProvider,
                                      )
                                      .deleteTransaction(transactionId, context)
                                      .whenComplete(() {
                                        setstate(() {
                                          deleteState = RequestState.success;
                                          context.pop();
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
      ],
    );
  }
}
