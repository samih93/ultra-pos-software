import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/stock_transactions/components/loading_stock_transactions.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/stock_transactions/components/stock_in_tab.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/stock_transactions/components/waste_out_tab.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/stock_transactions/stock_transactions_state.dart';
import 'package:desktoppossystem/shared/default%20components/app_bar_title.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockTransactionsScreen extends ConsumerWidget {
  const StockTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureTransaction = ref.watch(stockTransactionsProvider);
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButtonWidget(
            icon: Icons.calendar_month,
            onPressed: () {
              showDatePicker(
                context: context,
                currentDate: DateTime.now(),
                initialDate: ref.watch(selectedstockTransactionDateProvider),
                firstDate: DateTime.now().subtract(
                  const Duration(days: 365 * 3),
                ),
                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
              ).then((value) {
                if (value != null) {
                  ref
                          .read(selectedstockTransactionDateProvider.notifier)
                          .state =
                      value;
                }
              });
            },
            text:
                "${ref.watch(selectedstockTransactionDateProvider).mMMddyyyyFormat()}",
          ),
          kGap10,
        ],
        title: AppBarTitle(
          title: "${S.of(context).stockIn} / ${S.of(context).waste}",
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              padding: const EdgeInsets.all(5),
              labelPadding: EdgeInsets.zero,
              labelColor: context.primaryColor,
              tabs: [
                Tab(
                  icon: const Icon(
                    Icons.arrow_downward_outlined,
                    color: Pallete.greenColor,
                  ),
                  child: DefaultTextView(text: S.of(context).stockIn),
                ),
                Tab(
                  icon: const Icon(Icons.arrow_upward, color: Pallete.redColor),
                  child: DefaultTextView(text: S.of(context).wasteOut),
                ),
              ],
            ),
            futureTransaction.when(
              data: (data) => const Expanded(
                child: TabBarView(children: [StockInTab(), WasteOutTab()]),
              ),
              error: (error, stackTrace) => ErrorSection(
                title: error.toString(),
                retry: () {
                  ref.refresh(stockTransactionsProvider);
                },
              ),
              loading: () => const LoadingStockTransactions(),
            ),
          ],
        ),
      ).baseContainer(context.cardColor),
    );
  }
}
