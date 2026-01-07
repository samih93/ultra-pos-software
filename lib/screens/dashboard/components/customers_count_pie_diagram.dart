import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/receipts_count_by_view_model.dart';
import 'package:desktoppossystem/screens/dashboard/components/overview_dashboard.dart';
import 'package:desktoppossystem/screens/dashboard/dashboard_controller.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../shared/styles/pallete.dart';

final isZoneHourlyCustomersProvider = StateProvider<bool>((ref) {
  return true;
});

class CustomersCountPieDiagram extends ConsumerWidget {
  const CustomersCountPieDiagram({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isZone = ref.watch(isZoneHourlyCustomersProvider);
    final filter = ref.watch(selectedDashboardViewProvider);
    final futureCustomers = ref.watch(futureHourlyCustomersProvider);

    String type = filter.localizedName(context);
    return futureCustomers.when(
        data: (data) {
          Widget widget = SfCartesianChart(
              borderColor: Pallete.greyColor,
              title:
                  ChartTitle(text: "${S.of(context).hourlyCustomers}  $type"),
              enableSideBySideSeriesPlacement: false,
              primaryXAxis: CategoryAxis(
                title: AxisTitle(
                    text: S.of(context).hour, alignment: ChartAlignment.center),
              ),
              primaryYAxis: const NumericAxis(
                  isVisible: true,
                  title: AxisTitle(
                      text: "Count", alignment: ChartAlignment.center),
                  axisLine: AxisLine(width: 0),
                  labelFormat: '{value}',
                  majorTickLines: MajorTickLines(size: 0)),
              legend: const Legend(isVisible: false),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: isZone
                  ? <CartesianSeries<CustomersCountByViewModel, String>>[
                      AreaSeries<CustomersCountByViewModel, String>(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xffb287fd).withValues(alpha: 0.9),
                            const Color(0xffb287fd).withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.9],
                        ),
                        borderColor: Colors.transparent,
                        borderWidth: 0,
                        dataSource: data,
                        xValueMapper: (CustomersCountByViewModel dS, _) =>
                            dS.day.toString(),
                        yValueMapper: (CustomersCountByViewModel dS, _) =>
                            double.parse(dS.count.toString()),
                        name: S.of(context).receipt,
                        //! Enable data label
                        color: Theme.of(context).primaryColor,
                      ),
                      LineSeries<CustomersCountByViewModel, String>(
                        dataSource: data,
                        xValueMapper: (CustomersCountByViewModel dS, _) =>
                            dS.day.toString(),
                        yValueMapper: (CustomersCountByViewModel dS, _) =>
                            double.parse(dS.count.toString()),
                        name: S.of(context).customers,
                        width: 2,
                        color: Theme.of(context).primaryColor,
                        markerSettings: const MarkerSettings(
                          isVisible: false, // This removes all markers
                        ),
                      ),
                    ]
                  : <ColumnSeries<CustomersCountByViewModel, String>>[
                      ColumnSeries<CustomersCountByViewModel, String>(
                          gradient: myLinearGradient(context),
                          dataSource: data,
                          xValueMapper: (CustomersCountByViewModel dS, _) =>
                              dS.day.toString(),
                          yValueMapper: (CustomersCountByViewModel dS, _) =>
                              double.parse(dS.count.toString()),
                          name: S.of(context).receipt,
                          //! Enable data label
                          dataLabelSettings: const DataLabelSettings(
                            showZeroValue: false,
                            isVisible: true,
                            textStyle: TextStyle(fontSize: 10),
                          ))
                    ]);
          return Stack(children: [
            widget,
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: IconButton(
                icon: const Icon(Icons.expand),
                onPressed: () {
                  openWidgetInLargeDialog(context, widget);
                },
              ),
            ),
            Align(
              alignment: AlignmentDirectional.topStart,
              child: IconButton(
                  icon: Icon(
                      isZone ? Icons.bar_chart : Icons.show_chart_outlined),
                  onPressed: () {
                    ref
                        .read(isZoneHourlyCustomersProvider.notifier)
                        .update((state) => !state);
                  }),
            ),
          ]);
        },
        error: (error, stackTrace) => ErrorSection(
              retry: () => ref.refresh(
                futureHourlyCustomersProvider,
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
