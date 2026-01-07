import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/reports/revenue_vs_purchases_model.dart';
import 'package:desktoppossystem/screens/dashboard/dashboard_controller.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../shared/styles/pallete.dart';

class RevenueVsPurchasesLineChart extends ConsumerWidget {
  const RevenueVsPurchasesLineChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureData = ref.watch(futureRevenueVsPurchasesProvider);
    return futureData.when(
      data: (data) {
        Widget widget = Container(
          decoration: BoxDecoration(
            borderRadius: defaultRadius,
          ),
          child: SfCartesianChart(
            borderColor: Pallete.greyColor,
            title: const ChartTitle(text: 'Revenue vs Purchases vs Expenses'),
            legend: const Legend(isVisible: true),
            primaryXAxis: const CategoryAxis(
              majorGridLines: MajorGridLines(width: 0),
              labelRotation: -45,
            ),
            primaryYAxis: const NumericAxis(
              labelFormat: '{value}',
              axisLine: AxisLine(width: 0),
              majorTickLines: MajorTickLines(size: 0),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              // Revenue Line
              LineSeries<RevenueVsPurchasesVsExpensesModel, String>(
                name: 'Revenue',
                dataSource: data,
                xValueMapper: (RevenueVsPurchasesVsExpensesModel model, _) =>
                    model.period,
                yValueMapper: (RevenueVsPurchasesVsExpensesModel model, _) =>
                    model.revenue,
                color: Colors.green,
                width: 3,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  shape: DataMarkerType.circle,
                  height: 6,
                  width: 6,
                  color: Colors.green,
                  borderColor: Colors.white,
                  borderWidth: 2,
                ),
                dataLabelSettings: const DataLabelSettings(
                  showZeroValue: false,
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.top,
                  textStyle: TextStyle(fontSize: 10),
                ),
              ),
              // Purchases Line
              LineSeries<RevenueVsPurchasesVsExpensesModel, String>(
                name: 'Purchases',
                dataSource: data,
                xValueMapper: (RevenueVsPurchasesVsExpensesModel model, _) =>
                    model.period,
                yValueMapper: (RevenueVsPurchasesVsExpensesModel model, _) =>
                    model.purchases,
                color: Colors.red,
                width: 3,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  shape: DataMarkerType.diamond,
                  height: 6,
                  width: 6,
                  color: Colors.red,
                  borderColor: Colors.white,
                  borderWidth: 2,
                ),
                dataLabelSettings: const DataLabelSettings(
                  showZeroValue: false,
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.bottom,
                  textStyle: TextStyle(fontSize: 10),
                ),
              ),
              // Expenses Line
              LineSeries<RevenueVsPurchasesVsExpensesModel, String>(
                name: '${S.of(context).expenses.capitalizeFirstLetter()}',
                dataSource: data,
                xValueMapper: (RevenueVsPurchasesVsExpensesModel model, _) =>
                    model.period,
                yValueMapper: (RevenueVsPurchasesVsExpensesModel model, _) =>
                    model.expenses,
                color: Colors.orange,
                width: 3,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  shape: DataMarkerType.triangle,
                  height: 6,
                  width: 6,
                  color: Colors.orange,
                  borderColor: Colors.white,
                  borderWidth: 2,
                ),
                dataLabelSettings: const DataLabelSettings(
                  showZeroValue: false,
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.middle,
                  textStyle: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        );
        return Stack(
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
        );
      },
      error: (error, stackTrace) => ErrorSection(
        retry: () => ref.refresh(futureRevenueVsPurchasesProvider),
      ),
      loading: () {
        return const Skeletonizer(
          enabled: true,
          child: SfCartesianChart(
            borderColor: Pallete.greyColor,
            title: ChartTitle(text: " "),
            legend: Legend(isVisible: true),
          ),
        );
      },
    );
  }
}
