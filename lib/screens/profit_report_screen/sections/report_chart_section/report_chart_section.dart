import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
import 'package:desktoppossystem/shared/default%20components/progress_bar_indicator.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Syncfusion Charts

class ReportChartTab extends ConsumerWidget {
  const ReportChartTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var profitController = ref.watch(profitControllerProvider);

    double totalCost = profitController.totalRealCost;
    double totalWaste = profitController.totalWaste;

    double totalProfit =
        profitController.totalProfit -
        profitController.totalExpenses -
        totalWaste +
        profitController.totalSubscriptionIncome;
    double totalExpenses = profitController.totalExpenses;
    double totalRevenue = profitController.totalPaid;
    double totalAmount = totalRevenue;

    double costPercentage = totalAmount > 0
        ? (totalCost / totalAmount) * 100
        : 0;
    double revenuePercentage = totalAmount > 0
        ? (totalRevenue / totalAmount) * 100
        : 0;
    double profitPercentage = totalAmount > 0
        ? (totalProfit / totalAmount) * 100
        : 0;
    double expensePercentage = totalAmount > 0
        ? (totalExpenses / totalAmount) * 100
        : 0;
    double wastePercentage =
        ref.read(mainControllerProvider).isWorkWithIngredients
        ? totalAmount > 0
              ? (totalWaste / totalAmount) * 100
              : 0
        : 0;

    // **Data for Pie Chart**
    final List<_ChartData> chartData = [
      _ChartData(S.of(context).totalRevenue, totalRevenue, Pallete.orangeColor),
      _ChartData(S.of(context).totalCost, totalCost, Pallete.primaryColor),
      _ChartData(S.of(context).totalProfit, totalProfit, Pallete.greenColor),
      _ChartData(S.of(context).totalExpenses, totalExpenses, Pallete.redColor),
      if (ref.read(mainControllerProvider).isWorkWithIngredients)
        _ChartData(S.of(context).totalWaste, totalWaste, Colors.blue),
    ];
    final windowchildren = [
      // **Pie Chart using SfCircularChart**
      Expanded(
        child: SfCircularChart(
          borderColor: Colors.grey.shade300,
          legend: const Legend(
            isVisible: true,
            position: LegendPosition.bottom,
          ),
          series: <CircularSeries>[
            PieSeries<_ChartData, String>(
              explode: true,
              radius: '55%',
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.inside,
              ),
              dataSource: chartData
                  .where((e) => e.label != S.of(context).totalRevenue)
                  .toList(),
              pointColorMapper: (_ChartData data, _) => data.color,
              dataLabelMapper: (_ChartData data, _) =>
                  "${data.value.toStringAsFixed(2)} ",
              xValueMapper: (_ChartData data, _) => data.label,
              yValueMapper: (_ChartData data, _) => data.value,
            ),
          ],
        ),
      ),

      const SizedBox(height: 20),

      // **Progress Bars**
      Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ProgressBarIndicator(
                forRevenue: true,
                title: S.of(context).totalRevenue,
                percentage: revenuePercentage,
                color: Pallete.orangeColor,
                amount: totalRevenue,
              ),
              ProgressBarIndicator(
                title: S.of(context).totalCost,
                percentage: costPercentage,
                color: Pallete.blueColor,
                amount: totalCost,
              ),
              ProgressBarIndicator(
                title: S.of(context).totalProfit,
                percentage: profitPercentage,
                color: Pallete.greenColor,
                amount: totalProfit,
              ),
              ProgressBarIndicator(
                title: S.of(context).totalExpenses,
                percentage: expensePercentage,
                color: Pallete.redColor,
                amount: totalExpenses,
              ),
              if (ref.read(mainControllerProvider).isWorkWithIngredients)
                ProgressBarIndicator(
                  title: S.of(context).totalWaste,
                  percentage: wastePercentage,
                  color: Colors.blue,
                  amount: totalWaste,
                ),
            ],
          ),
        ),
      ),
    ];

    final mobileChildren = [
      // **Pie Chart using SfCircularChart**
      SizedBox(
        height: 400,
        child: SfCircularChart(
          borderColor: Colors.grey.shade300,
          legend: const Legend(
            isVisible: true,
            position: LegendPosition.bottom,
          ),
          series: <CircularSeries>[
            PieSeries<_ChartData, String>(
              explode: true,
              radius: '55%',
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.inside,
              ),
              dataSource: chartData
                  .where((e) => e.label != S.of(context).totalRevenue)
                  .toList(),
              pointColorMapper: (_ChartData data, _) => data.color,
              dataLabelMapper: (_ChartData data, _) =>
                  "${data.value.toStringAsFixed(2)} ",
              xValueMapper: (_ChartData data, _) => data.label,
              yValueMapper: (_ChartData data, _) => data.value,
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      // **Progress Bars**
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ProgressBarIndicator(
              forRevenue: true,
              title: S.of(context).totalRevenue,
              percentage: revenuePercentage,
              color: Pallete.orangeColor,
              amount: totalRevenue,
            ),
            ProgressBarIndicator(
              title: S.of(context).totalCost,
              percentage: costPercentage,
              color: Pallete.blueColor,
              amount: totalCost,
            ),
            ProgressBarIndicator(
              title: S.of(context).totalProfit,
              percentage: profitPercentage,
              color: Pallete.greenColor,
              amount: totalProfit,
            ),
            ProgressBarIndicator(
              title: S.of(context).totalExpenses,
              percentage: expensePercentage,
              color: Pallete.redColor,
              amount: totalExpenses,
            ),
            if (ref.read(mainControllerProvider).isWorkWithIngredients)
              ProgressBarIndicator(
                title: S.of(context).totalWaste,
                percentage: wastePercentage,
                color: Colors.blue,
                amount: totalWaste,
              ),
          ],
        ),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: context.isMobile
          ? SingleChildScrollView(child: Column(children: [...mobileChildren]))
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [...windowchildren],
            ),
    );
  }
}

/// **Helper Model for Chart Data**
class _ChartData {
  final String label;
  final double value;
  final Color color;

  _ChartData(this.label, this.value, this.color);
}
