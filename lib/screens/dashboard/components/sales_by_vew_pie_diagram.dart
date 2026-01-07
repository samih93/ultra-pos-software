import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/reports/daily_sale_model.dart';
import 'package:desktoppossystem/screens/dashboard/components/overview_dashboard.dart';
import 'package:desktoppossystem/screens/dashboard/dashboard_controller.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../shared/styles/pallete.dart';

final isZoneSalesProvider = StateProvider<bool>((ref) {
  return true;
});

class SalesByVewPieDiagram extends ConsumerWidget {
  const SalesByVewPieDiagram({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isZone = ref.watch(isZoneSalesProvider);
    final filter = ref.watch(selectedDashboardViewProvider);
    final futureSales = ref.watch(futureSalesProvider);

    String type = filter.localizedName(context);
    return futureSales.when(
        data: (data) {
          Widget widget = SfCartesianChart(
              borderColor: Pallete.greyColor,
              title: ChartTitle(
                  text: '${S.of(context).sales.toUpperCase()} $type'),
              enableSideBySideSeriesPlacement: false,
              primaryXAxis: CategoryAxis(
                title: AxisTitle(
                  text: filter != DashboardFilterEnum.lastYear &&
                          filter != DashboardFilterEnum.thisYear
                      ? "${S.of(context).day.capitalizeFirstLetter()}"
                      : "${S.of(context).month.capitalizeFirstLetter()}",
                  alignment: ChartAlignment.center,
                ),
              ),
              primaryYAxis: NumericAxis(
                isVisible: true,
                title: const AxisTitle(
                    text: "Money", alignment: ChartAlignment.center),
                axisLine: const AxisLine(width: 0),
                labelFormat: '{value} ${AppConstance.primaryCurrency}',
                majorTickLines: const MajorTickLines(size: 0),
              ),
              legend: const Legend(isVisible: false),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: isZone
                  ? <CartesianSeries<dynamic, dynamic>>[
                      AreaSeries<DailySalesModel, String>(
                        dataSource: data,
                        xValueMapper: (DailySalesModel dS, _) =>
                            dS.day.toString(),
                        yValueMapper: (DailySalesModel dS, _) =>
                            double.parse(dS.price.toString()),
                        name: 'Day',
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
                      ),
                      LineSeries<DailySalesModel, String>(
                        dataSource: data,
                        xValueMapper: (DailySalesModel dS, _) =>
                            dS.day.toString(),
                        yValueMapper: (DailySalesModel dS, _) =>
                            double.parse(dS.price.toString()),
                        name: 'Sales',
                        width: 2,
                        color: Theme.of(context).primaryColor,
                        markerSettings: const MarkerSettings(
                          isVisible: false, // This removes all markers
                        ),
                      ),
                    ]
                  : <ColumnSeries<DailySalesModel, String>>[
                      ColumnSeries<DailySalesModel, String>(
                          gradient: myLinearGradient(context),
                          dataSource: data,
                          xValueMapper: (DailySalesModel dS, _) =>
                              dS.day.toString(),
                          yValueMapper: (DailySalesModel dS, _) =>
                              double.parse(dS.price.toString()),
                          name: S.of(context).receipt,
                          //! Enable data label
                          dataLabelSettings: const DataLabelSettings(
                            showZeroValue: false,
                            isVisible: true,
                            textStyle: TextStyle(fontSize: 10),
                          ))
                    ]);
          return Stack(
            children: [
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
                        .read(isZoneSalesProvider.notifier)
                        .update((state) => !state);
                  },
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => ErrorSection(
              retry: () => ref.refresh(
                futureSalesProvider,
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
