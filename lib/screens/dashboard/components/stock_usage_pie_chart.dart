import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/reports/restaurant_stock_usage_model.dart';
import 'package:desktoppossystem/screens/dashboard/dashboard_controller.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../shared/styles/pallete.dart';

class StockUsagePieChart extends ConsumerWidget {
  const StockUsagePieChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureStockUsage = ref.watch(futureStockUsageProvider);
    return futureStockUsage.when(
        data: (data) {
          final double totalSellingStockCost =
              data.fold(0, (sum, e) => sum + e.totalPrice!);
          Widget widget = SfCircularChart(
              borderColor: Pallete.greyColor,
              title: ChartTitle(
                  text:
                      "${S.of(context).stockUsage} ( ${totalSellingStockCost.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()})"),
              legend: const Legend(isVisible: true),
              series: <CircularSeries>[
                //! Renders radial bar chart
                PieSeries<RestaurantStockUsageModel, String>(
                    explode: true,
                    // explodeIndex: 1,
                    radius: '70%',
                    dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelIntersectAction: LabelIntersectAction.shift,
                        overflowMode: OverflowMode.shift,
                        showZeroValue: true,
                        labelPosition: ChartDataLabelPosition.inside,
                        connectorLineSettings:
                            ConnectorLineSettings(type: ConnectorType.curve)),
                    dataSource: data,
                    pointColorMapper: (RestaurantStockUsageModel data, _) =>
                        data.color,
                    dataLabelMapper: (RestaurantStockUsageModel data, _) =>
                        data.unitType == UnitType.kg
                            ? data.qtyAsKilo.formatDouble().toString()
                            : data.qtyAsPortion.formatDouble().toString(),
                    xValueMapper: (RestaurantStockUsageModel data, _) =>
                        "${data.name}${data.unitType == UnitType.kg ? ' (kg)' : ' (po)'}",
                    yValueMapper: (RestaurantStockUsageModel data, _) =>
                        (data.unitType == UnitType.kg
                            ? data.qtyAsKilo
                            : data.qtyAsPortion))
              ]);
          return Container(
              decoration: BoxDecoration(
                borderRadius: defaultRadius,
              ),
              child: Stack(
                alignment: AlignmentDirectional.topEnd,
                children: [
                  widget,
                  IconButton(
                    icon: const Icon(Icons.expand),
                    onPressed: () {
                      openWidgetInLargeDialog(context, widget);
                    },
                  ),
                ],
              ));
        },
        error: (error, stackTrace) => ErrorSection(
              retry: () => ref.refresh(
                futureStockUsageProvider,
              ),
            ),
        loading: () {
          return const Skeletonizer(
              enabled: true,
              child: SfCircularChart(
                borderColor: Pallete.greyColor,
                title: ChartTitle(text: " "),
                legend: Legend(isVisible: true),
              ));
        });
  }
}
