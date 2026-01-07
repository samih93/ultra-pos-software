import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/products_sales_by_category/components/products_sales_by_catgeory_header.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/products_sales_by_category/components/sales_by_category_item.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductSalesByCategorytSection extends ConsumerWidget {
  ProductSalesByCategorytSection({super.key});
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var profitController = ref.watch(profitControllerProvider);

    return profitController.salesProductList.isNotEmpty
        ? Padding(
            padding: kPadd10,
            child: Column(
              children: [
                const ProductsSalesByCatgeoryHeader(),
                Divider(color: context.primaryColor),
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    trackVisibility: true,
                    thumbVisibility: true,
                    thickness: 10,
                    child: ListView.builder(
                      itemExtent: 55,
                      controller: _scrollController,
                      itemCount: profitController.salesByCategoryList.length,
                      itemBuilder: (context, index) {
                        final backgroundColor = index.isEven
                            ? ref.watch(isDarkModeProvider)
                                  ? context.cardColor
                                  : Pallete.whiteColor
                            : context.selectedPrimaryColor.withValues(
                                alpha: 0.5,
                              );
                        return SalesByCategoryItem(
                          backgroundColor: backgroundColor,
                          profitController.salesByCategoryList[index],
                          key: ValueKey(
                            profitController.salesByCategoryList[index].name,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // kGap5,
                // TotalProfitAmountByCategory(
                //     totalCost: profitController.totalCostByCategory,
                //     totalPaid: profitController.totalPaidByCategory,
                //     profit: profitController.totalProfitByCategory)
              ],
            ),
          )
        : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DefaultTextView(
                text: "No sales yet",
                color: Colors.grey,
                fontSize: 25,
              ),
            ],
          );
  }
}
