import 'package:desktoppossystem/controller/expenses_controller.dart';
import 'package:desktoppossystem/controller/financial_transaction_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_outline_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_form.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';

import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'expense_item.dart';

class AddExpenseTypeScreen extends ConsumerWidget {
  AddExpenseTypeScreen({this.isInExpenseScreen, super.key});
  final bool? isInExpenseScreen;
  final expenseTextController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var expensesController = ref.watch(expensesControllerProvider);
    return AlertDialog(
      content: SizedBox(
        height: 400,
        width: 350,
        child: Column(
          children: [
            AppTextFormField(
              onchange: (val) {
                expensesController.onSearchInExpenses(val.toString());
              },
              format: [EnglishOnlyTextInputFormatter()],
              inputtype: TextInputType.name,
              controller: expenseTextController,
              hinttext: S.of(context).addExpenseType,
            ),
            expensesController.fetchAllExpensesRequestState ==
                    RequestState.loading
                ? const CoreCircularIndicator()
                : expensesController.dialogExpensesList.isNotEmpty
                ? Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) => ExpenseItem(
                        expensesController.dialogExpensesList[index],
                        onpress: isInExpenseScreen != true
                            ? () {
                                ref
                                    .read(
                                      financialTransactionControllerProvider,
                                    )
                                    .onSelectExpense(
                                      expensesController
                                          .dialogExpensesList[index],
                                    );
                                context.pop();
                              }
                            : null,
                      ),
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider(color: Colors.grey, height: 1);
                      },
                      itemCount: expensesController.dialogExpensesList.length,
                    ),
                  )
                : expenseTextController.text.isNotEmpty
                ? Row(
                    children: [
                      DefaultTextView(text: expenseTextController.text.trim()),
                      DefaultOutlineButton(
                        name: "Add",
                        onpress: () async {
                          await expensesController.addExpense(
                            expenseTextController.text.trim(),
                          );
                        },
                      ),
                    ],
                  )
                : kEmptyWidget,
          ],
        ),
      ),
    );
  }
}
