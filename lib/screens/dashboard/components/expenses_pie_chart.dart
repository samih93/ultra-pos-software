import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/screens/dashboard/dashboard_controller.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExpensesPieChart extends ConsumerWidget {
  const ExpensesPieChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureExpenses = ref.watch(futureExpensesProvider);
    return futureExpenses.when(
        data: (data) {
          final double totalExpenses =
              data.fold(0, (sum, e) => sum + e.expenseAmount);
          Widget widget = SfCircularChart(
              // backgroundColor: Colors.grey.shade200,
              borderColor: Pallete.greyColor,
              title: ChartTitle(
                  text:
                      "${S.of(context).expenses} ( ${totalExpenses.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()})"),
              legend: const Legend(isVisible: true),
              series: <CircularSeries>[
                //! Renders radial bar chart
                PieSeries<ExpenseModel, String>(
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
                    pointColorMapper: (ExpenseModel data, _) =>
                        data.expenseColor,
                    dataLabelMapper: (ExpenseModel data, _) =>
                        data.expenseAmount.formatDouble().toString(),
                    xValueMapper: (ExpenseModel data, _) => data.expensePurpose,
                    yValueMapper: (ExpenseModel data, _) =>
                        (data.expenseAmount))
              ]);
          return Container(
              decoration: BoxDecoration(
                borderRadius: kRadius12,
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
                futureExpensesProvider,
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
