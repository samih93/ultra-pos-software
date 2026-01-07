import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/progress_bar_indicator.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseReportItem extends ConsumerWidget {
  const ExpenseReportItem(this.expenseModel,
      {this.backgroundColor = Colors.white, super.key});

  final ExpenseModel expenseModel;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var profitController = ref.watch(profitControllerProvider);
    double totalExpenses = profitController.totalExpenses;

    double percentage = totalExpenses > 0
        ? (expenseModel.expenseAmount / totalExpenses) * 100
        : 0.0;

    return ColoredBox(
      color: backgroundColor,
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Center(
                  child: DefaultTextView(
                      text: expenseModel.expensePurpose.validateString()))),
          Expanded(
              flex: 2,
              child: Center(
                  child: AppPriceText(
                      fontSize: 14,
                      text: "${expenseModel.expenseAmount.formatDouble()}",
                      unit: AppConstance.primaryCurrency
                          .currencyLocalization()))),
          Expanded(
              child: Center(
                  child: ProgressBarIndicator(
                      percentage: percentage, color: context.primaryColor))),
        ],
      ),
    );
  }
}
