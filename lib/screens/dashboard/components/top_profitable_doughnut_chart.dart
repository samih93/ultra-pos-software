import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/dashboard/dashboard_controller.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../shared/styles/pallete.dart';

class TopProfitableDoughnutChart extends ConsumerWidget {
  const TopProfitableDoughnutChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureProfitable = ref.watch(most15ProfitableProductsProvider);

    return futureProfitable.when(
      data: (data) {
        Widget widget = Container(
          decoration: BoxDecoration(borderRadius: defaultRadius),
          child: SfCircularChart(
            borderColor: Pallete.greyColor,
            title: const ChartTitle(text: 'Top 15 Most Profitable Items'),
            legend: const Legend(isVisible: true),
            series: <CircularSeries>[
              DoughnutSeries<ProductModel, String>(
                explode: true,
                radius: '70%',
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelIntersectAction: LabelIntersectAction.shift,
                  overflowMode: OverflowMode.shift,
                  showZeroValue: true,
                  labelPosition: ChartDataLabelPosition.inside,
                  connectorLineSettings: ConnectorLineSettings(
                    type: ConnectorType.curve,
                  ),
                ),
                dataSource: data,
                pointColorMapper: (ProductModel data, _) => data.categoryColor,
                dataLabelMapper: (ProductModel data, _) => (data.qty ?? 0)
                    .toStringAsFixed(2), // Show profit with 2 decimals
                xValueMapper: (ProductModel data, _) => data.name,
                yValueMapper: (ProductModel data, _) =>
                    double.parse(data.qty.toString()),
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
        retry: () => ref.refresh(most15ProfitableProductsProvider),
      ),
      loading: () {
        return const Skeletonizer(
          enabled: true,
          child: SfCircularChart(
            borderColor: Pallete.greyColor,
            title: ChartTitle(text: " "),
            legend: Legend(isVisible: true),
          ),
        );
      },
    );
  }
}
