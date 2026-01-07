part of 'add_expense_type_screen.dart';

class ExpenseItem extends ConsumerWidget {
  const ExpenseItem(this.expenseModel,
      {this.onpress, this.isInExpensesScreen, super.key});
  final ExpenseModel expenseModel;
  final VoidCallback? onpress;
  final bool? isInExpensesScreen;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
                onTap: onpress,
                child: DefaultTextView(
                  textAlign:
                      isEnglishLanguage ? TextAlign.left : TextAlign.right,
                  text: expenseModel.expensePurpose,
                )),
          ),
          AppSquaredOutlinedButton(
              child: const Icon(Icons.edit),
              onPressed: () {
                updateExpenseNameDialog(
                    expense: expenseModel, context: context, ref: ref);
              }),
          kGap5,
          AppSquaredOutlinedButton(
            child: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AreYouSureDialog(
                  agreeText: S.of(context).delete,
                  "${S.of(context).areYouSureDelete} '${expenseModel.expensePurpose}' ${S.of(context).quetionMark}",
                  onCancel: () => context.pop(),
                  onAgree: () async => await ref
                      .read(expensesControllerProvider)
                      .deleteExpense(expenseModel, context),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  updateExpenseNameDialog(
      {required ExpenseModel expense,
      required BuildContext context,
      required WidgetRef ref}) {
    var nameTextController = TextEditingController();
    nameTextController.text = expense.expensePurpose;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: DefaultTextView(
              text: S.of(context).edit,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultTextFormField(
                inputtype: TextInputType.text,
                controller: nameTextController,
              ),
              kGap10,
              ElevatedButtonWidget(
                icon: Icons.save,
                text: S.of(context).save,
                onPressed: () async {
                  if (nameTextController.text.isNotEmpty) {
                    expenseModel.expensePurpose =
                        nameTextController.text.trim();
                    await ref
                        .read(expensesControllerProvider)
                        .updateExpenseName(expenseModel, context);
                  } else {
                    ToastUtils.showToast(
                        message: "please enter expense purpose",
                        type: RequestState.error);
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }
}
