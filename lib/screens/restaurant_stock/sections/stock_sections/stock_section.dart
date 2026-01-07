import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/controller/restaurant_stock_controller.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/restaurant_stock/components/restaurant_stock_item.dart';
import 'package:desktoppossystem/screens/restaurant_stock/sections/stock_sections/components/restaurant_stock_balance.dart';
import 'package:desktoppossystem/screens/restaurant_stock/sections/stock_sections/components/restaurant_stock_filter_dialog.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/add_restaurant_stock.dart/add_restauarnt_stock_item_screen.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/daily_stock_management_screen/daily_stock_management_screen.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/stock_transactions/stock_transactions_screen.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/stock_transactions/stock_transactions_state.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/default components/app_text_title_section.dart';

class StockSection extends ConsumerWidget {
  const StockSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = ref.watch(restaurantStockControllerProvider);
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                AppTextTitleSection(S.of(context).stockScreen),
                if (ref.watch(mainControllerProvider).isAdmin) ...[
                  kGap10,
                  const RestaurantStockBalance(),
                ],
              ],
            ),
            AppSquaredOutlinedButton(
              child: const Icon((Icons.filter_list)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const RestaurantStockFilterDialog(),
                );
              },
            ),
          ],
        ),
        kGap10,
        Row(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppSquaredOutlinedButton(
              states: const [],
              onPressed: () {
                ref.refresh(stockTransactionsProvider);
                context.to(const StockTransactionsScreen());
              },
              child: const Icon(FontAwesomeIcons.rightLeft),
            ),
            Tooltip(
              message: S.of(context).downloadRestaurantStockReport,
              child: AppSquaredOutlinedButton(
                states: [
                  ref
                      .watch(globalControllerProvider)
                      .openRestaurantInExcelRequestState,
                ],
                child: const FaIcon(
                  FontAwesomeIcons.fileExcel,
                  size: 18,
                  color: Pallete.greenColor,
                ),
                onPressed: () async {
                  await downloadRestaurantStock(ref);
                },
              ),
            ),
            Tooltip(
              message: S.of(context).printRestaurantStock,
              child: AppSquaredOutlinedButton(
                states: [
                  ref
                      .watch(printerControllerProvider)
                      .printRestaurantStockRequestState,
                ],
                onPressed: () {
                  ref
                      .read(printerControllerProvider)
                      .generateAndPrintRestaurantStock(context);
                },
                child: const Icon(Icons.print),
              ),
            ),
            if (ref.read(mainControllerProvider).isSuperAdmin) ...[
              AppSquaredOutlinedButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  ref.read(forPackagingProvider.notifier).state = false;
                  context.to(const AddRestaurantStockItemScreen());
                },
              ),
            ],
            Tooltip(
              message: S.of(context).manageStock,
              child: AppSquaredOutlinedButton(
                size: const Size(38, 38),
                child: const Icon(FontAwesomeIcons.listCheck),
                onPressed: () {
                  ref
                      .read(restaurantStockControllerProvider)
                      .clearSearchInRestaurantStock();
                  context.to(const DailyStockManagementScreen());
                },
              ),
            ),
            kGap10,
            SizedBox(
              width: 200,
              child: AppTextFormField(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: context.primaryColor),
                ),
                onchange: (value) {
                  ref
                      .read(restaurantStockControllerProvider)
                      .searchInRestaurantStock(value.toString());
                },
                inputtype: TextInputType.name,
                hinttext: S.of(context).search,
              ),
            ),
          ],
        ),
        kGap10,
        switch (controller.fetchStockItemsRequestState) {
          RequestState.loading => const Center(
            child: CoreCircularIndicator(height: 70, coloredLogo: true),
          ),
          RequestState.success => ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: ref.read(mainControllerProvider).isSuperAdmin
                  ? 310
                  : 270,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: MyCustomScrollBehavior(),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            //     childAspectRatio: 0.6,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            mainAxisExtent: 130,
                            crossAxisCount: 3,
                          ),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, index) =>
                          RestaurantStockItem(controller.stockItems[index]),
                      itemCount: controller.stockItems.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
          RequestState.error => ErrorSection(
            retry: () {
              ref
                  .refresh(restaurantStockControllerProvider)
                  .fetchAllStockItems();
            },
          ),
        },
      ],
    );
  }

  Future<void> downloadRestaurantStock(WidgetRef ref) async {
    List<RestaurantStockModel> stockItems = [];

    await ref
        .read(receiptControllerProvider)
        .fetchAllStockItems()
        .then((value) {
          stockItems = value;
          stockItems.sort((a, b) {
            // First, compare by unitType
            int unitTypeComparison = a.unitType.name.compareTo(b.unitType.name);

            // If unitType is the same, then compare by qty
            if (unitTypeComparison == 0) {
              return b.qty.compareTo(a.qty); // Sort by qty in descending order
            } else {
              return unitTypeComparison; // Sort by unitType in ascending order
            }
          });
        })
        .whenComplete(() async {
          await ref
              .read(globalControllerProvider)
              .openRestaurantStockInExcel(stockItems);
        });
  }
}
