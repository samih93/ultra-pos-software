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
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardScreenMobile extends ConsumerStatefulWidget {
  const DashboardScreenMobile({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DashboardScreenMobileState();
}

class _DashboardScreenMobileState extends ConsumerState<DashboardScreenMobile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OverViewDashboard(),
        SizedBox(height: 10.h),
        Expanded(
          child: ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                children: [
                  const DashboardCardsSection(),
                  SizedBox(height: 10.h),

                  // All charts in vertical layout with full width
                  _buildChartCard(const TopSellingDoughnutChart()),
                  SizedBox(height: 10.h),

                  _buildChartCard(const TopProfitableDoughnutChart()),
                  SizedBox(height: 10.h),

                  _buildChartCard(const ExpensesPieChart()),
                  SizedBox(height: 10.h),

                  _buildChartCard(const SalesByUsersSection()),
                  SizedBox(height: 10.h),

                  // Conditional charts based on permissions
                  if (ref.watch(mainControllerProvider).isWorkWithIngredients &&
                      ref.watch(mainControllerProvider).isSuperAdmin) ...[
                    _buildChartCard(const StockUsagePieChart()),
                    SizedBox(height: 10.h),
                  ],

                  if (ref.watch(mainControllerProvider).isSuperAdmin) ...[
                    _buildChartCard(const SalesByVewPieDiagram()),
                    SizedBox(height: 10.h),

                    _buildChartCard(const RevenueVsPurchasesLineChart()),
                    SizedBox(height: 10.h),
                  ],

                  _buildChartCard(const CustomersCountPieDiagram()),
                  SizedBox(height: 10.h),

                  _buildChartCard(const Top10CustomersSection()),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ),
      ],
    ).baseContainer(context.cardColor);
  }

  // Helper method to build chart cards with consistent sizing
  Widget _buildChartCard(Widget chart) {
    return SizedBox(
      width: double.infinity,
      height: 300.h, // Responsive height
      child: chart,
    );
  }
}
