import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/stock_usage_section/components/stock_usage_card_mobile.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/stock_usage_section/components/stock_usage_header.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/stock_usage_section/components/total_usage_cost.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/constances/app_constances.dart';
import '../../../../shared/default components/default_price_text.dart';
import '../../../../shared/default components/default_text_view.dart';
import '../../../../shared/styles/pallete.dart';
import 'components/stock_usage_item.dart';

final isShowStockUsageProvider = StateProvider<bool>((ref) {
  return true;
});

class StockUsageSection extends ConsumerWidget {
  StockUsageSection({required this.packagingTotalCost, super.key});
  final double packagingTotalCost;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = ref.watch(profitControllerProvider);

    if (controller.stockUsageList.isEmpty) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DefaultTextView(
            text: "No usage yet",
            color: Colors.grey,
            fontSize: 40,
          ),
        ],
      );
    }

    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              DefaultTextView(
                text: "${S.of(context).packagingCost} => ",
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Pallete.redColor,
              ),
              AppPriceText(
                fontSize: 18,
                text: "${packagingTotalCost.formatDouble()}",
                unit: AppConstance.primaryCurrency,
              ),
              const Spacer(),
              Container(
                padding: defaultPadding,
                decoration: const BoxDecoration(color: Pallete.redColor),
                child: AppPriceText(
                  color: Pallete.whiteColor,
                  text: "${controller.restaurantTotalCost.formatDouble()}",
                  unit:
                      "${AppConstance.primaryCurrency.currencyLocalization()}",
                ),
              ),
            ],
          ),
          // Mobile view
          if (context.isMobile) ...[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: controller.stockUsageList.length,
                itemBuilder: (context, index) {
                  return StockUsageCardMobile(
                    stockUsage: controller.stockUsageList[index],
                  );
                },
              ),
            ),
          ]
          // Desktop view
          else ...[
            const StockUsageHeader(),
            Divider(height: 1, color: context.primaryColor),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                trackVisibility: true,
                thumbVisibility: true,
                thickness: 10,
                child: CustomScrollView(
                  controller: _scrollController,
                  cacheExtent: 30,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final backgroundColor = index.isEven
                            ? ref.watch(isDarkModeProvider)
                                  ? context.cardColor
                                  : Pallete.whiteColor
                            : context.selectedPrimaryColor.withValues(
                                alpha: 0.5,
                              );
                        return StockUsageItem(
                          backgroundColor: backgroundColor,
                          controller.stockUsageList[index],
                          key: ValueKey(controller.stockUsageList[index].name),
                        );
                      }, childCount: controller.stockUsageList.length),
                    ),
                  ],
                ),
              ),
            ),
          ],
          TotalUsageCost(totalCost: controller.restaurantTotalCost),
        ],
      ),
    );
  }
}
