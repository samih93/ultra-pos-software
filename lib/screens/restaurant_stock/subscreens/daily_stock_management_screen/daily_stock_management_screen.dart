import 'package:desktoppossystem/controller/restaurant_stock_controller.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/daily_stock_management_screen/components/daily_entry_stock_form.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/daily_stock_management_screen/components/stock_waste_form.dart';
import 'package:desktoppossystem/shared/default%20components/app_bar_title.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/default components/default_text_view.dart';
import '../../../../shared/styles/pallete.dart';

class DailyStockManagementScreen extends ConsumerWidget {
  const DailyStockManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = ref.watch(restaurantStockControllerProvider).stockItems;

    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: S.of(context).manageStock),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref
                .read(restaurantStockControllerProvider)
                .clearSearchInRestaurantStock();
            ref.read(restaurantStockControllerProvider).clearSelectedEntry();
            context.pop();
          },
        ),
      ),
      body: Row(
        crossAxisAlignment: .start,
        children: [
          // Table to display stock
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 250,
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
                        hinttext: "${S.of(context).search}...",
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: DefaultTextView(
                        text: 'Name',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Expanded(
                      child: DefaultTextView(
                        text: 'Unit Type',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Expanded(
                      child: DefaultTextView(
                        text: 'Quantity',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (ref.read(mainControllerProvider).isSuperAdmin)
                      const Expanded(
                        child: DefaultTextView(
                          text: 'Price Per Unit',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const Divider(thickness: 1, height: 2),
                // ListView.builder for better performance
                Expanded(
                  child: ScrollConfiguration(
                    behavior: MyCustomScrollBehavior(),
                    child: ListView.builder(
                      itemCount: stock.length,
                      itemBuilder: (context, index) {
                        final item = stock[index];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                ref
                                    .read(restaurantStockControllerProvider)
                                    .onSelectEntryItem(item);
                              },
                              child: Container(
                                color: item.isSelected == true
                                    ? context.primaryColor.withValues(
                                        alpha: 0.3,
                                      )
                                    : Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: DefaultTextView(text: item.name),
                                    ),
                                    Expanded(
                                      child: DefaultTextView(
                                        text: item.unitType.name,
                                      ),
                                    ),
                                    Expanded(
                                      child: DefaultTextView(
                                        text: item.qty.toString(),
                                      ),
                                    ),
                                    if (ref
                                        .read(mainControllerProvider)
                                        .isSuperAdmin)
                                      Expanded(
                                        child: DefaultTextView(
                                          text: item.pricePerUnit.toString(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            index < stock.length - 1
                                ? const Divider(height: 1)
                                : kEmptyWidget,
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    dividerColor: Pallete.greyColor,
                    labelColor: context.primaryColor,
                    tabs: [
                      Tab(
                        child: DefaultTextView(
                          text: S.of(context).add,
                          fontSize: 16,
                        ),
                      ),
                      Tab(
                        child: DefaultTextView(
                          text: S.of(context).waste,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  ref
                              .watch(restaurantStockControllerProvider)
                              .selectedEntryStockItem ==
                          null
                      ? const Expanded(
                          child: TabBarView(
                            children: [
                              Center(
                                child: DefaultTextView(
                                  text: "No item has been selected",
                                  color: Pallete.greyColor,
                                ),
                              ),
                              Center(
                                child: DefaultTextView(
                                  text: "No item has been selected",
                                  color: Pallete.greyColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: TabBarView(
                            children: [
                              DailyEntryStockForm(
                                ref
                                    .watch(restaurantStockControllerProvider)
                                    .selectedEntryStockItem,
                              ),
                              StockWasteForm(
                                ref
                                    .watch(restaurantStockControllerProvider)
                                    .selectedEntryStockItem,
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ).baseContainer(context.cardColor),
    );
  }
}
