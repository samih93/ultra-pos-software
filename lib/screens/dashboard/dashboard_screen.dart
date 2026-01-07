import 'package:desktoppossystem/screens/dashboard/components/cards/dashboard_cards_section.dart';
import 'package:desktoppossystem/screens/dashboard/components/customers_count_pie_diagram.dart';
import 'package:desktoppossystem/screens/dashboard/components/expenses_pie_chart.dart';
import 'package:desktoppossystem/screens/dashboard/components/overview_dashboard.dart';
import 'package:desktoppossystem/screens/dashboard/components/revenue_vs_purchases_line_chart.dart';
import 'package:desktoppossystem/screens/dashboard/components/sales_by_users_section.dart';
import 'package:desktoppossystem/screens/dashboard/components/sales_by_vew_pie_diagram.dart';
import 'package:desktoppossystem/screens/dashboard/components/stock_usage_pie_chart.dart';
import 'package:desktoppossystem/screens/dashboard/components/top10_customers_section.dart';
import 'package:desktoppossystem/screens/dashboard/components/top_profitable_doughnut_chart.dart';
import 'package:desktoppossystem/screens/dashboard/components/top_selling_doughnut_chart.dart';
import 'package:desktoppossystem/screens/dashboard/dashboard_screen_mobile.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      mobileView: const DashboardScreenMobile(),
      desktopView: _dashboardScreenDesktop(),
    );
  }

  Widget _dashboardScreenDesktop() {
    final minusWidth = context.width < 1310 ? 60 : 300;
    return Column(
      crossAxisAlignment: .start,
      children: [
        OverViewDashboard(),
        kGap10,
        Expanded(
          child: ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const DashboardCardsSection(),
                  kGap10,
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: (context.width - minusWidth) / 3,
                        height: 300,
                        child: const TopSellingDoughnutChart(),
                      ),
                      SizedBox(
                        width: (context.width - minusWidth) / 3,
                        height: 300,
                        child: const TopProfitableDoughnutChart(),
                      ),
                      SizedBox(
                        width: (context.width - minusWidth) / 3,
                        height: 300,
                        child: const ExpensesPieChart(),
                      ),
                      SizedBox(
                        width: (context.width - minusWidth) / 3,
                        height: 300,
                        child: const SalesByUsersSection(),
                      ),
                      if (ref
                              .watch(mainControllerProvider)
                              .isWorkWithIngredients &&
                          ref.watch(mainControllerProvider).isSuperAdmin)
                        SizedBox(
                          width: (context.width - minusWidth) / 3,
                          height: 300,
                          child: const StockUsagePieChart(),
                        ),
                      if (ref.watch(mainControllerProvider).isSuperAdmin)
                        SizedBox(
                          width: (context.width - minusWidth) / 3,
                          height: 300,
                          child: const SalesByVewPieDiagram(),
                        ),
                      if (ref.watch(mainControllerProvider).isSuperAdmin)
                        SizedBox(
                          width: (context.width - minusWidth) / 3,
                          height: 300,
                          child: const RevenueVsPurchasesLineChart(),
                        ),
                      SizedBox(
                        width: (context.width - minusWidth) / 3,
                        height: 300,
                        child: const CustomersCountPieDiagram(),
                      ),
                      SizedBox(
                        width: (context.width - minusWidth) / 3,
                        height: 300,
                        child: const Top10CustomersSection(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        kGap10,
      ],
    ).baseContainer(context.cardColor);
  }
}
