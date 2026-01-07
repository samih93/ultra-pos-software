import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/profit_report_screen/components/profit_overview_buttons.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/expenses_section/expenses_section.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/products_sales_by_category/product_sales_by_category_section.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/report_chart_section/report_chart_section.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/subscriptions_section/subscriptions_section.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/waste_section/waste_section.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/constances/app_constances.dart';
import '../../shared/default%20components/default_price_text.dart';
import '../../shared/styles/sizes.dart';
import 'profit_controller.dart';
import 'sections/products_sales_section/product_sales_section.dart';
import 'sections/stock_usage_section/stock_usage_section.dart';

class ProfitReportScreen extends ConsumerWidget {
  const ProfitReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profitController = ref.watch(profitControllerProvider);
    final mainController = ref.watch(mainControllerProvider);
    final isWorkWithIngredients = mainController.isWorkWithIngredients;
    final subscriptionActivated = mainController.subscriptionActivated;

    return Column(
      crossAxisAlignment: .start,
      children: [
        ProfitOverviewButtons(),
        kGap5,
        Expanded(
          child: _buildTabs(
            context,
            ref,
            isWorkWithIngredients,
            subscriptionActivated,
            profitController,
          ),
        ),
      ],
    ).baseContainer(context.cardColor);
  }

  Widget _buildTabs(
    BuildContext context,
    WidgetRef ref,
    bool isWorkWithIngredients,
    bool subscriptionActivated,
    ProfitController profitController,
  ) {
    // Calculate tab length dynamically
    int tabLength =
        4; // Base tabs: Sales, Sales by Category, Expenses, Report Charts
    if (isWorkWithIngredients) tabLength += 2; // Add Stock Usage and Waste
    if (subscriptionActivated) tabLength += 1; // Add Subscriptions

    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: DefaultTabController(
        length: tabLength,
        child: Column(
          children: [
            TabBar(
              dividerColor: Pallete.greyColor,
              tabAlignment: TabAlignment.center,
              isScrollable: true,
              labelColor: context.primaryColor,
              tabs: [
                if (isWorkWithIngredients)
                  Tab(
                    child: Text(
                      S.of(context).stockUsage,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                Tab(
                  child: Text(
                    S.of(context).sales,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Tab(
                  child: Text(
                    S.of(context).salesByCategories,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).expenses,
                        style: const TextStyle(fontSize: 16),
                      ),
                      AppPriceText(
                        fontWeight: FontWeight.bold,
                        text:
                            " / ${ref.watch(profitControllerProvider).totalExpenses.formatDouble()}",
                        unit: AppConstance.primaryCurrency
                            .currencyLocalization(),
                      ),
                    ],
                  ),
                ),
                if (subscriptionActivated)
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S.of(context).subscriptions,
                          style: const TextStyle(fontSize: 16),
                        ),
                        AppPriceText(
                          fontWeight: FontWeight.bold,
                          text:
                              " / ${ref.watch(profitControllerProvider).totalSubscriptionIncome.formatDouble()}",
                          unit: AppConstance.primaryCurrency
                              .currencyLocalization(),
                        ),
                      ],
                    ),
                  ),
                if (isWorkWithIngredients)
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S.of(context).waste,
                          style: const TextStyle(fontSize: 16),
                        ),
                        AppPriceText(
                          fontWeight: FontWeight.bold,
                          text:
                              " / ${ref.watch(profitControllerProvider).totalWaste.formatDouble()}",
                          unit: AppConstance.primaryCurrency
                              .currencyLocalization(),
                        ),
                      ],
                    ),
                  ),
                Tab(
                  child: Text(
                    S.of(context).reportCharts,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  if (isWorkWithIngredients)
                    _buildStockUsageTab(context, ref, true, profitController),
                  _buildSalesTab(),
                  _buildSalesByCategoryTab(),
                  const ExpensesSection(),
                  if (subscriptionActivated) _buildSubscriptionsTab(),
                  if (isWorkWithIngredients) _buildWasteTab(),
                  const ReportChartTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockUsageTab(
    BuildContext context,
    WidgetRef ref,
    bool isShowStockUsage,
    ProfitController profitController,
  ) {
    return Padding(
      padding: kPadd15,
      child: Column(
        children: [
          StockUsageSection(
            packagingTotalCost: profitController.packagingTotalCost
                .formatDouble(),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTab() {
    return ProductSalesSection();
  }

  Widget _buildSalesByCategoryTab() {
    return ProductSalesByCategorytSection();
  }

  Widget _buildSubscriptionsTab() {
    return SubscriptionsSection();
  }

  Widget _buildWasteTab() {
    return const WasteSection();
  }
}
