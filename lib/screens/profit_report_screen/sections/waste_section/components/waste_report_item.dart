import 'package:desktoppossystem/models/reports/waste_by_stock_model.dart';
import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/progress_bar_indicator.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WasteReportItem extends ConsumerWidget {
  const WasteReportItem(
    this.wasteByStockModel, {
    this.backgroundColor = Colors.white,
    super.key,
  });

  final WasteByStockModel wasteByStockModel;
  final Color backgroundColor;

  Widget buildQtyTextWidget(BuildContext context) {
    if (wasteByStockModel.unitType == UnitType.portion) {
      return AppPriceText(
        fontSize: 14,
        text: wasteByStockModel.totalQtyAsPortions.formatDouble().toString(),
        unit: UnitType.portion.uniteTypeToString(),
      );
    } else {
      return AppPriceText(
        fontSize: 14,
        text: wasteByStockModel.totalQtyAsKg.formatDouble().toString(),
        unit: UnitType.kg.uniteTypeToString(),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var profitController = ref.watch(profitControllerProvider);
    double totalWaste = profitController.totalWaste;

    double percentage = totalWaste > 0
        ? (wasteByStockModel.totalPrice / totalWaste) * 100
        : 0.0;

    return ColoredBox(
      color: backgroundColor,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: DefaultTextView(
                maxlines: 2,
                text: wasteByStockModel.name.validateString(),
              ),
            ),
          ),
          Expanded(flex: 2, child: Center(child: buildQtyTextWidget(context))),
          Expanded(
            child: Center(
              child: AppPriceText(
                fontSize: 14,
                text: "${wasteByStockModel.totalPrice.formatDouble()}",
                unit: AppConstance.primaryCurrency.currencyLocalization(),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ProgressBarIndicator(
                percentage: percentage,
                color: context.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
