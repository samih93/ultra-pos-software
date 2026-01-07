import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/financial_transaction_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/financial_transaction_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/components/daily_sales_transactions_dialog/components/add_expense_type_screen.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddDailyTransactionDialog extends ConsumerWidget {
  AddDailyTransactionDialog({super.key});

  final GlobalKey<FormState> _transationsKey = GlobalKey<FormState>();
  bool isloadingAddAmount = false;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel usermodel =
        ref.watch(currentUserProvider) ?? UserModel.fakeUser();
    var transactionController = ref.watch(
      financialTransactionControllerProvider,
    );

    return AlertDialog(
      title: Center(
        child: Text("${S.of(context).add} ${S.of(context).transaction}"),
      ),
      content: SizedBox(
        width: 350,
        height: 250,
        child: Form(
          key: _transationsKey,
          child: Column(
            children: [
              CustomToggleButton(
                text1: S.of(context).withdraw.capitalizeFirstLetter(),
                text2: S.of(context).deposit.capitalizeFirstLetter(),
                isSelected: transactionController.isPaymentTypeWithDraw,
                onPressed: (index) {
                  transactionController.onchangePaymentType();
                },
              ),
              AppTextFormField(
                showText: true,
                onvalidate: (value) {
                  if (value!.isEmpty) {
                    return S.of(context).amountAlert;
                  }
                  return null;
                },
                format: numberTextFormatter,
                controller: transactionController.receiptAmountTextController,
                inputtype: TextInputType.number,
                border: const UnderlineInputBorder(),
                hinttext: S.of(context).amount,
              ),
              kGap10,
              if (transactionController.selectedTransactionType ==
                  TransactionType.withdraw) ...[
                AppTextFormField(
                  onvalidate: (value) {
                    if (value!.isEmpty) {
                      return S.of(context).expenseAlert;
                    }
                    return null;
                  },
                  suffixIcon: transactionController.selectedExpense == null
                      ? kEmptyWidget
                      : InkWell(
                          onTap: () {
                            transactionController.clearSelectedExpense();
                          },
                          child: const Icon(Icons.close),
                        ),
                  ontap: () {
                    ref
                        .read(financialTransactionControllerProvider)
                        .clearSelectedExpense();
                    showDialog(
                      context: context,
                      builder: (internalContext) =>
                          // Pass the controller to the provider
                          AddExpenseTypeScreen(),
                    );
                  },
                  inputtype: TextInputType.text,
                  controller: transactionController.noteTextController,
                  readonly: true,
                  hinttext: S.of(context).tapHereToSelectExpense,
                ),
              ],
              kGap10,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomToggleButton(
                    text1: AppConstance.primaryCurrency.currencyLocalization(),
                    text2: AppConstance.secondaryCurrency
                        .currencyLocalization(),
                    isSelected: transactionController.isPrimaryCurrency,
                    onPressed: (index) {
                      transactionController.onchangePrimaryCurrencyCurrency();
                    },
                  ),
                ],
              ),
              if (transactionController.selectedTransactionType ==
                  TransactionType.withdraw)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const DefaultTextView(text: "from cash ?"),
                    Checkbox(
                      semanticLabel: "from cash",
                      value: transactionController.withDrawFromCash,
                      onChanged: (val) {
                        transactionController.onchangeWithDrawFromCash();
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            transactionController.receiptAmountTextController.clear();
            isloadingAddAmount = false;
            context.pop();
          },
          child: Text(S.of(context).cancel),
        ),
        isloadingAddAmount
            ? const SizedBox(width: 60, child: CoreCircularIndicator())
            : TextButton(
                onPressed: () async {
                  if (_transationsKey.currentState!.validate()) {
                    String transactionDate = DateTime.now().toString();

                    transactionDate =
                        "${ref.read(salesSelectedDateProvider).toString().split(" ").first} ${transactionDate.split(" ")[1]}";

                    FinancialTransactionModel
                    transaction = FinancialTransactionModel(
                      transactionDate: transactionDate,
                      primaryAmount: transactionController.isPrimaryCurrency
                          ? double.parse(
                              transactionController
                                  .receiptAmountTextController
                                  .text,
                            )
                          : 0,
                      dollarRate: ref.read(saleControllerProvider).dolarRate,
                      secondaryAmount: !transactionController.isPrimaryCurrency
                          ? double.parse(
                              transactionController
                                  .receiptAmountTextController
                                  .text,
                            )
                          : 0,
                      isTransactionInPrimary:
                          transactionController.isPrimaryCurrency,
                      paymentType: PaymentType.cash,
                      flow:
                          transactionController.selectedTransactionType ==
                              TransactionType.deposit
                          ? TransactionFlow.IN
                          : (transactionController.selectedTransactionType ==
                                    TransactionType.withdraw
                                ? TransactionFlow.OUT
                                : TransactionFlow
                                      .IN), // Adjust logic for your flow
                      transactionType:
                          transactionController.selectedTransactionType,
                      receiptId:
                          null, // If this is linked to receipt, assign here
                      fromCash: ref
                          .read(financialTransactionControllerProvider)
                          .withDrawFromCash,
                      expenseId: transactionController.selectedExpense?.id,
                      note:
                          transactionController.selectedExpense?.expensePurpose,
                      customerId: null, // assign if applicable
                      shiftId: ref.read(currentShiftProvider).id!,
                      userId: ref.read(currentUserProvider)?.id ?? 0,
                    );
                    await ref
                        .read(financialTransactionControllerProvider)
                        .addFinancialTransaction(transaction)
                        .then((value) {
                          transactionController.resetTransactionDialog();
                          context.pop();
                        });
                  }
                },
                child: Text(S.of(context).add),
              ),
      ],
    );
  }
}
