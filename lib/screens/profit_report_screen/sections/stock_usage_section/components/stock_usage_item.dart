import 'package:desktoppossystem/models/reports/restaurant_stock_usage_model.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/default components/default_text_view.dart';

class StockUsageItem extends ConsumerWidget {
  const StockUsageItem(this.stockUsage,
      {this.backgroundColor = Colors.white, super.key});
  final RestaurantStockUsageModel stockUsage;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: backgroundColor,
      child: Row(children: [
        Expanded(
            flex: 3,
            child: Center(
                child: DefaultTextView(
              text: stockUsage.name.toString(),
            ))),
        Expanded(
            flex: 1,
            child: Center(
                child: DefaultTextView(
              text: stockUsage.unitType!.name.toString(),
            ))),
        Expanded(
            flex: 1,
            child: Center(
              child: AppPriceText(
                  unit: "${UnitType.kg.uniteTypeToString()}",
                  text: stockUsage.qtyAsKilo.formatDouble().toString()),
            )),
        Expanded(
          flex: 1,
          child: AppPriceText(
              unit: "${UnitType.portion.uniteTypeToString()}",
              text: stockUsage.qtyAsPortion.formatDouble().toString()),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AppPriceText(
                      text: "${stockUsage.totalPrice!.formatDouble()}",
                      unit:
                          "${AppConstance.primaryCurrency.currencyLocalization()}"),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
