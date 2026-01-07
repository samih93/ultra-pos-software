import 'package:desktoppossystem/models/reports/sales_product_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfitSalesItems extends ConsumerWidget {
  const ProfitSalesItems(this.salesProductModel,
      {this.backgroundColor = Colors.white, // Default to white
      super.key});
  final SalesProductModel salesProductModel;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLtr = ref.read(mainControllerProvider).isLtr;
    final percentagePerItem = salesProductModel.totalCost != 0
        ? ((salesProductModel.profit / salesProductModel.totalCost) * 100)
            .round()
        : 0.0;
    return ColoredBox(
      color: backgroundColor,
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: DefaultTextView(
                  textAlign: isLtr ? TextAlign.left : TextAlign.right,
                  text: salesProductModel.name.validateString())),
          Expanded(
              flex: 2,
              child: Center(
                  child: DefaultTextView(
                      text: salesProductModel.barcode.validateString()))),
          Expanded(
              child: Center(
                  child:
                      DefaultTextView(text: salesProductModel.qty.toString()))),
          Expanded(
              child: Center(
                  child: DefaultTextView(
                      text: salesProductModel.totalCost
                          .formatDouble()
                          .toString()))),
          Expanded(
              child: Center(
                  child: DefaultTextView(
                      text: salesProductModel.paidCost
                          .formatDouble()
                          .toString()))),
          Expanded(
              child: Center(
                  child: RichText(
            text: TextSpan(
                style: TextStyle(color: context.brightnessColor),
                text: salesProductModel.profit.formatDouble().toString(),
                children: [
                  TextSpan(
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.w500),
                      text: " ($percentagePerItem%)")
                ]),
          )))
        ],
      ),
    );
  }
}
