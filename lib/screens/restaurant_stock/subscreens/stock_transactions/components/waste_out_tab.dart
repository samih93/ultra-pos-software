import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/stock_transaction_model.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/stock_transactions/components/stock_transaction_header.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/stock_transactions/components/stock_transaction_item.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/stock_transactions/stock_transactions_state.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WasteOutTab extends ConsumerWidget {
  const WasteOutTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wasteOutList = ref.watch(wasteOutProvider);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab Bar
          TabBar(
            tabs: [
              DefaultTextView(
                  text: S.of(context).normalWaste,
                  textHeight: 2), // "Normal Waste"
              const DefaultTextView(
                text: "Staff meal",
                textHeight: 2,
              ), // "Normal Waste"
            ],
            labelColor: context.primaryColor,
            indicatorColor: context.primaryColor,
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              children: [
                // Normal Waste Tab
                buildWasteList(
                  context: context,
                  wasteList: wasteOutList
                      .where((t) => t.wasteType != WasteType.staff)
                      .toList(),
                ),

                // Staff Waste Tab
                buildWasteList(
                  context: context,
                  wasteList: wasteOutList
                      .where((t) => t.wasteType == WasteType.staff)
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Reusable waste list builder
  Widget buildWasteList({
    required BuildContext context,
    required List<StockTransactionModel> wasteList,
  }) {
    return Column(
      children: [
        const StockTransactionHeader(
          isWasteOut: true,
        ),
        Expanded(
          child: wasteList.isEmpty
              ? const Center(child: Text("no waste "))
              : ListView.separated(
                  itemCount: wasteList.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 0.7,
                    color: Pallete.greyColor,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: StockTransactionItem(
                        isWasteOut: true,
                        model: wasteList[index],
                        key: ValueKey(wasteList[index].id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
