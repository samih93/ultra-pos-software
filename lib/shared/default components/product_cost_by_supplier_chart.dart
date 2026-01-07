import 'package:desktoppossystem/models/reports/product_history_model.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

final productHistoryProvider =
    FutureProvider.family<List<ProductHistoryModel>, int>(
        (ref, productId) async {
  final response = await ref
      .read(productProviderRepository)
      .fetchProductHistory(productId: productId);
  return response.fold((l) {
    throw Exception(l.message);
  }, (r) => r);
});

class ProductCostBySupplierChart extends ConsumerWidget {
  final int productId;

  const ProductCostBySupplierChart({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(productHistoryProvider(productId));

    return asyncData.when(
      data: (allData) {
        if (allData.isEmpty) {
          return const Center(child: Text('No history data available'));
        }

        // Group by supplier
        final dataBySupplier = <String, List<ProductHistoryModel>>{};
        for (var item in allData) {
          dataBySupplier.putIfAbsent(item.supplierName, () => []).add(item);
        }
        for (var list in dataBySupplier.values) {
          list.sort((a, b) => a.puchaseDate.compareTo(b.puchaseDate));
        }
        final seriesList = <LineSeries<ProductHistoryModel, DateTime>>[];
        dataBySupplier.forEach((supplier, dataList) {
          seriesList.add(LineSeries<ProductHistoryModel, DateTime>(
            name: supplier,
            dataSource: dataList,
            xValueMapper: (item, _) => DateTime.parse(item.puchaseDate),
            yValueMapper: (item, _) => item.cost,
            markerSettings: const MarkerSettings(isVisible: true),
          ));
        });

        return SfCartesianChart(
          title: const ChartTitle(text: 'Cost by Supplier'),
          legend:
              const Legend(isVisible: true, position: LegendPosition.bottom),
          tooltipBehavior: TooltipBehavior(enable: true),
          primaryXAxis: DateTimeAxis(
            title: const AxisTitle(text: 'Purchase Date'),
            dateFormat: DateFormat.yMMMd(),
            intervalType: DateTimeIntervalType.days,
            labelRotation: -45,
          ),
          primaryYAxis: NumericAxis(
            title: const AxisTitle(text: 'Cost'),
            numberFormat: NumberFormat.simpleCurrency(decimalDigits: 2),
          ),
          series: seriesList,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
