import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/default%20components/default_prodgress_indicator.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';

import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  final String title;
  final double value;
  final Color color;

  ChartData(this.title, this.value, this.color);
}

class RevenueAndProfitChart extends ConsumerWidget {
  const RevenueAndProfitChart({required this.customerId, super.key});
  final int customerId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueFuture =
        ref.watch(revenuAndProfitByCustomerProvider(customerId));
    return revenueFuture.when(
      data: (data) {
        List<ChartData> chartData = [
          ChartData(S.of(context).totalRevenue,
              data["revenue"].validateDouble(), Colors.orange),
          ChartData(S.of(context).totalPurchases,
              data["profit"].validateDouble(), Pallete.primaryColor),
        ];
        return SfCircularChart(
            // backgroundColor: Colors.grey.shade200,
            borderColor: Pallete.greyColor,
            title: ChartTitle(
                text:
                    "${S.of(context).totalPurchases} / ${S.of(context).totalProfit}"),
            legend: const Legend(isVisible: true),
            series: <CircularSeries>[
              //! Renders radial bar chart
              PieSeries<ChartData, String>(
                explode: true,
                // explodeIndex: 1,
                radius: '55%',
                dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelIntersectAction: LabelIntersectAction.shift,
                    overflowMode: OverflowMode.shift,
                    showZeroValue: true,
                    labelPosition: ChartDataLabelPosition.inside,
                    connectorLineSettings:
                        ConnectorLineSettings(type: ConnectorType.curve)),
                dataSource: chartData,
                pointColorMapper: (ChartData data, _) => data.color,
                dataLabelMapper: (ChartData data, _) =>
                    data.value.formatDouble().toString(),
                xValueMapper: (ChartData data, _) => data.title,
                yValueMapper: (ChartData data, _) => data.value,
              ),
            ]);
      },
      error: (error, stackTrace) => ErrorSection(
        title: error.toString(),
        retry: () => ref.refresh(revenuAndProfitByCustomerProvider(customerId)),
      ),
      loading: () => const Center(child: DefaultProgressIndicator()),
    );
  }
}
