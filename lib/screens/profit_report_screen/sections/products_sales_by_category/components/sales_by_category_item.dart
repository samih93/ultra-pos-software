import 'package:desktoppossystem/models/reports/sales_by_category_model.dart';
import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/progress_bar_indicator.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalesByCategoryItem extends ConsumerWidget {
  const SalesByCategoryItem(this.salesByCategoryModel,
      {this.backgroundColor = Colors.white, super.key});
  final SalesByCategoryModel salesByCategoryModel;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var profitController = ref.watch(profitControllerProvider);

    final percentage = salesByCategoryModel.profit > 0
        ? (salesByCategoryModel.profit / profitController.totalProfit) * 100
        : 0.0;
    final percentagePerCategory = salesByCategoryModel.totalCost != 0
        ? ((salesByCategoryModel.profit / salesByCategoryModel.totalCost) * 100)
            .round()
        : 0.0;
    return ColoredBox(
      color: backgroundColor,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Center(
                child: RichText(
                  text: TextSpan(
                      style: TextStyle(color: context.brightnessColor),
                      text: salesByCategoryModel.name.validateString(),
                      children: [
                        TextSpan(
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500),
                            text: " ($percentagePerCategory%)")
                      ]),
                ),
              )),
          Expanded(
              child: Center(
                  child: DefaultTextView(
                      text: salesByCategoryModel.totalCost
                          .formatDouble()
                          .toString()))),
          Expanded(
              child: Center(
                  child: DefaultTextView(
                      text: salesByCategoryModel.paidCost
                          .formatDouble()
                          .toString()))),
          Expanded(
              child: Center(
                  child: DefaultTextView(
                      text: salesByCategoryModel.profit
                          .formatDouble()
                          .toString()))),
          Expanded(
              child: Center(
                  child: ProgressBarIndicator(
                      percentage: percentage, color: context.primaryColor))),
        ],
      ),
    );
  }
}
